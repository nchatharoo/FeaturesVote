//
//  FeatureVoteViewModel.swift
//  FeaturesVote
//
//  Created by Nadheer on 16/04/2025.
//

import Foundation
import SwiftUI

@MainActor
@Observable public class FeatureVoteViewModel {
    nonisolated private let notificationService: VoteNotificationService
    private let storageService: KeychainVoteStorage
    private let jsonFilename: String
    
    public private(set) var features: [Features] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?
    
    public var userVotedStatus: [String: Bool] = [:]
    
    /// Initialization with a custom notification service
    public init(
        notificationService: VoteNotificationService,
        appIdentifier: String,
        jsonFilename: String,
        maxVotesPerDay: Int = 10,
        minTimeBetweenVotes: TimeInterval = 30.0
    ) {
        self.notificationService = notificationService
        self.storageService = KeychainVoteStorage(
            appIdentifier: appIdentifier,
            maxVotesPerDay: maxVotesPerDay,
            minTimeBetweenVotes: minTimeBetweenVotes
        )
        self.jsonFilename = jsonFilename
    }
    
    /// Initialization with a Discord service (for backward compatibility)
    public convenience init(config: VoteConfig, jsonFilename: String) {
        let service: VoteNotificationService
        
        service = DiscordVoteService(webhookURL: config.discordWebhookURL)
        
        
        self.init(
            notificationService: service,
            appIdentifier: config.appIdentifier,
            jsonFilename: jsonFilename,
            maxVotesPerDay: config.maxVotesPerDay,
            minTimeBetweenVotes: config.minTimeBetweenVotes
        )
    }
    
    public func loadFeaturesFromBundle() {
        isLoading = true
        errorMessage = nil
        guard let url = Bundle.main.url(forResource: jsonFilename,
                                        withExtension: "json") else {
            errorMessage = "JSON file not found: \(jsonFilename)"
            isLoading = false
            return
        }
        
        do {
            // Load data from file
            let jsonData = try Data(contentsOf: url)
            
            loadFeatures(from: jsonData)
        } catch {
            errorMessage = "File loading error: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    public func loadFeatures(from jsonData: Data) {
        isLoading = true
        errorMessage = nil
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Decode the data
            let loadedFeatures = try decoder.decode([Features].self, from: jsonData)
            
            Task {
                let votedFeatures = await storageService.getVotedFeatures()
                
                // Initialize the userVotedStatus dictionary
                var updatedVoteStatus = [String: Bool]()
                for feature in loadedFeatures {
                    updatedVoteStatus[feature.id] = votedFeatures.contains(feature.id)
                }
                
                self.userVotedStatus = updatedVoteStatus
                self.features = loadedFeatures
                self.isLoading = false
            }
        } catch {
            self.errorMessage = "Loading error: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    public func voteForFeature(id: String) async {
        guard features.contains(where: { $0.id == id }) else {
            errorMessage = "Feature not found"
            return
        }
        
        // Check if the user has already voted
        if userVotedStatus[id] == true {
            errorMessage = "You have already voted for this feature"
            return
        }
        
        do {
            // Check vote limitations
            guard await storageService.canVoteForFeature(id: id) else {
                throw VoteError.rateLimited
            }
            
            // Mark as voted locally
            userVotedStatus[id] = true
            
            // Record the vote
            await storageService.recordVote(forFeatureId: id)
            
            // Find the feature to send to the notification service
            if let feature = features.first(where: { $0.id == id }) {
                // Send the notification
                try await notificationService.sendVote(feature: feature)
            }
        } catch {
            if let voteError = error as? VoteError {
                errorMessage = voteError.errorDescription
            } else {
                errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    public func clearError() {
        errorMessage = nil
    }
}
