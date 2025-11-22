import Foundation
import SwiftUI
import Combine

/// 支持的语言
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case chineseSimplified = "zh-Hans"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chineseSimplified:
            return "简体中文"
        }
    }
    
    var localizedDisplayName: String {
        switch self {
        case .english:
            return "English"
        case .chineseSimplified:
            return "简体中文"
        }
    }
}

/// 语言管理器
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            saveLanguage()
            updateBundle()
            // 发送通知，通知应用重新加载界面
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
    
    private let languageKey = "app.selectedLanguage"
    private var bundle: Bundle?
    
    private init() {
        // 从 UserDefaults 加载保存的语言
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // 如果没有保存的语言，使用系统语言
            let systemLanguage = Locale.preferredLanguages.first ?? "en"
            if systemLanguage.hasPrefix("zh") {
                self.currentLanguage = .chineseSimplified
            } else {
                self.currentLanguage = .english
            }
        }
        updateBundle()
    }
    
    /// 更新 Bundle 以使用选定的语言
    private func updateBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            self.bundle = Bundle.main
            return
        }
        self.bundle = bundle
    }
    
    /// 保存语言设置
    private func saveLanguage() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
    }
    
    /// 获取本地化字符串（使用当前选择的语言）
    func localizedString(for key: String, comment: String = "") -> String {
        if let bundle = bundle {
            return NSLocalizedString(key, bundle: bundle, comment: comment)
        }
        return NSLocalizedString(key, comment: comment)
    }
    
    /// 切换语言
    func setLanguage(_ language: AppLanguage) {
        guard currentLanguage != language else { return }
        currentLanguage = language
    }
    
    /// 获取当前语言的 Bundle
    var currentBundle: Bundle {
        return bundle ?? Bundle.main
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

/// 扩展 String 以使用 LanguageManager
extension String {
    /// 使用 LanguageManager 获取本地化字符串
    var localizedWithManager: String {
        return LanguageManager.shared.localizedString(for: self)
    }
}

