import SwiftUI

struct TestsScreen: View {
    @StateObject private var viewModel = TestsViewModel()
    @Environment(\.appRouter) private var router
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                HStack {
                    Text("Testler")
                        .font(.custom("Urbanist-Bold", size: 22))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer().frame(height: 16)
                
                // Tab Navigation with Filter Button
                TabNavigationBarWithFilter(
                    selectedTabIndex: viewModel.uiState.selectedTabIndex,
                    onTabChanged: { viewModel.selectTab($0) },
                    onFilterClick: { viewModel.showFilterSheet() }
                )
                .padding(.horizontal, 16)
                
                // Active Filters Chips
                if viewModel.uiState.hasActiveFilters {
                    Spacer().frame(height: 16)
                    ActiveFiltersChips(
                        selectedCategory: viewModel.uiState.selectedCategoryFilter,
                        selectedCompletion: viewModel.uiState.selectedCompletionFilter,
                        onClearCategory: { viewModel.clearCategoryFilter() },
                        onClearCompletion: { viewModel.clearCompletionFilter() }
                    )
                }
                
                Spacer().frame(height: 16)
                
                // Test Grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(Array(viewModel.uiState.displayedTests.enumerated()), id: \.element.id) { index, test in
                            let border = viewModel.uiState.selectedTabIndex == 0 ? 1 : 0
                            let isPremiumLock = index > border && !viewModel.uiState.isPremium
                            
                            TestGridCard(
                                test: test,
                                isPremiumLock: isPremiumLock,
                                onTap: {
                                    if test.isCompleted {
                                        router.navigate(to: .quizResult(fileName: test.fileName))
                                    } else {
                                        router.navigate(to: .quizIntro(test: test))
                                    }
                                },
                                onPremiumTap: {
                                    router.navigate(to: .paywall())
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .refreshable {
            viewModel.refreshData()
        }
        .task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            viewModel.loadTestsData()
        }
        .sheet(isPresented: $viewModel.uiState.showFilterSheet) {
            FilterBottomSheet(
                selectedCategory: viewModel.uiState.tempCategoryFilter,
                selectedCompletion: viewModel.uiState.tempCompletionFilter,
                onCategoryChanged: { viewModel.setCategoryFilter($0) },
                onCompletionChanged: { viewModel.setCompletionFilter($0) },
                onDismiss: { viewModel.dismissFilterSheet() },
                onApply: { viewModel.applyFiltersFromSheet() }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Tab Navigation Bar with Filter
struct TabNavigationBarWithFilter: View {
    let selectedTabIndex: Int
    let onTabChanged: (Int) -> Void
    let onFilterClick: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Tab Container
            HStack(spacing: 4) {
                TabButton(
                    text: "Konu Testleri",
                    isSelected: selectedTabIndex == 0,
                    onClick: { onTabChanged(0) }
                )
                
                TabButton(
                    text: "Denemeler",
                    isSelected: selectedTabIndex == 1,
                    onClick: { onTabChanged(1) }
                )
            }
            .padding(4)
            .background(Color.white)
            .cornerRadius(50)
            
            // Filter Button
            Button(action: onFilterClick) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let text: String
    let isSelected: Bool
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            Text(text)
                .font(.custom("Urbanist-SemiBold", size: 14))
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isSelected ? Color.primary1 : Color.white)
                .cornerRadius(50)
        }
    }
}

// MARK: - Test Grid Card (Based on TestCard from HomeScreen)
struct TestGridCard: View {
    let test: TestUiModel
    let isPremiumLock: Bool
    let onTap: () -> Void
    var onPremiumTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            if !isPremiumLock {
                onTap()
            } else {
                onPremiumTap?()
            }
        }) {
            VStack(spacing: 8) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(
                            test.isCompleted ? Color(hex: "FFCDD2") : Color(hex: "E0E0E0"),
                            lineWidth: 6
                        )
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(test.progressValue))
                        .stroke(
                            test.isCompleted ? Color(hex: "4CAF50") : Color.primary1,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    // Category Icon
                    Image(systemName: getCategoryIcon(test.category))
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                // Title
                Text(test.title)
                    .font(.custom("Urbanist-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Stats or Progress
                if test.isCompleted {
                    HStack(spacing: 4) {
                        // Correct count
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "4CAF50"))
                                .font(.caption)
                            Text("\(test.correctAnswerCount)")
                                .font(.custom("Urbanist-Regular", size: 14))
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
                        )
                        .cornerRadius(16)
                        
                        // Wrong count
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "F44336"))
                                .font(.caption)
                            Text("\(test.wrongAnswerCount)")
                                .font(.custom("Urbanist-Regular", size: 14))
                                .foregroundColor(.textPrimary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "E0E0E0"), lineWidth: 1)
                        )
                        .cornerRadius(16)
                    }
                } else {
                    Text(
                        test.isStarted
                            ? "\(test.answeredQuestionCount)/\(test.totalQuestions) Soru"
                            : "\(test.totalQuestions) Soru"
                    )
                    .font(.custom("Urbanist-Regular", size: 14))
                    .foregroundColor(.textSecondary)
                }
                
                // Button
                Text(
                    isPremiumLock
                        ? "Premium"
                        : (test.isCompleted
                            ? "Sonuçlar"
                            : (test.isStarted ? "Devam Et" : "Başla"))
                )
                .font(.custom("Urbanist-Bold", size: 16))
                .foregroundColor(
                    isPremiumLock || test.isStarted || test.isCompleted
                        ? .white : .primary1
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    Group {
                        if isPremiumLock {
                            LinearGradient(
                                colors: [Color(hex: "FF8D28"), Color(hex: "FF2D55")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else if test.isStarted || test.isCompleted {
                            Color.primary1
                        } else {
                            Color.white
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            test.isStarted || test.isCompleted || isPremiumLock
                                ? Color.clear : Color(hex: "BDBDBD"),
                            lineWidth: 1
                        )
                )
                .cornerRadius(12)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "ilkyardim":
            return "cross.case.fill"
        case "trafik":
            return "exclamationmark.triangle.fill"
        case "trafikadabi":
            return "car.fill"
        case "motor":
            return "gear"
        default:
            return "doc.text.fill"
        }
    }
}

// MARK: - Active Filters Chips
struct ActiveFiltersChips: View {
    let selectedCategory: CategoryFilter
    let selectedCompletion: CompletionFilter
    let onClearCategory: () -> Void
    let onClearCompletion: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if selectedCategory != .all {
                    ActiveFilterChip(
                        label: selectedCategory.rawValue,
                        onClear: onClearCategory
                    )
                }
                
                if selectedCompletion != .all {
                    ActiveFilterChip(
                        label: selectedCompletion.rawValue,
                        onClear: onClearCompletion
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Active Filter Chip
struct ActiveFilterChip: View {
    let label: String
    let onClear: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.custom("Urbanist-Medium", size: 16))
                .foregroundColor(Color(hex: "082145"))
            
            Button(action: onClear) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textPrimary)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(Color(hex: "CCE7FF"))
        .cornerRadius(16)
    }
}

// MARK: - Filter Bottom Sheet
struct FilterBottomSheet: View {
    let selectedCategory: CategoryFilter
    let selectedCompletion: CompletionFilter
    let onCategoryChanged: (CategoryFilter) -> Void
    let onCompletionChanged: (CompletionFilter) -> Void
    let onDismiss: () -> Void
    let onApply: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Filtreler")
                    .font(.custom("Urbanist-Bold", size: 20))
                    .foregroundColor(.black)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 64)
            
            Spacer().frame(height: 24)
            
            // Test Konuları
            Text("Test Konuları")
                .font(.custom("Urbanist-SemiBold", size: 16))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 16)
            
            Spacer().frame(height: 12)
            
            // Category Chips - Row 1
            HStack(spacing: 8) {
                FilterChipButton(
                    label: "Tümü",
                    isSelected: selectedCategory == .all,
                    onClick: { onCategoryChanged(.all) }
                )
                
                FilterChipButton(
                    label: "İlkyardım",
                    isSelected: selectedCategory == .ilkyardim,
                    onClick: { onCategoryChanged(.ilkyardim) }
                )
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 8)
            
            // Category Chips - Row 2
            HStack(spacing: 8) {
                FilterChipButton(
                    label: "Trafik İşaretleri",
                    isSelected: selectedCategory == .trafik,
                    onClick: { onCategoryChanged(.trafik) }
                )
                
                FilterChipButton(
                    label: "Trafik ve Çevre",
                    isSelected: selectedCategory == .trafikAdabi,
                    onClick: { onCategoryChanged(.trafikAdabi) }
                )
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 8)
            
            // Category Chips - Row 3
            HStack(spacing: 8) {
                FilterChipButton(
                    label: "Motor",
                    isSelected: selectedCategory == .motor,
                    onClick: { onCategoryChanged(.motor) }
                )
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Divider
            Divider()
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
            
            // Tamamlanma Durumu
            Text("Tamamlanma Durumu")
                .font(.custom("Urbanist-SemiBold", size: 16))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 16)
            
            Spacer().frame(height: 12)
            
            // Completion Chips - Row 1
            HStack(spacing: 8) {
                FilterChipButton(
                    label: "Tümü",
                    isSelected: selectedCompletion == .all,
                    onClick: { onCompletionChanged(.all) }
                )
                
                FilterChipButton(
                    label: "Başlamadıklarım",
                    isSelected: selectedCompletion == .notStarted,
                    onClick: { onCompletionChanged(.notStarted) }
                )
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 8)
            
            // Completion Chips - Row 2
            HStack(spacing: 8) {
                FilterChipButton(
                    label: "Devam ettiklerim",
                    isSelected: selectedCompletion == .inProgress,
                    onClick: { onCompletionChanged(.inProgress) }
                )
                
                FilterChipButton(
                    label: "Tamamladıklarım",
                    isSelected: selectedCompletion == .completed,
                    onClick: { onCompletionChanged(.completed) }
                )
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 32)
            
            // Apply Button
            Button(action: onApply) {
                Text("Filtreyi Uygula")
                    .font(.custom("Urbanist-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.primary1)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            
            Spacer().frame(height: 16)
        }
        .background(Color.white)
    }
}

// MARK: - Filter Chip Button
struct FilterChipButton: View {
    let label: String
    let isSelected: Bool
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            Text(label)
                .font(.custom("Urbanist-Medium", size: 16))
                .foregroundColor(isSelected ? Color(hex: "082145") : .textPrimary)
                .padding(.horizontal, 16)
                .frame(height: 35)
                .background(isSelected ? Color(hex: "CCE7FF") : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color.primary1 : Color(hex: "BDBDBD"),
                            lineWidth: 1
                        )
                )
                .cornerRadius(16)
        }
    }
}

#Preview {
    NavigationStack {
        TestsScreen()
    }
}
