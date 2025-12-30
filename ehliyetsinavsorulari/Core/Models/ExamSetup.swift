import Foundation
import SwiftUI
internal import Combine

// MARK: - Exam Setup Data
struct ExamSetupData: Codable {
    var examDate: Date?
    var isLastMinuteStudy: Bool
    var isExamDateUnknown: Bool
    var isReminderEnabled: Bool
    
    init() {
        self.examDate = nil
        self.isLastMinuteStudy = false
        self.isExamDateUnknown = false
        self.isReminderEnabled = true  // Default true
    }
    
    init(examDate: Date?, isLastMinuteStudy: Bool, isExamDateUnknown: Bool, isReminderEnabled: Bool) {
        self.examDate = examDate
        self.isLastMinuteStudy = isLastMinuteStudy
        self.isExamDateUnknown = isExamDateUnknown
        self.isReminderEnabled = isReminderEnabled
    }
    
    // Validation
    var isValid: Bool {
        // En az bir seçenek seçilmiş olmalı
        return examDate != nil || isLastMinuteStudy || isExamDateUnknown
    }
    
    // Sınava kalan gün sayısı
    var daysUntilExam: Int? {
        guard let examDate = examDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: examDate)
        return components.day
    }
    
    // Mesaj oluştur
    var motivationalMessage: String {
        if let days = daysUntilExam {
            if days > 0 {
                return "Sınavınıza \(days) gün kaldı!"
            } else if days == 0 {
                return "Sınavınız bugün! Başarılar!"
            } else {
                return "Sınavınız geçti. Yeni tarih belirleyin."
            }
        } else if isLastMinuteStudy {
            return "Son dakika! Yoğun çalış!"
        } else if isExamDateUnknown {
            return "Tarih belli olunca hatırlat!"
        }
        return "Sınav bilgilerinizi girin"
    }
}

// MARK: - Exam Setup UI State (SwiftUI için)
class ExamSetupUIState: ObservableObject {
    @Published var selectedDate: Date?
    @Published var isLastMinuteStudy: Bool = false
    @Published var isExamDateUnknown: Bool = false
    @Published var isReminderEnabled: Bool = true
    @Published var showDatePicker: Bool = false
    
    var canProceed: Bool {
        selectedDate != nil || isLastMinuteStudy || isExamDateUnknown
    }
    
    func toExamSetupData() -> ExamSetupData {
        ExamSetupData(
            examDate: selectedDate,
            isLastMinuteStudy: isLastMinuteStudy,
            isExamDateUnknown: isExamDateUnknown,
            isReminderEnabled: isReminderEnabled
        )
    }
    
    func reset() {
        selectedDate = nil
        isLastMinuteStudy = false
        isExamDateUnknown = false
        isReminderEnabled = true
        showDatePicker = false
    }
}

// MARK: - Reminder Settings (Hatırlatıcı ayarları)
struct ReminderSettings: Codable {
    var isEnabled: Bool
    var frequency: ReminderFrequency
    var time: Date  // Saat (sadece saat ve dakika kullanılır)
    
    enum ReminderFrequency: String, Codable {
        case daily = "Günlük"
        case everyOtherDay = "İki Günde Bir"
        case weekly = "Haftalık"
        case custom = "Özel"
    }
    
    init() {
        self.isEnabled = true
        self.frequency = .daily
        
        // Varsayılan saat: 20:00
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        self.time = Calendar.current.date(from: components) ?? Date()
    }
}
