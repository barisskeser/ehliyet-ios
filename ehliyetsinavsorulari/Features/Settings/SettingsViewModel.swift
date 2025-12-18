import Foundation
import SwiftUI
import UserNotifications
internal import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var uiState = SettingsUiState()
    
    // MARK: - Dependencies
    private let databaseManager = DatabaseManager.shared
    
    init() {
        loadSettings()
    }
    
    // MARK: - Data Loading
    func loadSettings() {
        // Check premium status (placeholder - implement with StoreKit)
        uiState.isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        
        // Load exam date
        if let examDate = UserDefaults.standard.object(forKey: "examDate") as? Date {
            uiState.examDate = examDate
            updateExamDateInfo()
        }
        
        // Check notification permission
        checkNotificationPermission()
    }
    
    func refreshNotificationPermission() {
        checkNotificationPermission()
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.uiState.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func updateExamDateInfo() {
        guard let examDate = uiState.examDate else {
            uiState.daysUntilExam = 0
            uiState.examDateFormatted = ""
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let exam = calendar.startOfDay(for: examDate)
        
        if let days = calendar.dateComponents([.day], from: today, to: exam).day {
            uiState.daysUntilExam = max(0, days)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        uiState.examDateFormatted = formatter.string(from: examDate)
    }
    
    // MARK: - Actions
    func onEditExamDateClick() {
        uiState.showDatePickerDialog = true
    }
    
    func onDismissDatePicker() {
        uiState.showDatePickerDialog = false
    }
    
    func onSaveExamDate(_ date: Date) {
        uiState.examDate = date
        UserDefaults.standard.set(date, forKey: "examDate")
        updateExamDateInfo()
        uiState.showDatePickerDialog = false
    }
    
    func onClearDataClick() {
        uiState.showClearDataDialog = true
    }
    
    func onDismissClearDataDialog() {
        uiState.showClearDataDialog = false
    }
    
    func onConfirmClearData() {
        databaseManager.clearAllData()
        uiState.showClearDataDialog = false
    }
    
    func toggleNotifications(_ enabled: Bool) {
        if enabled {
            requestNotificationPermission()
        } else {
            uiState.showPermissionDialog = true
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self.uiState.notificationsEnabled = true
                } else {
                    self.uiState.showPermissionDialog = true
                }
            }
        }
    }
    
    func onDismissPermissionDialog() {
        uiState.showPermissionDialog = false
    }
    
    func onOpenNotificationSettings() {
        uiState.showPermissionDialog = false
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func shareApp() {
        let text = "Ehliyet sınavına hazırlanmak için harika bir uygulama! 🚗"
        let url = URL(string: "https://apps.apple.com/app/id123456789")!
        
        let activityVC = UIActivityViewController(
            activityItems: [text, url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    func rateApp() {
        if let url = URL(string: "https://apps.apple.com/app/id123456789?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    func contactUs() {
        let email = "destek@ehliyetsinavi.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - UI State
struct SettingsUiState {
    var isPremium: Bool = false
    var examDate: Date? = nil
    var daysUntilExam: Int = 0
    var examDateFormatted: String = ""
    var notificationsEnabled: Bool = false
    var showDatePickerDialog: Bool = false
    var showClearDataDialog: Bool = false
    var showPermissionDialog: Bool = false
}
