import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var testProgress: [TestProgressEntity]
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Design System Test")
                .font(.headlineLarge)
                .foregroundColor(.textPrimary)
            
            Text("✅ Renkler, Fontlar, Spacing Hazır")
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
            
            Text("Kayıtlı test sayısı: \(testProgress.count)")
                .font(.headline)
            
            // Design System Color Test
            VStack(spacing: 8) {
                Text("Renkler:")
                    .font(.titleMedium)
                
                HStack(spacing: 4) {
                    ColorBox(color: .primary1, name: "Primary")
                    ColorBox(color: .correctColor, name: "Doğru")
                    ColorBox(color: .wrongColor, name: "Yanlış")
                    ColorBox(color: .emptyColor, name: "Boş")
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
            
            // Test Buttons
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    TestButton(title: "Test DB", color: .primary1) {
                        testDatabase()
                    }
                    
                    TestButton(title: "List DB", color: .successColor) {
                        listRecords()
                    }
                }
                
                HStack(spacing: 8) {
                    TestButton(title: "UserDefaults", color: .warningColor) {
                        testUserDefaults()
                    }
                    
                    TestButton(title: "Asset Loader", color: .accent) {
                        testAssetLoader()
                    }
                }
            }
            
            Text("Check Console for results")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    func testDatabase() {
        // Yeni test progress ekle
        let timestamp = Date().timeIntervalSince1970
        let newProgress = TestProgressEntity(fileName: "test-\(timestamp)", testId: "test-\(Int(timestamp))")
        modelContext.insert(newProgress)
        
        do {
            try modelContext.save()
            print("✅ Database'e kayıt eklendi")
        } catch {
            print("❌ Hata: \(error)")
        }
    }
    
    func listRecords() {
        print("📊 Toplam kayıt: \(testProgress.count)")
        for progress in testProgress {
            print("  - \(progress.fileName)")
        }
    }
    
    func testUserDefaults() {
        let manager = UserDefaultsManager.shared
        
        // Onboarding test
        manager.isOnboardingCompleted = true
        print("✅ Onboarding: \(manager.isOnboardingCompleted)")
        
        // Exam setup test
        var setup = ExamSetupData()
        setup.examDate = Date()
        setup.isReminderEnabled = true
        manager.examSetupData = setup
        
        if let savedSetup = manager.examSetupData {
            print("✅ Exam setup kaydedildi")
            print("  Tarih: \(savedSetup.examDate?.description ?? "yok")")
            print("  Hatırlatıcı: \(savedSetup.isReminderEnabled)")
        }
        
        // Premium test
        manager.isPremium = false
        print("✅ Premium: \(manager.isPremium)")
        
        // Reset test
        print("🔄 Reset yapılıyor...")
        manager.resetAll()
        print("✅ Reset tamamlandı")
        print("  Onboarding: \(manager.isOnboardingCompleted)")
    }
    
    func testAssetLoader() {
        print("\n🧪 ===== ASSET LOADER TEST =====\n")
        let loader = AssetLoader.shared
        
        // Test index yükle
        print("1️⃣ Test Index Yükleme:")
        let tests = loader.loadTestIndex()
        print("   Toplam test: \(tests.count)")
        if let first = tests.first {
            print("   İlk test: \(first.title)")
            print("   Dosya: \(first.fileName)")
            print("   Soru sayısı: \(first.totalQuestions)")
            print("   Premium: \(first.isPremium)")
        }
        
        // İlk test'i yükle (Yeni detaylı model)
        print("\n2️⃣ Test Data Yükleme:")
        if let fileName = tests.first?.fileName {
            if let testData = loader.loadTest(fileName: fileName) {
                print("✅ Test yüklendi: \(testData.title)")
                print("   Test ID: \(testData.testId)")
                print("   Soru sayısı: \(testData.questions.count)")
                
                if let firstQuestion = testData.questions.first {
                    print("\n3️⃣ İlk Soru Detayları:")
                    print("   Soru #: \(firstQuestion.questionNumber)")
                    print("   ID: \(firstQuestion.id)")
                    print("   Metin: \(firstQuestion.questionText)")
                    print("   Kategori: \(firstQuestion.category)")
                    print("   Tip: \(firstQuestion.type)")
                    print("   Ana görsel var mı: \(firstQuestion.hasImage ? "✅" : "❌")")
                    print("   Şık sayısı: \(firstQuestion.options.count)")
                    print("   Doğru cevap: \(firstQuestion.correctAnswer)")
                    print("   Açıklama: \(firstQuestion.explanation)")
                    
                    print("\n4️⃣ Şıklar:")
                    for option in firstQuestion.options {
                        let marker = option.key.lowercased() == firstQuestion.correctAnswer.lowercased() ? "✅" : "  "
                        print("   \(marker) \(option.key.uppercased()): \(option.text)")
                    }
                    
                    if let correctAns = firstQuestion.correctAnswerObject {
                        print("\n5️⃣ Doğru Cevap Detayı:")
                        print("   Şık: \(correctAns.key.uppercased())")
                        print("   Metin: \(correctAns.text)")
                    }
                }
            }
        }
        
        print("\n6️⃣ UserProgress Test:")
        var progress = TestProgress(testId: "test-1", fileName: "test-1.json")
        progress.answerQuestion(index: 0, answer: "A")
        progress.answerQuestion(index: 1, answer: "B")
        progress.complete(correctCount: 35, wrongCount: 15)
        print("   Test ID: \(progress.testId)")
        print("   Cevaplanan: \(progress.answeredCount)")
        print("   Skor: \(progress.score ?? 0)%")
        print("   Geçti mi: \(progress.isPassed ? "✅" : "❌")")
        
        print("\n7️⃣ ExamSetup Test:")
        var examSetup = ExamSetupData()
        examSetup.examDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
        print("   Kalan gün: \(examSetup.daysUntilExam ?? 0)")
        print("   Mesaj: \(examSetup.motivationalMessage)")
        
        print("\n✅ ===== TEST TAMAMLANDI =====\n")
    }
}

// MARK: - Helper Views
struct ColorBox: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(color)
                .frame(width: 60, height: 60)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            Text(name)
                .font(.labelSmall)
                .foregroundColor(.textSecondary)
        }
    }
}

struct TestButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.labelMedium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(CornerRadius.button)
        }
    }
}

#Preview {
    ContentView()
}
