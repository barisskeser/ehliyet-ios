import Foundation
import SwiftUI
internal import Combine

// MARK: - Answer State
enum AnswerState {
    case unanswered
    case selected
    case correct
    case incorrect
}

// MARK: - Button State
enum QuizButtonState {
    case next
    case finish
    
    var text: String {
        switch self {
        case .next: return "Devam"
        case .finish: return "Tamamla"
        }
    }
}

// MARK: - Answer UI Model
struct AnswerUiModel: Identifiable {
    let id: String
    let questionId: String
    let choice: String  // A, B, C, D
    let text: String
    let image: String?
    let isCorrect: Bool
    let explanation: String?
    var state: AnswerState
    var isClickable: Bool
    
    init(
        id: String = UUID().uuidString,
        questionId: String,
        choice: String,
        text: String,
        image: String? = nil,
        isCorrect: Bool,
        explanation: String? = nil,
        state: AnswerState = .unanswered,
        isClickable: Bool = true
    ) {
        self.id = id
        self.questionId = questionId
        self.choice = choice
        self.text = text
        self.image = image
        self.isCorrect = isCorrect
        self.explanation = explanation
        self.state = state
        self.isClickable = isClickable
    }
}

// MARK: - Question UI Model
struct QuestionUiModel: Identifiable {
    let id: String
    let questionNumber: Int
    let questionText: String
    let image: String?
    let type: String?
    let videoName: String?
    var answers: [AnswerUiModel]
    let correctAnswer: String
    let categoryId: String?
    var selectedOption: String?
    var isSaved: Bool
    
    var isCorrectSelected: Bool {
        guard let selected = selectedOption else { return false }
        return answers.first { $0.choice.lowercased() == selected.lowercased() }?.isCorrect ?? false
    }
    
    var isAnswerSelected: Bool {
        selectedOption != nil
    }
    
    var isAnswerChecked: Bool {
        selectedOption != nil && answers.contains { $0.state == .correct || $0.state == .incorrect }
    }
    
    init(
        id: String,
        questionNumber: Int,
        questionText: String,
        image: String? = nil,
        type: String? = nil,
        videoName: String? = nil,
        answers: [AnswerUiModel],
        correctAnswer: String,
        categoryId: String? = nil,
        selectedOption: String? = nil,
        isSaved: Bool = false
    ) {
        self.id = id
        self.questionNumber = questionNumber
        self.questionText = questionText
        self.image = image
        self.type = type
        self.videoName = videoName
        self.answers = answers
        self.correctAnswer = correctAnswer
        self.categoryId = categoryId
        self.selectedOption = selectedOption
        self.isSaved = isSaved
    }
}

// MARK: - Quiz UI State
struct QuizUiState {
    var id: String?
    var fileName: String?
    var questions: [QuestionUiModel] = []
    var currentQuestion: QuestionUiModel?
    var currentQuestionIndex: Int = 0
    var showExitConfirmationSheet: Bool = false
    var isPremium: Bool = false
    var isLoading: Bool = false
    var shouldNavigateToResult: Bool = false
    var shouldNavigateBack: Bool = false
    
    var buttonState: QuizButtonState {
        if currentQuestionIndex == questions.count - 1 {
            return .finish
        } else {
            return .next
        }
    }
    
    var progressLabel: String {
        "\(currentQuestionIndex + 1)/\(questions.count)"
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
}

// MARK: - Quiz ViewModel
@MainActor
class QuizViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = QuizUiState()
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let databaseManager = DatabaseManager.shared
    private let userDefaultsManager = UserDefaultsManager.shared
    
    private let testUiModel: TestUiModel
    
    init(testUiModel: TestUiModel) {
        self.testUiModel = testUiModel
        uiState.isPremium = userDefaultsManager.isPremium
        uiState.fileName = testUiModel.fileName
        uiState.id = testUiModel.id
    }
    
    // MARK: - Load Quiz
    func loadQuiz() {
        uiState.isLoading = true
        
        print("🔍 QuizViewModel loadQuiz - fileName: \(testUiModel.fileName)")
        
        guard let testData = assetLoader.loadTest(fileName: testUiModel.fileName) else {
            print("❌ Test yüklenemedi: \(testUiModel.fileName)")
            uiState.isLoading = false
            return
        }
        
        print("✅ Test yüklendi: \(testData.title), \(testData.questions.count) soru")
        
        // Get saved progress
        let progress = databaseManager.getTestProgress(fileName: testUiModel.fileName)
        let answeredQuestions = progress?.answeredQuestions ?? [:]
        // Use saved lastQuestionIndex directly (like Android)
        let lastQuestionIndex = progress?.lastQuestionIndex ?? 0
        
        // Convert to QuestionUiModel
        var questionModels: [QuestionUiModel] = []
        
        for (index, question) in testData.questions.enumerated() {
            let questionId = "\(testUiModel.fileName)_q\(index)"
            
            // Create answers
            var answers: [AnswerUiModel] = []
            let optionLetters = ["A", "B", "C", "D"]
            
            for (optionIndex, option) in question.options.enumerated() {
                let choice = optionLetters[optionIndex]
                let isCorrect = choice.lowercased() == question.correctAnswer.lowercased()
                
                // Check if this was the user's answer
                let userAnswer = answeredQuestions[index]
                var state: AnswerState = .unanswered
                var isClickable = true
                
                if let userAnswer = userAnswer {
                    isClickable = false
                    if choice.lowercased() == userAnswer.lowercased() {
                        state = isCorrect ? .correct : .incorrect
                    } else if isCorrect {
                        state = .correct
                    }
                }
                
                answers.append(AnswerUiModel(
                    questionId: questionId,
                    choice: choice,
                    text: option.text,
                    image: option.image,
                    isCorrect: isCorrect,
                    explanation: isCorrect ? question.explanation : nil,
                    state: state,
                    isClickable: isClickable
                ))
            }
            
            // Check if question is saved
            let isSaved = databaseManager.isSavedQuestion(fileName: testUiModel.fileName, questionIndex: index)
            
            let questionModel = QuestionUiModel(
                id: questionId,
                questionNumber: index + 1,
                questionText: question.question,
                image: question.mainImage,
                type: question.type,
                videoName: question.videoName,
                answers: answers,
                correctAnswer: question.correctAnswer,
                categoryId: question.categoryId,
                selectedOption: answeredQuestions[index],
                isSaved: isSaved
            )
            
            questionModels.append(questionModel)
        }
        
        uiState.questions = questionModels
        uiState.currentQuestionIndex = min(lastQuestionIndex, questionModels.count - 1)
        uiState.currentQuestion = questionModels[uiState.currentQuestionIndex]
        uiState.isLoading = false
        
        print("📊 Quiz loaded: \(questionModels.count) questions, starting at index \(uiState.currentQuestionIndex)")
    }
    
    // MARK: - Actions
    
    func onCloseClick() {
        if uiState.currentQuestionIndex > 0 {
            uiState.showExitConfirmationSheet = true
        } else {
            uiState.shouldNavigateBack = true
        }
    }
    
    func onDismissExitSheet() {
        uiState.showExitConfirmationSheet = false
    }
    
    func onExitConfirmed() {
        uiState.showExitConfirmationSheet = false
        uiState.shouldNavigateBack = true
    }
    
    func onSaveClick() {
        guard var currentQuestion = uiState.currentQuestion else { return }
        
        currentQuestion.isSaved.toggle()
        uiState.currentQuestion = currentQuestion
        
        // Update in questions array
        if let index = uiState.questions.firstIndex(where: { $0.id == currentQuestion.id }) {
            uiState.questions[index].isSaved = currentQuestion.isSaved
        }
        
        // TODO: Save to database
    }
    
    func onAnswerSelected(_ answer: AnswerUiModel) {
        guard var currentQuestion = uiState.currentQuestion,
              !currentQuestion.isAnswerChecked else { return }
        
        // Unselect all options first
        for i in 0..<currentQuestion.answers.count {
            currentQuestion.answers[i].state = .unanswered
        }
        
        // Select the tapped answer
        if let answerIndex = currentQuestion.answers.firstIndex(where: { $0.id == answer.id }) {
            if answer.state == .selected {
                currentQuestion.answers[answerIndex].state = .unanswered
            } else {
                currentQuestion.answers[answerIndex].state = .selected
            }
        }
        
        uiState.currentQuestion = currentQuestion
        
        // Check answer immediately after selection
        checkAnswer()
    }
    
    private func checkAnswer() {
        guard var currentQuestion = uiState.currentQuestion else { return }
        
        // Find selected answer
        guard let selectedAnswer = currentQuestion.answers.first(where: { $0.state == .selected }) else { return }
        
        // Mark all answers as not clickable
        for i in 0..<currentQuestion.answers.count {
            currentQuestion.answers[i].isClickable = false
            
            // Mark correct/incorrect states
            if currentQuestion.answers[i].state == .selected {
                currentQuestion.answers[i].state = currentQuestion.answers[i].isCorrect ? .correct : .incorrect
            } else if currentQuestion.answers[i].isCorrect {
                currentQuestion.answers[i].state = .correct
            }
        }
        
        currentQuestion.selectedOption = selectedAnswer.choice
        uiState.currentQuestion = currentQuestion
        
        // Update in questions array
        if let index = uiState.questions.firstIndex(where: { $0.id == currentQuestion.id }) {
            uiState.questions[index] = currentQuestion
        }
        
        // Save progress
        saveProgress()
    }
    
    func onActionButtonClicked() {
        switch uiState.buttonState {
        case .next:
            moveToNextQuestion()
        case .finish:
            finishTest()
        }
    }
    
    func onPreviousQuestionClick() {
        guard uiState.currentQuestionIndex > 0 else { return }
        
        uiState.currentQuestionIndex -= 1
        uiState.currentQuestion = uiState.questions[uiState.currentQuestionIndex]
    }
    
    private func moveToNextQuestion() {
        guard uiState.currentQuestionIndex < uiState.questions.count - 1 else {
            finishTest()
            return
        }
        
        uiState.currentQuestionIndex += 1
        uiState.currentQuestion = uiState.questions[uiState.currentQuestionIndex]
        
        saveProgress()
    }
    
    private func finishTest() {
        saveProgress(isCompleted: true)
        uiState.shouldNavigateToResult = true
    }
    
    private func saveProgress(isCompleted: Bool = false) {
        guard let fileName = uiState.fileName else { return }
        
        let answeredQuestions = uiState.questions.filter { $0.selectedOption != nil }
        let correctCount = answeredQuestions.filter { $0.isCorrectSelected }.count
        let wrongCount = answeredQuestions.filter { !$0.isCorrectSelected && $0.isAnswerSelected }.count
        
        // Build answered questions dictionary
        var answeredDict: [Int: String] = [:]
        for (index, question) in uiState.questions.enumerated() {
            if let selected = question.selectedOption {
                answeredDict[index] = selected
            }
        }
        
        // Use upsertTestProgress to save progress
        databaseManager.upsertTestProgress(
            fileName: fileName,
            testId: uiState.id ?? fileName,
            totalQuestionCount: uiState.questions.count,
            answeredQuestionCount: answeredQuestions.count,
            correctAnswerCount: correctCount,
            wrongAnswerCount: wrongCount,
            lastQuestionIndex: uiState.currentQuestionIndex,
            answeredQuestions: answeredDict,
            isCompleted: isCompleted
        )
        
        print("💾 Progress saved: \(answeredQuestions.count) answered, \(correctCount) correct, \(wrongCount) wrong, completed: \(isCompleted)")
    }
}
