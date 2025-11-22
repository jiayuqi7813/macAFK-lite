import Foundation
import SwiftUI

extension String {
    /// 本地化字符串（使用 LanguageManager）
    var localized: String {
        return LanguageManager.shared.localizedString(for: self)
    }
    
    /// 带注释的本地化字符串
    func localized(comment: String) -> String {
        return LanguageManager.shared.localizedString(for: self, comment: comment)
    }
}

