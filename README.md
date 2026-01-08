# Claude Code Switcher

一个 macOS 原生应用，用于管理和切换 Claude Code 的代理配置。

## 功能特性

- **配置管理**: 添加、编辑、删除多个代理配置
- **一键切换**: 快速切换不同的代理配置
- **状态显示**: 实时显示当前激活的配置和连接状态
- **原生体验**: 使用 SwiftUI 构建的 macOS 原生应用

## 截图

应用主界面显示所有已保存的配置列表，可以：
- 点击 "Activate" 切换到指定配置
- 点击铅笔图标编辑配置
- 点击垃圾桶图标删除配置

## 系统要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本（用于构建）

## 构建方法

### 方法 1: 使用构建脚本（推荐）

```bash
# 安装 xcodegen（如果尚未安装）
brew install xcodegen

# 运行构建脚本
./build.sh
```

构建完成后，DMG 安装包位于 `build/Claude Code Switcher.dmg`

### 方法 2: 手动构建

```bash
# 1. 安装 xcodegen
brew install xcodegen

# 2. 生成 Xcode 项目
cd ClaudeCodeSwitcher
xcodegen generate

# 3. 使用 Xcode 打开并构建
open ClaudeCodeSwitcher.xcodeproj
```

## 使用方法

1. **添加配置**: 点击右下角的 "Add Configuration" 按钮
2. **填写信息**:
   - Name: 配置名称（如 "Relay 1", "Relay 2"）
   - API Key: 你的 API 密钥
   - Base URL: 代理服务器地址（如 `https://relay.nf.video`）
   - Model: 选择模型（opus/sonnet/haiku）
   - Always Thinking: 是否启用思考模式
3. **切换配置**: 在配置列表中点击 "Activate" 按钮即可切换

## 配置存储

- **应用配置**: `~/Library/Application Support/ClaudeCodeSwitcher/configs.json`
- **Claude 配置**: `~/.claude/settings.json`

## 项目结构

```
ClaudeCodeSwitcher/
├── ClaudeCodeSwitcher/
│   ├── ClaudeCodeSwitcherApp.swift  # 应用入口
│   ├── ContentView.swift            # 主界面
│   ├── ConfigEditView.swift         # 配置编辑界面
│   ├── ConfigManager.swift          # 配置管理逻辑
│   ├── Models.swift                 # 数据模型
│   ├── Info.plist                   # 应用配置
│   ├── ClaudeCodeSwitcher.entitlements
│   └── Assets.xcassets/             # 资源文件
└── project.yml                      # xcodegen 配置
```

## License

MIT License
