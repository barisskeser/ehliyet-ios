import Foundation
import SwiftUI
internal import Combine

@MainActor
class QuizResultViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = QuizResultUiState()
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let databaseManager = DatabaseManager.shared
    private let fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
        loadResult()
    }
    
    // MARK: - Data Loading
    func loadResult() {
        print("📊 QuizResultViewModel loadResult - fileName: \(fileName)")
        
        guard let testData = assetLoader.loadTest(fileName: fileName) else {
            print("❌ Test yüklenemedi: \(fileName)")
            return
        }
        
        guard let progress = databaseManager.getTestProgress(fileName: fileName) else {
            print("❌ Progress bulunamadı: \(fileName)")
            return
        }
        
        let answeredQuestions = progress.answeredQuestions
        let totalCount = testData.questions.count
        
        // Calculate correct, wrong, empty counts
        var correctCount = 0
        var wrongCount = 0
        var emptyCount = 0
        
        // Topic-based statistics
        var topicStats: [String: (correct: Int, wrong: Int, total: Int)] = [:]
        
        for (index, question) in testData.questions.enumerated() {
            let category = question.categoryId ?? "other"
            
            if topicStats[category] == nil {
                topicStats[category] = (0, 0, 0)
            }
            topicStats[category]?.total += 1
            
            if let userAnswer = answeredQuestions[index] {
                let isCorrect = userAnswer.lowercased() == question.correctAnswer.lowercased()
                if isCorrect {
                    correctCount += 1
                    topicStats[category]?.correct += 1
                } else {
                    wrongCount += 1
                    topicStats[category]?.wrong += 1
                }
            } else {
                emptyCount += 1
            }
        }
        
        let percentage = totalCount > 0 ? Float(correctCount) / Float(totalCount) : 0
        
        // Create topic UI models
        let topics: [TopicUiModel] = topicStats.map { (categoryId, stats) in
            let topicPercentage = stats.total > 0 ? Float(stats.correct) / Float(stats.total) : 0
            return TopicUiModel(
                categoryId: categoryId,
                title: getCategoryName(categoryId),
                percentage: topicPercentage,
                correctCount: stats.correct,
                wrongCount: stats.wrong,
                iconName: getCategoryIcon(categoryId)
            )
        }.sorted { $0.title < $1.title }
        
        // Get motivation message based on percentage
        let (motivationMessage, motivationIcon) = getMotivationMessage(percentage: percentage)
        
        uiState = QuizResultUiState(
            testName: testData.title,
            fileName: fileName,
            correctCount: correctCount,
            wrongCount: wrongCount,
            emptyCount: emptyCount,
            percentage: percentage,
            topics: topics,
            motivationMessage: motivationMessage,
            motivationIcon: motivationIcon
        )
        
        print("✅ Result loaded: \(correctCount) correct, \(wrongCount) wrong, \(emptyCount) empty, \(Int(percentage * 100))%")
    }
    
    // MARK: - Actions
    func restartTest() {
        // Delete progress and restart
        databaseManager.deleteTestProgress(fileName: fileName)
        print("🔄 Test progress deleted for restart: \(fileName)")
    }
    
    // MARK: - Helper Functions
    private func getCategoryName(_ categoryId: String) -> String {
        switch categoryId {
        case "trafik":
            return "Trafik"
        case "motor":
            return "Motor"
        case "ilkyardim":
            return "İlk Yardım"
        case "trafikadabi":
            return "Trafik Adabı"
        default:
            return "Diğer"
        }
    }
    
    private func getCategoryIcon(_ categoryId: String) -> String {
        switch categoryId {
        case "trafik":
            return "car.fill"
        case "motor":
            return "engine.combustion.fill"
        case "ilkyardim":
            return "cross.case.fill"
        case "trafikadabi":
            return "hand.raised.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    private func getMotivationMessage(percentage: Float) -> (String, String) {
        switch percentage {
        case 0.80...:
            return ("Muhteşemsin! Bu başarı senin ne kadar çalışkan olduğunu gösteriyor. Gerçek sınavda da aynı performansı gösterebilirsin!", "character_result_success")
        case 0.70..<0.80:
            return ("Tebrikler, harika bir performans! Sınav geçme notunu yakaladın. Biraz daha pratik yaparak kendinle yarışmaya devam et!", "character_result_success")
        case 0.50..<0.70:
            return ("Aferin, başardın! Geçme notunun üzerindesin. Şimdi hedefin bu başarıyı daha da iyileştirmek olsun. Sen yaparsın!", "character_result_success")
        case 0.40..<0.50:
            return ("Çok yakındasın! Sadece birkaç soru daha doğru yapsan geçeceksin. Eksik olduğun konuları tekrar et, başarı kapıda!", "character_result_try")
        default:
            return ("Her başarı hikayesi bir yerden başlar! Bu deneme sana güçlü ve zayıf yönlerini gösterdi. Şimdi eksikleri tamamlama zamanı, sen yaparsın!", "character_result_try")
        }
    }
}

// MARK: - UI State
struct QuizResultUiState {
    var testName: String = ""
    var fileName: String = ""
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var emptyCount: Int = 0
    var percentage: Float = 0
    var topics: [TopicUiModel] = []
    var motivationMessage: String = ""
    var motivationIcon: String = ""
}

// MARK: - Topic UI Model
struct TopicUiModel: Identifiable {
    let id = UUID()
    let categoryId: String
    let title: String
    let percentage: Float
    let correctCount: Int
    let wrongCount: Int
    let iconName: String
}
