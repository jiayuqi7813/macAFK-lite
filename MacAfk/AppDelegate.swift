import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var appModel = AppModel()
    private let languageManager = LanguageManager.shared
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 初始状态：隐藏 Dock 图标，只在状态栏显示
        NSApp.setActivationPolicy(.accessory)
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = loadMenuBarIcon(isActive: false)
            button.action = #selector(toggleMenu)
        }
        
        // Create the menu
        constructMenu()
        
        // 监听窗口关闭事件，以便在窗口关闭时隐藏Dock图标
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )
        
        // 监听窗口显示事件，确保窗口显示时激活策略为regular
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
        
        // 监听语言切换事件，更新菜单
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange),
            name: .languageChanged,
            object: nil
        )
        
        // 监听 AppModel 的 isJiggling 状态变化，自动更新图标和菜单
        appModel.$isJiggling
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuBarIcon()
                    self?.updateMenuTitle()
                }
            }
            .store(in: &cancellables)
        
        // 监听 AppModel 的 isLowBrightness 状态变化，自动更新菜单
        appModel.$isLowBrightness
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateMenuTitle()
                }
            }
            .store(in: &cancellables)
    }
    
    // 关闭窗口后不退出应用，继续在后台运行
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    @objc func toggleMenu() {
        statusItem.menu?.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        let statusTitle = appModel.isJiggling ? languageManager.localizedString(for: "menu.stop_jiggling") : languageManager.localizedString(for: "menu.start_jiggling")
        let toggleItem = NSMenuItem(title: statusTitle, action: #selector(toggleJiggler), keyEquivalent: "S")
        menu.addItem(toggleItem)
        
        let brightnessItem = NSMenuItem(title: languageManager.localizedString(for: "settings.low_brightness_mode"), action: #selector(toggleBrightness), keyEquivalent: "B")
        brightnessItem.state = appModel.isLowBrightness ? .on : .off
        menu.addItem(brightnessItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: languageManager.localizedString(for: "menu.show_main_window"), action: #selector(showMainWindow), keyEquivalent: "w"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: languageManager.localizedString(for: "button.quit"), action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func toggleJiggler() {
        appModel.toggleJiggle()
        updateMenu()
    }
    
    @objc func toggleBrightness() {
        appModel.toggleBrightnessMode()
        updateMenu()
    }
    
    func updateMenu() {
        updateMenuTitle()
        updateMenuBarIcon()
    }
    
    private func updateMenuTitle() {
        guard let menu = statusItem.menu else { return }
        
        menu.items[0].title = appModel.isJiggling ? languageManager.localizedString(for: "menu.stop_jiggling") : languageManager.localizedString(for: "menu.start_jiggling")
        menu.items[1].state = appModel.isLowBrightness ? .on : .off
    }
    
    private func updateMenuBarIcon() {
        if let button = statusItem.button {
            button.image = loadMenuBarIcon(isActive: appModel.isJiggling)
        }
    }
    
    @objc func languageDidChange() {
        // 语言切换时重新构建菜单
        constructMenu()
    }
    
    
    @objc func showMainWindow() {
        // 显示窗口前，将激活策略改为 regular，以便菜单栏正常显示
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // 查找真正的应用主窗口，排除状态栏窗口和其他系统窗口
        if let mainWindow = NSApp.windows.first(where: { window in
            // 排除状态栏窗口和不能成为主窗口的窗口
            return window.canBecomeKey && !window.className.contains("StatusBar")
        }) {
            mainWindow.makeKeyAndOrderFront(nil)
            mainWindow.center()
        } else {
            // 如果没有找到现有窗口，可能需要创建一个新窗口
            print("⚠️ 未找到可显示的主窗口")
        }
    }
    
    @objc func windowDidBecomeKey(_ notification: Notification) {
        // 窗口成为主窗口时，确保激活策略为regular，以便菜单栏正常显示
        NSApp.setActivationPolicy(.regular)
    }
    
    @objc func windowWillClose(_ notification: Notification) {
        // 延迟检查，确保窗口关闭事件完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 检查是否还有可见的应用窗口（不包括菜单等系统窗口）
            let visibleWindows = NSApp.windows.filter { window in
                window.isVisible && window.canBecomeKey
            }
            
            if visibleWindows.isEmpty {
                // 所有窗口关闭后，隐藏 Dock 图标
                NSApp.setActivationPolicy(.accessory)
            }
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Menu Bar Icon
    
    private func loadMenuBarIcon(isActive: Bool) -> NSImage? {
        let iconName = isActive ? "menubar-active" : "menubar-idle"
        
        // 从 Asset Catalog 加载图标
        guard let image = NSImage(named: iconName) else {
            // 如果加载失败，使用系统图标作为后备
            print("⚠️ 无法加载图标: \(iconName)")
            return NSImage(systemSymbolName: isActive ? "sleep.circle.fill" : "sleep", accessibilityDescription: "MacAfk Pro")
        }
        
        // Asset Catalog 中已设置为 template，这里设置尺寸
        image.size = NSSize(width: 24, height: 24)
        
        return image
    }
}
