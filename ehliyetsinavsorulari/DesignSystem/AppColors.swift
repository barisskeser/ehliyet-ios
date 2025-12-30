import SwiftUI

// MARK: - App Color Palette
extension Color {
    // MARK: - Primary Colors
    static let primary1 = Color(hex: "1E88E5")      // Ana mavi
    static let primary2 = Color(hex: "1976D2")      // Koyu mavi
    static let primary3 = Color(hex: "42A5F5")      // Açık mavi
    
    // MARK: - Accent Colors
    static let accent = Color(hex: "FF6B6B")        // Vurgu rengi (kırmızımsı)
    static let accentLight = Color(hex: "FF8A8A")   // Açık vurgu
    
    // MARK: - Success/Error Colors
    static let correctColor = Color(hex: "4CAF50")  // Doğru cevap (yeşil)
    static let wrongColor = Color(hex: "FF9800")    // Yanlış cevap (turuncu)
    static let emptyColor = Color(hex: "E0E0E0")    // Boş/cevapsız (gri)
    static let successColor = Color(hex: "4CAF50")  // Başarı
    static let errorColor = Color(hex: "F44336")    // Hata
    static let warningColor = Color(hex: "FFC107")  // Uyarı
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "212121")   // Ana metin
    static let textSecondary = Color(hex: "636E7D") // İkincil metin
    static let textTertiary = Color(hex: "9E9E9E")  // Üçüncül metin
    static let textDisabled = Color(hex: "BDBDBD")  // Devre dışı metin
    static let textOnPrimary = Color.white          // Primary üzerinde metin
    
    // MARK: - Background Colors
    static let appBackground = Color(hex: "F5F5F5") // Ana arka plan
    static let cardBackground = Color.white         // Kart arka planı
    static let surfaceBackground = Color(hex: "FAFAFA") // Yüzey arka planı
    
    // MARK: - Border/Divider Colors
    static let borderColor = Color(hex: "E0E0E0")   // Kenarlık
    static let dividerColor = Color(hex: "EEEEEE")  // Ayırıcı
    
    // MARK: - Premium/Special Colors
    static let premiumGold = Color(hex: "FFD700")   // Premium altın
    static let premiumGradientStart = Color(hex: "FFD700")
    static let premiumGradientEnd = Color(hex: "FFA500")
    
    // MARK: - Category Colors (Konu kategorileri için)
    static let trafficColor = Color(hex: "2196F3")      // Trafik - Mavi
    static let motorColor = Color(hex: "FF9800")        // Motor - Turuncu
    static let firstAidColor = Color(hex: "F44336")     // İlk Yardım - Kırmızı
    static let trafficEthicsColor = Color(hex: "4CAF50") // Trafik Adabı - Yeşil
    
    // MARK: - Chart Colors (Grafik renkleri)
    static let chartColor1 = Color(hex: "1E88E5")
    static let chartColor2 = Color(hex: "43A047")
    static let chartColor3 = Color(hex: "FB8C00")
    static let chartColor4 = Color(hex: "E53935")
    static let chartColor5 = Color(hex: "8E24AA")
}

// MARK: - Semantic Colors (Anlamsal renkler)
extension Color {
    /// Doğru cevap için kullanılır
    static var correct: Color { .correctColor }
    
    /// Yanlış cevap için kullanılır
    static var wrong: Color { .wrongColor }
    
    /// Boş/cevaplanmamış için kullanılır
    static var empty: Color { .emptyColor }
    
    /// Başarılı işlem için kullanılır
    static var success: Color { .successColor }
    
    /// Hata durumu için kullanılır
    static var error: Color { .errorColor }
    
    /// Uyarı için kullanılır
    static var warning: Color { .warningColor }
}
