# WeBox for iOS · Xcode 26 / Liquid Glass 分支

本仓库 fork 自 [zhangx16/WeBox-for-IOS](https://github.com/zhangx16/WeBox-for-IOS)，在原项目基础上改用 **Xcode 26 + iOS 26 SDK** 云编译，并完成 Liquid Glass 适配。上游实现说明见文末「分析来源与许可」，代码版权归属不变（GPL-3.0）。

基于本机 WeBox Android 0.1.64（versionCode 67）静态分析实现的 iOS 原生移植预览版。SwiftUI + JavaScriptCore + AVPlayer，最低 iOS 17，支持 iPhone / iPad。

当前版本 0.3.0 在 0.2.0 基础上适配 iOS 26 Liquid Glass 外观：用 iOS 26 SDK 构建后系统控件（标签栏、导航栏、表单、搜索栏、弹窗）自动采用新材质，自绘卡片 / 胶囊 / 播放器浮层改为系统玻璃材质，iOS 17–18 保持原有语义卡片外观。工程同时把 MPVKit 升级到 1.0.0（mpv 0.41 / ffmpeg 8.1）以适配 Xcode 26 工具链。

0.2.0 新增独立 JS/WASM 计算、RSA/AES-GCM、二进制缓冲、内存 HLS 与媒体处理代理、mpv 引擎、HLS 离线包、REXENC 认证取钥、订阅、M3U/AppleCMS、Android 备份和 TMDB；重新设计发现、全局搜索与源管理界面。

三个用户提供的 JS 源作为测试夹具回归验证，不预装站点。完整能力与验证边界见 [0.2 兼容说明](docs/COMPATIBILITY-0.2.md)。界面离线预览见 [preview.html](docs/ui-draft/preview.html)。

## 获取 IPA

优先从 [Releases](https://github.com/zrtnb6/WeBox-iOS-XC26/releases) 下载对应版本 IPA（打 `v*` tag 时自动发布）。也可以进入 [GitHub Actions](https://github.com/zrtnb6/WeBox-iOS-XC26/actions/workflows/ios.yml)，打开最近成功的 `Build iOS (Xcode 26 · Liquid Glass)`，下载 `WeBox-iOS-unsigned`，解压取得 `WeBox-unsigned.ipa`；同一 artifact 里的 `evidence.md` 记录了 Xcode 版本、`DTSDKName`、`MinimumOSVersion`、体积与架构。

**这是未签名 IPA，不能直接安装到普通 iPhone。** 请使用自己的开发者证书 / 侧载工具签名后安装，或用 Xcode 选择自己的 Team 构建。仓库不包含签名证书，不提供已签名安装包。GitHub Artifact 下载需要登录，保留 30 天；可手动重新运行工作流生成。

## 本地构建

需要 macOS、Xcode 26+（iOS 26 SDK）、XcodeGen：

```sh
brew install xcodegen
xcodegen generate
open WeBox.xcodeproj
```

选择 WeBox scheme，在 Signing & Capabilities 中设置自己的 Team 和唯一 Bundle Identifier，然后运行。模拟器不需要开发者证书。测试目标 `WeBoxTests` 覆盖内置示例、WeBox 原生协议、XPTV、存储、HTML、加密、异常传播及备份。

CI 在 `macos-26` 上生成工程，会先断言 `xcrun --sdk iphoneos --show-sdk-version` 为 26.x，再跑 iOS 模拟器测试、archive iPhone App、打包未签名 IPA，最后输出构建证据并上传 artifact。Linux / Windows 不能运行 Xcode；编译结果以 CI 为准。

适配细节与取舍见 [Xcode 26 / Liquid Glass 适配说明](docs/XC26-LIQUID-GLASS.md)。

## 分析来源与许可

APK SHA-256：`3471efd5adf82ade673532f82f5d024cbc76a611a9f20fcc3bcb82be33e7891b`。

使用 [REA](https://github.com/morluto/rea) 6.7.0 与固定摘要的 JADX headless 0.7.1 静态分析；未执行 Android App。只提交移植代码和需用的 JS 运行资源，不提交 APK、反编译 Java 全量或本机凭证。来源与摘要见 [分析记录](docs/REVERSE_ENGINEERING.md)。

本项目按 [GPL-3.0](LICENSE) 发布。APK 内提供 GPL-3.0 文本；复用其运行库和演示脚本的版权归原作者。第三方 JS 依赖声明见 [web-licenses.txt](WeBox/Resources/Runtime/web-licenses.txt)。Android App 顶层具体授权与上游源码地址仍待确认；发布至 App Store 或其他渠道前应核实原作者授权及 GPL 对应源码要求。
