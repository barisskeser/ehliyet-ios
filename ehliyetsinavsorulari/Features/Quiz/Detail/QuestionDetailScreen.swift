import SwiftUI
internal import Combine

struct QuestionDetailScreen: View {
    @StateObject private var viewModel: QuestionDetailViewModel
    @Environment(\.appRouter) private var router
    
    let fileName: String
    let questionIndex: Int
    let selectedAnswer: String?
    let isSimulation: Bool
    
    init(fileName: String, questionIndex: Int, selectedAnswer: String? = nil, isSimulation: Bool = false) {
        self.fileName = fileName
        self.questionIndex = questionIndex
        self.selectedAnswer = selectedAnswer
        self.isSimulation = isSimulation
        _viewModel = StateObject(wrappedValue: QuestionDetailViewModel(
            fileName: fileName,
            questionIndex: questionIndex,
            selectedAnswer: selectedAnswer
        ))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                DetailTopBar(
                    progress: viewModel.uiState.progress,
                    label: viewModel.uiState.progressLabel,
                    isSaved: viewModel.uiState.isSaved,
                    isSimulationMode: isSimulation,
                    onCloseClick: {
                        router.goBack()
                    },
                    onSaveClick: {
                        viewModel.onSaveClick()
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer().frame(height: 16)
                
                // Question Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Question Image (if exists)
                        if let imageBase64 = viewModel.uiState.questionImage, !imageBase64.isEmpty {
                            Base64ImageView(base64String: imageBase64)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .cornerRadius(12)
                        }
                        
                        // Question Text
                        Text(viewModel.uiState.questionText)
                            .font(.custom("Urbanist-SemiBold", size: 16))
                            .foregroundColor(.textPrimary)
                        
                        // Answers
                        VStack(spacing: 12) {
                            ForEach(viewModel.uiState.answers) { answer in
                                DetailAnswerRow(answer: answer)
                            }
                        }
                        
                        // Explanation (if correct answer has one)
                        if let explanation = viewModel.uiState.answers.first(where: { $0.isCorrect })?.explanation,
                           !explanation.isEmpty {
                            ExplanationCard(explanation: explanation)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            viewModel.loadQuestion()
        }
    }
}

// MARK: - Detail Top Bar
struct DetailTopBar: View {
    let progress: Float
    let label: String
    let isSaved: Bool
    let isSimulationMode: Bool
    let onCloseClick: () -> Void
    let onSaveClick: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onCloseClick) {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
            }
            
            // Progress Bar
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primary1)
                            .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                    }
                }
                .frame(height: 8)
                
                Text(label)
                    .font(.custom("Urbanist-Medium", size: 12))
                    .foregroundColor(.textSecondary)
            }
            
            if !isSimulationMode {
                Button(action: onSaveClick) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundColor(isSaved ? .primary1 : .textSecondary)
                }
            }
        }
    }
}

// MARK: - Detail Answer Row
struct DetailAnswerRow: View {
    let answer: DetailAnswerUiModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Choice letter
            Text(answer.choice)
                .font(.custom("Urbanist-Bold", size: 16))
                .foregroundColor(textColor)
                .frame(width: 32, height: 32)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 2)
                )
            
            // Answer image (if exists)
            if let imageBase64 = answer.image, !imageBase64.isEmpty {
                Base64ImageView(base64String: imageBase64)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            
            // Answer text
            Text(answer.text)
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Result icon
            if answer.state == .correct {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "4CAF50"))
                    .font(.title2)
            } else if answer.state == .incorrect {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(hex: "F44336"))
                    .font(.title2)
            }
        }
        .padding(12)
        .background(cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: answer.state != .unanswered ? 2 : 0)
        )
    }
    
    private var textColor: Color {
        switch answer.state {
        case .correct:
            return .white
        case .incorrect:
            return .white
        case .unanswered:
            return .textPrimary
        }
    }
    
    private var backgroundColor: Color {
        switch answer.state {
        case .correct:
            return Color(hex: "4CAF50")
        case .incorrect:
            return Color(hex: "F44336")
        case .unanswered:
            return .white
        }
    }
    
    private var borderColor: Color {
        switch answer.state {
        case .correct:
            return Color(hex: "4CAF50")
        case .incorrect:
            return Color(hex: "F44336")
        case .unanswered:
            return Color(hex: "E0E0E0")
        }
    }
    
    private var cardBackground: Color {
        switch answer.state {
        case .correct:
            return Color(hex: "E8F5E9")
        case .incorrect:
            return Color(hex: "FFEBEE")
        case .unanswered:
            return .white
        }
    }
}

// MARK: - Explanation Card
struct ExplanationCard: View {
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.primary1)
                
                Text("Açıklama")
                    .font(.custom("Urbanist-Bold", size: 16))
                    .foregroundColor(.textPrimary)
            }
            
            Text(explanation)
                .font(.custom("Urbanist-Regular", size: 14))
                .foregroundColor(.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary1.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    QuestionDetailScreen(fileName: "test_1", questionIndex: 0)
}
