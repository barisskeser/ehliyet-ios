import SwiftUI
import SwiftData

@main
struct EhliyetSinavSorulariApp: App {
    let modelContainer: ModelContainer
    
    init() {
        // Schema configuration with migration support
        let schema = Schema([
            TestProgressEntity.self,
            FlashcardLearningEntity.self,
            SavedQuestionEntity.self,
            MistakeQuestionEntity.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("✅ ModelContainer başlatıldı")
        } catch {
            print("⚠️ ModelContainer hatası, veritabanı sıfırlanıyor: \(error)")
            
            // Eski veritabanını sil ve yeniden dene
            Self.deleteExistingDatabase()
            
            do {
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                print("✅ ModelContainer yeniden başlatıldı")
            } catch {
                fatalError("ModelContainer başlatılamadı: \(error)")
            }
        }
        
        // Font kontrolü - Debug için
        #if DEBUG
        FontInstaller.registerUrbanistFonts()
        FontChecker.printAvailableFonts()
        FontChecker.checkUrbanistFonts()
        #endif
    }
    
    /// Eski SwiftData veritabanını siler (migration hatalarında kullanılır)
    private static func deleteExistingDatabase() {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        
        let storeURL = appSupportURL.appendingPathComponent("default.store")
        
        // SwiftData dosyalarını sil
        let extensions = ["", "-shm", "-wal"]
        for ext in extensions {
            let fileURL = URL(fileURLWithPath: storeURL.path + ext)
            try? fileManager.removeItem(at: fileURL)
        }
        
        print("🗑️ Eski veritabanı silindi")
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .task {
                    // MainActor context'inde DatabaseManager'ı ayarla
                    DatabaseManager.shared.setModelContext(modelContainer.mainContext)
                    print("✅ DatabaseManager context ayarlandı")
                }
        }
        .modelContainer(modelContainer)
    }
}
