import SwiftUI

/// Navigation destination resolver - Android'deki NavigationExtensions.kt'nin iOS karşılığı
struct NavigationCoordinator: View {
    @Environment(\.appRouter) private var router
    let route: AppRoute
    
    var body: some View {
        destinationView(for: route)
    }
    
    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        // MARK: - Quiz Routes
        case .quizIntro(let test):
            QuizIntroScreen(
                testUiModel: test,
                onStartQuiz: { _ in }
            )
            
        case .quiz(let test):
            QuizScreen(testUiModel: test)
            
        case .quizResult(let fileName):
            QuizResultScreen(fileName: fileName)
            
        case .quizReview(let fileName, let categoryKey, let isSimulation):
            QuizReviewScreen(fileName: fileName, categoryKey: categoryKey, isSimulation: isSimulation)
            
        case .questionDetail(let fileName, let questionIndex, let selectedAnswer, let isSimulation):
            QuestionDetailScreen(fileName: fileName, questionIndex: questionIndex, selectedAnswer: selectedAnswer, isSimulation: isSimulation)
            
        // MARK: - Content Routes
        case .contentDetail(let categoryId, let categoryTitle):
            ContentDetailPlaceholder(categoryId: categoryId, categoryTitle: categoryTitle)
            
        case .htmlViewer(let fileName, let title, _, _):
            HtmlViewerPlaceholder(fileName: fileName, title: title)
            
        // MARK: - Flashcard Routes
        case .cardIndex(let title):
            CardIndexPlaceholder(title: title)
            
        case .flashcard(let categoryId, let categoryTitle, let mode, _):
            FlashcardPlaceholder(categoryId: categoryId, categoryTitle: categoryTitle, mode: mode)
            
        case .flashcardResult(let categoryId, let categoryTitle, let mode, let learnedCount, let learningCount, let totalCount):
            FlashcardResultPlaceholder(categoryId: categoryId, categoryTitle: categoryTitle, mode: mode, learnedCount: learnedCount, learningCount: learningCount, totalCount: totalCount)
            
        case .allCards:
            AllCardsPlaceholder()
            
        // MARK: - Match Game Routes
        case .matchGameCategory:
            MatchGameCategoryPlaceholder()
            
        case .matchGame(let categoryId, let categoryTitle):
            MatchGamePlaceholder(categoryId: categoryId, categoryTitle: categoryTitle)
            
        case .matchGameResult(let categoryId, let categoryTitle, let moves):
            MatchGameResultPlaceholder(categoryId: categoryId, categoryTitle: categoryTitle, moves: moves)
            
        // MARK: - Saved/Mistake Routes
        case .mistakeTestIntro:
            MistakeTestIntroScreen()
            
        case .mistakeQuestionsList:
            MistakeQuestionsListScreen()
            
        case .savedQuestionsList:
            SavedQuestionsListScreen()
            
        case .customQuiz(let mode):
            CustomQuizPlaceholder(mode: mode)
            
        // MARK: - Simulation Routes
        case .simulationIntro:
            SimulationIntroPlaceholder()
            
        case .simulationResult(let fileName):
            SimulationResultPlaceholder(fileName: fileName)
            
        // MARK: - Settings & Profile Routes
        case .settings:
            SettingsScreen()
            
        case .profile:
            ProfilePlaceholder()
            
        // MARK: - Subscription Routes
        case .paywall(let showPromo):
            PaywallPlaceholder(showPromo: showPromo)
            
        case .promo(let startCampaignIfNotStarted):
            PromoPlaceholder(startCampaignIfNotStarted: startCampaignIfNotStarted)
            
        case .subscription:
            SubscriptionPlaceholder()
            
        // MARK: - Onboarding Routes
        case .welcome:
            WelcomePlaceholder()
            
        case .onboarding:
            OnboardingPlaceholder()
            
        case .examSetup:
            ExamSetupPlaceholder()
            
        // MARK: - Utility Routes
        case .webViewer(let url, let title):
            WebViewerPlaceholder(url: url, title: title)
            
        case .flashCardSettings:
            FlashCardSettingsPlaceholder()
            
        // MARK: - Tab Routes (normally not navigated to via path)
        case .home, .tests, .contents, .statistics:
            EmptyView()
        }
    }
}

// MARK: - Placeholder Views (Henüz implement edilmemiş ekranlar için)

struct QuizResultPlaceholder: View {
    let fileName: String
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Quiz Sonucu", subtitle: fileName) {
            router.goBack()
        }
    }
}

struct QuizReviewPlaceholder: View {
    let fileName: String
    let categoryKey: String?
    let isSimulation: Bool
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Quiz İnceleme", subtitle: fileName) {
            router.goBack()
        }
    }
}

struct QuestionDetailPlaceholder: View {
    let fileName: String
    let questionIndex: Int
    let selectedAnswer: String?
    let isSimulation: Bool
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Soru Detayı", subtitle: "Soru \(questionIndex + 1)") {
            router.goBack()
        }
    }
}

struct ContentDetailPlaceholder: View {
    let categoryId: String
    let categoryTitle: String
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: categoryTitle, subtitle: categoryId) {
            router.goBack()
        }
    }
}

struct HtmlViewerPlaceholder: View {
    let fileName: String
    let title: String
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: title, subtitle: fileName) {
            router.goBack()
        }
    }
}

struct CardIndexPlaceholder: View {
    let title: String
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Hafıza Kartları", subtitle: title) {
            router.goBack()
        }
    }
}

struct FlashcardPlaceholder: View {
    let categoryId: String
    let categoryTitle: String
    let mode: FlashcardMode
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: categoryTitle, subtitle: mode.rawValue) {
            router.goBack()
        }
    }
}

struct FlashcardResultPlaceholder: View {
    let categoryId: String
    let categoryTitle: String
    let mode: FlashcardMode
    let learnedCount: Int
    let learningCount: Int
    let totalCount: Int
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Flashcard Sonucu", subtitle: "\(learnedCount)/\(totalCount)") {
            router.goBack()
        }
    }
}

struct AllCardsPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Tüm Kartlar", subtitle: "") {
            router.goBack()
        }
    }
}

struct MatchGameCategoryPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Eşleştirme Oyunu", subtitle: "Kategori Seç") {
            router.goBack()
        }
    }
}

struct MatchGamePlaceholder: View {
    let categoryId: String
    let categoryTitle: String
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: categoryTitle, subtitle: "Eşleştirme") {
            router.goBack()
        }
    }
}

struct MatchGameResultPlaceholder: View {
    let categoryId: String
    let categoryTitle: String
    let moves: Int
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Oyun Sonucu", subtitle: "\(moves) hamle") {
            router.goBack()
        }
    }
}

struct MistakeTestIntroPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Hatalar Testi", subtitle: "") {
            router.goBack()
        }
    }
}

struct MistakeQuestionsListPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Yanlış Sorular", subtitle: "") {
            router.goBack()
        }
    }
}

struct SavedQuestionsListPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Kaydedilen Sorular", subtitle: "") {
            router.goBack()
        }
    }
}

struct CustomQuizPlaceholder: View {
    let mode: CustomQuizMode
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Özel Quiz", subtitle: mode.rawValue) {
            router.goBack()
        }
    }
}

struct SimulationIntroPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Simülasyon", subtitle: "Giriş") {
            router.goBack()
        }
    }
}

struct SimulationResultPlaceholder: View {
    let fileName: String
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Simülasyon Sonucu", subtitle: fileName) {
            router.goBack()
        }
    }
}

struct SettingsPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Ayarlar", subtitle: "") {
            router.goBack()
        }
    }
}

struct ProfilePlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Profil", subtitle: "") {
            router.goBack()
        }
    }
}

struct PaywallPlaceholder: View {
    let showPromo: Bool
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Premium", subtitle: showPromo ? "Promo" : "") {
            router.goBack()
        }
    }
}

struct PromoPlaceholder: View {
    let startCampaignIfNotStarted: Bool
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Kampanya", subtitle: "") {
            router.goBack()
        }
    }
}

struct SubscriptionPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Abonelik", subtitle: "") {
            router.goBack()
        }
    }
}

struct WelcomePlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Hoş Geldiniz", subtitle: "") {
            router.goBack()
        }
    }
}

struct OnboardingPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Onboarding", subtitle: "") {
            router.goBack()
        }
    }
}

struct ExamSetupPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Sınav Ayarları", subtitle: "") {
            router.goBack()
        }
    }
}

struct WebViewerPlaceholder: View {
    let url: String
    let title: String
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: title, subtitle: url) {
            router.goBack()
        }
    }
}

struct FlashCardSettingsPlaceholder: View {
    @Environment(\.appRouter) private var router
    
    var body: some View {
        PlaceholderScreen(title: "Kart Ayarları", subtitle: "") {
            router.goBack()
        }
    }
}

// MARK: - Generic Placeholder Screen
struct PlaceholderScreen: View {
    let title: String
    let subtitle: String
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.primary1)
            
            Text(title)
                .font(.custom("Urbanist-Bold", size: 24))
                .foregroundColor(.textPrimary)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.custom("Urbanist-Medium", size: 16))
                    .foregroundColor(.textSecondary)
            }
            
            Text("Bu ekran henüz implement edilmedi")
                .font(.custom("Urbanist-Regular", size: 14))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.textPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.custom("Urbanist-Bold", size: 18))
                    .foregroundColor(.textPrimary)
            }
        }
    }
}
