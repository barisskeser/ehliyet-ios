import Foundation
import SwiftUI
internal import Combine

@MainActor
class QuizIntroViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = QuizIntroUiState()
    
    // MARK: - Dependencies
    private let assetLoader = AssetLoader.shared
    private let databaseManager = DatabaseManager.shared
    private let testUiModel: TestUiModel
    
    init(testUiModel: TestUiModel) {
        self.testUiModel = testUiModel
        
        // Önce temel bilgileri set et (fallback)
        uiState = QuizIntroUiState(
            testName: testUiModel.title,
            fileName: testUiModel.fileName,
            questionCount: testUiModel.totalQuestions,
            questions: (1...testUiModel.totalQuestions).map { number in
                QuestionNumberUiModel(
                    number: number,
                    state: .unanswered,
                    category: nil
                )
            },
            isStarted: testUiModel.isStarted,
            isCompleted: testUiModel.isCompleted
        )
        
        print("📱 QuizIntroViewModel init - fileName: \(testUiModel.fileName)")
    }
    
    // MARK: - Computed Properties
    var hasMultipleCategories: Bool {
        let categories = uiState.questions.compactMap { $0.category }.filter { !$0.isEmpty }
        return Set(categories).count > 1
    }
    
    // MARK: - Data Loading
    func loadQuizInfo() {
        print("📱 loadQuizInfo çağrıldı - fileName: \(testUiModel.fileName)")
        
        // Test verisini JSON'dan yükle
        guard let testData = assetLoader.loadTest(fileName: testUiModel.fileName) else {
            print("❌ Test yüklenemedi: \(testUiModel.fileName)")
            return
        }
        
        print("✅ Test yüklendi: \(testData.title), \(testData.questions.count) soru")
        
        // Veritabanından progress bilgisini al
        let progress = databaseManager.getTestProgress(fileName: testUiModel.fileName)
        let answeredQuestions = progress?.answeredQuestions ?? [:]
        let lastQuestionIndex = progress?.lastQuestionIndex ?? 0
        
        print("📊 Progress loaded: answeredQuestions=\(answeredQuestions.count), lastQuestionIndex=\(lastQuestionIndex)")
        print("📊 Answered questions dict: \(answeredQuestions)")
        
        // Soru numaralarını oluştur
        var questionModels: [QuestionNumberUiModel] = []
        
        for (index, question) in testData.questions.enumerated() {
            let userAnswer = answeredQuestions[index]
            let isAnswered = userAnswer != nil
            
            let state: QuestionAnswerState
            if index == lastQuestionIndex && lastQuestionIndex > 0 {
                // Kaldığı soru (Android'deki gibi lastQuestionIndex kullan)
                state = .current
            } else if isAnswered {
                // Doğru cevabı kontrol et
                let isCorrect = userAnswer?.lowercased() == question.correctAnswer.lowercased()
                state = isCorrect ? .correct : .incorrect
            } else {
                state = .unanswered
            }
            
            questionModels.append(QuestionNumberUiModel(
                number: index + 1,
                state: state,
                category: question.categoryId
            ))
        }
        
        // isStarted: lastQuestionIndex > 0 veya cevaplanan soru varsa başlamış demek
        let isStarted = lastQuestionIndex > 0 || !answeredQuestions.isEmpty
        
        // Test tipi ve açıklamalar
        let testType = getTestType(fileName: testUiModel.fileName)
        let description = getTestDescription(testType: testType, questionCount: testData.questions.count)
        let infoCardMessage = getInfoCardMessage(testType: testType)
        
        uiState = QuizIntroUiState(
            testName: testData.title,
            fileName: testUiModel.fileName,
            questionCount: testData.questions.count,
            questions: questionModels,
            isStarted: isStarted,
            isCompleted: progress?.isCompleted ?? false,
            testType: testType,
            description: description,
            infoCardMessage: infoCardMessage
        )
    }
    
    // MARK: - Actions
    func refreshData() {
        loadQuizInfo()
    }
    
    // MARK: - Helper Functions
    
    private func getTestType(fileName: String) -> TestType {
        if fileName.hasPrefix("trafik/") {
            return .trafik
        } else if fileName.hasPrefix("motor/") {
            return .motor
        } else if fileName.hasPrefix("ilkyardim/") {
            return .ilkyardim
        } else if fileName.hasPrefix("trafikadabi/") {
            return .trafikAdabi
        } else {
            return .general
        }
    }
    
    private func getTestDescription(testType: TestType, questionCount: Int) -> String {
        switch testType {
        case .general:
            return "Bu deneme sınavı, gerçek ehliyet sınavının tam bir simülasyonudur. Tüm konulardan \(questionCount) soru içerir. Dikkatli ve sakin bir şekilde çözmeniz önerilir. Başarılar!"
        case .trafik:
            return "Bu test, trafik ve çevre bilgisi konusunda bilginizi ölçmek için hazırlanmıştır. Test \(questionCount) sorudan oluşmaktadır. Trafik işaretleri, yol kuralları, sürüş teknikleri ve çevre bilinci gibi konular üzerine sorular içermektedir. Bu konu ehliyet sınavının önemli bir parçasıdır, dikkatli çözmeniz başarınızı artıracaktır."
        case .motor:
            return "Bu test, motor ve araç tekniği bilgilerinizi ölçmeye yöneliktir. Test \(questionCount) sorudan oluşmaktadır. Araç bakımı, motor parçaları, yakıt sistemi, fren sistemi ve güvenli sürüş için araç kontrolü gibi teknik konuları kapsamaktadır. Araç teknolojisi hakkında temel bilgilerinizi pekiştirmek için bu testi dikkatlice çözün."
        case .ilkyardim:
            return "Bu test, ilk yardım bilgilerinizi değerlendirmek için tasarlanmıştır. Test \(questionCount) sorudan oluşmaktadır. Temel ilk yardım müdahaleleri, kaza anında yapılması gerekenler, yaralı taşıma teknikleri ve acil durum yönetimi gibi hayati konuları içermektedir. İlk yardım bilgisi, sadece sınavda değil, gerçek hayatta da size büyük fayda sağlayacaktır."
        case .trafikAdabi:
            return "Bu test, trafik adabı ve etik kurallar konusundaki bilginizi ölçer. Test \(questionCount) sorudan oluşmaktadır. Trafikte nezaket, diğer sürücülere saygı, yaya önceliği, çevre duyarlılığı ve sorumlu sürücü davranışları gibi konuları kapsamaktadır. Trafik adabı, güvenli ve uyumlu bir trafik ortamının temelini oluşturur."
        }
    }
    
    private func getInfoCardMessage(testType: TestType) -> String {
        switch testType {
        case .general:
            return "Tüm konuları bu testte çözeceksin. Haydi bunu gerçek sınavmış gibi çöz!"
        case .trafik:
            return "Trafik bilgini test etme zamanı! Dikkatli ol, her soru önemli."
        case .motor:
            return "Motor ve araç tekniği konusunda kendini sına! Başarılar."
        case .ilkyardim:
            return "İlk yardım bilgini test et. Bu bilgiler hayat kurtarabilir!"
        case .trafikAdabi:
            return "Trafik adabı konusunda ne kadar bilgilisin? Haydi görelim!"
        }
    }
}

// MARK: - UI State
struct QuizIntroUiState {
    var testName: String = ""
    var fileName: String = ""
    var questionCount: Int = 0
    var questions: [QuestionNumberUiModel] = []
    var isStarted: Bool = false
    var isCompleted: Bool = false
    var testType: TestType = .general
    var description: String = ""
    var infoCardMessage: String = ""
}

// MARK: - Test Type
enum TestType {
    case general
    case trafik
    case motor
    case ilkyardim
    case trafikAdabi
}
