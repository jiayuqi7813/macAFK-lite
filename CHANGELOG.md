# Changelog

所有重要的项目更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### Added
- 多架构构建支持（ARM64 和 x86_64）
- Universal Binary（通用二进制）版本
- GitHub Actions CI/CD 自动化工作流
- 多语言支持（中文/英文）
- 语言设置界面
- 抖动间隔持久化保存
- 优化的构建脚本

### Changed
- 窗口默认尺寸调整为 400x700
- 间隔显示格式（使用 "s" 和 "min"）

### Fixed
- 语言管理器缺少 Combine 导入问题
- 应用重启后抖动间隔重置问题

## [1.0.0] - 2024-11-XX

### Added
- 初始版本发布
- 鼠标抖动防休眠功能
- 低亮度模式
- 自定义快捷键支持
- Pro 版本（真实硬件亮度控制）
- Lite 版本（Gamma 软件调光，App Store 兼容）
- 状态栏菜单集成
- 可调节的抖动间隔（10秒 - 10分钟）

### Security
- 无网络请求
- 本地数据存储
- 开源代码可审计

---

## 版本说明

### 版本说明
- ✅ 真实硬件亮度控制（DisplayServices API）
- ✅ 更好的省电效果
- ✅ 无沙盒限制
- ✅ 直接从 GitHub 下载
- ✅ 开源透明

---

[Unreleased]: https://github.com/yourusername/macAFK/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/macAFK/releases/tag/v1.0.0

