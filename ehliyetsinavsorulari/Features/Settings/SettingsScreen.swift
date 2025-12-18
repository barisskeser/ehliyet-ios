import SwiftUI

struct SettingsScreen: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.appRouter) private var router
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Toolbar
                    SettingsToolbar(
                        title: "Ayarlar",
                        onBackTap: {
                            router.goBack()
                        }
                    )
                    
                    VStack(spacing: 16) {
                        // Premium Card (if not premium)
                        if !viewModel.uiState.isPremium {
                            PremiumCard(onTap: {
                                router.navigate(to: .paywall())
                            })
                        }
                        
                        // Exam Date Section
                        if viewModel.uiState.examDate != nil {
                            ExamCountdownCard(
                                daysUntilExam: viewModel.uiState.daysUntilExam,
                                examDate: viewModel.uiState.examDateFormatted,
                                onEditTap: {
                                    selectedDate = viewModel.uiState.examDate ?? Date()
                                    viewModel.onEditExamDateClick()
                                }
                            )
                        } else {
                            SelectExamDateCard(
                                onTap: {
                                    selectedDate = Date()
                                    viewModel.onEditExamDateClick()
                                }
                            )
                        }
                        
                        // Data Management Section
                        SectionHeader(title: "Veri Yönetimi")
                        
                        SettingsItem(
                            icon: "trash",
                            title: "Verileri temizle",
                            onTap: {
                                viewModel.onClearDataClick()
                            }
                        )
                        
                        SettingsToggleItem(
                            icon: "bell",
                            title: "Bildirimlere İzin Ver",
                            isOn: viewModel.uiState.notificationsEnabled,
                            onToggle: { enabled in
                                viewModel.toggleNotifications(enabled)
                            }
                        )
                        
                        // Social Section
                        SectionHeader(title: "Sosyal")
                        
                        SettingsItem(
                            icon: "square.and.arrow.up",
                            title: "Uygulamayı paylaş",
                            onTap: {
                                viewModel.shareApp()
                            }
                        )
                        
                        SettingsItem(
                            icon: "star",
                            title: "Bizi değerlendir",
                            onTap: {
                                viewModel.rateApp()
                            }
                        )
                        
                        SettingsItem(
                            icon: "envelope",
                            title: "Bize ulaşın",
                            onTap: {
                                viewModel.contactUs()
                            }
                        )
                        
                        Spacer().frame(height: 32)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.uiState.showDatePickerDialog) {
            DatePickerSheet(
                selectedDate: $selectedDate,
                onDismiss: {
                    viewModel.onDismissDatePicker()
                },
                onSave: {
                    viewModel.onSaveExamDate(selectedDate)
                }
            )
            .presentationDetents([.medium])
        }
        .alert("Tüm Verileri Sil", isPresented: $viewModel.uiState.showClearDataDialog) {
            Button("İptal", role: .cancel) {
                viewModel.onDismissClearDataDialog()
            }
            Button("Sil", role: .destructive) {
                viewModel.onConfirmClearData()
            }
        } message: {
            Text("Tüm test sonuçlarınız, kaydedilen sorularınız, çözülen sorularınız ve diğer verileriniz kalıcı olarak silinecektir. Bu işlem geri alınamaz.")
        }
        .alert("Bildirim İzni Gerekli", isPresented: $viewModel.uiState.showPermissionDialog) {
            Button("İptal", role: .cancel) {
                viewModel.onDismissPermissionDialog()
            }
            Button("Ayarlara Git") {
                viewModel.onOpenNotificationSettings()
            }
        } message: {
            Text("Bildirim almak için lütfen uygulama ayarlarından bildirim iznini etkinleştirin.")
        }
    }
}

// MARK: - Settings Toolbar
struct SettingsToolbar: View {
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

// MARK: - Premium Card
struct PremiumCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Premium Üyelik")
                    .font(.custom("Urbanist-Bold", size: 24))
                    .foregroundColor(Color(hex: "FF6B35"))
                
                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(text: "Sınırsız test")
                    FeatureRow(text: "Tüm Konulara Erişim")
                    FeatureRow(text: "Reklamsız deneyim")
                }
                
                Text("Şimdi Dene")
                    .font(.custom("Urbanist-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.primary1)
                    .cornerRadius(16)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "4CAF50"))
            
            Text(text)
                .font(.custom("Urbanist-Regular", size: 16))
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Exam Countdown Card
struct ExamCountdownCard: View {
    let daysUntilExam: Int
    let examDate: String
    let onEditTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(daysUntilExam) gün")
                    .font(.custom("Urbanist-Bold", size: 32))
                    .foregroundColor(.primary1)
                
                Text("Sınav Tarihi: \(examDate)")
                    .font(.custom("Urbanist-Regular", size: 14))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Button(action: onEditTap) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title)
                    .foregroundColor(.primary1)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
    }
}

// MARK: - Select Exam Date Card
struct SelectExamDateCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sınav Tarihi Belirle")
                        .font(.custom("Urbanist-Bold", size: 18))
                        .foregroundColor(.textPrimary)
                    
                    Text("Sınavına kaç gün kaldığını takip et")
                        .font(.custom("Urbanist-Regular", size: 14))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "calendar.badge.plus")
                    .font(.title)
                    .foregroundColor(.primary1)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom("Urbanist-Bold", size: 18))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Settings Item
struct SettingsItem: View {
    let icon: String
    let title: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.textPrimary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.custom("Urbanist-Medium", size: 16))
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Toggle Item
struct SettingsToggleItem: View {
    let icon: String
    let title: String
    let isOn: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.textPrimary)
                .frame(width: 24)
            
            Text(title)
                .font(.custom("Urbanist-Medium", size: 16))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { onToggle($0) }
            ))
            .tint(.primary1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(16)
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let onDismiss: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("İptal") {
                    onDismiss()
                }
                .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text("Sınav Tarihi")
                    .font(.custom("Urbanist-Bold", size: 18))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("Kaydet") {
                    onSave()
                }
                .foregroundColor(.primary1)
                .fontWeight(.bold)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "tr_TR"))
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.appBackground)
    }
}

#Preview {
    SettingsScreen()
}
