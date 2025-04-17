import SwiftUI

/// Structure de thème pour personnaliser l'apparence des vues FeaturesVote
public struct FeaturesTheme: Sendable {
    // MARK: - Typographie
    
    /// Poids de la police pour les titres
    public var titleFontWeight: Font.Weight
    
    /// Taille de la police pour les titres
    public var titleFontSize: CGFloat
    
    /// Nom de la police personnalisée pour les titres (optionnel)
    public var titleFontName: String?
    
    /// Poids de la police pour le corps du texte
    public var bodyFontWeight: Font.Weight
    
    /// Taille de la police pour le corps du texte
    public var bodyFontSize: CGFloat
    
    /// Nom de la police personnalisée pour le corps du texte (optionnel)
    public var bodyFontName: String?
    
    /// Poids de la police pour les étiquettes
    public var captionFontWeight: Font.Weight
    
    /// Taille de la police pour les étiquettes
    public var captionFontSize: CGFloat
    
    /// Nom de la police personnalisée pour les étiquettes (optionnel)
    public var captionFontName: String?
    
    // MARK: - Couleurs
    
    /// Couleur d'accentuation principale (pour les votes actifs, etc.)
    public var accentColor: Color
    
    /// Couleur du texte primaire
    public var primaryTextColor: Color
    
    /// Couleur du texte secondaire
    public var secondaryTextColor: Color
    
    /// Couleur d'arrière-plan principale
    public var backgroundColor: Color
    
    /// Couleur d'arrière-plan pour les cartes
    public var cardBackgroundColor: Color
    
    /// Couleur du bouton de vote (non voté)
    public var voteButtonColor: Color
    
    /// Initialisation du thème avec toutes les options de personnalisation
    /// Utilise des valeurs par défaut pour tous les paramètres
    public init(
        // Typographie
        titleFontWeight: Font.Weight = .bold,
        titleFontSize: CGFloat = 17,
        titleFontName: String? = nil,
        bodyFontWeight: Font.Weight = .regular,
        bodyFontSize: CGFloat = 15,
        bodyFontName: String? = nil,
        captionFontWeight: Font.Weight = .regular,
        captionFontSize: CGFloat = 13,
        captionFontName: String? = nil,
        // Couleurs
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
    
    // Helpers pour appliquer les polices
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

// MARK: - Environment Key et Extension

/// Clé d'environnement pour le thème FeaturesVote
private struct FeaturesThemeKey: EnvironmentKey {
    static let defaultValue = FeaturesTheme()
}

extension EnvironmentValues {
    /// Accès au thème FeaturesVote via l'environnement
    public var featuresTheme: FeaturesTheme {
        get { self[FeaturesThemeKey.self] }
        set { self[FeaturesThemeKey.self] = newValue }
    }
}

// MARK: - ViewModifier pour appliquer le thème

/// Modificateur pour appliquer un thème FeaturesVote à une vue
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

// MARK: - Extension View pour simplifier l'application du thème

extension View {
    /// Applique un thème complet aux vues FeaturesVote
    /// - Parameter theme: Le thème à appliquer
    /// - Returns: La vue avec le thème appliqué
    public func featuresTheme(_ theme: FeaturesTheme) -> some View {
        self.modifier(FeaturesThemeModifier(theme: theme))
    }
}
