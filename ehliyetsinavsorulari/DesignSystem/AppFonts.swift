import SwiftUI

// MARK: - Typography System (Material Design 3 inspired)
extension Font {
    // MARK: - Display (Büyük başlıklar)
    static let displayLarge = Font.custom("Urbanist-Bold", size: 57)
    static let displayMedium = Font.custom("Urbanist-Bold", size: 45)
    static let displaySmall = Font.custom("Urbanist-Bold", size: 36)
    
    // MARK: - Headline (Başlıklar)
    static let headlineLarge = Font.custom("Urbanist-SemiBold", size: 32)
    static let headlineMedium = Font.custom("Urbanist-SemiBold", size: 28)
    static let headlineSmall = Font.custom("Urbanist-SemiBold", size: 24)
    
    // MARK: - Title (Alt başlıklar)
    static let titleLarge = Font.custom("Urbanist-SemiBold", size: 22)
    static let titleMedium = Font.custom("Urbanist-Medium", size: 16)
    static let titleSmall = Font.custom("Urbanist-Medium", size: 14)
    
    // MARK: - Body (Gövde metinleri)
    static let bodyLarge = Font.custom("Urbanist-Regular", size: 16)
    static let bodyMedium = Font.custom("Urbanist-Regular", size: 14)
    static let bodySmall = Font.custom("Urbanist-Regular", size: 12)
    
    // MARK: - Label (Etiketler, butonlar)
    static let labelLarge = Font.custom("Urbanist-Medium", size: 14)
    static let labelMedium = Font.custom("Urbanist-Medium", size: 12)
    static let labelSmall = Font.custom("Urbanist-Medium", size: 11)
}

// MARK: - Font Weight Extension
extension Font {
    /// Custom font with weight
    static func urbanist(size: CGFloat, weight: FontWeight) -> Font {
        let fontName: String
        switch weight {
        case .regular:
            fontName = "Urbanist-Regular"
        case .medium:
            fontName = "Urbanist-Medium"
        case .semibold:
            fontName = "Urbanist-SemiBold"
        case .bold:
            fontName = "Urbanist-Bold"
        }
        return Font.custom(fontName, size: size)
    }
    
    enum FontWeight {
        case regular
        case medium
        case semibold
        case bold
    }
}

// MARK: - Fallback to System Fonts (Eğer Urbanist yüklü değilse)
extension Font {
    /// Safe font loading with system fallback
    static func safeCustom(_ name: String, size: CGFloat) -> Font {
        // Try custom font first, fallback to system
        return Font.custom(name, size: size)
    }
}

// MARK: - Common Text Styles (Hızlı kullanım için)
struct AppTextStyle {
    // Navigation Title
    static let navigationTitle = Font.headlineLarge
    
    // Section Headers
    static let sectionHeader = Font.headlineSmall
    
    // Card Titles
    static let cardTitle = Font.titleMedium
    
    // Button Text
    static let button = Font.labelLarge
    
    // Body Text
    static let body = Font.bodyMedium
    
    // Caption
    static let caption = Font.labelSmall
}
