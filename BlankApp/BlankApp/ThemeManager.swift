import UIKit

enum AppTheme: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var displayName: String {
        switch self {
        case .system: return "跟随系统"
        case .light:  return "浅色"
        case .dark:   return "深色"
        }
    }

    var uiStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

final class ThemeManager {
    static let shared = ThemeManager()
    static let didChangeNotification = Notification.Name("ThemeDidChangeNotification")

    private let key = "appTheme"

    var current: AppTheme {
        get {
            AppTheme(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            apply(theme: newValue)
            NotificationCenter.default.post(name: ThemeManager.didChangeNotification, object: nil)
        }
    }

    private init() {}

    func applySavedTheme() {
        apply(theme: current)
    }

    private func apply(theme: AppTheme) {
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { $0.overrideUserInterfaceStyle = theme.uiStyle }
        }
    }
}
