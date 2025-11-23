import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var appModel = AppModel()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 设置应用为 accessory 类型（不显示在 Dock 栏）
        NSApp.setActivationPolicy(.accessory)
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sleep", accessibilityDescription: "MacAfk")
            button.action = #selector(toggleMenu)
        }
        
        // Create the menu
        constructMenu()
    }
    
    // 窗口关闭时不退出应用
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    @objc func toggleMenu() {
        statusItem.menu?.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        let statusTitle = appModel.isJiggling ? NSLocalizedString("menu.stop_jiggling", comment: "") : NSLocalizedString("menu.start_jiggling", comment: "")
        let toggleItem = NSMenuItem(title: statusTitle, action: #selector(toggleJiggler), keyEquivalent: "S")
        menu.addItem(toggleItem)
        
        let brightnessItem = NSMenuItem(title: NSLocalizedString("settings.low_brightness_mode", comment: ""), action: #selector(toggleBrightness), keyEquivalent: "B")
        brightnessItem.state = appModel.isLowBrightness ? .on : .off
        menu.addItem(brightnessItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("menu.show_main_window", comment: ""), action: #selector(showMainWindow), keyEquivalent: "w"))
        menu.addItem(NSMenuItem(title: NSLocalizedString("button.quit", comment: ""), action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        // Observe changes to update menu
        // In a real app we'd use Combine to update the menu item titles.
        // For now, we'll just rebuild or update on action.
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
        guard let menu = statusItem.menu else { return }
        
        menu.items[0].title = appModel.isJiggling ? NSLocalizedString("menu.stop_jiggling", comment: "") : NSLocalizedString("menu.start_jiggling", comment: "")
        menu.items[1].state = appModel.isLowBrightness ? .on : .off
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: appModel.isJiggling ? "sleep.circle.fill" : "sleep", accessibilityDescription: "MacAfk")
        }
    }
    
    
    @objc func showMainWindow() {
        // 临时切换到 regular 模式以显示窗口和 Dock 图标
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // 查找并显示主窗口
        var foundWindow = false
        for window in NSApp.windows {
            // 查找 SwiftUI 主窗口
            if window.title == "" || window.className.contains("SwiftUI") {
                window.makeKeyAndOrderFront(nil)
                window.center()
                foundWindow = true
                
                // 添加窗口关闭监听
                NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: window)
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(windowWillClose),
                    name: NSWindow.willCloseNotification,
                    object: window
                )
                break
            }
        }
        
        // 如果没找到窗口，也要尝试激活第一个窗口
        if !foundWindow, let firstWindow = NSApp.windows.first {
            firstWindow.makeKeyAndOrderFront(nil)
            firstWindow.center()
            
            NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: firstWindow)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(windowWillClose),
                name: NSWindow.willCloseNotification,
                object: firstWindow
            )
        }
    }
    
    @objc func windowWillClose(_ notification: Notification) {
        // 窗口关闭时，恢复为 accessory 模式（隐藏 Dock 图标）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
