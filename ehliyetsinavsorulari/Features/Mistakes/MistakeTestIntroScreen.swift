import SwiftUI

struct MistakeTestIntroScreen: View {
    @StateObject private var viewModel = MistakeTestIntroViewModel()
    @Environment(\.appRouter) private var router
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Toolbar
                MistakeToolbar(
                    title: "Hatalar Testi",
                    onBackTap: {
                        router.goBack()
                    }
                )
                
                VStack {
                    Spacer().frame(height: 40)
                    
                    // Mistake count section
                    HStack(alignment: .bottom) {
                        Image("character_state_mistake")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                        
                        Spacer().frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.uiState.mistakeCount)")
                                .font(.custom("Urbanist-Bold", size: 32))
                                .foregroundColor(.textPrimary)
                            
                            Text("hatalı soru var")
                                .font(.custom("Urbanist-Medium", size: 22))
                                .foregroundColor(.textPrimary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    Divider()
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    Spacer().frame(height: 16)
                    
                    // Description
                    Text("Bu testin içerisinde şu ana kadar yaptığın tüm hatalı soruları çözebilir, yanlış yaptığın soruların doğrularını öğrenme fırsatı bulabilirsin. Sorunun doğru cevabını verdiğin takdirde hatalı sorular listesinden silinecektir.")
                        .font(.custom("Urbanist-Regular", size: 14))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Bottom button
                    if viewModel.uiState.mistakeCount > 0 {
                        Button(action: {
                            router.navigate(to: .mistakeQuestionsList)
                        }) {
                            Text("Soruları incele")
                                .font(.custom("Urbanist-Bold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.primary1)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        Text("Henüz hatalı soru yok")
                            .font(.custom("Urbanist-Medium", size: 16))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer().frame(height: 24)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            viewModel.loadMistakeCount()
        }
    }
}

// MARK: - Mistake Toolbar
struct MistakeToolbar: View {
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
            
            Image(systemName: "chevron.left")
                .font(.title3)
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    MistakeTestIntroScreen()
}
