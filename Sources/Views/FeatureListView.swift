//
//  FeatureListView.swift
//  FeaturesVote
//
//  Created by Nadheer on 16/04/2025.
//

import SwiftUI

public struct FeatureListView: View {
    @Bindable var viewModel: FeatureVoteViewModel
    
    // Access the theme via the environment
    @Environment(\.featuresTheme) private var theme
    
    public init(viewModel: FeatureVoteViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .tint(theme.accentColor)
            } else {
                List {
                    ForEach(viewModel.features) { feature in
                        let userVotedBinding = Binding<Bool>(
                            get: { viewModel.userVotedStatus[feature.id] ?? false },
                            set: { _ in }
                        )
                        
                        FeatureRow(feature: feature, userVoted: userVotedBinding) {
                            Task {
                                await viewModel.voteForFeature(id: feature.id)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(theme.backgroundColor)
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
