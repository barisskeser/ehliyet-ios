import UIKit
import CoreText

/// Font dosyalarını yükleyip isimlerini kontrol eden yardımcı sınıf
struct FontInstaller {
    
    /// Belirtilen font dosyasını yükler ve PostScript adını döndürür
    static func registerFont(fileName: String, fileExtension: String = "ttf") -> String? {
        guard let fontURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("❌ Font dosyası bulunamadı: \(fileName).\(fileExtension)")
            return nil
        }
        
        guard let fontData = try? Data(contentsOf: fontURL) as CFData,
              let provider = CGDataProvider(data: fontData),
              let font = CGFont(provider) else {
            print("❌ Font yüklenemedi: \(fileName).\(fileExtension)")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(font, &error) {
            if let postScriptName = font.postScriptName as String? {
                print("✅ Font yüklendi: \(postScriptName) <- \(fileName).\(fileExtension)")
                return postScriptName
            }
        } else {
            // Font zaten kayıtlı olabilir, bu sorun değil
            if let postScriptName = font.postScriptName as String? {
                print("ℹ️  Font zaten kayıtlı: \(postScriptName)")
                return postScriptName
            }
        }
        
        return nil
    }
    
    /// Tüm Urbanist fontlarını yükler
    static func registerUrbanistFonts() {
        print("\n=== Urbanist Fontları Yükleniyor ===")
        
        let fontFiles = [
            "urbanist",
            "urbanist_bold",
            "urbanist_semibold", 
            "urbanist_medium",
            "urbanist_light",
            "urbanist_extrabold",
            "urbanist_black"
        ]
        
        var registeredFonts: [String] = []
        
        for fileName in fontFiles {
            if let postScriptName = registerFont(fileName: fileName) {
                registeredFonts.append(postScriptName)
            }
        }
        
        print("\n=== Kayıtlı Font Sayısı: \(registeredFonts.count)/\(fontFiles.count) ===")
        print("\n=== SwiftUI'da Kullanım ===")
        print("Örnek: .font(.custom(\"FontPostScriptAdı\", size: 16))")
        print("\nKayıtlı fontlar:")
        for font in registeredFonts {
            print("  .font(.custom(\"\(font)\", size: 16))")
        }
        print("=====================================\n")
    }
}
