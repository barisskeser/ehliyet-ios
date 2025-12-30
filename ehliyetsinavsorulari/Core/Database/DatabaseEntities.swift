import Foundation
import SwiftData

// Test ilerlemesi için entity
@Model
class TestProgressEntity {
    @Attribute(.unique) var fileName: String = ""
    var testId: String = ""
    var answeredQuestionsData: Data = Data() // JSON encoded [Int: String]
    var isCompleted: Bool = false
    var score: Int?
    var completedDate: Date?
    var totalQuestionCount: Int = 50
    var answeredQuestionCount: Int = 0
    var correctAnswerCount: Int = 0
    var wrongAnswerCount: Int = 0
    var lastQuestionIndex: Int = 0
    var startedDate: Date = Date()
    var lastAnsweredDate: Date = Date()
    
    init(fileName: String, testId: String, totalQuestionCount: Int = 50) {
        self.fileName = fileName
        self.testId = testId
        self.answeredQuestionsData = Data()
        self.isCompleted = false
        self.score = nil
        self.completedDate = nil
        self.totalQuestionCount = totalQuestionCount
        self.answeredQuestionCount = 0
        self.correctAnswerCount = 0
        self.wrongAnswerCount = 0
        self.lastQuestionIndex = 0
        self.startedDate = Date()
        self.lastAnsweredDate = Date()
    }
    
    // JSON'dan cevapları decode et
    var answeredQuestions: [Int: String] {
        get {
            guard !answeredQuestionsData.isEmpty else { return [:] }
            return (try? JSONDecoder().decode([Int: String].self, from: answeredQuestionsData)) ?? [:]
        }
        set {
            answeredQuestionsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
}

// Flashcard öğrenme durumu
@Model
class FlashcardLearningEntity {
    @Attribute(.unique) var id: String
    var categoryId: String
    var cardId: String
    var cardDescription: String
    var imageBase64: String
    var status: String // "LEARNED" veya "LEARNING"
    var savedAt: Date
    
    init(id: String, categoryId: String, cardId: String, cardDescription: String, imageBase64: String, status: String) {
        self.id = id
        self.categoryId = categoryId
        self.cardId = cardId
        self.cardDescription = cardDescription
        self.imageBase64 = imageBase64
        self.status = status
        self.savedAt = Date()
    }
}

// Kaydedilmiş sorular
@Model
class SavedQuestionEntity {
    @Attribute(.unique) var id: String
    var testFileName: String
    var questionIndex: Int
    var questionText: String
    var savedAt: Date
    
    init(id: String, testFileName: String, questionIndex: Int, questionText: String) {
        self.id = id
        self.testFileName = testFileName
        self.questionIndex = questionIndex
        self.questionText = questionText
        self.savedAt = Date()
    }
}

// Yanlış yapılan sorular
@Model
class MistakeQuestionEntity {
    @Attribute(.unique) var id: String
    var testFileName: String
    var questionIndex: Int
    var questionText: String
    var userAnswer: String
    var correctAnswer: String
    var createdAt: Date
    
    init(id: String, testFileName: String, questionIndex: Int, questionText: String, userAnswer: String, correctAnswer: String) {
        self.id = id
        self.testFileName = testFileName
        self.questionIndex = questionIndex
        self.questionText = questionText
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.createdAt = Date()
    }
}
