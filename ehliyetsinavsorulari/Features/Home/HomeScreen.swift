import SwiftUI

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.appRouter) private var router
    @State private var animatedPercentage: Int = 0

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                ZStack(alignment: .top) {
                    // Top Gradient Background
                    TopGradientBackground()

                    VStack {
                        Spacer().frame(height: 16)
                        // Header (Greeting + Settings)
                        HeaderView(onSettingsTap: {
                            router.navigate(to: .settings)
                        })
                        .padding(.horizontal, 16)

                        Spacer().frame(height: 24)

                        // Progress Card (Geçme Olasılığı)
                        ProgressCard(
                            passPercentage: viewModel.uiState.passPercentage,
                            animatedPercentage: $animatedPercentage
                        )
                        .padding(.horizontal, 16)

                        // Premium Campaign (if needed)
                        if viewModel.uiState.showDiscountedCampaign
                            && !viewModel.uiState.isPremium
                        {
                            PremiumTimeDown(
                                time: viewModel.uiState.premiumCampaignTime
                            )
                            .padding(.horizontal, 16)
                        }

                        // Tests Section
                        LastTestsSection(
                            tests: viewModel.uiState.ongoingTests,
                            isPremium: viewModel.uiState.isPremium,
                            onTestTap: { test in
                                if test.isCompleted {
                                    router.navigate(to: .quizResult(fileName: test.fileName))
                                } else {
                                    router.navigate(to: .quizIntro(test: test))
                                }
                            },
                            onSeeAllTapped: {
                                router.navigate(to: .tests)
                            }
                        )

                        // Subjects Section
                        LastSubjectsSection()

                        // Repeat Section
                        RepeatSection(
                            isPremium: viewModel.uiState.isPremium,
                            onSavedQuestionsTap: {
                                router.navigate(to: .savedQuestionsList)
                            },
                            onMistakeTestTap: {
                                router.navigate(to: .mistakeTestIntro)
                            },
                            onFlashcardsTap: {
                                router.navigate(to: .cardIndex())
                            },
                            onMatchGameTap: {
                                router.navigate(to: .matchGameCategory)
                            },
                            onVideoQuestionsTap: {
                                let videoTest = TestUiModel(
                                    id: "videolusorular",
                                    title: "Videolu Sorular",
                                    fileName: "videolusorular/videolusorular.json",
                                    totalQuestions: 50,
                                    category: "video",
                                    answeredQuestionCount: 0,
                                    correctAnswerCount: 0,
                                    wrongAnswerCount: 0,
                                    isCompleted: false,
                                    isStarted: false,
                                    isPremium: false
                                )
                                router.navigate(to: .quiz(test: videoTest))
                            }
                        )

                        Spacer().frame(height: 32)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .refreshable {
            viewModel.refreshData()
        }
        .onAppear {
            // Animate percentage
            withAnimation(.easeOut(duration: 1.0)) {
                animatedPercentage = viewModel.uiState.passPercentage
            }
        }
        .task {
            // Database context hazır olduktan sonra gerçek verileri yükle
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 saniye bekle
            viewModel.loadHomeData()
        }
        .onChange(of: viewModel.uiState.passPercentage) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedPercentage = newValue
            }
        }
    }
}

// MARK: - Top Gradient Background
struct TopGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "CCE7FF"),  // Açık mavi
                Color(hex: "FFD6B2"),  // Açık turuncu
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 230)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
    }
}

// MARK: - Header
struct HeaderView: View {
    let onSettingsTap: () -> Void

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Günaydın"
        case 12..<18:
            return "İyi Günler"
        case 18..<22:
            return "İyi Akşamlar"
        default:
            return "İyi Geceler"
        }
    }

    var body: some View {
        HStack {
            Text(greeting)
                .font(.custom("Urbanist-Bold", size: 22))
                .foregroundColor(.black)

            Spacer()

            Button(action: onSettingsTap) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    let passPercentage: Int
    @Binding var animatedPercentage: Int
    @State private var showInfoDialog = false

    var body: some View {
        VStack() {
            // Title + Info Icon
            HStack {
                Text("Geçme Olasılığınız")
                    .font(.custom("Urbanist-Bold", size: 18))
                    .foregroundColor(.black)

                Spacer()

                Button(action: { showInfoDialog = true }) {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer().frame(height: 8)

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "E0E0E0"))
                        .frame(height: 12)

                    // Filled Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.primary1)
                        .frame(
                            width: geometry.size.width
                                * CGFloat(animatedPercentage) / 100,
                            height: 12
                        )
                }
            }
            .frame(height: 12)
            .padding(.horizontal, 16)

            // Percentage Text
            Text("%\(animatedPercentage)")
                .font(.custom("Urbanist-Bold", size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer().frame(height: 8)

            HStack(alignment: .top) {
                // Motivational Text
                Text(
                    passPercentage < 20
                        ? "Harika bir başlangıç! Her soru seni hedefe biraz daha yaklaştırıyor, devam et!"
                        : "Her çalışma seni hedefe bir adım daha yaklaştırıyor. Başarı için doğru yoldasın!"
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("Urbanist-Regular", size: 14))
                .padding(.leading, 16)
                .padding(.bottom, 16)
                .foregroundColor(Color.textPrimary)
                

                VStack {
                    Spacer()
                    // Character Image (Bottom Right)
                    Image("character_home_progress")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 121, height: 85)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .alert("Geçme Olasılığı", isPresented: $showInfoDialog) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(
                "Doğru cevapladığınız sorulara göre hesaplanan tahmini geçme olasılığınız."
            )
        }

    }
}

// MARK: - Premium Time Down
struct PremiumTimeDown: View {
    let time: String

    var body: some View {
        Button(action: {
            print("Premium campaign tapped")
        }) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sana Özel")
                        .font(.custom("Urbanist-Bold", size: 16))
                        .foregroundColor(.white)

                    Text("%40 indirim")
                        .font(.custom("Urbanist-Bold", size: 16))
                        .foregroundColor(.white)
                }

                Spacer()

                Text(time)
                    .font(.custom("Urbanist-Bold", size: 22))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF8D28"), Color(hex: "FF2D55")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Last Tests Section
struct LastTestsSection: View {
    let tests: [TestUiModel]
    let isPremium: Bool
    let onTestTap: (TestUiModel) -> Void
    let onSeeAllTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Header
            HStack {
                Text("Testler")
                    .font(.custom("Urbanist-Bold", size: 18))
                    .foregroundColor(.black)
                    .padding(.leading, 16)

                Spacer()

                Button("Tümünü Gör") {
                    onSeeAllTapped()
                }
                .font(.custom("Urbanist-Bold", size: 16))
                .foregroundColor(.black)
                .padding(.trailing, 16)
            }

            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(tests.enumerated()), id: \.element.id) {
                        index,
                        test in
                        let isPremiumLock = !isPremium && test.isPremium

                        TestCard(
                            test: test,
                            isPremiumLock: isPremiumLock,
                            onTap: { onTestTap(test) }
                        )
                        .frame(width: 180)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Test Card
struct TestCard: View {
    let test: TestUiModel
    let isPremiumLock: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            if !isPremiumLock {
                onTap()
            }
        }) {
            VStack(spacing: 8) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color(hex: "E0E0E0"), lineWidth: 6)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: CGFloat(test.progressValue))
                        .stroke(
                            test.isCompleted
                                ? Color(hex: "4CAF50") : Color.primary1,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Image(
                        systemName: isPremiumLock
                            ? "lock.fill" : "doc.text.fill"
                    )
                    .font(.title2)
                    .foregroundColor(isPremiumLock ? .orange : .primary1)
                }

                // Title
                Text(test.title)
                    .font(.custom("Urbanist-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                // Stats or Progress
                if test.isCompleted {
                    HStack(spacing: 4) {
                        // Correct count
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "4CAF50"))
                                .font(.caption)
                            Text("\(test.correctAnswerCount)")
                                .font(.custom("Urbanist-Regular", size: 14))
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
                        )
                        .cornerRadius(16)

                        // Wrong count
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "FF9800"))
                                .font(.caption)
                            Text("\(test.wrongAnswerCount)")
                                .font(.custom("Urbanist-Regular", size: 14))
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
                        )
                        .cornerRadius(16)
                    }
                } else {
                    Text(
                        test.isStarted
                            ? "\(test.answeredQuestionCount)/\(test.totalQuestions) Soru"
                            : "\(test.totalQuestions) Soru"
                    )
                    .font(.custom("Urbanist-Regular", size: 14))
                    .foregroundColor(.textSecondary)
                }

                // Button
                Text(
                    isPremiumLock
                        ? "Premium"
                        : (test.isCompleted
                            ? "Sonuçlar"
                            : (test.isStarted ? "Devam Et" : "Başla"))
                )
                .font(.custom("Urbanist-Bold", size: 16))
                .foregroundColor(
                    isPremiumLock || test.isStarted || test.isCompleted
                        ? .white : .primary1
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    Group {
                        if isPremiumLock {
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF8D28"), Color(hex: "FF2D55"),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else if test.isStarted || test.isCompleted {
                            Color.primary1
                        } else {
                            Color.white
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            test.isStarted || test.isCompleted || isPremiumLock
                                ? Color.clear : Color(hex: "BDBDBD"),
                            lineWidth: 1
                        )
                )
                .cornerRadius(12)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Last Subjects Section
struct LastSubjectsSection: View {
    let subjects = [
        (
            "İlk Yardım", "Temel ilk yardım konuları ve uygulamaları içerir",
            "first_aid_subject"
        ),
        (
            "Motor", "Araç motoru ve teknik bilgiler içerir",
            "motor_subject"
        ),
        (
            "Trafik İşaretleri",
            "Trafik levhaları ve işaretlerinin anlamları içerir",
            "traffic_subject"
        ),
        (
            "Trafik ve Çevre",
            "Trafik kuralları ve çevre bilinci konuları içerir",
            "traffic_sign_subject"
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Konu İçerikleri")
                .font(.custom("Urbanist-Bold", size: 18))
                .foregroundColor(.black)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(subjects, id: \.0) { subject in
                        SubjectCard(
                            title: subject.0,
                            description: subject.1,
                            icon: subject.2
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Subject Card
struct SubjectCard: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        Button(action: {
            print("\(title) tapped")
        }) {
            HStack {
                VStack {
                    Spacer()
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 73, height: 74)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Urbanist-Bold", size: 20))
                        .foregroundColor(.black)

                    Text(description)
                        .font(.custom("Urbanist-Regular", size: 14))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Repeat Section
struct RepeatSection: View {
    let isPremium: Bool
    let onSavedQuestionsTap: () -> Void
    let onMistakeTestTap: () -> Void
    let onFlashcardsTap: () -> Void
    let onMatchGameTap: () -> Void
    let onVideoQuestionsTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tekrarla")
                .font(.custom("Urbanist-Bold", size: 18))
                .foregroundColor(.black)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                RepeatItem(
                    title: "Hafıza Kartları",
                    icon: "flashcards",
                    isPremiumVisible: false,
                    onTap: onFlashcardsTap
                )
                
                RepeatItem(
                    title: "Kaydedilen Sorular",
                    icon: "saved_questions",
                    isPremiumVisible: !isPremium,
                    onTap: onSavedQuestionsTap
                )
                
                RepeatItem(
                    title: "Hatalar Testi",
                    icon: "mistakes_test",
                    isPremiumVisible: !isPremium,
                    onTap: onMistakeTestTap
                )
                
                RepeatItem(
                    title: "Videolu Sorular",
                    icon: "video_test",
                    isPremiumVisible: !isPremium,
                    onTap: onVideoQuestionsTap
                )
                
                RepeatItem(
                    title: "Kart Eşleştirme Oyunu",
                    icon: "match_game",
                    isPremiumVisible: false,
                    onTap: onMatchGameTap
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Repeat Item
struct RepeatItem: View {
    let title: String
    let icon: String
    let isPremiumVisible: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                HStack {
                    Text(title)
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.textPrimary)
                        .padding(.vertical, 16)
                        .padding(.leading, 24)

                    Spacer()

                    VStack {
                        Spacer()
                        Image(icon)
                            .font(.title2)
                            .foregroundColor(.primary1)
                            .padding(.trailing, 24)
                    }
                }
                .frame(height: 56)
                .background(Color.white)
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)

            if isPremiumVisible {
                Image("premium_badge")
                    .foregroundColor(.orange)
                    .frame(width: 32, height: 26, alignment: Alignment.top)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
    }
}
