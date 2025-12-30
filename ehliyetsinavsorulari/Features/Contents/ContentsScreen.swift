import SwiftUI

struct ContentsScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("İçerikler Ekranı")
                    .font(.headlineLarge)
                    .foregroundColor(.textPrimary)
                
                Text("Konu anlatımları burada görünecek")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("İçerikler")
    }
}

#Preview {
    NavigationStack {
        ContentsScreen()
    }
}
