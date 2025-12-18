import Foundation

/// Sınav geçme olasılığını hesaplayan manager
/// Android'deki ExamPredictionManager'ın iOS karşılığı
///
/// Türkiye Ehliyet Sınavı Kriterleri:
/// - Trafik: 70 soru, minimum %70 başarı
/// - Motor: 30 soru, minimum %70 başarı
/// - İlkyardım: 12 soru, minimum %83.33 başarı
/// - Toplam: 112 soru, genel minimum 70 puan
@MainActor
class ExamPredictionManager {
    static let shared = ExamPredictionManager()
    
    private let databaseManager = DatabaseManager.shared
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Sınav geçme olasılığını hesaplar
    func calculatePassProbability() -> ExamPredictionResult {
        let testProgresses = databaseManager.getAllTestProgresses()
        let flashcards = databaseManager.getAllFlashcards()
        
        let totalAnswered = testProgresses.reduce(0) { $0 + $1.answeredQuestionCount }
        let totalCorrect = testProgresses.reduce(0) { $0 + $1.correctAnswerCount }
        let totalWrong = testProgresses.reduce(0) { $0 + $1.wrongAnswerCount }
        
        // Hiç veri yoksa
        if totalAnswered == 0 {
            return createLowDataPrediction()
        }
        
        // Temel başarı oranı
        let overallAccuracy = Double(totalCorrect) / Double(totalAnswered) * 100
        
        // Son performans (son 50 soru veya mevcut)
        let recentProgresses = Array(testProgresses.prefix(5)) // Son 5 test
        let recentTotal = recentProgresses.reduce(0) { $0 + $1.answeredQuestionCount }
        let recentCorrect = recentProgresses.reduce(0) { $0 + $1.correctAnswerCount }
        let recentAccuracy = recentTotal > 0 ? Double(recentCorrect) / Double(recentTotal) * 100 : overallAccuracy
        
        // Deneme sınavı performansı
        let completedTests = testProgresses.filter { $0.isCompleted }
        let passedTests = completedTests.filter { progress in
            let total = progress.correctAnswerCount + progress.wrongAnswerCount
            guard total > 0 else { return false }
            return Double(progress.correctAnswerCount) / Double(total) >= 0.70
        }
        
        let examScore: Double
        if !completedTests.isEmpty {
            examScore = Double(passedTests.count) / Double(completedTests.count) * 100
        } else {
            examScore = recentAccuracy * 0.9
        }
        
        // Flashcard ilerlemesi
        let learnedFlashcards = flashcards.filter { $0.status == "LEARNED" }.count
        let flashcardProgress = Double(learnedFlashcards) / 8.0 * 100 // 8 kategori
        
        // Dinamik ağırlıklandırma
        let hasLimitedQuestions = totalAnswered < 50
        let questionWeight = hasLimitedQuestions ? 0.40 : 0.50
        let recentWeight = hasLimitedQuestions ? 0.20 : 0.25
        let examWeight = hasLimitedQuestions ? 0.20 : 0.20
        let flashcardWeight = hasLimitedQuestions ? 0.20 : 0.05
        
        // Ağırlıklı toplam
        var weightedScore = overallAccuracy * questionWeight +
                           recentAccuracy * recentWeight +
                           examScore * examWeight +
                           flashcardProgress * flashcardWeight
        
        // İyileşme bonusu
        if recentAccuracy > overallAccuracy {
            let improvement = recentAccuracy - overallAccuracy
            if improvement > 10 {
                weightedScore += 3
            } else if improvement > 5 {
                weightedScore += 1
            }
        }
        
        // Final skor (0-100 arası)
        let finalScore = min(max(Int(weightedScore), 0), 100)
        
        // Güvenilirlik seviyesi
        let confidence = determineConfidence(
            totalAnswered: totalAnswered,
            completedTests: completedTests.count
        )
        
        return ExamPredictionResult(
            passPercentage: finalScore,
            confidence: confidence,
            totalQuestionsSolved: totalAnswered,
            totalCorrect: totalCorrect,
            totalWrong: totalWrong,
            completedExams: completedTests.count,
            passedExams: passedTests.count,
            overallAccuracy: overallAccuracy,
            recentAccuracy: recentAccuracy
        )
    }
    
    // MARK: - Private Methods
    
    private func createLowDataPrediction() -> ExamPredictionResult {
        return ExamPredictionResult(
            passPercentage: 0,
            confidence: .low,
            totalQuestionsSolved: 0,
            totalCorrect: 0,
            totalWrong: 0,
            completedExams: 0,
            passedExams: 0,
            overallAccuracy: 0,
            recentAccuracy: 0
        )
    }
    
    private func determineConfidence(totalAnswered: Int, completedTests: Int) -> PredictionConfidence {
        if totalAnswered >= 300 && completedTests >= 5 {
            return .veryHigh
        } else if totalAnswered >= 150 && completedTests >= 3 {
            return .high
        } else if totalAnswered >= 50 {
            return .medium
        } else {
            return .low
        }
    }
}

// MARK: - Result Models

struct ExamPredictionResult {
    let passPercentage: Int
    let confidence: PredictionConfidence
    let totalQuestionsSolved: Int
    let totalCorrect: Int
    let totalWrong: Int
    let completedExams: Int
    let passedExams: Int
    let overallAccuracy: Double
    let recentAccuracy: Double
}

enum PredictionConfidence {
    case low
    case medium
    case high
    case veryHigh
    
    var description: String {
        switch self {
        case .low: return "Düşük"
        case .medium: return "Orta"
        case .high: return "Yüksek"
        case .veryHigh: return "Çok Yüksek"
        }
    }
}
