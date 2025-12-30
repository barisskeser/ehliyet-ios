import SwiftUI

struct QuizResultScreen: View {
    @StateObject private var viewModel: QuizResultViewModel
    @Environment(\.appRouter) private var router
    @State private var showRestartConfirmation = false
    
    let fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
        _viewModel = StateObject(wrappedValue: QuizResultViewModel(fileName: fileName))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Toolbar
                ResultToolbar(
                    title: "Sonuçlar",
                    onBackTap: {
                        router.popToRoot()
                    }
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Progress Circle and Stats Row
                        HStack(alignment: .center, spacing: 8) {
                            // Progress Circle
                            ProgressCircleView(
                                percentage: viewModel.uiState.percentage
                            )
                            .frame(width: 140, height: 140)
                            
                            // Stats Column
                            VStack(spacing: 8) {
                                StatRow(
                                    icon: "checkmark.circle.fill",
                                    iconColor: Color(hex: "4CAF50"),
                                    label: "Doğru",
                                    value: viewModel.uiState.correctCount
                                )
                                
                                StatRow(
                                    icon: "xmark.circle.fill",
                                    iconColor: Color(hex: "F44336"),
                                    label: "Yanlış",
                                    value: viewModel.uiState.wrongCount
                                )
                                
                                StatRow(
                                    icon: "minus.circle.fill",
                                    iconColor: .primary1,
                                    label: "Boş",
                                    value: viewModel.uiState.emptyCount
                                )
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Topic Cards
                        if !viewModel.uiState.topics.isEmpty {
                            HStack(spacing: 6) {
                                ForEach(viewModel.uiState.topics) { topic in
                                    TopicCardView(topic: topic)
                                        .onTapGesture {
                                            router.navigate(to: .quizReview(
                                                fileName: fileName,
                                                categoryKey: topic.categoryId,
                                                isSimulation: false
                                            ))
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Control Button
                        ActionRow(
                            icon: "book.fill",
                            title: "Kontrol Et",
                            onTap: {
                                router.navigate(to: .quizReview(fileName: fileName, categoryKey: nil, isSimulation: false))
                            }
                        )
                        .padding(.horizontal, 16)
                        
                        // Share Button
                        ActionRow(
                            icon: "square.and.arrow.up",
                            title: "Sonucunu Paylaş",
                            onTap: {
                                shareResult()
                            }
                        )
                        .padding(.horizontal, 16)
                        
                        // Motivation Card
                        InfoCardView(
                            text: viewModel.uiState.motivationMessage,
                            imageName: viewModel.uiState.motivationIcon.isEmpty ? "characterstates" : viewModel.uiState.motivationIcon
                        )
                        .padding(.horizontal, 16)
                        
                        Spacer().frame(height: 20)
                    }
                }
                
                // Bottom Buttons
                VStack(spacing: 8) {
                    // Ana Sayfaya Dön
                    Button(action: {
                        router.popToRoot()
                    }) {
                        Text("Ana Sayfaya Dön")
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.primary1)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    
                    // Baştan Çöz
                    Button(action: {
                        showRestartConfirmation = true
                    }) {
                        Text("Baştan Çöz")
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.primary1)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .alert("Sınavı Baştan Çöz", isPresented: $showRestartConfirmation) {
            Button("İptal", role: .cancel) {}
            Button("Tamam", role: .destructive) {
                viewModel.restartTest()
                // Navigate to quiz intro
                let test = TestUiModel(
                    id: fileName,
                    title: viewModel.uiState.testName,
                    fileName: fileName,
                    totalQuestions: viewModel.uiState.correctCount + viewModel.uiState.wrongCount + viewModel.uiState.emptyCount,
                    category: "",
                    answeredQuestionCount: 0,
                    correctAnswerCount: 0,
                    wrongAnswerCount: 0,
                    isCompleted: false,
                    isStarted: false,
                    isPremium: false
                )
                router.popToRoot()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    router.navigate(to: .quizIntro(test: test))
                }
            }
        } message: {
            Text("Sınavı baştan çözmeniz durumunda mevcut ilerlemeniz sıfırlanacaktır")
        }
    }
    
    private func shareResult() {
        let percentage = Int(viewModel.uiState.percentage * 100)
        let text = """
        🚗 Ehliyet Sınavı Sonucum
        
        📝 \(viewModel.uiState.testName)
        ✅ Doğru: \(viewModel.uiState.correctCount)
        ❌ Yanlış: \(viewModel.uiState.wrongCount)
        ⭕ Boş: \(viewModel.uiState.emptyCount)
        📊 Başarı: %\(percentage)
        
        #EhliyetSınavı #Ehliyet
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Result Toolbar
struct ResultToolbar: View {
    let title: String
    let onBackTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBackTap) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            Text(title)
                .font(.custom("Urbanist-Bold", size: 18))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            // Placeholder for symmetry
            Image(systemName: "xmark")
                .font(.title3)
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }
}

// MARK: - Progress Circle
struct ProgressCircleView: View {
    let percentage: Float
    
    var body: some View {
        ZStack {
            // Background circle (Error/Wrong portion)
            Circle()
                .stroke(Color(hex: "F44336"), lineWidth: 16)
            
            // Foreground circle (Success/Correct portion)
            Circle()
                .trim(from: 0, to: CGFloat(percentage))
                .stroke(
                    Color(hex: "4CAF50"),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            Text("%\(Int(percentage * 100))")
                .font(.custom("Urbanist-Bold", size: 20))
                .foregroundColor(.textPrimary)
        }
        .padding(8)
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
            
            Text(label)
                .font(.custom("Urbanist-Medium", size: 16))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text("\(value)")
                .font(.custom("Urbanist-Medium", size: 16))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Topic Card
struct TopicCardView: View {
    let topic: TopicUiModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Mini progress circle
            ZStack {
                Circle()
                    .stroke(Color(hex: "F44336"), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: CGFloat(topic.percentage))
                    .stroke(
                        Color(hex: "4CAF50"),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: topic.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.textPrimary)
            }
            
            Text(topic.title)
                .font(.custom("Urbanist-SemiBold", size: 11))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(16)
    }
}

// MARK: - Action Row
struct ActionRow: View {
    let icon: String
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.textPrimary)
                
                Text(title)
                    .font(.custom("Urbanist-SemiBold", size: 16))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuizResultScreen(fileName: "test_1")
}
