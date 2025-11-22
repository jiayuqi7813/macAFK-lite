import SwiftUI
import AppKit

/// 快捷键录制视图
struct ShortcutRecorderView: View {
    let action: ShortcutAction
    @Binding var isRecording: Bool
    @ObservedObject var shortcutManager: ShortcutManager
    
    @State private var recordedKeyCode: UInt16?
    @State private var recordedModifiers: NSEvent.ModifierFlags = []
    
    var body: some View {
        HStack {
            if isRecording {
                HStack {
                    Image(systemName: "keyboard.fill")
                        .foregroundColor(.red)
                    Text("shortcut.editor.recording".localized)
                        .foregroundColor(.red)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.red, lineWidth: 2)
                        )
                )
                
                Button("button.cancel".localized) {
                    isRecording = false
                }
                .buttonStyle(.bordered)
            } else {
                Button(shortcutManager.getShortcutDisplay(for: action)) {
                    isRecording = true
                    startRecording()
                }
                .font(.system(.body, design: .monospaced))
                .buttonStyle(.bordered)
            }
        }
        .onAppear {
            if isRecording {
                startRecording()
            }
        }
    }
    
    private func startRecording() {
        // 使用本地事件监听器录制快捷键
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if self.isRecording {
                self.recordedKeyCode = event.keyCode
                self.recordedModifiers = event.modifierFlags.intersection([.command, .control, .option, .shift])
                
                // 至少需要一个修饰键
                if !self.recordedModifiers.isEmpty {
                    self.shortcutManager.updateShortcut(
                        for: self.action,
                        keyCode: self.recordedKeyCode!,
                        modifiers: self.recordedModifiers
                    )
                    self.isRecording = false
                }
                
                return nil // 阻止事件传播
            }
            return event
        }
    }
}

/// 快捷键编辑器主视图
struct ShortcutEditorView: View {
    @ObservedObject var shortcutManager: ShortcutManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var recordingAction: ShortcutAction?
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("shortcut.editor.title".localized)
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
            
            // 快捷键列表
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(ShortcutAction.allCases, id: \.self) { action in
                        ShortcutEditRow(
                            action: action,
                            shortcutManager: shortcutManager,
                            isRecording: Binding(
                                get: { recordingAction == action },
                                set: { isRecording in
                                    recordingAction = isRecording ? action : nil
                                }
                            )
                        )
                    }
                }
                .padding()
            }
            
            Divider()
            
            // 底部按钮
            HStack {
                Button("button.reset_defaults".localized) {
                    shortcutManager.resetToDefaults()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("button.done".localized) {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 500, height: 400)
    }
}

/// 单个快捷键编辑行
struct ShortcutEditRow: View {
    let action: ShortcutAction
    @ObservedObject var shortcutManager: ShortcutManager
    @Binding var isRecording: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // 图标和名称
            HStack(spacing: 12) {
                Image(systemName: action.icon)
                    .foregroundColor(action.color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(action.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text(action.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 快捷键录制
            ShortcutRecorderView(
                action: action,
                isRecording: $isRecording,
                shortcutManager: shortcutManager
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

// 扩展 ShortcutAction 添加显示属性
extension ShortcutAction: CaseIterable {
    static var allCases: [ShortcutAction] {
        [.toggleJiggle, .toggleBrightness, .increaseJiggleInterval, .decreaseJiggleInterval]
    }
    
    var displayName: String {
        switch self {
        case .toggleJiggle: return "shortcut.toggle_jiggle".localized
        case .toggleBrightness: return "shortcut.toggle_brightness".localized
        case .increaseJiggleInterval: return "shortcut.increase_interval".localized
        case .decreaseJiggleInterval: return "shortcut.decrease_interval".localized
        }
    }
    
    var description: String {
        switch self {
        case .toggleJiggle: return "shortcut.toggle_jiggle.description".localized
        case .toggleBrightness: return "shortcut.toggle_brightness.description".localized
        case .increaseJiggleInterval: return "shortcut.increase_interval.description".localized
        case .decreaseJiggleInterval: return "shortcut.decrease_interval.description".localized
        }
    }
    
    var icon: String {
        switch self {
        case .toggleJiggle: return "power"
        case .toggleBrightness: return "sun.max"
        case .increaseJiggleInterval: return "arrow.up.circle"
        case .decreaseJiggleInterval: return "arrow.down.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .toggleJiggle: return .green
        case .toggleBrightness: return .orange
        case .increaseJiggleInterval: return .blue
        case .decreaseJiggleInterval: return .purple
        }
    }
}

