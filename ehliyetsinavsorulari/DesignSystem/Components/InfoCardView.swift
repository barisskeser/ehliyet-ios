import SwiftUI

/// Android'deki InfoCard component'inin iOS karşılığı
/// Bilgilendirme mesajı ve sağ tarafta karakter görseli içeren kart
struct InfoCardView: View {
    let text: String
    let imageName: String
    
    init(text: String, imageName: String = "characterstates") {
        self.text = text
        self.imageName = imageName
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(text)
                .font(.custom("Urbanist-Medium", size: 16))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 80, alignment: .bottom)
        }
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    VStack(spacing: 16) {
        InfoCardView(
            text: "Kartların yarısından fazlasını öğrenmişsin, birkaç pratikle bilge bir baykuştan daha da bilge olacaksın."
        )
        
        InfoCardView(
            text: "Tüm konuları bu testte çözeceksin. Haydi bunu gerçek sınavmış gibi çöz!",
            imageName: "character_home_progress"
        )
    }
    .padding()
    .background(Color.appBackground)
}
