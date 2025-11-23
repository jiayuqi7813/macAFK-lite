import Foundation
import AppKit
import CoreGraphics
import Combine

/// 亮度控制类 - Gamma 调光模式（App Store 兼容）
/// 使用 Gamma 表实现软件级别的亮度调节
/// 参考：MonitorControl Lite
class BrightnessControl: ObservableObject {
    
    private var previousBrightness: Float = 1.0  // 默认为最大亮度
    private let displayQueue: DispatchQueue
    private var hasSetBrightness = false  // 标记是否已设置过亮度
    
    // Gamma 表（App Store 兼容模式）
    private var defaultGammaTableRed: [CGGammaValue] = []
    private var defaultGammaTableGreen: [CGGammaValue] = []
    private var defaultGammaTableBlue: [CGGammaValue] = []
    
    init() {
        self.displayQueue = DispatchQueue(label: "com.macafk.lite.brightness")
        self.loadDefaultGammaTables()
    }
    
    /// 加载默认 Gamma 表（参考 MonitorControl Lite）
    private func loadDefaultGammaTables() {
        let displayID = CGMainDisplayID()
        var sampleCount: UInt32 = 0
        
        // 获取当前 Gamma 表大小
        CGGetDisplayTransferByTable(displayID, 0, nil, nil, nil, &sampleCount)
        
        if sampleCount == 0 {
            sampleCount = 256 // 默认值
        }
        
        // 读取当前 Gamma 表
        var red = [CGGammaValue](repeating: 0, count: Int(sampleCount))
        var green = [CGGammaValue](repeating: 0, count: Int(sampleCount))
        var blue = [CGGammaValue](repeating: 0, count: Int(sampleCount))
        
        CGGetDisplayTransferByTable(displayID, sampleCount, &red, &green, &blue, &sampleCount)
        
        // 保存原始表
        self.defaultGammaTableRed = red
        self.defaultGammaTableGreen = green
        self.defaultGammaTableBlue = blue
        
        print("ℹ️ [亮度控制] Gamma 表已加载（\(sampleCount) 个采样点）")
    }
    
    // MARK: - Public Methods
    
    func setLowestBrightness(level: Float = 0.1) {
        // 如果之前没有设置过亮度，保存当前值（假设为正常亮度 1.0）
        if !hasSetBrightness {
            previousBrightness = 1.0
        }
        let clampedLevel = max(min(level, 0.5), 0.01) // 限制在 0.01 到 0.5 之间
        setAppleBrightness(value: clampedLevel)
        print("🌙 [亮度控制] 已设置低亮度模式 (\(clampedLevel))，之前亮度: \(previousBrightness)")
    }
    
    func restoreBrightness() {
        setAppleBrightness(value: previousBrightness)
        print("☀️ [亮度控制] 已恢复亮度到: \(previousBrightness)")
    }
    
    /// 直接设置亮度（用于测试和手动调节）
    func setCustomBrightness(level: Float) {
        // 记录用户手动设置的亮度，作为恢复值
        previousBrightness = level
        hasSetBrightness = true
        setAppleBrightness(value: level)
    }
    
    /// 获取当前亮度（Gamma 模式下返回上次设置的值）
    func getCurrentBrightness() -> Float {
        return previousBrightness
    }
    
    // MARK: - Private Methods
    
    /// 设置亮度（使用 Gamma 调光）
    private func setAppleBrightness(value: Float) {
        let clampedValue = max(min(value, 1.0), 0.0)
        
        self.displayQueue.sync {
            self.setGammaBrightness(clampedValue)
            // 标记已设置过亮度
            self.hasSetBrightness = true
        }
    }
    
    /// 使用 Gamma 表调节亮度（App Store 兼容方案）
    /// 参考：MonitorControl Lite 实现
    private func setGammaBrightness(_ brightness: Float) {
        let displayID = CGMainDisplayID()
        
        // 将原始 Gamma 表的每个值乘以亮度系数
        let gammaTableRed = self.defaultGammaTableRed.map { $0 * brightness }
        let gammaTableGreen = self.defaultGammaTableGreen.map { $0 * brightness }
        let gammaTableBlue = self.defaultGammaTableBlue.map { $0 * brightness }
        
        // 应用调整后的 Gamma 表
        let sampleCount = UInt32(gammaTableRed.count)
        CGSetDisplayTransferByTable(displayID, sampleCount, gammaTableRed, gammaTableGreen, gammaTableBlue)
    }
}
