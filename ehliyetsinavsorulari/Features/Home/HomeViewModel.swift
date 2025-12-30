import Foundation
internal import Combine
import SwiftData

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = HomeUiState()
    @Published var isLoading = false
    @Published var isReady = false
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let userDefaultsManager = UserDefaultsManager.shared
    private let databaseManager = DatabaseManager.shared
    private let examPredictionManager = ExamPredictionManager.shared
    
    init() {
        // İlk yüklemede sadece JSON'dan test listesini yükle
        loadInitialData()
    }
    
    // MARK: - Initial Load (Database olmadan)
    private func loadInitialData() {
        let testMetadataList = assetLoader.loadTestIndex()
        
        var testModels: [TestUiModel] = []
        for metadata in testMetadataList {
            let testModel = TestUiModel(
                id: metadata.id,
                title: metadata.title,
                fileName: metadata.fileName,
                totalQuestions: metadata.totalQuestions,
                category: metadata.category,
                answeredQuestionCount: 0,
                correctAnswerCount: 0,
                wrongAnswerCount: 0,
                isCompleted: false,
                isStarted: false,
                isPremium: metadata.isPremium
            )
            testModels.append(testModel)
        }
        
        uiState = HomeUiState(
            ongoingTests: testModels,
            passPercentage: 0,
            isPremium: userDefaultsManager.isPremium
        )
        isReady = true
    }
    
    // MARK: - Data Loading
    func loadHomeData() {
        isLoading = true
        
        Task {
            // Test index'i yükle (JSON'dan metadata)
            let testMetadataList = assetLoader.loadTestIndex()
            
            // Veritabanından tüm test ilerlemelerini al
            let allProgresses = databaseManager.getAllTestProgresses()
            
            // Tüm testleri al ve progress bilgilerini yükle
            var testModels: [TestUiModel] = []
            
            for metadata in testMetadataList {
                // Veritabanından ilerleme bilgisini çek
                let progress = allProgresses.first { $0.fileName == metadata.fileName }
                
                let testModel = TestUiModel(
                    id: metadata.id,
                    title: metadata.title,
                    fileName: metadata.fileName,
                    totalQuestions: metadata.totalQuestions,
                    category: metadata.category,
                    answeredQuestionCount: progress?.answeredQuestionCount ?? 0,
                    correctAnswerCount: progress?.correctAnswerCount ?? 0,
                    wrongAnswerCount: progress?.wrongAnswerCount ?? 0,
                    isCompleted: progress?.isCompleted ?? false,
                    isStarted: (progress?.answeredQuestionCount ?? 0) > 0,
                    isPremium: metadata.isPremium
                )
                
                testModels.append(testModel)
            }
            
            // Geçme olasılığını hesapla (ExamPredictionManager ile)
            let prediction = examPredictionManager.calculatePassProbability()
            
            uiState = HomeUiState(
                ongoingTests: testModels,
                passPercentage: prediction.passPercentage,
                isPremium: userDefaultsManager.isPremium
            )
            
            isLoading = false
        }
    }
    
    // MARK: - Actions
    func refreshData() {
        loadHomeData()
    }
}

// MARK: - UI State
struct HomeUiState {
    var ongoingTests: [TestUiModel] = []
    var passPercentage: Int = 0
    var isPremium: Bool = false
    var showDiscountedCampaign: Bool = false
    var premiumCampaignTime: String = "15:00"
}

// MARK: - Test UI Model (Android'deki TestUiModel'in iOS karşılığı)
struct TestUiModel: Identifiable, Hashable {
    let id: String
    let title: String
    let fileName: String
    let totalQuestions: Int
    let category: String
    let answeredQuestionCount: Int
    let correctAnswerCount: Int
    let wrongAnswerCount: Int
    let isCompleted: Bool
    let isStarted: Bool
    let isPremium: Bool
    
    var progressPercentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(answeredQuestionCount) / Double(totalQuestions)) * 100)
    }
    
    var progressValue: Float {
        guard totalQuestions > 0 else { return 0 }
        return Float(correctAnswerCount) / Float(totalQuestions)
    }
    
    var emptyQuestions: Int {
        totalQuestions - answeredQuestionCount
    }
}
