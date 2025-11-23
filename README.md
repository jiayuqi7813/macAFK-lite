# MacAfk Lite - macOS 防休眠工具

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-blue" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.0-orange" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>


**⚠️ 该版本为 appstore 上架版本，采用 _软件调光_，即使用软件为电脑增加一层遮罩以调整屏幕亮度。  
如需 _硬件调光_，请使用 **[MacAfk Pro](https://github.com/jiayuqi7813/macAFK-Pro/releases)**。**

主要是macos上架appstore有沙箱限制，无法使用硬件调光，所以使用软件调光。

>由于大多数企业电脑的 macOS 存在通过 MDM 管控禁止用户修改锁屏时间的情况，并且现在很多人都习惯将任务分配给 LLM Agent，然后自己去~~摸鱼~~。而此时电脑锁屏会影响大模型任务失败，所以开发了这款程序。

>你可以安心地打开它,它会通过鼠标细微（根本无法察觉）的抖动来防止系统进入休眠状态。



## ✨ 主要特性

### 🖱️ 防休眠功能
- **自动鼠标抖动** - 防止系统进入休眠状态
- **可调节间隔** - 10秒到10分钟，6个档位可选
- **无感操作** - 1像素移动，完全不影响工作

### 🌙 智能亮度控制
- **软件调光** - 使用 Gamma 表实现软件亮度调节，App Store 兼容
- **低亮度模式** - 一键降低屏幕亮度，保护眼睛
- **沙盒安全** - 完全符合 App Store 安全要求

### ⌨️ 强大的快捷键系统
- **全局快捷键** - 后台运行也能快速控制
- **完全自定义** - 可视化编辑器，实时录制新快捷键
- **自动保存** - 配置持久化，重启后保留

### 🎨 现代化界面
- **SwiftUI 构建** - 原生 macOS 体验
- **状态栏集成** - 轻量化，不占用 Dock 空间
- **直观操作** - 一目了然的状态显示

---

## 🚀 快速开始

### 下载安装

#### 从 GitHub 下载
```bash
# GitHub Releases 下载
https://github.com/jiayuqi7813/macAFK-lite/releases

# 或克隆源码自行编译
git clone https://github.com/jiayuqi7813/macAFK-lite.git
cd macAFK-lite
./build.sh
```

#### App Store
- App Store: 搜索 "MacAfk Lite"（即将上架）

### 首次运行

1. **授予辅助功能权限**
   - 打开「系统设置」→「隐私与安全性」→「辅助功能」
   - 添加 MacAfk Lite 并启用

2. **启动应用**
   - 点击状态栏图标
   - 或使用快捷键 `⌘ ⌃ S`

3. **开始使用**
   - 开启防休眠：点击按钮或按 `⌘ ⌃ S`
   - 启用低亮度：勾选开关或按 `⌘ ⌃ B`

---

## ⌨️ 默认快捷键

| 快捷键 | 功能 |
|--------|------|
| `⌘ ⌃ S` | 切换防休眠 |
| `⌘ ⌃ B` | 切换低亮度模式 |
| `⌘ ⌃ ↑` | 增加抖动间隔 |
| `⌘ ⌃ ↓` | 减少抖动间隔 |

**自定义快捷键**：点击主界面的「自定义所有快捷键」按钮

---

## 🔧 从源码构建

### 环境要求
- macOS 14+
- Xcode 13.0+
- Swift 5.0+

### 构建步骤

#### 快速构建
```bash
cd macAFK-lite
xcodebuild -scheme MacAfk -configuration Release-AppStore build
```

#### 使用构建脚本
```bash
# 使用自动化脚本构建 Lite 版本
./build.sh
```

---

## 🛠️ 技术架构

```
MacAfk Lite
├── AppModel.swift              # 应用状态管理
├── BrightnessControl.swift     # Gamma 表亮度控制
├── Jiggler.swift               # 鼠标抖动引擎
├── ShortcutManager.swift       # 快捷键管理系统
├── ShortcutEditorView.swift    # 快捷键编辑器
├── ContentView.swift           # 主界面
├── SettingsView.swift          # 设置界面
└── AppDelegate.swift           # 状态栏集成
```

### 核心技术
- **SwiftUI** - 现代化 UI 框架
- **CoreGraphics** - 鼠标事件模拟
- **Gamma 表** - 软件调光（App Store 兼容）
- **NSEvent** - 全局快捷键监听
- **UserDefaults** - 配置持久化

---

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

### 开发流程
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范
- 遵循 Swift 官方代码风格
- 添加必要的注释
- 更新相关文档

---

## 📝 相关文档

- [更新日志](CHANGELOG.md)

---

## ❓ 常见问题

### Q: 快捷键不工作？
A: 请确保已在「系统设置」→「隐私与安全性」→「辅助功能」中授予 MacAfk Lite 权限。

### Q: 亮度控制不起作用？
A: MacAfk Lite 使用 Gamma 调光技术，这是软件级别的调整，不会改变屏幕的实际硬件亮度。如果需要真实的硬件亮度控制，请使用系统设置。或者使用MacAfk Pro

### Q: 会影响电池续航吗？
A: 使用默认 60 秒间隔，影响极小（<0.02% CPU）。

### Q: 与 App Store 兼容吗？
A: 是的，MacAfk Lite 完全符合 App Store 的沙盒要求。

### Q: 支持外接显示器吗？
A: 主要针对主显示器进行优化。

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

---

## 💬 联系方式

- **问题反馈**: [GitHub Issues](https://github.com/jiayuqi7813/macAFK-lite/issues)
- **功能建议**: [GitHub Discussions](https://github.com/jiayuqi7813/macAFK-lite/discussions)

---

<p align="center">
  <strong>⭐️ 如果这个项目对你有帮助，请给个 Star！</strong>
</p>

<p align="center">
  Made with ❤️ for macOS users
</p>
