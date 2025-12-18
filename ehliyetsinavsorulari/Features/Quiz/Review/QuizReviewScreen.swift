import SwiftUI

struct QuizReviewScreen: View {
    @StateObject private var viewModel: QuizReviewViewModel
    @Environment(\.appRouter) private var router
    
    let fileName: String
    let categoryKey: String?
    let isSimulation: Bool
    
    init(fileName: String, categoryKey: String? = nil, isSimulation: Bool = false) {
        self.fileName = fileName
        self.categoryKey = categoryKey
        self.isSimulation = isSimulation
        _viewModel = StateObject(wrappedValue: QuizReviewViewModel(fileName: fileName, categoryKey: categoryKey))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Toolbar
                ReviewToolbar(
                    title: "Kontrol Et",
                    onBackTap: {
                        router.goBack()
                    }
                )
                
                // Content
                if viewModel.uiState.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Spacer()
                } else if viewModel.uiState.questions.isEmpty {
                    Spacer()
                    Text("Soru yok")
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.textSecondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.uiState.questions) { question in
                                ReviewQuestionCard(
                                    question: question,
                                    showSaveButton: !isSimulation,
                                    onTap: {
                                        router.navigate(to: .questionDetail(
                                            fileName: question.fileName,
                                            questionIndex: question.questionIndex,
                                            selectedAnswer: question.selectedAnswer,
                                            isSimulation: isSimulation
                                        ))
                                    },
                                    onSaveTap: {
                                        viewModel.onSaveClick(question: question)
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            viewModel.loadReviewQuestions()
        }
    }
}

// MARK: - Review Toolbar
struct ReviewToolbar: View {
    let title: String
    let onBackTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBackTap) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            Text(title)
                .font(.custom("Urbanist-Bold", size: 18))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            // Placeholder for symmetry
            Image(systemName: "chevron.left")
                .font(.title3)
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }
}

// MARK: - Review Question Card
struct ReviewQuestionCard: View {
    let question: ReviewQuestionItem
    let showSaveButton: Bool
    let onTap: () -> Void
    let onSaveTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Correct/Wrong icon
                Image(systemName: question.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(question.isCorrect ? Color(hex: "4CAF50") : Color(hex: "F44336"))
                
                // Question image (if exists)
                if let imageBase64 = question.image, !imageBase64.isEmpty {
                    Base64ImageView(base64String: imageBase64)
                        .frame(width: 72, height: 72)
                        .cornerRadius(8)
                }
                
                // Question text
                Text(question.questionText)
                    .font(.custom("Urbanist-Medium", size: 14))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Bookmark button
                if showSaveButton {
                    Button(action: onSaveTap) {
                        Image(systemName: question.isSaved ? "bookmark.fill" : "bookmark")
                            .font(.title3)
                            .foregroundColor(question.isSaved ? .primary1 : .textSecondary)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuizReviewScreen(fileName: "test_1")
}
