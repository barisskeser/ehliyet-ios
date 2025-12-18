import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let onboardingCompleted = "onboardingCompleted"
        static let examSetupData = "examSetupData"
        static let isPremium = "isPremium"
        static let firstPaywallShown = "firstPaywallShown"
    }
    
    // MARK: - Onboarding
    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: Keys.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Keys.onboardingCompleted) }
    }
    
    // MARK: - Exam Setup
    var examSetupData: ExamSetupData? {
        get {
            guard let data = defaults.data(forKey: Keys.examSetupData) else { return nil }
            return try? JSONDecoder().decode(ExamSetupData.self, from: data)
        }
        set {
            if let data = newValue {
                let encoded = try? JSONEncoder().encode(data)
                defaults.set(encoded, forKey: Keys.examSetupData)
            } else {
                defaults.removeObject(forKey: Keys.examSetupData)
            }
        }
    }
    
    // MARK: - Premium
    var isPremium: Bool {
        get { true }
        set { defaults.set(newValue, forKey: Keys.isPremium) }
    }
    
    var firstPaywallShown: Bool {
        get { defaults.bool(forKey: Keys.firstPaywallShown) }
        set { defaults.set(newValue, forKey: Keys.firstPaywallShown) }
    }
    
    // MARK: - Reset
    func resetAll() {
        defaults.removeObject(forKey: Keys.onboardingCompleted)
        defaults.removeObject(forKey: Keys.examSetupData)
        defaults.removeObject(forKey: Keys.isPremium)
        defaults.removeObject(forKey: Keys.firstPaywallShown)
    }
}
