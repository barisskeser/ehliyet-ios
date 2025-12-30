import SwiftUI

// MARK: - Corner Radius System
enum CornerRadius {
    /// 4pt - Çok küçük yuvarlaklık
    static let xs: CGFloat = 4
    
    /// 8pt - Küçük yuvarlaklık
    static let sm: CGFloat = 8
    
    /// 12pt - Orta yuvarlaklık (varsayılan)
    static let md: CGFloat = 12
    
    /// 16pt - Büyük yuvarlaklık
    static let lg: CGFloat = 16
    
    /// 20pt - Çok büyük yuvarlaklık
    static let xl: CGFloat = 20
    
    /// 24pt - Ekstra büyük yuvarlaklık
    static let xxl: CGFloat = 24
    
    /// 999pt - Tam yuvarlak (pill shape)
    static let full: CGFloat = 999
}

// MARK: - Component Specific Corner Radius
extension CornerRadius {
    /// Card corner radius
    static let card: CGFloat = md
    
    /// Button corner radius
    static let button: CGFloat = lg
    
    /// TextField corner radius
    static let textField: CGFloat = sm
    
    /// Dialog/Sheet corner radius
    static let dialog: CGFloat = xl
    
    /// Chip/Tag corner radius
    static let chip: CGFloat = full
    
    /// Image corner radius
    static let image: CGFloat = md
}

// MARK: - RoundedCorner Shape (Specific corners)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - View Extension
extension View {
    /// Sadece belirli köşeleri yuvarla
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
