import Foundation
import SwiftUI
internal import Combine

@MainActor
class MistakeTestIntroViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = MistakeTestIntroUiState()
    
    // MARK: - Dependencies
    private let databaseManager = DatabaseManager.shared
    
    // MARK: - Data Loading
    func loadMistakeCount() {
        let count = databaseManager.getMistakeQuestionCount()
        uiState.mistakeCount = count
        
        print("📋 MistakeTestIntroViewModel - mistakeCount: \(count)")
    }
}

// MARK: - UI State
struct MistakeTestIntroUiState {
    var mistakeCount: Int = 0
}
