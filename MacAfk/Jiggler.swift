import Foundation
import Combine
import IOKit.pwr_mgt

class Jiggler: ObservableObject {
    @Published var isRunning = false
    @Published var currentInterval: TimeInterval = 60 {
        didSet {
            if !isLoading {
                saveInterval()
            }
        }
    }
    
    private var assertionID: IOPMAssertionID = 0
    
    // 可选的间隔档位（秒）
    private let intervalPresets: [TimeInterval] = [10, 30, 60, 120, 300, 600]
    private var currentPresetIndex: Int = 2 {
        didSet {
            if !isLoading {
                saveInterval()
            }
        }
    }
    
    private let intervalKey = "jiggler.interval"
    private let presetIndexKey = "jiggler.presetIndex"
    private var isLoading = false
    
    init() {
        loadInterval()
    }
    
    func start() {
        // 确保在主线程上执行
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.start()
            }
            return
        }
        
        guard !isRunning else {
            print("⚠️ [Jiggler] 已经在运行中")
            return
        }
        
        print("🚀 [Jiggler] 准备启动...")
        
        // 使用 IOPMAssertion 防止系统休眠
        let reason = "AFK Lite - Prevent System Sleep" as CFString
        let assertionType = kIOPMAssertionTypePreventUserIdleSystemSleep as CFString
        
        let result = IOPMAssertionCreateWithName(
            assertionType,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        
        if result == kIOReturnSuccess {
            print("✅ [Jiggler] 防休眠断言创建成功 (ID: \(assertionID))")
            isRunning = true
        } else {
            print("❌ [Jiggler] 防休眠断言创建失败 (错误代码: \(result))")
            return
        }
        
        print("▶️ [Jiggler] 已启动防休眠模式")
    }
    
    func stop() {
        // 确保在主线程上执行
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.stop()
            }
            return
        }
        
        guard isRunning else { return }
        
        // 释放防休眠断言
        if assertionID != 0 {
            let result = IOPMAssertionRelease(assertionID)
            if result == kIOReturnSuccess {
                print("✅ [Jiggler] 防休眠断言已释放 (ID: \(assertionID))")
            } else {
                print("⚠️ [Jiggler] 释放防休眠断言失败 (错误代码: \(result))")
            }
            assertionID = 0
        }
        
        isRunning = false
        print("⏸️ [Jiggler] 已停止")
    }
    
    /// 增加抖动间隔（保留UI兼容性，但IOPMAssertion不需要间隔）
    func increaseInterval() {
        guard currentPresetIndex < intervalPresets.count - 1 else {
            print("⚠️ [Jiggler] 已达到最大间隔")
            return
        }
        
        currentPresetIndex += 1
        currentInterval = intervalPresets[currentPresetIndex]
        
        print("⬆️ [Jiggler] 间隔增加到 \(Int(currentInterval)) 秒（仅用于显示）")
    }
    
    /// 减少抖动间隔（保留UI兼容性，但IOPMAssertion不需要间隔）
    func decreaseInterval() {
        guard currentPresetIndex > 0 else {
            print("⚠️ [Jiggler] 已达到最小间隔")
            return
        }
        
        currentPresetIndex -= 1
        currentInterval = intervalPresets[currentPresetIndex]
        
        print("⬇️ [Jiggler] 间隔减少到 \(Int(currentInterval)) 秒（仅用于显示）")
    }
    
    /// 设置自定义间隔（保留UI兼容性，但IOPMAssertion不需要间隔）
    func setInterval(_ interval: TimeInterval) {
        currentInterval = interval
        
        // 更新档位索引（找最接近的）
        if let closestIndex = intervalPresets.enumerated().min(by: { abs($0.element - interval) < abs($1.element - interval) })?.offset {
            currentPresetIndex = closestIndex
        }
        
        print("🔧 [Jiggler] 间隔设置为 \(Int(currentInterval)) 秒（仅用于显示）")
    }
    
    /// 获取间隔显示字符串
    func getIntervalDisplay() -> String {
        if currentInterval < 60 {
            return "\(Int(currentInterval)) s"
        } else {
            let minutes = Int(currentInterval / 60)
            return "\(minutes) min"
        }
    }
    
    // MARK: - 持久化
    
    /// 保存间隔设置到 UserDefaults
    private func saveInterval() {
        UserDefaults.standard.set(currentInterval, forKey: intervalKey)
        UserDefaults.standard.set(currentPresetIndex, forKey: presetIndexKey)
    }
    
    /// 从 UserDefaults 加载间隔设置
    private func loadInterval() {
        isLoading = true
        defer { isLoading = false }
        
        // 尝试加载保存的间隔
        if let savedInterval = UserDefaults.standard.object(forKey: intervalKey) as? TimeInterval,
           savedInterval > 0 {
            currentInterval = savedInterval
            
            // 尝试加载保存的档位索引
            let savedIndex = UserDefaults.standard.integer(forKey: presetIndexKey)
            if savedIndex >= 0 && savedIndex < intervalPresets.count {
                currentPresetIndex = savedIndex
            } else {
                // 如果索引无效，找最接近的档位
                if let closestIndex = intervalPresets.enumerated().min(by: { abs($0.element - savedInterval) < abs($1.element - savedInterval) })?.offset {
                    currentPresetIndex = closestIndex
                }
            }
            print("📖 [Jiggler] 已加载保存的间隔: \(Int(currentInterval)) 秒 (档位: \(currentPresetIndex))")
        } else {
            // 如果没有保存的设置，使用默认值
            currentInterval = 60
            currentPresetIndex = 2
            print("ℹ️ [Jiggler] 使用默认间隔: 60 秒")
        }
    }
    
}
