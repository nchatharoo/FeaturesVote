import SwiftUI

/// Theme structure to customize the appearance of FeaturesVote views
public struct FeaturesTheme: Sendable {
    // MARK: - Typography
    
    /// Font weight for titles
    public var titleFontWeight: Font.Weight
    
    /// Font size for titles
    public var titleFontSize: CGFloat
    
    /// Custom font name for titles (optional)
    public var titleFontName: String?
    
    /// Font weight for body text
    public var bodyFontWeight: Font.Weight
    
    /// Font size for body text
    public var bodyFontSize: CGFloat
    
    /// Custom font name for body text (optional)
    public var bodyFontName: String?
    
    /// Font weight for captions
    public var captionFontWeight: Font.Weight
    
    /// Font size for captions
    public var captionFontSize: CGFloat
    
    /// Custom font name for captions (optional)
    public var captionFontName: String?
    
    // MARK: - Couleurs
    
    /// Main accent color (for active votes, etc.)
    public var accentColor: Color
    
    /// Primary text color
    public var primaryTextColor: Color
    
    /// Secondary text color
    public var secondaryTextColor: Color
    
    /// Main background color
    public var backgroundColor: Color
    
    /// Background color for cards
    public var cardBackgroundColor: Color
    
    /// Vote button color (not voted)
    public var voteButtonColor: Color
    
    /// Initialize the theme with all customization options
    /// Uses default values for all parameters
    public init(
        // Typography
        titleFontWeight: Font.Weight = .bold,
        titleFontSize: CGFloat = 17,
        titleFontName: String? = nil,
        bodyFontWeight: Font.Weight = .regular,
        bodyFontSize: CGFloat = 15,
        bodyFontName: String? = nil,
        captionFontWeight: Font.Weight = .regular,
        captionFontSize: CGFloat = 13,
        captionFontName: String? = nil,
        // Colors
        accentColor: Color = .blue,
        primaryTextColor: Color = .primary,
        secondaryTextColor: Color = .secondary,
        backgroundColor: Color = Color(.systemBackground),
        cardBackgroundColor: Color = Color(.secondarySystemBackground),
        voteButtonColor: Color = Color(.systemGray6)
    ) {
        // Typographie
        self.titleFontWeight = titleFontWeight
        self.titleFontSize = titleFontSize
        self.titleFontName = titleFontName
        self.bodyFontWeight = bodyFontWeight
        self.bodyFontSize = bodyFontSize
        self.bodyFontName = bodyFontName
        self.captionFontWeight = captionFontWeight
        self.captionFontSize = captionFontSize
        self.captionFontName = captionFontName
        // Couleurs
        self.accentColor = accentColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.backgroundColor = backgroundColor
        self.cardBackgroundColor = cardBackgroundColor
        self.voteButtonColor = voteButtonColor
    }
    
    // Helpers to apply fonts
    public func applyTitleFont(to text: Text) -> Text {
        if let customFont = titleFontName {
            return text.font(.custom(customFont, size: titleFontSize, relativeTo: .headline))
        }
        return text.font(.system(size: titleFontSize, weight: titleFontWeight))
    }
    
    public func applyBodyFont(to text: Text) -> Text {
        if let customFont = bodyFontName {
            return text.font(.custom(customFont, size: bodyFontSize, relativeTo: .body))
        }
        return text.font(.system(size: bodyFontSize, weight: bodyFontWeight))
    }
    
    public func applyCaptionFont(to text: Text) -> Text {
        if let customFont = captionFontName {
            return text.font(.custom(customFont, size: captionFontSize, relativeTo: .caption))
        }
        return text.font(.system(size: captionFontSize, weight: captionFontWeight))
    }
}


/// Environment key for the FeaturesVote theme
private struct FeaturesThemeKey: EnvironmentKey {
    static let defaultValue = FeaturesTheme()
}

extension EnvironmentValues {
    /// Access to the FeaturesVote theme via the environment
    public var featuresTheme: FeaturesTheme {
        get { self[FeaturesThemeKey.self] }
        set { self[FeaturesThemeKey.self] = newValue }
    }
}

/// Modifier to apply a FeaturesVote theme to a view
public struct FeaturesThemeModifier: ViewModifier {
    let theme: FeaturesTheme
    
    public init(theme: FeaturesTheme) {
        self.theme = theme
    }
    
    public func body(content: Content) -> some View {
        content
            .environment(\.featuresTheme, theme)
    }
}

extension View {
    /// Applies a complete theme to FeaturesVote views
    /// - Parameter theme: The theme to apply
    /// - Returns: The view with the theme applied
    public func featuresTheme(_ theme: FeaturesTheme) -> some View {
        self.modifier(FeaturesThemeModifier(theme: theme))
    }
}
