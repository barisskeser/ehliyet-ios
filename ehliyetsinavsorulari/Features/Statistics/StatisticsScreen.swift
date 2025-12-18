import SwiftUI

struct StatisticsScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("İstatistikler Ekranı")
                    .font(.headlineLarge)
                    .foregroundColor(.textPrimary)
                
                Text("Grafikler ve istatistikler burada görünecek")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("İstatistikler")
    }
}

#Preview {
    NavigationStack {
        StatisticsScreen()
    }
}
