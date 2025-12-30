import SwiftUI

enum TabItem: String, CaseIterable {
    case home = "Home"
    case tests = "Tests"
    case contents = "Contents"
    case statistics = "Statistics"
    
    var iconName: String {
        switch self {
        case .home:
            return "house.fill"
        case .tests:
            return "doc.text.fill"
        case .contents:
            return "book.fill"
        case .statistics:
            return "chart.bar.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Ana Sayfa"
        case .tests:
            return "Testler"
        case .contents:
            return "İçerikler"
        case .statistics:
            return "İstatistikler"
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .home:
            HomeScreen()
        case .tests:
            TestsScreen()
        case .contents:
            ContentsScreen()
        case .statistics:
            StatisticsScreen()
        }
    }
}
