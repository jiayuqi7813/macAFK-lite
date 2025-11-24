import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var appModel: AppModel
    @State private var launchAtLogin = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("settings.macafk_settings".localized)
                .font(.headline)
            
            Toggle("settings.enable_low_brightness_mode".localized, isOn: $appModel.isLowBrightness)
                .help("settings.low_brightness_mode.help".localized)
            
            Toggle("settings.launch_at_login".localized, isOn: $launchAtLogin)
                .help("settings.launch_at_login.help".localized)
                .onChange(of: launchAtLogin) { _, newValue in
                    setLaunchAtLogin(enabled: newValue)
                }
            
            Divider()
            
            Text("settings.shortcuts".localized)
                .font(.subheadline)
            Text("settings.toggle_jiggler_shortcut".localized)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
            
            Button("button.quit_macafk".localized) {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            // 读取当前的开机自启动状态
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status == .enabled {
                    print("✅ 开机自启动已启用")
                } else {
                    try SMAppService.mainApp.register()
                    print("✅ 已设置开机自启动")
                }
            } else {
                try SMAppService.mainApp.unregister()
                print("❌ 已取消开机自启动")
            }
        } catch {
            print("❗️ 设置开机自启动失败: \(error.localizedDescription)")
            // 恢复开关状态
            DispatchQueue.main.async {
                launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        }
    }
}
