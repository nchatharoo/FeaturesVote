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
    
    /// Initialisation avec un service de notification personnalisé
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
    
    /// Initialisation avec un service Discord (pour rétrocompatibilité)
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
            errorMessage = "Fichier JSON non trouvé: \(jsonFilename)"
            isLoading = false
            return
        }
        
        do {
            // Charger les données du fichier
            let jsonData = try Data(contentsOf: url)
            
            loadFeatures(from: jsonData)
        } catch {
            errorMessage = "Erreur de chargement du fichier: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    public func loadFeatures(from jsonData: Data) {
        isLoading = true
        errorMessage = nil
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Décoder les données
            let loadedFeatures = try decoder.decode([Features].self, from: jsonData)
            
            Task {
                let votedFeatures = await storageService.getVotedFeatures()
                
                // Initialiser le dictionnaire userVotedStatus
                var updatedVoteStatus = [String: Bool]()
                for feature in loadedFeatures {
                    updatedVoteStatus[feature.id] = votedFeatures.contains(feature.id)
                }
                
                self.userVotedStatus = updatedVoteStatus
                self.features = loadedFeatures
                self.isLoading = false
            }
        } catch {
            self.errorMessage = "Erreur de chargement: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    public func voteForFeature(id: String) async {
        guard features.contains(where: { $0.id == id }) else {
            errorMessage = "Fonctionnalité non trouvée"
            return
        }
        
        // Vérifier si l'utilisateur a déjà voté
        if userVotedStatus[id] == true {
            errorMessage = "Vous avez déjà voté pour cette fonctionnalité"
            return
        }
        
        do {
            // Vérifier la limitation des votes
            guard await storageService.canVoteForFeature(id: id) else {
                throw VoteError.rateLimited
            }
            
            // Marquer comme voté localement
            userVotedStatus[id] = true
            
            // Enregistrer le vote
            await storageService.recordVote(forFeatureId: id)
            
            // Trouver la fonctionnalité pour l'envoyer au service de notification
            if let feature = features.first(where: { $0.id == id }) {
                // Envoyer la notification
                try await notificationService.sendVote(feature: feature)
            }
        } catch {
            if let voteError = error as? VoteError {
                errorMessage = voteError.errorDescription
            } else {
                errorMessage = "Erreur: \(error.localizedDescription)"
            }
        }
    }
    
    public func clearError() {
        errorMessage = nil
    }
}
