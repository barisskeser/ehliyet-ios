import Foundation

// MARK: - User Progress (Kullanıcı genel ilerlemesi)
struct UserProgress: Codable {
    var testProgress: [String: TestProgress]  // testId: TestProgress
    var passPercentage: Int
    var totalQuestionsAnswered: Int
    var totalCorrectAnswers: Int
    var lastUpdated: Date
    
    init() {
        self.testProgress = [:]
        self.passPercentage = 0
        self.totalQuestionsAnswered = 0
        self.totalCorrectAnswers = 0
        self.lastUpdated = Date()
    }
    
    // Genel istatistikler
    var averageScore: Int {
        let completedTests = testProgress.values.filter { $0.isCompleted }
        guard !completedTests.isEmpty else { return 0 }
        let totalScore = completedTests.compactMap { $0.score }.reduce(0, +)
        return totalScore / completedTests.count
    }
    
    var completedTestCount: Int {
        testProgress.values.filter { $0.isCompleted }.count
    }
    
    var inProgressTestCount: Int {
        testProgress.values.filter { !$0.isCompleted && !$0.answeredQuestions.isEmpty }.count
    }
}

// MARK: - Test Progress (Tek bir test'in ilerlemesi)
struct TestProgress: Codable {
    let testId: String
    let fileName: String
    var answeredQuestions: [Int: String]  // questionIndex: userAnswer ("A", "B", "C", "D")
    var isCompleted: Bool
    var score: Int?  // 0-100 arası puan
    var correctCount: Int?
    var wrongCount: Int?
    var completedDate: Date?
    var startedDate: Date
    var lastAnsweredDate: Date
    
    init(testId: String, fileName: String) {
        self.testId = testId
        self.fileName = fileName
        self.answeredQuestions = [:]
        self.isCompleted = false
        self.score = nil
        self.correctCount = nil
        self.wrongCount = nil
        self.completedDate = nil
        self.startedDate = Date()
        self.lastAnsweredDate = Date()
    }
    
    // Convenience methods
    mutating func answerQuestion(index: Int, answer: String) {
        answeredQuestions[index] = answer
        lastAnsweredDate = Date()
    }
    
    mutating func complete(correctCount: Int, wrongCount: Int) {
        self.isCompleted = true
        self.correctCount = correctCount
        self.wrongCount = wrongCount
        self.completedDate = Date()
        
        let total = correctCount + wrongCount
        self.score = total > 0 ? Int((Double(correctCount) / Double(total)) * 100) : 0
    }
    
    // Computed properties
    var answeredCount: Int {
        answeredQuestions.count
    }
    
    var emptyCount: Int {
        50 - answeredCount  // Varsayılan 50 soru
    }
    
    var progressPercentage: Int {
        Int((Double(answeredCount) / 50.0) * 100)
    }
    
    var isPassed: Bool {
        guard let score = score else { return false }
        return score >= 70  // %70 geçme notu
    }
    
    var timeSpent: TimeInterval {
        if let completed = completedDate {
            return completed.timeIntervalSince(startedDate)
        }
        return lastAnsweredDate.timeIntervalSince(startedDate)
    }
}

// MARK: - Question Progress (Soru bazlı ilerleme - İstatistikler için)
struct QuestionProgress: Codable {
    let questionId: String
    let testId: String
    let questionIndex: Int
    var userAnswer: String?
    var isCorrect: Bool?
    var attemptCount: Int
    var lastAttemptDate: Date?
    
    init(questionId: String, testId: String, questionIndex: Int) {
        self.questionId = questionId
        self.testId = testId
        self.questionIndex = questionIndex
        self.userAnswer = nil
        self.isCorrect = nil
        self.attemptCount = 0
        self.lastAttemptDate = nil
    }
    
    mutating func recordAnswer(_ answer: String, isCorrect: Bool) {
        self.userAnswer = answer
        self.isCorrect = isCorrect
        self.attemptCount += 1
        self.lastAttemptDate = Date()
    }
}

// MARK: - Category Stats (Kategori bazlı istatistikler)
struct CategoryStats: Codable {
    let categoryId: String
    var totalQuestions: Int
    var answeredQuestions: Int
    var correctAnswers: Int
    var wrongAnswers: Int
    
    var successRate: Int {
        guard answeredQuestions > 0 else { return 0 }
        return Int((Double(correctAnswers) / Double(answeredQuestions)) * 100)
    }
    
    init(categoryId: String) {
        self.categoryId = categoryId
        self.totalQuestions = 0
        self.answeredQuestions = 0
        self.correctAnswers = 0
        self.wrongAnswers = 0
    }
}
