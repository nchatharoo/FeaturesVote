//
//  Models.swift
//  FeaturesVote
//
//  Created by Nadheer on 16/04/2025.
//

import Foundation

public struct Features: Identifiable, Equatable, Codable, Sendable {
    public var id: String
    public var title: String
    public var description: String
    
    public init(id: String, title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

public enum VoteError: Error, LocalizedError {
    case featureNotFound
    case rateLimited
    case jsonConversionFailed
    case webhookFailed
    
    public var errorDescription: String? {
        switch self {
        case .featureNotFound:
            return "The requested feature was not found"
        case .rateLimited:
            return "Vote limit reached, please try again later"
        case .jsonConversionFailed:
            return "Error during data conversion"
        case .webhookFailed:
            return "Error sending data"
        }
    }
}

public struct VoteConfig {
    public let discordWebhookURL: String
    public let appIdentifier: String
    public let maxVotesPerDay: Int
    public let minTimeBetweenVotes: TimeInterval
    
    public init(
        discordWebhookURL: String,
        appIdentifier: String,
        maxVotesPerDay: Int = 10,
        minTimeBetweenVotes: TimeInterval = 30.0
    ) {
        self.discordWebhookURL = discordWebhookURL
        self.appIdentifier = appIdentifier
        self.maxVotesPerDay = maxVotesPerDay
        self.minTimeBetweenVotes = minTimeBetweenVotes
    }
}
