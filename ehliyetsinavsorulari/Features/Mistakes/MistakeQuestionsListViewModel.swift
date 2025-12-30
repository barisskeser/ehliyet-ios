import Foundation
import SwiftUI
internal import Combine

@MainActor
class MistakeQuestionsListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = MistakeQuestionsListUiState()
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let databaseManager = DatabaseManager.shared
    
    // MARK: - Data Loading
    func loadMistakeQuestions() {
        uiState.isLoading = true
        
        print("📋 MistakeQuestionsListViewModel loadMistakeQuestions")
        
        let mistakeEntities = databaseManager.getAllMistakeQuestions()
        
        var items: [MistakeQuestionItem] = []
        
        for entity in mistakeEntities {
            // Load test data to get question image
            guard let testData = assetLoader.loadTest(fileName: entity.testFileName) else {
                continue
            }
            
            guard entity.questionIndex < testData.questions.count else {
                continue
            }
            
            let question = testData.questions[entity.questionIndex]
            
            items.append(MistakeQuestionItem(
                id: entity.id,
                fileName: entity.testFileName,
                questionIndex: entity.questionIndex,
                questionText: entity.questionText,
                image: question.mainImage,
                userAnswer: entity.userAnswer
            ))
        }
        
        uiState.questions = items
        uiState.isLoading = false
        
        print("✅ Mistake questions loaded: \(items.count)")
    }
}

// MARK: - UI State
struct MistakeQuestionsListUiState {
    var questions: [MistakeQuestionItem] = []
    var isLoading: Bool = false
}

// MARK: - Mistake Question Item
struct MistakeQuestionItem: Identifiable {
    let id: String
    let fileName: String
    let questionIndex: Int
    let questionText: String
    let image: String?
    let userAnswer: String
}
