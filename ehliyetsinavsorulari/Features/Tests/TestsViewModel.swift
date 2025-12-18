import Foundation
internal import Combine

// MARK: - Filter Enums
enum CompletionFilter: String, CaseIterable {
    case all = "Tümü"
    case notStarted = "Başlamadıklarım"
    case inProgress = "Devam ettiklerim"
    case completed = "Tamamladıklarım"
}

enum CategoryFilter: String, CaseIterable {
    case all = "Tümü"
    case ilkyardim = "İlkyardım"
    case trafik = "Trafik İşaretleri"
    case trafikAdabi = "Trafik ve Çevre"
    case motor = "Motor"
    
    var categoryId: String? {
        switch self {
        case .all: return nil
        case .ilkyardim: return "ilkyardim"
        case .trafik: return "trafik"
        case .trafikAdabi: return "trafikadabi"
        case .motor: return "motor"
        }
    }
}

// MARK: - ViewModel
@MainActor
class TestsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = TestsUiState()
    @Published var isLoading = false
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let userDefaultsManager = UserDefaultsManager.shared
    private let databaseManager = DatabaseManager.shared
    
    // Separate test lists (like Android)
    private var konuTests: [TestUiModel] = []
    private var denemelerTests: [TestUiModel] = []
    
    init() {
        loadInitialData()
    }
    
    // MARK: - Initial Load
    private func loadInitialData() {
        // Load Denemeler (Trial Exams) from tests-index.json
        let testMetadataList = assetLoader.loadTestIndex()
        denemelerTests = testMetadataList.map { metadata in
            TestUiModel(
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
        }
        
        // Load Konu Testleri (Subject Tests) from category index files
        konuTests = assetLoader.loadSubjectTests()
        
        uiState.isPremium = userDefaultsManager.isPremium
        applyFilters()
    }
    
    // MARK: - Data Loading
    func loadTestsData() {
        isLoading = true
        
        Task {
            let allProgresses = databaseManager.getAllTestProgresses()
            
            // Load Denemeler with progress
            let testMetadataList = assetLoader.loadTestIndex()
            denemelerTests = testMetadataList.map { metadata in
                let progress = allProgresses.first { $0.fileName == metadata.fileName }
                return TestUiModel(
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
            }
            
            // Load Konu Testleri with progress
            let subjectTests = assetLoader.loadSubjectTests()
            konuTests = subjectTests.map { test in
                let progress = allProgresses.first { $0.fileName == test.fileName }
                return TestUiModel(
                    id: test.id,
                    title: test.title,
                    fileName: test.fileName,
                    totalQuestions: test.totalQuestions,
                    category: test.category,
                    answeredQuestionCount: progress?.answeredQuestionCount ?? 0,
                    correctAnswerCount: progress?.correctAnswerCount ?? 0,
                    wrongAnswerCount: progress?.wrongAnswerCount ?? 0,
                    isCompleted: progress?.isCompleted ?? false,
                    isStarted: (progress?.answeredQuestionCount ?? 0) > 0,
                    isPremium: test.isPremium
                )
            }
            
            uiState.isPremium = userDefaultsManager.isPremium
            applyFilters()
            
            isLoading = false
        }
    }
    
    // MARK: - Tab Selection
    func selectTab(_ index: Int) {
        uiState.selectedTabIndex = index
        applyFilters()
    }
    
    // MARK: - Filter Actions
    func showFilterSheet() {
        uiState.tempCategoryFilter = uiState.selectedCategoryFilter
        uiState.tempCompletionFilter = uiState.selectedCompletionFilter
        uiState.showFilterSheet = true
    }
    
    func dismissFilterSheet() {
        uiState.showFilterSheet = false
    }
    
    func setCategoryFilter(_ filter: CategoryFilter) {
        uiState.tempCategoryFilter = filter
    }
    
    func setCompletionFilter(_ filter: CompletionFilter) {
        uiState.tempCompletionFilter = filter
    }
    
    func applyFiltersFromSheet() {
        uiState.selectedCategoryFilter = uiState.tempCategoryFilter
        uiState.selectedCompletionFilter = uiState.tempCompletionFilter
        uiState.showFilterSheet = false
        applyFilters()
    }
    
    func clearCategoryFilter() {
        uiState.selectedCategoryFilter = .all
        applyFilters()
    }
    
    func clearCompletionFilter() {
        uiState.selectedCompletionFilter = .all
        applyFilters()
    }
    
    // MARK: - Apply Filters
    private func applyFilters() {
        // Select base tests based on tab (like Android)
        let baseTests: [TestUiModel]
        switch uiState.selectedTabIndex {
        case 0:
            baseTests = konuTests
        default:
            baseTests = denemelerTests
        }
        
        // Apply category filter
        var filteredTests = baseTests
        if let categoryId = uiState.selectedCategoryFilter.categoryId {
            filteredTests = filteredTests.filter { $0.category.lowercased() == categoryId }
        }
        
        // Apply completion filter
        switch uiState.selectedCompletionFilter {
        case .all:
            break
        case .notStarted:
            filteredTests = filteredTests.filter { $0.answeredQuestionCount == 0 }
        case .inProgress:
            filteredTests = filteredTests.filter { $0.answeredQuestionCount > 0 && !$0.isCompleted }
        case .completed:
            filteredTests = filteredTests.filter { $0.isCompleted }
        }
        
        uiState.displayedTests = filteredTests
    }
    
    // MARK: - Actions
    func refreshData() {
        loadTestsData()
    }
}

// MARK: - UI State
struct TestsUiState {
    var displayedTests: [TestUiModel] = []
    var selectedTabIndex: Int = 0
    var isPremium: Bool = false
    
    // Filters
    var selectedCategoryFilter: CategoryFilter = .all
    var selectedCompletionFilter: CompletionFilter = .all
    
    // Temp filters (for bottom sheet)
    var tempCategoryFilter: CategoryFilter = .all
    var tempCompletionFilter: CompletionFilter = .all
    
    var showFilterSheet: Bool = false
    
    var hasActiveFilters: Bool {
        selectedCategoryFilter != .all || selectedCompletionFilter != .all
    }
}
