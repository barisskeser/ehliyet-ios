import SwiftUI

struct MistakeQuestionsListScreen: View {
    @StateObject private var viewModel = MistakeQuestionsListViewModel()
    @Environment(\.appRouter) private var router
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Toolbar
                MistakeQuestionsToolbar(
                    title: "Soruları İncele",
                    onBackTap: {
                        router.goBack()
                    }
                )
                
                VStack(spacing: 16) {
                    // Start Solving Button (only if there are questions)
                    if !viewModel.uiState.questions.isEmpty {
                        Button(action: {
                            router.navigate(to: .customQuiz(mode: .mistakes))
                        }) {
                            Text("Çözmeye başla")
                                .font(.custom("Urbanist-Bold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.primary1)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Content
                    if viewModel.uiState.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    } else if viewModel.uiState.questions.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.textSecondary)
                            
                            Text("Hatalı soru yok")
                                .font(.custom("Urbanist-Medium", size: 16))
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.uiState.questions) { question in
                                    MistakeQuestionCard(
                                        question: question,
                                        onTap: {
                                            router.navigate(to: .questionDetail(
                                                fileName: question.fileName,
                                                questionIndex: question.questionIndex,
                                                selectedAnswer: question.userAnswer
                                            ))
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            viewModel.loadMistakeQuestions()
        }
    }
}

// MARK: - Mistake Questions Toolbar
struct MistakeQuestionsToolbar: View {
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
            
            Image(systemName: "chevron.left")
                .font(.title3)
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.appBackground)
    }
}

// MARK: - Mistake Question Card
struct MistakeQuestionCard: View {
    let question: MistakeQuestionItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
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
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MistakeQuestionsListScreen()
}
