import SwiftUI
import ServiceManagement

struct PreferencesView: View {
    @ObservedObject var appModel: AppModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var showRestartAlert = false
    @State private var previewBrightness: Float = 0.1
    @State private var isPreviewMode = false
    @State private var launchAtLogin = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("menu.preferences".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // 设置内容
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 低亮度设置
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sun.max")
                                .foregroundColor(.orange)
                                .font(.title3)
                            
                            Text("preferences.low_brightness_settings".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // 亮度滑块
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("preferences.brightness_level".localized)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(appModel.lowBrightnessLevel * 100))%")
                                        .font(.system(.subheadline, design: .monospaced))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "sun.min")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Slider(value: $appModel.lowBrightnessLevel, in: 0.01...0.5, step: 0.01)
                                        .onChange(of: appModel.lowBrightnessLevel) { oldValue, newValue in
                                            if isPreviewMode {
                                                appModel.brightnessControl.setCustomBrightness(level: newValue)
                                            }
                                        }
                                    
                                    Image(systemName: "sun.max")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            // 快速设置按钮
                            HStack(spacing: 8) {
                                ForEach([("1%", 0.01), ("5%", 0.05), ("10%", 0.1), ("20%", 0.2), ("30%", 0.3)], id: \.0) { label, value in
                                    Button(label) {
                                        appModel.lowBrightnessLevel = Float(value)
                                        if isPreviewMode {
                                            appModel.brightnessControl.setCustomBrightness(level: Float(value))
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .tint(appModel.lowBrightnessLevel == Float(value) ? .orange : .gray)
                                }
                            }
                            
                            // 预览按钮
                            HStack {
                                Button(action: {
                                    isPreviewMode.toggle()
                                    if isPreviewMode {
                                        previewBrightness = appModel.brightnessControl.getCurrentBrightness()
                                        appModel.brightnessControl.setCustomBrightness(level: appModel.lowBrightnessLevel)
                                    } else {
                                        appModel.brightnessControl.setCustomBrightness(level: previewBrightness)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: isPreviewMode ? "eye.fill" : "eye")
                                        Text(isPreviewMode ? "preferences.stop_preview".localized : "preferences.preview_brightness".localized)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(isPreviewMode ? .red : .orange)
                                .controlSize(.regular)
                            }
                            
                            Text("preferences.brightness_hint".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 32)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                    
                    // 常规设置
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "gearshape")
                                .foregroundColor(.purple)
                                .font(.title3)
                            
                            Text("settings.macafk_settings".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("settings.launch_at_login".localized, isOn: $launchAtLogin)
                                .toggleStyle(.switch)
                                .help("settings.launch_at_login.help".localized)
                                .onChange(of: launchAtLogin) { _, newValue in
                                    setLaunchAtLogin(enabled: newValue)
                                }
                        }
                        .padding(.leading, 32)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                    
                    // 语言设置
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            Text("menu.language".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(AppLanguage.allCases, id: \.self) { language in
                                Button(action: {
                                    if languageManager.currentLanguage != language {
                                        languageManager.setLanguage(language)
                                        showRestartAlert = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: languageManager.currentLanguage == language ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(languageManager.currentLanguage == language ? .blue : .secondary)
                                        
                                        Text(language.localizedDisplayName)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(languageManager.currentLanguage == language ? Color.blue.opacity(0.1) : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.leading, 32)
                        
                        Text("menu.language.restart_required".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 32)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
                .padding()
            }
            
            Divider()
            
            // 底部按钮
            HStack {
                Spacer()
                
                Button("button.done".localized) {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 550, height: 600)
        .onAppear {
            // 读取当前的开机自启动状态
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .onDisappear {
            // 退出时如果还在预览模式，恢复亮度
            if isPreviewMode {
                appModel.brightnessControl.setCustomBrightness(level: previewBrightness)
            }
        }
        .alert("menu.language.restart_required".localized, isPresented: $showRestartAlert) {
            Button("button.done".localized) {
                showRestartAlert = false
            }
        } message: {
            Text("menu.language.restart_required".localized)
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
            print("⚠️ 设置开机自启动失败: \(error.localizedDescription)")
            // 恢复开关状态
            DispatchQueue.main.async {
                launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        }
    }
}

