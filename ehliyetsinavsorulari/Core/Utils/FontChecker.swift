import SwiftUI
import UIKit

/// Font isimlerini kontrol etmek için yardımcı sınıf
/// Uygulamayı çalıştırdığınızda console'da tüm yüklü font isimlerini gösterir
struct FontChecker {
    static func printAvailableFonts() {
        print("=== Yüklü Font Aileleri ===")
        for family in UIFont.familyNames.sorted() {
            print("Font Ailesi: \(family)")
            let names = UIFont.fontNames(forFamilyName: family)
            for name in names {
                print("  - \(name)")
            }
        }
        print("=== Font Listesi Sonu ===")
    }
    
    static func checkUrbanistFonts() {
        print("=== Urbanist Font Kontrolü ===")
        let urbanistVariants = [
            "Urbanist-Regular",
            "Urbanist-Bold",
            "Urbanist-SemiBold",
            "Urbanist-Medium",
            "Urbanist-Light",
            "Urbanist-ExtraBold",
            "Urbanist-Black"
        ]
        
        for variant in urbanistVariants {
            if let font = UIFont(name: variant, size: 12) {
                print("✅ \(variant) - BULUNDU")
            } else {
                print("❌ \(variant) - BULUNAMADI")
            }
        }
        print("=== Urbanist Kontrol Sonu ===")
    }
}
