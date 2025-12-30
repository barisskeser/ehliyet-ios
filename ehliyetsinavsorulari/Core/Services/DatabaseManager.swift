import Foundation
import SwiftData

/// SwiftData işlemlerini yöneten ana manager
/// Android'deki Room DAO'larının iOS karşılığı
@MainActor
class DatabaseManager {
    private var modelContext: ModelContext?
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    /// ModelContext'i set eder - App başlatıldığında çağrılmalı
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Test Progress Operations
    
    /// Tüm test ilerlemelerini getirir
    func getAllTestProgresses() -> [TestProgressEntity] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<TestProgressEntity>(
            sortBy: [SortDescriptor(\.lastAnsweredDate, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Test progresses fetch hatası: \(error)")
            return []
        }
    }
    
    /// Belirli bir testin ilerlemesini getirir
    func getTestProgress(fileName: String) -> TestProgressEntity? {
        guard let context = modelContext else { return nil }
        
        let descriptor = FetchDescriptor<TestProgressEntity>(
            predicate: #Predicate { $0.fileName == fileName }
        )
        
        do {
            return try context.fetch(descriptor).first
        } catch {
            print("❌ Test progress fetch hatası: \(error)")
            return nil
        }
    }
    
    /// Test ilerlemesi oluşturur veya günceller
    func upsertTestProgress(
        fileName: String,
        testId: String,
        totalQuestionCount: Int,
        answeredQuestionCount: Int,
        correctAnswerCount: Int,
        wrongAnswerCount: Int,
        lastQuestionIndex: Int,
        answeredQuestions: [Int: String],
        isCompleted: Bool,
        score: Int? = nil
    ) {
        guard let context = modelContext else { return }
        
        if let existing = getTestProgress(fileName: fileName) {
            existing.answeredQuestionCount = answeredQuestionCount
            existing.correctAnswerCount = correctAnswerCount
            existing.wrongAnswerCount = wrongAnswerCount
            existing.lastQuestionIndex = lastQuestionIndex
            existing.answeredQuestions = answeredQuestions
            existing.isCompleted = isCompleted
            existing.score = score
            existing.lastAnsweredDate = Date()
            if isCompleted {
                existing.completedDate = Date()
            }
        } else {
            let entity = TestProgressEntity(
                fileName: fileName,
                testId: testId,
                totalQuestionCount: totalQuestionCount
            )
            entity.answeredQuestionCount = answeredQuestionCount
            entity.correctAnswerCount = correctAnswerCount
            entity.wrongAnswerCount = wrongAnswerCount
            entity.lastQuestionIndex = lastQuestionIndex
            entity.answeredQuestions = answeredQuestions
            entity.isCompleted = isCompleted
            entity.score = score
            context.insert(entity)
        }
        
        saveContext()
    }
    
    /// Bir soruya cevap kaydeder
    func recordAnswer(
        fileName: String,
        testId: String,
        totalQuestionCount: Int,
        questionIndex: Int,
        answer: String,
        isCorrect: Bool
    ) {
        guard let context = modelContext else { return }
        
        let entity: TestProgressEntity
        if let existing = getTestProgress(fileName: fileName) {
            entity = existing
        } else {
            entity = TestProgressEntity(
                fileName: fileName,
                testId: testId,
                totalQuestionCount: totalQuestionCount
            )
            context.insert(entity)
        }
        
        // Cevapları güncelle
        var answers = entity.answeredQuestions
        let wasAnswered = answers[questionIndex] != nil
        answers[questionIndex] = answer
        entity.answeredQuestions = answers
        
        // Sayaçları güncelle (ilk cevap ise)
        if !wasAnswered {
            entity.answeredQuestionCount += 1
            if isCorrect {
                entity.correctAnswerCount += 1
            } else {
                entity.wrongAnswerCount += 1
            }
        }
        
        entity.lastAnsweredDate = Date()
        saveContext()
    }
    
    /// Testi tamamla
    func completeTest(fileName: String, correctCount: Int, wrongCount: Int) {
        guard let entity = getTestProgress(fileName: fileName) else { return }
        
        entity.isCompleted = true
        entity.correctAnswerCount = correctCount
        entity.wrongAnswerCount = wrongCount
        entity.completedDate = Date()
        
        let total = correctCount + wrongCount
        entity.score = total > 0 ? Int((Double(correctCount) / Double(total)) * 100) : 0
        
        saveContext()
    }
    
    // MARK: - Flashcard Operations
    
    /// Tüm flashcard'ları getirir
    func getAllFlashcards() -> [FlashcardLearningEntity] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<FlashcardLearningEntity>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Flashcards fetch hatası: \(error)")
            return []
        }
    }
    
    /// Öğrenilmiş flashcard sayısını döndürür
    func getLearnedFlashcardCount() -> Int {
        let flashcards = getAllFlashcards()
        return flashcards.filter { $0.status == "LEARNED" }.count
    }
    
    // MARK: - Saved Questions Operations
    
    /// Kaydedilmiş soru sayısını döndürür
    func getSavedQuestionCount() -> Int {
        guard let context = modelContext else { return 0 }
        
        let descriptor = FetchDescriptor<SavedQuestionEntity>()
        
        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("❌ Saved questions count hatası: \(error)")
            return 0
        }
    }
    
    /// Tüm kaydedilmiş soruları döndürür
    func getAllSavedQuestions() -> [SavedQuestionEntity] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<SavedQuestionEntity>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Saved questions fetch hatası: \(error)")
            return []
        }
    }
    
    /// Belirli bir sorunun kaydedilip kaydedilmediğini kontrol eder
    func isSavedQuestion(fileName: String, questionIndex: Int) -> Bool {
        guard let context = modelContext else { return false }
        
        let id = "\(fileName)_\(questionIndex)"
        let predicate = #Predicate<SavedQuestionEntity> { $0.id == id }
        var descriptor = FetchDescriptor<SavedQuestionEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let results = try context.fetch(descriptor)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    /// Soruyu kaydet
    func saveQuestion(fileName: String, questionIndex: Int, questionText: String) {
        guard let context = modelContext else { return }
        
        let id = "\(fileName)_\(questionIndex)"
        
        // Zaten varsa ekleme
        if isSavedQuestion(fileName: fileName, questionIndex: questionIndex) {
            return
        }
        
        let entity = SavedQuestionEntity(
            id: id,
            testFileName: fileName,
            questionIndex: questionIndex,
            questionText: questionText
        )
        context.insert(entity)
        saveContext()
    }
    
    /// Kaydedilmiş soruyu sil
    func deleteSavedQuestion(fileName: String, questionIndex: Int) {
        guard let context = modelContext else { return }
        
        let id = "\(fileName)_\(questionIndex)"
        let predicate = #Predicate<SavedQuestionEntity> { $0.id == id }
        let descriptor = FetchDescriptor<SavedQuestionEntity>(predicate: predicate)
        
        do {
            let results = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            saveContext()
        } catch {
            print("❌ Saved question delete hatası: \(error)")
        }
    }
    
    /// ID ile kaydedilmiş soruyu sil
    func deleteSavedQuestionById(id: String) {
        guard let context = modelContext else { return }
        
        let predicate = #Predicate<SavedQuestionEntity> { $0.id == id }
        let descriptor = FetchDescriptor<SavedQuestionEntity>(predicate: predicate)
        
        do {
            let results = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            saveContext()
        } catch {
            print("❌ Saved question delete hatası: \(error)")
        }
    }
    
    // MARK: - Mistake Questions Operations
    
    /// Yanlış soru sayısını döndürür
    func getMistakeQuestionCount() -> Int {
        guard let context = modelContext else { return 0 }
        
        let descriptor = FetchDescriptor<MistakeQuestionEntity>()
        
        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("❌ Mistake questions count hatası: \(error)")
            return 0
        }
    }
    
    /// Tüm yanlış soruları döndürür
    func getAllMistakeQuestions() -> [MistakeQuestionEntity] {
        guard let context = modelContext else { return [] }
        
        let descriptor = FetchDescriptor<MistakeQuestionEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Mistake questions fetch hatası: \(error)")
            return []
        }
    }
    
    /// Yanlış soru ekle
    func addMistakeQuestion(fileName: String, questionIndex: Int, questionText: String, userAnswer: String, correctAnswer: String) {
        guard let context = modelContext else { return }
        
        let id = "\(fileName)_\(questionIndex)"
        
        // Zaten varsa güncelle
        let predicate = #Predicate<MistakeQuestionEntity> { $0.id == id }
        var descriptor = FetchDescriptor<MistakeQuestionEntity>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let existing = try context.fetch(descriptor)
            if let entity = existing.first {
                entity.userAnswer = userAnswer
                entity.createdAt = Date()
            } else {
                let entity = MistakeQuestionEntity(
                    id: id,
                    testFileName: fileName,
                    questionIndex: questionIndex,
                    questionText: questionText,
                    userAnswer: userAnswer,
                    correctAnswer: correctAnswer
                )
                context.insert(entity)
            }
            saveContext()
        } catch {
            print("❌ Mistake question add hatası: \(error)")
        }
    }
    
    /// Yanlış soruyu sil (doğru cevaplandığında)
    func deleteMistakeQuestion(fileName: String, questionIndex: Int) {
        guard let context = modelContext else { return }
        
        let id = "\(fileName)_\(questionIndex)"
        let predicate = #Predicate<MistakeQuestionEntity> { $0.id == id }
        let descriptor = FetchDescriptor<MistakeQuestionEntity>(predicate: predicate)
        
        do {
            let results = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            saveContext()
        } catch {
            print("❌ Mistake question delete hatası: \(error)")
        }
    }
    
    /// Test ilerlemesini sil
    func deleteTestProgress(fileName: String) {
        guard let context = modelContext else { return }
        
        let predicate = #Predicate<TestProgressEntity> { $0.fileName == fileName }
        let descriptor = FetchDescriptor<TestProgressEntity>(predicate: predicate)
        
        do {
            let results = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            saveContext()
            print("✅ Test progress deleted: \(fileName)")
        } catch {
            print("❌ Test progress delete hatası: \(error)")
        }
    }
    
    /// Tüm verileri temizle
    func clearAllData() {
        guard let context = modelContext else { return }
        
        do {
            // Test Progress
            let progressDescriptor = FetchDescriptor<TestProgressEntity>()
            let progresses = try context.fetch(progressDescriptor)
            for entity in progresses {
                context.delete(entity)
            }
            
            // Saved Questions
            let savedDescriptor = FetchDescriptor<SavedQuestionEntity>()
            let savedQuestions = try context.fetch(savedDescriptor)
            for entity in savedQuestions {
                context.delete(entity)
            }
            
            // Mistake Questions
            let mistakeDescriptor = FetchDescriptor<MistakeQuestionEntity>()
            let mistakeQuestions = try context.fetch(mistakeDescriptor)
            for entity in mistakeQuestions {
                context.delete(entity)
            }
            
            // Flashcard Learning
            let flashcardDescriptor = FetchDescriptor<FlashcardLearningEntity>()
            let flashcards = try context.fetch(flashcardDescriptor)
            for entity in flashcards {
                context.delete(entity)
            }
            
            saveContext()
            print("✅ Tüm veriler temizlendi")
        } catch {
            print("❌ Clear all data hatası: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    /// Toplam çözülen soru sayısı
    func getTotalAnsweredQuestions() -> Int {
        let progresses = getAllTestProgresses()
        return progresses.reduce(0) { $0 + $1.answeredQuestionCount }
    }
    
    /// Toplam doğru cevap sayısı
    func getTotalCorrectAnswers() -> Int {
        let progresses = getAllTestProgresses()
        return progresses.reduce(0) { $0 + $1.correctAnswerCount }
    }
    
    /// Toplam yanlış cevap sayısı
    func getTotalWrongAnswers() -> Int {
        let progresses = getAllTestProgresses()
        return progresses.reduce(0) { $0 + $1.wrongAnswerCount }
    }
    
    /// Tamamlanan test sayısı
    func getCompletedTestCount() -> Int {
        let progresses = getAllTestProgresses()
        return progresses.filter { $0.isCompleted }.count
    }
    
    /// Geçilen test sayısı (70% ve üzeri)
    func getPassedTestCount() -> Int {
        let progresses = getAllTestProgresses()
        return progresses.filter { progress in
            guard progress.isCompleted else { return false }
            let total = progress.correctAnswerCount + progress.wrongAnswerCount
            guard total > 0 else { return false }
            let percentage = Double(progress.correctAnswerCount) / Double(total)
            return percentage >= 0.70
        }.count
    }
    
    // MARK: - Private Helpers
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ Context save hatası: \(error)")
        }
    }
}
