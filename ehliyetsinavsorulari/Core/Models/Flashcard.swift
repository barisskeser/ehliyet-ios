import Foundation
import UIKit

// MARK: - Card Category (Flashcard kategorisi)
struct CardCategory: Codable, Identifiable {
    let id: String
    let title: String
    let cardDescription: String
    let iconBase64: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case cardDescription = "description"
        case iconBase64 = "icon_base64"
    }
    
    // Base64'ü UIImage'e çevir
    var iconImage: UIImage? {
        guard let imageData = Data(base64Encoded: iconBase64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

// MARK: - Card (Tekil flashcard)
struct Card: Codable, Identifiable {
    let id: String
    let cardDescription: String
    var isSaved: Int  // 0 veya 1 (JSON'dan geliyor)
    let category: String
    let imageBase64: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case cardDescription = "description"
        case isSaved = "is_saved"
        case category
        case imageBase64 = "image_base64"
    }
    
    // Convenience boolean property
    var isSavedBool: Bool {
        get { isSaved != 0 }
        set { isSaved = newValue ? 1 : 0 }
    }
    
    // Base64'ü UIImage'e çevir
    var cardImage: UIImage? {
        guard let imageData = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

// MARK: - Card Data (JSON root object)
struct CardData: Codable {
    let category: CardCategory
    let cards: [Card]
    
    var totalCards: Int {
        cards.count
    }
}

// MARK: - Card Category Item (UI için özet bilgi)
struct CardCategoryItem: Identifiable {
    let id: String
    let title: String
    let cardDescription: String
    let iconBase64: String
    let totalCards: Int
    var learnedCount: Int = 0
    var learningCount: Int = 0
    
    var progressPercentage: Int {
        guard totalCards > 0 else { return 0 }
        return Int((Double(learnedCount) / Double(totalCards)) * 100)
    }
    
    var remainingCount: Int {
        totalCards - learnedCount - learningCount
    }
}

// MARK: - Card Categories Index (index JSON için)
struct CardCategoriesIndex: Codable {
    let categories: [CategoryIndexItem]
}

struct CategoryIndexItem: Codable, Identifiable {
    let id: String
    let title: String
    let categoryDescription: String
    let iconBase64: String
    let totalCards: Int
    let fileName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case categoryDescription = "description"
        case iconBase64 = "icon_base64"
        case totalCards = "total_cards"
        case fileName = "file_name"
    }
}

// MARK: - Match Game Models (Eşleştirme oyunu)
struct MatchCard: Identifiable {
    let id: String
    let pairId: String  // Eşleşecek kartın ID'si
    let cardDescription: String
    let imageBase64: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
    let type: MatchCardType
    var matchResult: MatchResult = .none
    
    enum MatchCardType {
        case image   // Görsel kartı
        case text    // Açıklama kartı
    }
    
    enum MatchResult {
        case none       // Henüz eşleştirilmedi
        case correct    // Doğru eşleştirildi (yeşil)
        case incorrect  // Yanlış eşleştirildi (turuncu)
    }
}

// MARK: - Match Game State
struct MatchGameState {
    var cards: [MatchCard] = []
    var firstSelectedCard: MatchCard? = nil
    var secondSelectedCard: MatchCard? = nil
    var matchedCount: Int = 0
    var moves: Int = 0
    var isCompleted: Bool = false
    var isCheckingMatch: Bool = false
    var elapsedTime: TimeInterval = 0
    
    var score: Int {
        guard moves > 0 else { return 0 }
        // Skor = (matchedCount * 100) - (yanlış hamle sayısı * 10)
        let wrongMoves = moves - matchedCount
        return max(0, (matchedCount * 100) - (wrongMoves * 10))
    }
}
