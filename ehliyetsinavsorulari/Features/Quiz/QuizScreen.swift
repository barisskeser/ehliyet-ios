import SwiftUI
import AVKit

struct QuizScreen: View {
    @StateObject private var viewModel: QuizViewModel
    @Environment(\.appRouter) private var router
    
    let testUiModel: TestUiModel
    
    init(testUiModel: TestUiModel) {
        self.testUiModel = testUiModel
        _viewModel = StateObject(wrappedValue: QuizViewModel(testUiModel: testUiModel))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            if viewModel.uiState.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let currentQuestion = viewModel.uiState.currentQuestion {
                VStack(spacing: 0) {
                    // Top Bar
                    QuizTopBar(
                        progress: viewModel.uiState.progress,
                        label: viewModel.uiState.progressLabel,
                        isSaved: currentQuestion.isSaved,
                        onCloseClick: { viewModel.onCloseClick() },
                        onSaveClick: { viewModel.onSaveClick() }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    Spacer().frame(height: 16)
                    
                    // Question View
                    QuizQuestionView(
                        question: currentQuestion,
                        onAnswerSelected: { answer in
                            viewModel.onAnswerSelected(answer)
                        }
                    )
                    .padding(.horizontal, 16)
                    
                    // Bottom Buttons
                    HStack(spacing: 8) {
                        // Previous Button (only show if not first question)
                        if viewModel.uiState.currentQuestionIndex > 0 {
                            Button(action: { viewModel.onPreviousQuestionClick() }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.primary1)
                                    .cornerRadius(16)
                            }
                        }
                        
                        // Action Button (Devam / Tamamla)
                        Button(action: { viewModel.onActionButtonClicked() }) {
                            Text(viewModel.uiState.buttonState.text)
                                .font(.custom("Urbanist-Bold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.primary1)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            } else {
                Text("Soru yüklenemedi")
                    .font(.custom("Urbanist-Medium", size: 16))
                    .foregroundColor(.textSecondary)
            }
        }
        .navigationBarHidden(true)
        .task {
            viewModel.loadQuiz()
        }
        .onChange(of: viewModel.uiState.shouldNavigateBack) { _, shouldNavigate in
            if shouldNavigate {
                router.goBack()
            }
        }
        .onChange(of: viewModel.uiState.shouldNavigateToResult) { _, shouldNavigate in
            if shouldNavigate {
                // Quiz sonuç ekranına git
                router.replace(with: .quizResult(fileName: testUiModel.fileName))
            }
        }
        .sheet(isPresented: $viewModel.uiState.showExitConfirmationSheet) {
            ExitConfirmationSheet(
                onDismiss: { viewModel.onDismissExitSheet() },
                onConfirmExit: { viewModel.onExitConfirmed() },
                onContinueTest: { viewModel.onDismissExitSheet() }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Top Bar
struct QuizTopBar: View {
    let progress: Double
    let label: String
    let isSaved: Bool
    let onCloseClick: () -> Void
    let onSaveClick: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Close Button
            Button(action: onCloseClick) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textPrimary)
            }
            
            // Progress Bar
            QuizProgressBar(progress: progress, label: label)
            
            // Save Button
            Button(action: onSaveClick) {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 18))
                    .foregroundColor(isSaved ? .primary1 : .textPrimary)
            }
        }
    }
}

// MARK: - Progress Bar
struct QuizProgressBar: View {
    let progress: Double
    let label: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 24)
                
                // Progress
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.primary1)
                    .frame(width: max(geometry.size.width * CGFloat(progress), 50), height: 24)
                
                // Label
                Text(label)
                    .font(.custom("Urbanist-SemiBold", size: 12))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(height: 24)
    }
}

// MARK: - Question View
struct QuizQuestionView: View {
    let question: QuestionUiModel
    let onAnswerSelected: (AnswerUiModel) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Video Player (if video question)
                if question.type == "video", let videoName = question.videoName, !videoName.isEmpty {
                    VideoPlayerView(videoName: videoName)
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                }
                
                // Question Image (if exists)
                if let imageBase64 = question.image, !imageBase64.isEmpty {
                    Base64ImageView(base64String: imageBase64)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.bottom, 20)
                }
                
                // Question Text
                Text(question.questionText)
                    .font(.custom("Urbanist-Bold", size: 18))
                    .foregroundColor(.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer().frame(height: 16)
                
                // Answer Options
                VStack(spacing: 8) {
                    ForEach(question.answers) { answer in
                        AnswerOptionView(
                            answer: answer,
                            onTap: {
                                if answer.isClickable {
                                    onAnswerSelected(answer)
                                }
                            }
                        )
                    }
                }
                
                Spacer().frame(height: 16)
            }
        }
    }
}

// MARK: - Answer Option View
struct AnswerOptionView: View {
    let answer: AnswerUiModel
    let onTap: () -> Void
    
    private var backgroundColor: Color {
        switch answer.state {
        case .correct:
            return Color(hex: "D5F3C4")
        case .incorrect:
            return Color(hex: "FDD8D8")
        case .selected:
            return Color(hex: "D8E8FD")
        case .unanswered:
            return .white
        }
    }
    
    private var borderColor: Color {
        switch answer.state {
        case .selected:
            return .primary1
        default:
            return .clear
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // State Icon
                if answer.state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "4CAF50"))
                        .font(.system(size: 20))
                } else if answer.state == .incorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "F44336"))
                        .font(.system(size: 20))
                }
                
                // Answer Content
                if let imageBase64 = answer.image, !imageBase64.isEmpty {
                    Base64ImageView(base64String: imageBase64)
                        .frame(maxWidth: .infinity)
                        .frame(height: 75)
                } else {
                    Text(answer.text)
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: answer.state == .selected ? 1 : 0)
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        
        // Show explanation for correct answer
        if answer.state == .correct, let explanation = answer.explanation, !explanation.isEmpty {
            Text(explanation)
                .font(.custom("Urbanist-Regular", size: 14))
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 20)
                .padding(.top, 4)
        }
    }
}

// MARK: - Base64 Image View
struct Base64ImageView: View {
    let base64String: String
    
    var body: some View {
        if let image = decodeBase64Image(base64String) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
        }
    }
    
    private func decodeBase64Image(_ base64String: String) -> UIImage? {
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

// MARK: - Video Player View
struct VideoPlayerView: View {
    let videoName: String
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onDisappear {
                        player.pause()
                    }
            } else {
                Rectangle()
                    .fill(Color.black)
                    .overlay(
                        ProgressView()
                            .tint(.white)
                    )
            }
        }
        .onAppear {
            loadVideo()
        }
        .onChange(of: videoName) { _, newValue in
            loadVideo()
        }
    }
    
    private func loadVideo() {
        // Try to load from bundle
        let cleanName = videoName.replacingOccurrences(of: ".mp4", with: "")
        if let url = Bundle.main.url(forResource: cleanName, withExtension: "mp4") {
            player = AVPlayer(url: url)
        } else {
            print("❌ Video not found: \(videoName)")
        }
    }
}

// MARK: - Exit Confirmation Sheet
struct ExitConfirmationSheet: View {
    let onDismiss: () -> Void
    let onConfirmExit: () -> Void
    let onContinueTest: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16)
            
            // Icon
            Image("character_crying")
                .resizable()
                .scaledToFit()
                .frame(width: 160)
                .padding(.bottom, 16)
            
            // Title
            Text("Dur gitme... Testi bitirmene çok az kaldı, başarabilirsin!")
                .font(.custom("Urbanist-Bold", size: 20))
                .foregroundColor(.textPrimary)
                .padding(.bottom, 8)
            
            // Continue Button
            Button(action: onContinueTest) {
                Text("Teste devam et")
                    .font(.custom("Urbanist-Bold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primary1)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 12)
            
            // Exit Button
            Button(action: onConfirmExit) {
                Text("Çıkış yap")
                    .font(.custom("Urbanist-SemiBold", size: 18))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 16)
        }
    }
}

#Preview {
    QuizScreen(
        testUiModel: TestUiModel(
            id: "1",
            title: "Deneme Sınavı 1",
            fileName: "test-1",
            totalQuestions: 50,
            category: "test",
            answeredQuestionCount: 0,
            correctAnswerCount: 0,
            wrongAnswerCount: 0,
            isCompleted: false,
            isStarted: false,
            isPremium: false
        )
    )
}
