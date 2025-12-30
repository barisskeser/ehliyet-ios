import Foundation
import SwiftUI
internal import Combine

@MainActor
class QuizReviewViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = QuizReviewUiState()
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let databaseManager = DatabaseManager.shared
    private let fileName: String
    private let categoryKey: String?
    
    init(fileName: String, categoryKey: String? = nil) {
        self.fileName = fileName
        self.categoryKey = categoryKey
    }
    
    // MARK: - Data Loading
    func loadReviewQuestions() {
        uiState.isLoading = true
        
        print("📋 QuizReviewViewModel loadReviewQuestions - fileName: \(fileName), category: \(categoryKey ?? "all")")
        
        guard let testData = assetLoader.loadTest(fileName: fileName) else {
            print("❌ Test yüklenemedi: \(fileName)")
            uiState.isLoading = false
            return
        }
        
        guard let progress = databaseManager.getTestProgress(fileName: fileName) else {
            print("❌ Progress bulunamadı: \(fileName)")
            uiState.isLoading = false
            return
        }
        
        let answeredQuestions = progress.answeredQuestions
        
        var reviewItems: [ReviewQuestionItem] = []
        
        for (index, question) in testData.questions.enumerated() {
            // Sadece cevaplanmış soruları göster
            guard let userAnswer = answeredQuestions[index] else { continue }
            
            // Kategori filtresi
            if let category = categoryKey, question.categoryId != category {
                continue
            }
            
            let isCorrect = userAnswer.lowercased() == question.correctAnswer.lowercased()
            let isSaved = databaseManager.isSavedQuestion(fileName: fileName, questionIndex: index)
            
            let item = ReviewQuestionItem(
                id: "\(fileName)_\(index)",
                fileName: fileName,
                questionIndex: index,
                questionText: question.question,
                image: question.mainImage,
                isCorrect: isCorrect,
                isSaved: isSaved,
                selectedAnswer: userAnswer,
                categoryId: question.categoryId
            )
            
            reviewItems.append(item)
        }
        
        uiState.questions = reviewItems
        uiState.isLoading = false
        
        print("✅ Review loaded: \(reviewItems.count) questions")
    }
    
    // MARK: - Actions
    func onSaveClick(question: ReviewQuestionItem) {
        if question.isSaved {
            // Unsave
            databaseManager.deleteSavedQuestion(fileName: question.fileName, questionIndex: question.questionIndex)
        } else {
            // Save
            databaseManager.saveQuestion(
                fileName: question.fileName,
                questionIndex: question.questionIndex,
                questionText: question.questionText
            )
        }
        
        // Update UI
        if let index = uiState.questions.firstIndex(where: { $0.id == question.id }) {
            uiState.questions[index].isSaved.toggle()
        }
    }
}

// MARK: - UI State
struct QuizReviewUiState {
    var questions: [ReviewQuestionItem] = []
    var isLoading: Bool = false
}

// MARK: - Review Question Item
struct ReviewQuestionItem: Identifiable {
    let id: String
    let fileName: String
    let questionIndex: Int
    let questionText: String
    let image: String?
    let isCorrect: Bool
    var isSaved: Bool
    let selectedAnswer: String
    let categoryId: String?
}
