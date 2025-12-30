import Foundation
import UIKit

// MARK: - Test Data (Ana test verisi - Gerçek Android JSON formatı)
struct TestData: Codable, Identifiable {
    let id: UUID
    let testNumber: Int
    let testId: String
    let name: String
    let questionCount: Int
    let questions: [Question]
    
    enum CodingKeys: String, CodingKey {
        case testNumber
        case testId
        case name
        case questionCount
        case questions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.testNumber = try container.decode(Int.self, forKey: .testNumber)
        self.testId = try container.decode(String.self, forKey: .testId)
        self.name = try container.decode(String.self, forKey: .name)
        self.questionCount = try container.decode(Int.self, forKey: .questionCount)
        self.questions = try container.decode([Question].self, forKey: .questions)
    }
    
    // Convenience property
    var title: String { name }
    var totalQuestions: Int { questionCount }
}

// MARK: - Question (Tek bir soru - Gerçek Android JSON formatı)
struct Question: Codable, Identifiable {
    let id: String
    let order: Int
    let categoryId: String
    let question: String
    let type: String  // "image", "text", veya "video"
    let options: [QuestionOption]
    let correctAnswer: String  // "a", "b", "c", veya "d"
    let explanation: String
    let mainImage: String?
    let videoName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case order
        case categoryId
        case question
        case type
        case options
        case correctAnswer
        case explanation
        case mainImage
        case videoName
    }
    
    // Convenience computed properties
    var hasImage: Bool {
        mainImage != nil && !(mainImage?.isEmpty ?? true)
    }
    
    var correctAnswerObject: QuestionOption? {
        options.first { $0.key.lowercased() == correctAnswer.lowercased() }
    }
    
    var questionNumber: Int { order }
    var questionText: String { question }
    var category: String { categoryId }
    
    var mainUIImage: UIImage? {
        guard let base64 = mainImage else { return nil }
        var cleanBase64 = base64
        if let range = base64.range(of: "base64,") {
            cleanBase64 = String(base64[range.upperBound...])
        }
        guard let imageData = Data(base64Encoded: cleanBase64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

// MARK: - Question Option (Şık - Gerçek Android JSON formatı)
struct QuestionOption: Codable, Identifiable {
    let id: UUID
    let key: String  // "a", "b", "c", "d"
    let text: String
    let image: String?  // nullable base64 image
    
    enum CodingKeys: String, CodingKey {
        case key
        case text
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.key = try container.decode(String.self, forKey: .key)
        self.text = try container.decode(String.self, forKey: .text)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
    }
    
    var hasImage: Bool {
        image != nil && !(image?.isEmpty ?? true)
    }
    
    var optionImage: UIImage? {
        guard let base64 = image else { return nil }
        return decodeBase64(base64)
    }
    
    private func decodeBase64(_ base64String: String) -> UIImage? {
        var cleanBase64 = base64String
        if let range = base64String.range(of: "base64,") {
            cleanBase64 = String(base64String[range.upperBound...])
        }
        guard let imageData = Data(base64Encoded: cleanBase64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

// MARK: - Test Index Models (Test listesi için)
struct TestIndexResponse: Codable {
    let tests: [TestMetadata]
}

struct TestMetadata: Codable, Identifiable {
    let id: String
    let fileName: String
    let title: String
    let totalQuestions: Int
    let category: String
    let isPremium: Bool
}
