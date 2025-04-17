//
//  Services.swift
//  FeaturesVote
//
//  Created by Nadheer on 16/04/2025.
//

import Foundation
import Security
import SwiftUI

/// Protocole définissant un service de notification pour les votes
public protocol VoteNotificationService: Sendable {
    /// Méthode pour envoyer un vote à un service externe
    /// - Parameter feature: La fonctionnalité qui a reçu un vote
    func sendVote(feature: Features) async throws
}

/// Service de notification via Discord webhook
public actor DiscordVoteService: VoteNotificationService {
    private let webhookURL: String
    
    public init(webhookURL: String) {
        self.webhookURL = webhookURL
    }
    
    public func sendVote(feature: Features) async throws {
        // Message pour Discord
        let message: [String: Any] = [
            "username": "Feature Vote Bot",
            "embeds": [
                [
                    "title": "Nouveau vote!",
                    "color": 5814783, // Bleu
                    "fields": [
                        ["name": "Fonctionnalité", "value": feature.title, "inline": true],
                        ["name": "Description", "value": feature.description]
                    ]
                ]
            ]
        ]
        
        // Envoi au webhook
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message) else {
            throw VoteError.jsonConversionFailed
        }
        
        var request = URLRequest(url: URL(string: webhookURL)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 || (200...299).contains(httpResponse.statusCode) else {
            throw VoteError.webhookFailed
        }
    }
}

/// Service pour stocker les votes dans la Keychain
actor KeychainVoteStorage {
    private let appIdentifier: String
    private let maxVotesPerDay: Int
    private let minTimeBetweenVotes: TimeInterval
    
    // Clés pour la Keychain
    private var votedFeaturesKey: String { "\(appIdentifier).votedFeatures" }
    private var lastVoteTimeKey: String { "\(appIdentifier).lastVoteTime" }
    private var votesCountTodayKey: String { "\(appIdentifier).votesCountToday" }
    private var lastVoteDateKey: String { "\(appIdentifier).lastVoteDate" }
    
    init(
        appIdentifier: String,
        maxVotesPerDay: Int = 10,
        minTimeBetweenVotes: TimeInterval = 30.0
    ) {
        self.appIdentifier = appIdentifier
        self.maxVotesPerDay = maxVotesPerDay
        self.minTimeBetweenVotes = minTimeBetweenVotes
    }
    
    // MARK: - Keychain Helper Methods
    
    private func saveToKeychain(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func loadFromKeychain(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess ? result as? Data : nil
    }
    
    // MARK: - Data Storage
    
    private func saveStringArray(_ array: [String], forKey key: String) {
        if let data = try? JSONEncoder().encode(array) {
            _ = saveToKeychain(key: key, data: data)
        }
    }
    
    private func loadStringArray(forKey key: String) -> [String] {
        guard let data = loadFromKeychain(key: key),
              let array = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return array
    }
    
    private func saveDate(_ date: Date, forKey key: String) {
        if let data = try? JSONEncoder().encode(date) {
            _ = saveToKeychain(key: key, data: data)
        }
    }
    
    private func loadDate(forKey key: String) -> Date? {
        guard let data = loadFromKeychain(key: key),
              let date = try? JSONDecoder().decode(Date.self, from: data) else {
            return nil
        }
        return date
    }
    
    private func saveInteger(_ integer: Int, forKey key: String) {
        if let data = try? JSONEncoder().encode(integer) {
            _ = saveToKeychain(key: key, data: data)
        }
    }
    
    private func loadInteger(forKey key: String) -> Int {
        guard let data = loadFromKeychain(key: key),
              let integer = try? JSONDecoder().decode(Int.self, from: data) else {
            return 0
        }
        return integer
    }
    
    // MARK: - Vote Limitation Logic
    
    func canVoteForFeature(id: String) -> Bool {
        // 1. Vérifier si l'utilisateur a déjà voté pour cette fonctionnalité
        let votedFeatures = loadStringArray(forKey: votedFeaturesKey)
        if votedFeatures.contains(id) {
            return false
        }
        
        // 2. Vérifier la limite de temps entre votes
        if let lastVoteTime = loadDate(forKey: lastVoteTimeKey) {
            let timeSinceLastVote = Date().timeIntervalSince(lastVoteTime)
            if timeSinceLastVote < minTimeBetweenVotes {
                return false
            }
        }
        
        // 3. Vérifier la limite journalière
        let today = Calendar.current.startOfDay(for: Date())
        let lastVoteDate = loadDate(forKey: lastVoteDateKey) ?? Date(timeIntervalSince1970: 0)
        
        if Calendar.current.isDate(today, inSameDayAs: lastVoteDate) {
            let votesToday = loadInteger(forKey: votesCountTodayKey)
            if votesToday >= maxVotesPerDay {
                return false
            }
        } else {
            // Nouveau jour - réinitialiser le compteur
            saveInteger(0, forKey: votesCountTodayKey)
        }
        
        return true
    }
    
    func recordVote(forFeatureId id: String) {
        // Enregistrer la fonctionnalité votée
        var votedFeatures = loadStringArray(forKey: votedFeaturesKey)
        votedFeatures.append(id)
        saveStringArray(votedFeatures, forKey: votedFeaturesKey)
        
        // Enregistrer l'heure du vote
        saveDate(Date(), forKey: lastVoteTimeKey)
        
        // Mettre à jour le compteur journalier
        let today = Calendar.current.startOfDay(for: Date())
        let lastVoteDate = loadDate(forKey: lastVoteDateKey) ?? Date(timeIntervalSince1970: 0)
        
        if Calendar.current.isDate(today, inSameDayAs: lastVoteDate) {
            let votesToday = loadInteger(forKey: votesCountTodayKey)
            saveInteger(votesToday + 1, forKey: votesCountTodayKey)
        } else {
            saveInteger(1, forKey: votesCountTodayKey)
            saveDate(today, forKey: lastVoteDateKey)
        }
    }
    
    func getVotedFeatures() -> [String] {
        return loadStringArray(forKey: votedFeaturesKey)
    }
}

