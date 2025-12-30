import Foundation
import SwiftUI
internal import Combine

@MainActor
class SavedQuestionsListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = SavedQuestionsListUiState()
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let databaseManager = DatabaseManager.shared
    
    // MARK: - Data Loading
    func loadSavedQuestions() {
        uiState.isLoading = true
        
        print("📋 SavedQuestionsListViewModel loadSavedQuestions")
        
        let savedEntities = databaseManager.getAllSavedQuestions()
        
        var items: [SavedQuestionItem] = []
        
        for entity in savedEntities {
            // Load test data to get question text and image
            guard let testData = assetLoader.loadTest(fileName: entity.testFileName) else {
                continue
            }
            
            guard entity.questionIndex < testData.questions.count else {
                continue
            }
            
            let question = testData.questions[entity.questionIndex]
            
            items.append(SavedQuestionItem(
                id: entity.id,
                fileName: entity.testFileName,
                questionIndex: entity.questionIndex,
                questionText: question.question,
                image: question.mainImage
            ))
        }
        
        uiState.questions = items
        uiState.isLoading = false
        
        print("✅ Saved questions loaded: \(items.count)")
    }
    
    // MARK: - Actions
    func getSelectedAnswer(for question: SavedQuestionItem) -> String? {
        // Get the user's answer from progress
        let progress = databaseManager.getTestProgress(fileName: question.fileName)
        return progress?.answeredQuestions[question.questionIndex]
    }
}

// MARK: - UI State
struct SavedQuestionsListUiState {
    var questions: [SavedQuestionItem] = []
    var isLoading: Bool = false
}

// MARK: - Saved Question Item
struct SavedQuestionItem: Identifiable {
    let id: String
    let fileName: String
    let questionIndex: Int
    let questionText: String
    let image: String?
}
