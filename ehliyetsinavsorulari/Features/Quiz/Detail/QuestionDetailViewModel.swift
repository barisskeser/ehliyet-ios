import Foundation
import SwiftUI
internal import Combine


@MainActor
class QuestionDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = QuestionDetailUiState()
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let databaseManager = DatabaseManager.shared
    
    private let fileName: String
    private let questionIndex: Int
    private let selectedAnswer: String?
    
    init(fileName: String, questionIndex: Int, selectedAnswer: String? = nil) {
        self.fileName = fileName
        self.questionIndex = questionIndex
        self.selectedAnswer = selectedAnswer
    }
    
    // MARK: - Data Loading
    func loadQuestion() {
        print("📋 QuestionDetailViewModel loadQuestion - fileName: \(fileName), index: \(questionIndex)")
        
        guard let testData = assetLoader.loadTest(fileName: fileName) else {
            print("❌ Test yüklenemedi: \(fileName)")
            return
        }
        
        guard questionIndex < testData.questions.count else {
            print("❌ Question index out of bounds: \(questionIndex)")
            return
        }
        
        let question = testData.questions[questionIndex]
        let isSaved = databaseManager.isSavedQuestion(fileName: fileName, questionIndex: questionIndex)
        
        // Get selected answer (from parameter or from progress)
        let userAnswer: String?
        if let passedAnswer = selectedAnswer, !passedAnswer.isEmpty {
            userAnswer = passedAnswer
        } else {
            let progress = databaseManager.getTestProgress(fileName: fileName)
            userAnswer = progress?.answeredQuestions[questionIndex]
        }
        
        let correctAnswer = question.correctAnswer.lowercased()
        
        // Create answer models with states
        let optionLetters = ["A", "B", "C", "D"]
        var answers: [DetailAnswerUiModel] = []
        
        for (optionIndex, option) in question.options.enumerated() {
            let choice = optionLetters[optionIndex]
            let isCorrect = choice.lowercased() == correctAnswer
            
            var state: DetailAnswerState = .unanswered
            if let userAnswer = userAnswer {
                if choice.lowercased() == correctAnswer {
                    state = .correct
                } else if choice.lowercased() == userAnswer.lowercased() {
                    state = .incorrect
                }
            }
            
            answers.append(DetailAnswerUiModel(
                choice: choice,
                text: option.text,
                image: option.image,
                isCorrect: isCorrect,
                state: state,
                explanation: isCorrect ? question.explanation : nil
            ))
        }
        
        // Calculate progress
        let totalQuestions = testData.questions.count
        let progress = Float(questionIndex + 1) / Float(totalQuestions)
        let progressLabel = "\(questionIndex + 1)/\(totalQuestions)"
        
        uiState = QuestionDetailUiState(
            questionText: question.question,
            questionImage: question.mainImage,
            answers: answers,
            isSaved: isSaved,
            progress: progress,
            progressLabel: progressLabel,
            fileName: fileName,
            questionIndex: questionIndex
        )
        
        print("✅ Question loaded: \(question.question.prefix(50))...")
    }
    
    // MARK: - Actions
    func onSaveClick() {
        if uiState.isSaved {
            // Unsave
            databaseManager.deleteSavedQuestion(fileName: fileName, questionIndex: questionIndex)
            uiState.isSaved = false
        } else {
            // Save
            databaseManager.saveQuestion(
                fileName: fileName,
                questionIndex: questionIndex,
                questionText: uiState.questionText
            )
            uiState.isSaved = true
        }
    }
}

// MARK: - UI State
struct QuestionDetailUiState {
    var questionText: String = ""
    var questionImage: String? = nil
    var answers: [DetailAnswerUiModel] = []
    var isSaved: Bool = false
    var progress: Float = 0
    var progressLabel: String = ""
    var fileName: String = ""
    var questionIndex: Int = 0
}

// MARK: - Answer UI Model
struct DetailAnswerUiModel: Identifiable {
    let id = UUID()
    let choice: String
    let text: String
    let image: String?
    let isCorrect: Bool
    let state: DetailAnswerState
    let explanation: String?
}

// MARK: - Answer State
enum DetailAnswerState {
    case unanswered
    case correct
    case incorrect
}
