import SwiftUI

/// Merkezi navigation yöneticisi - Android'deki NavController'ın iOS karşılığı
@MainActor
@Observable
class AppRouter {
    /// Navigation path - her tab için ayrı path tutulur
    var homePath: [AppRoute] = []
    var testsPath: [AppRoute] = []
    var contentsPath: [AppRoute] = []
    var statisticsPath: [AppRoute] = []
    
    /// Aktif tab
    var selectedTab: TabItem = .home
    
    /// Aktif tab'ın path'ini döndürür
    var currentPath: [AppRoute] {
        get {
            switch selectedTab {
            case .home: return homePath
            case .tests: return testsPath
            case .contents: return contentsPath
            case .statistics: return statisticsPath
            }
        }
        set {
            switch selectedTab {
            case .home: homePath = newValue
            case .tests: testsPath = newValue
            case .contents: contentsPath = newValue
            case .statistics: statisticsPath = newValue
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    /// Yeni bir ekrana git
    func navigate(to route: AppRoute) {
        currentPath.append(route)
    }
    
    /// Geri git
    func goBack() {
        if !currentPath.isEmpty {
            currentPath.removeLast()
        }
    }
    
    /// Belirli bir ekrana kadar geri git
    func popTo(_ route: AppRoute) {
        if let index = currentPath.firstIndex(of: route) {
            currentPath = Array(currentPath.prefix(through: index))
        }
    }
    
    /// Root'a git (tüm stack'i temizle)
    func popToRoot() {
        currentPath.removeAll()
    }
    
    /// Stack'i temizle ve yeni rotaya git
    func navigateAndClearStack(to route: AppRoute) {
        currentPath.removeAll()
        currentPath.append(route)
    }
    
    /// Mevcut ekranı değiştir (pop + push)
    func replace(with route: AppRoute) {
        if !currentPath.isEmpty {
            currentPath.removeLast()
        }
        currentPath.append(route)
    }
    
    // MARK: - Tab Navigation
    
    /// Tab değiştir
    func switchTab(to tab: TabItem) {
        selectedTab = tab
    }
    
    /// Tab'a git ve root'a dön
    func navigateToTab(_ tab: TabItem) {
        selectedTab = tab
        // Tab değiştiğinde o tab'ın root'una dön
        switch tab {
        case .home: homePath.removeAll()
        case .tests: testsPath.removeAll()
        case .contents: contentsPath.removeAll()
        case .statistics: statisticsPath.removeAll()
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Quiz intro ekranına git
    func navigateToQuizIntro(test: TestUiModel) {
        navigate(to: .quizIntro(test: test))
    }
    
    /// Quiz ekranına git
    func navigateToQuiz(test: TestUiModel) {
        navigate(to: .quiz(test: test))
    }
    
    /// Quiz intro'dan quiz'e geç (replace)
    func startQuiz(test: TestUiModel) {
        replace(with: .quiz(test: test))
    }
    
    /// Quiz sonuç ekranına git
    func navigateToQuizResult(fileName: String) {
        replace(with: .quizResult(fileName: fileName))
    }
    
    /// Settings ekranına git
    func navigateToSettings() {
        navigate(to: .settings)
    }
    
    /// Paywall ekranına git
    func navigateToPaywall(showPromo: Bool = false) {
        navigate(to: .paywall(showPromo: showPromo))
    }
}

// MARK: - Environment Key
struct AppRouterKey: EnvironmentKey {
    @MainActor static let defaultValue = AppRouter()
}

extension EnvironmentValues {
    var appRouter: AppRouter {
        get { self[AppRouterKey.self] }
        set { self[AppRouterKey.self] = newValue }
    }
}
