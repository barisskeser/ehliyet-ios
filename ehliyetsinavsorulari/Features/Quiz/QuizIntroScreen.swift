import SwiftUI

struct QuizIntroScreen: View {
    @StateObject private var viewModel: QuizIntroViewModel
    @Environment(\.appRouter) private var router
    
    let testUiModel: TestUiModel
    let onStartQuiz: (TestUiModel) -> Void
    
    init(testUiModel: TestUiModel, onStartQuiz: @escaping (TestUiModel) -> Void = { _ in }) {
        self.testUiModel = testUiModel
        self.onStartQuiz = onStartQuiz
        _viewModel = StateObject(wrappedValue: QuizIntroViewModel(testUiModel: testUiModel))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            QuizIntroToolbar(
                title: viewModel.uiState.testName,
                onBackTap: { router.goBack() }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Soru sayısı ve konu bilgisi
                    HStack(spacing: 8) {
                        Text("\(viewModel.uiState.questionCount) Soru")
                            .font(.custom("Urbanist-Regular", size: 14))
                            .foregroundColor(.textPrimary)
                        
                        Text("•")
                            .font(.custom("Urbanist-Bold", size: 26))
                            .foregroundColor(.textPrimary)
                        
                        Text("Tüm Konular")
                            .font(.custom("Urbanist-Regular", size: 14))
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Soru numaraları grid
                    if !viewModel.uiState.questions.isEmpty {
                        QuestionNumberGrid(
                            questions: viewModel.uiState.questions,
                            isStarted: viewModel.uiState.isStarted
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        
                        // Kategori legend (sadece başlamamışsa ve birden fazla kategori varsa)
                        if !viewModel.uiState.isStarted && viewModel.hasMultipleCategories {
                            CategoryLegend()
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }
                    }
                    
                    // Hakkında bölümü
                    Text("Hakkında")
                        .font(.custom("Urbanist-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    
                    Text(viewModel.uiState.description)
                        .font(.custom("Urbanist-Medium", size: 16))
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    Spacer().frame(height: 24)
                    
                    // Info Card
                    InfoCardView(
                        text: viewModel.uiState.infoCardMessage,
                        imageName: "character_info_card"
                    )
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 32)
                }
            }
            
            // Başla/Devam Et butonu
            Button(action: {
                // Quiz ekranına git (replace ile - intro'yu stack'ten çıkar)
                router.replace(with: .quiz(test: testUiModel))
            }) {
                Text(viewModel.uiState.isStarted ? "Devam Et" : "Başla")
                    .font(.custom("Urbanist-Bold", size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primary1)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .task {
            // View yüklendikten sonra detaylı verileri çek
            viewModel.loadQuizInfo()
        }
        .onAppear {
            // Ekrana her geldiğinde verileri yenile
            viewModel.loadQuizInfo()
        }
    }
}

// MARK: - Toolbar
struct QuizIntroToolbar: View {
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

// MARK: - Question Number Grid
struct QuestionNumberGrid: View {
    let questions: [QuestionNumberUiModel]
    let isStarted: Bool
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 10)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(questions) { question in
                QuestionNumberCell(
                    number: question.number,
                    state: question.state,
                    category: question.category,
                    showCategoryColor: !isStarted
                )
            }
        }
    }
}

// MARK: - Question Number Cell
struct QuestionNumberCell: View {
    let number: Int
    let state: QuestionAnswerState
    let category: String?
    let showCategoryColor: Bool
    
    var body: some View {
        Text("\(number)")
            .font(.custom("Urbanist-Medium", size: 14))
            .foregroundColor(textColor)
            .frame(width: 32, height: 32)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
    
    private var textColor: Color {
        switch state {
        case .current:
            return .white
        default:
            return .textPrimary
        }
    }
    
    private var backgroundColor: Color {
        if showCategoryColor && state == .unanswered {
            return categoryBackgroundColor
        }
        
        switch state {
        case .current:
            return .primary1
        case .correct:
            return Color(hex: "E8F5E9") // Success light
        case .incorrect:
            return Color(hex: "FFEBEE") // Error light
        case .unanswered:
            return .white
        }
    }
    
    private var borderColor: Color {
        if showCategoryColor && state == .unanswered {
            return categoryBorderColor
        }
        
        switch state {
        case .current:
            return .primary1
        case .correct:
            return Color(hex: "4CAF50") // Success
        case .incorrect:
            return Color(hex: "F44336") // Error
        case .unanswered:
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        switch state {
        case .unanswered:
            return showCategoryColor ? 1.5 : 0
        default:
            return 1
        }
    }
    
    private var categoryBackgroundColor: Color {
        switch category {
        case "trafik":
            return Color(hex: "E3F2FD") // Pastel mavi
        case "motor":
            return Color(hex: "FFE0B2") // Pastel turuncu
        case "ilkyardim":
            return Color(hex: "FCE4EC") // Pastel pembe
        case "trafikadabi":
            return Color(hex: "E8F5E9") // Pastel yeşil
        default:
            return .white
        }
    }
    
    private var categoryBorderColor: Color {
        switch category {
        case "trafik":
            return Color(hex: "90CAF9") // Soft mavi
        case "motor":
            return Color(hex: "FFB74D") // Soft turuncu
        case "ilkyardim":
            return Color(hex: "F48FB1") // Soft pembe
        case "trafikadabi":
            return Color(hex: "A5D6A7") // Soft yeşil
        default:
            return .white
        }
    }
}

// MARK: - Category Legend
struct CategoryLegend: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                CategoryLegendItem(category: "trafik", name: "Trafik")
                CategoryLegendItem(category: "motor", name: "Motor")
            }
            HStack(spacing: 16) {
                CategoryLegendItem(category: "ilkyardim", name: "İlk Yardım")
                CategoryLegendItem(category: "trafikadabi", name: "Trafik Adabı")
            }
        }
    }
}

struct CategoryLegendItem: View {
    let category: String
    let name: String
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(borderColor, lineWidth: 1.5)
                )
                .frame(width: 20, height: 20)
            
            Text(name)
                .font(.custom("Urbanist-Medium", size: 14))
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var backgroundColor: Color {
        switch category {
        case "trafik":
            return Color(hex: "E3F2FD")
        case "motor":
            return Color(hex: "FFE0B2")
        case "ilkyardim":
            return Color(hex: "FCE4EC")
        case "trafikadabi":
            return Color(hex: "E8F5E9")
        default:
            return .white
        }
    }
    
    private var borderColor: Color {
        switch category {
        case "trafik":
            return Color(hex: "90CAF9")
        case "motor":
            return Color(hex: "FFB74D")
        case "ilkyardim":
            return Color(hex: "F48FB1")
        case "trafikadabi":
            return Color(hex: "A5D6A7")
        default:
            return .white
        }
    }
}

// MARK: - Models
enum QuestionAnswerState {
    case unanswered
    case current
    case correct
    case incorrect
}

struct QuestionNumberUiModel: Identifiable {
    let id = UUID()
    let number: Int
    let state: QuestionAnswerState
    let category: String?
}

#Preview {
    QuizIntroScreen(
        testUiModel: TestUiModel(
            id: "1",
            title: "Deneme Sınavı 1",
            fileName: "test-1",
            totalQuestions: 50,
            category: "test",
            answeredQuestionCount: 25,
            correctAnswerCount: 20,
            wrongAnswerCount: 5,
            isCompleted: false,
            isStarted: true,
            isPremium: false
        ),
        onStartQuiz: { _ in }
    )
}
