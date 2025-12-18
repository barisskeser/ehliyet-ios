import Foundation

/// Tüm uygulama rotaları - Android'deki Screen.kt'nin iOS karşılığı
enum AppRoute: Hashable {
    // MARK: - Tab Routes (Bottom Navigation)
    case home
    case tests
    case contents
    case statistics
    
    // MARK: - Quiz Routes
    case quizIntro(test: TestUiModel)
    case quiz(test: TestUiModel)
    case quizResult(fileName: String)
    case quizReview(fileName: String, categoryKey: String? = nil, isSimulation: Bool = false)
    case questionDetail(fileName: String, questionIndex: Int, selectedAnswer: String? = nil, isSimulation: Bool = false)
    
    // MARK: - Content Routes
    case contentDetail(categoryId: String, categoryTitle: String)
    case htmlViewer(fileName: String, title: String, categoryId: String, itemId: Int)
    
    // MARK: - Flashcard Routes
    case cardIndex(title: String = "")
    case flashcard(categoryId: String, categoryTitle: String, mode: FlashcardMode = .newCards, shouldRestart: Bool = false)
    case flashcardResult(categoryId: String, categoryTitle: String, mode: FlashcardMode, learnedCount: Int, learningCount: Int, totalCount: Int)
    case allCards
    
    // MARK: - Match Game Routes
    case matchGameCategory
    case matchGame(categoryId: String, categoryTitle: String)
    case matchGameResult(categoryId: String, categoryTitle: String, moves: Int)
    
    // MARK: - Saved/Mistake Routes
    case mistakeTestIntro
    case mistakeQuestionsList
    case savedQuestionsList
    case customQuiz(mode: CustomQuizMode)
    
    // MARK: - Simulation Routes
    case simulationIntro
    case simulationResult(fileName: String)
    
    // MARK: - Settings & Profile Routes
    case settings
    case profile
    
    // MARK: - Subscription Routes
    case paywall(showPromo: Bool = false)
    case promo(startCampaignIfNotStarted: Bool = false)
    case subscription
    
    // MARK: - Onboarding Routes
    case welcome
    case onboarding
    case examSetup
    
    // MARK: - Utility Routes
    case webViewer(url: String, title: String)
    case flashCardSettings
}

// MARK: - Supporting Enums
enum FlashcardMode: String, Hashable {
    case newCards = "NEW_CARDS"
    case savedCards = "SAVED_CARDS"
}

enum CustomQuizMode: String, Hashable {
    case saved = "SAVED"
    case mistakes = "MISTAKES"
}
