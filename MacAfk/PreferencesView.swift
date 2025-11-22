import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var showRestartAlert = false
    
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
        .frame(width: 500, height: 400)
        .alert("menu.language.restart_required".localized, isPresented: $showRestartAlert) {
            Button("button.done".localized) {
                showRestartAlert = false
            }
        } message: {
            Text("menu.language.restart_required".localized)
        }
    }
}

