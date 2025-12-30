import Foundation
import UIKit

// MARK: - Category Index Models
struct CategoryIndexModel: Codable {
    let categoryId: String
    let categoryName: String
    let color: String
    let totalGroups: Int
    let totalQuestions: Int
    let groups: [CategoryGroup]
}

struct CategoryGroup: Codable {
    let groupNumber: Int
    let groupId: String
    let file: String
}

enum TestCategory: String, CaseIterable {
    case ilkyardim
    case motor
    case trafik
    case trafikadabi
    
    var folderName: String {
        switch self {
        case .ilkyardim: return "ilkyardim"
        case .motor: return "motor"
        case .trafik: return "trafik"
        case .trafikadabi: return "trafikadabi"
        }
    }
    
    var indexFileName: String {
        switch self {
        case .ilkyardim: return "ilk-yardim-index"
        case .motor: return "motor-index"
        case .trafik: return "trafik-index"
        case .trafikadabi: return "trafik-adabi-index"
        }
    }
}

class AssetLoader {
    static let shared = AssetLoader()
    private init() {}
    
    // Cache for category indexes
    private var categoryIndexCache: [TestCategory: CategoryIndexModel] = [:]
    
    // MARK: - Test Loading
    
    // MARK: - Denemeler (Trial Exams) Loading
    
    func loadTestIndex() -> [TestMetadata] {
        // Bundle içeriğini debug et
        if let resourcePath = Bundle.main.resourcePath {
            print("📁 Bundle resourcePath: \(resourcePath)")
            let fileManager = FileManager.default
            if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                print("📁 Bundle içeriği: \(contents)")
            }
        }
        
        // Farklı path kombinasyonlarını dene
        let possiblePaths = [
            ("JSON/tests", "tests-index", "json"),
            ("Resources/JSON/tests", "tests-index", "json"),
            ("tests", "tests-index", "json"),
            ("", "tests-index", "json")
        ]
        
        var foundPath: String?
        for (dir, name, ext) in possiblePaths {
            if let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: dir.isEmpty ? nil : dir) {
                print("✅ Bulundu: \(dir)/\(name).\(ext)")
                foundPath = path
                break
            }
        }
        
        guard let path = foundPath else {
            print("❌ tests-index.json hiçbir path'te bulunamadı")
            return []
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let index = try decoder.decode(TestIndexResponse.self, from: data)
            print("✅ \(index.tests.count) test metadata yüklendi")
            return index.tests
        } catch {
            print("❌ Test index decode hatası: \(error)")
            return []
        }
    }
    
    // MARK: - Subject Tests (Konu Testleri) Loading
    
    func loadSubjectTests() -> [TestUiModel] {
        var allTests: [TestUiModel] = []
        
        print("🔍 Loading subject tests...")
        
        // Debug: List bundle contents to find JSON files
        debugListBundleContents()
        
        for category in TestCategory.allCases {
            let categoryTests = loadTestsFromCategory(category)
            print("   \(category.rawValue): \(categoryTests.count) tests loaded")
            allTests.append(contentsOf: categoryTests)
        }
        
        print("📊 Total subject tests loaded: \(allTests.count)")
        
        // Shuffle with fixed seed for consistent order (like Android)
        var generator = SeededRandomGenerator(seed: 1)
        return allTests.shuffled(using: &generator)
    }
    
    private func debugListBundleContents() {
        print("📦 Bundle contents debug:")
        
        // Check bundle resource path
        if let resourcePath = Bundle.main.resourcePath {
            print("   Bundle path: \(resourcePath)")
            
            let fileManager = FileManager.default
            
            // List top-level contents
            if let contents = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
                print("   Top-level items: \(contents.filter { !$0.hasPrefix(".") && !$0.hasPrefix("_") }.prefix(20))")
            }
            
            // Check for JSON folder
            let jsonPath = resourcePath + "/JSON"
            if fileManager.fileExists(atPath: jsonPath) {
                print("   ✅ JSON folder exists")
                if let contents = try? fileManager.contentsOfDirectory(atPath: jsonPath) {
                    print("   JSON subfolders: \(contents)")
                }
            } else {
                print("   ❌ JSON folder NOT found at \(jsonPath)")
            }
            
            // Check for ilkyardim folder directly
            let ilkyardimPath = resourcePath + "/JSON/ilkyardim"
            if fileManager.fileExists(atPath: ilkyardimPath) {
                print("   ✅ ilkyardim folder exists")
                if let contents = try? fileManager.contentsOfDirectory(atPath: ilkyardimPath) {
                    print("   ilkyardim files: \(contents.prefix(5))...")
                }
            } else {
                print("   ❌ ilkyardim folder NOT found")
            }
        }
        
        // List all json files in bundle
        if let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            print("   JSON files in root: \(urls.count)")
            // Check if any are index files
            let indexFiles = urls.filter { $0.lastPathComponent.contains("index") }
            print("   Index files found: \(indexFiles.map { $0.lastPathComponent })")
        }
    }
    
    private func loadCategoryIndex(_ category: TestCategory) -> CategoryIndexModel? {
        // Check cache first
        if let cached = categoryIndexCache[category] {
            return cached
        }
        
        print("🔍 Loading category index for: \(category.rawValue)")
        print("   Folder: \(category.folderName), Index: \(category.indexFileName)")
        
        // Try multiple path patterns - Xcode may flatten or preserve structure
        let possiblePaths = [
            ("JSON/\(category.folderName)", category.indexFileName, "json"),
            ("Resources/JSON/\(category.folderName)", category.indexFileName, "json"),
            (category.folderName, category.indexFileName, "json"),
            ("", category.indexFileName, "json"),  // Flattened - file at root
            ("JSON", category.indexFileName, "json"),  // All JSON in one folder
        ]
        
        var foundPath: String?
        for (dir, name, ext) in possiblePaths {
            print("   Trying: dir='\(dir)', name='\(name)', ext='\(ext)'")
            if let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: dir.isEmpty ? nil : dir) {
                print("   ✅ Found at: \(path)")
                foundPath = path
                break
            }
        }
        
        // Fallback: Try to find by URL if path doesn't work
        if foundPath == nil {
            print("   Trying URL-based search...")
            if let url = Bundle.main.url(forResource: category.indexFileName, withExtension: "json") {
                print("   ✅ Found via URL: \(url.path)")
                foundPath = url.path
            }
        }
        
        // Fallback: Try direct file system path
        if foundPath == nil, let resourcePath = Bundle.main.resourcePath {
            print("   Trying direct file system path...")
            let directPaths = [
                "\(resourcePath)/JSON/\(category.folderName)/\(category.indexFileName).json",
                "\(resourcePath)/\(category.folderName)/\(category.indexFileName).json",
                "\(resourcePath)/\(category.indexFileName).json"
            ]
            
            let fileManager = FileManager.default
            for path in directPaths {
                if fileManager.fileExists(atPath: path) {
                    print("   ✅ Found via direct path: \(path)")
                    foundPath = path
                    break
                }
            }
        }
        
        guard let path = foundPath else {
            print("❌ \(category.indexFileName).json bulunamadı - tried all paths")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let index = try decoder.decode(CategoryIndexModel.self, from: data)
            categoryIndexCache[category] = index
            print("✅ \(index.categoryName) index yüklendi: \(index.groups.count) grup")
            return index
        } catch {
            print("❌ Category index decode hatası: \(error)")
            return nil
        }
    }
    
    private func loadTestsFromCategory(_ category: TestCategory) -> [TestUiModel] {
        guard let categoryIndex = loadCategoryIndex(category) else {
            return []
        }
        
        return categoryIndex.groups.map { group in
            TestUiModel(
                id: group.groupId,
                title: "\(categoryIndex.categoryName) Test \(group.groupNumber)",
                fileName: "\(category.folderName)/\(group.file)",
                totalQuestions: 12, // Default, will be updated when loaded
                category: category.rawValue,
                answeredQuestionCount: 0,
                correctAnswerCount: 0,
                wrongAnswerCount: 0,
                isCompleted: false,
                isStarted: false,
                isPremium: group.groupNumber > 2 // First 2 tests free per category
            )
        }
    }
    
    // MARK: - Single Test Loading
    
    func loadTest(fileName: String) -> TestData? {
        print("🔍 loadTest called with fileName: \(fileName)")
        
        // Clean the fileName - remove .json extension and extract just the file name
        var cleanFileName = fileName.replacingOccurrences(of: ".json", with: "")
        
        // If fileName contains a path (like "ilkyardim/ilkyardim_group-1.json"), extract just the file part
        if cleanFileName.contains("/") {
            cleanFileName = (cleanFileName as NSString).lastPathComponent
        }
        
        print("   Clean fileName: \(cleanFileName)")
        
        // Try multiple path patterns - files are flattened in bundle
        let possiblePaths = [
            ("", cleanFileName, "json"),  // Root level (flattened bundle)
            ("JSON/tests", cleanFileName, "json"),
            ("Resources/JSON/tests", cleanFileName, "json"),
            ("tests", cleanFileName, "json")
        ]
        
        var foundPath: String?
        for (dir, name, ext) in possiblePaths {
            if let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: dir.isEmpty ? nil : dir) {
                print("   ✅ Found at: \(path)")
                foundPath = path
                break
            }
        }
        
        guard let path = foundPath else {
            print("❌ \(fileName) bulunamadı (tried: \(cleanFileName))")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let testData = try decoder.decode(TestData.self, from: data)
            
            print("✅ Test yüklendi: \(testData.title), \(testData.questions.count) soru")
            return testData
        } catch {
            print("❌ Test decode hatası: \(error)")
            print("   Detay: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Flashcard Loading
    
    func loadFlashcardIndex() -> CardCategoriesIndex? {
        let possiblePaths = [
            ("JSON/flashcards", "flashcards-index", "json"),
            ("Resources/JSON/flashcards", "flashcards-index", "json"),
            ("flashcards", "flashcards-index", "json")
        ]
        
        var foundPath: String?
        for (dir, name, ext) in possiblePaths {
            if let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: dir.isEmpty ? nil : dir) {
                foundPath = path
                break
            }
        }
        
        guard let path = foundPath else {
            print("❌ flashcards-index.json bulunamadı")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let index = try decoder.decode(CardCategoriesIndex.self, from: data)
            print("✅ \(index.categories.count) flashcard kategorisi yüklendi")
            return index
        } catch {
            print("❌ Flashcard index decode hatası: \(error)")
            return nil
        }
    }
    
    func loadFlashcardCategory(fileName: String) -> CardData? {
        let cleanFileName = fileName.replacingOccurrences(of: ".json", with: "")
        
        let possiblePaths = [
            ("JSON/flashcards", cleanFileName, "json"),
            ("Resources/JSON/flashcards", cleanFileName, "json"),
            ("flashcards", cleanFileName, "json")
        ]
        
        var foundPath: String?
        for (dir, name, ext) in possiblePaths {
            if let path = Bundle.main.path(forResource: name, ofType: ext, inDirectory: dir.isEmpty ? nil : dir) {
                foundPath = path
                break
            }
        }
        
        guard let path = foundPath else {
            print("❌ \(fileName) bulunamadı")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let cardData = try decoder.decode(CardData.self, from: data)
            print("✅ Flashcard kategori yüklendi: \(cardData.category.title), \(cardData.totalCards) kart")
            return cardData
        } catch {
            print("❌ Flashcard decode hatası: \(error)")
            return nil
        }
    }
    
    // MARK: - Image Helpers
    
    func decodeBase64Image(_ base64String: String) -> UIImage? {
        // "data:image/png;base64," prefix'ini kaldır
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

// MARK: - Seeded Random Generator (for consistent shuffling)
struct SeededRandomGenerator: RandomNumberGenerator {
    var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
