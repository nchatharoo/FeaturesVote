//
//  FeatureRow.swift
//  FeaturesVote
//
//  Created by Nadheer on 16/04/2025.
//

import SwiftUI

/// View to display a feature row
public struct FeatureRow: View {
    let feature: Features
    let onVote: () -> Void
    @Binding var userVoted: Bool
    
    // Access the theme via the environment
    @Environment(\.featuresTheme) private var theme
    
    public init(feature: Features, userVoted: Binding<Bool>, onVote: @escaping () -> Void) {
        self.feature = feature
        self._userVoted = userVoted
        self.onVote = onVote
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Vote button on the left
            VStack {
                Button(action: onVote) {
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(userVoted ? theme.primaryTextColor : theme.accentColor )
                        
                            theme.applyTitleFont(to:                  Text(userVoted ? "1" : "0"))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(userVoted ? theme.primaryTextColor : theme.accentColor )
                    }
                    .padding(8)
                    .frame(width: 50, height: 50)
                    .background(theme.voteButtonColor)
                    .cornerRadius(8)
                }
            }
            .padding(.trailing, 4)
            
            // Feature content
            VStack(alignment: .leading, spacing: 6) {
                theme.applyTitleFont(to: Text(feature.title))
                    .foregroundStyle(theme.primaryTextColor)
                    .lineLimit(1)
                
                theme.applyBodyFont(to: Text(feature.description))
                    .foregroundStyle(theme.secondaryTextColor)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 8)
    }
}
