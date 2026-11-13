# Xcode 26 / Liquid Glass 适配说明

本分支在上游 0.2.0 代码基础上做三件事：换工具链、适配 iOS 26 外观、把云编译搬到 `macos-26`。

## 1. 工具链

| 项 | 上游 | 本分支 |
| --- | --- | --- |
| Runner | `macos-15`（Xcode 16） | `macos-26`（Xcode 26） |
| SDK | iOS 18 | iOS 26（CI 断言 `--show-sdk-version` 为 `26.*`） |
| MPVKit | 固定 commit `98c3453` | `1.0.0`（`288527d`，mpv 0.41 / ffmpeg 8.1） |
| 版本号 | 0.2.0 (2) | 0.3.0 (3) |

**deployment target 仍是 iOS 17.0**，这是刻意的：

- Liquid Glass 由「用 iOS 26 SDK 构建」触发，运行在 iOS 26 设备上即生效，不需要把最低版本抬到 26。
- 抬到 26 会直接把 iOS 17/18 用户挡在门外，收益为零。
- 自绘界面用 `#available(iOS 26.0, *)` 分支，旧系统走原有语义卡片，功能与观感都不退化。

Info.plist 中没有 `UIDesignRequiresCompatibility`，所以不会退回旧设计。

## 2. 外观分层

**系统控件零代码。** `TabView`、导航栏、`Form`/`List`、`.searchable`、`sheet`、`alert` 只要有 iOS 26 SDK 就自动变成玻璃材质，包括工具条按钮的玻璃按压反馈。

**自绘表面走适配层。** 新增 `WeBox/Views/LiquidGlassStyle.swift`：

| 封装 | iOS 26 | iOS 17–18 |
| --- | --- | --- |
| `wbGlass(_:tint:interactive:)` | `glassEffect(glass, in: shape)` | `background(fallbackFill, in: shape)` |
| `wbGlassCard(cornerRadius:)` | 圆角玻璃卡片 | 原 `WeBoxTheme.card` |
| `wbGlassCapsule(tint:)` | 胶囊玻璃（chip / 工具按钮） | 原胶囊底色 |
| `wbGlassButton(prominent:)` | `.buttonStyle(.glass)` / `.glassProminent` | `.bordered` / `.borderedProminent` |
| `WeBoxGlassGroup` | `GlassEffectContainer`（相邻玻璃互相吸附融合） | 直接透传内容 |

应用位置：

- 发现页：顶部「+」按钮、搜索框、内容源 chip 组、继续观看卡片。
- 浏览 / 详情页：模块 chip 组、加载更多、收藏、「立即播放」（glassProminent）、播放线路容器、错误提示卡片。
- 播放器：右上设置按钮、mpv 控制行、错误横幅（黑色半透明玻璃，避免压在视频上刺眼）。
- 导入 / 源管理：导入进度浮层。
- 标签栏：`tabBarMinimizeBehavior(.onScrollDown)`，下滑时收起、回滚时展开。

**背景。** `WeBoxBackdrop` 在系统底色上叠两团很淡的径向光晕，给玻璃提供可折射的内容。没有它，纯色背景上的玻璃会显得发灰、像半透明塑料。

## 3. 有意没做的事

- 没给海报网格、选集宫格逐格加玻璃：几十个玻璃图层会掉帧，且视觉噪声大。密集网格继续用扁平卡片。
- 没用 `.backgroundExtensionEffect()` 让内容穿到导航栏下：这个 App 的详情页顶部是海报，穿过去可读性会变差。
- 没引入 `MeshGradient`（iOS 18+）做动态背景：会额外抬高最低版本，收益不抵成本。

## 4. CI 产出

`Build iOS (Xcode 26 · Liquid Glass)` 工作流：

1. 选最新的 `/Applications/Xcode*.app`，打印 `xcodebuild -version` 与 iPhoneOS SDK，SDK 不是 26.x 直接失败。
2. `xcodegen generate` → 缓存 `build/SPM`（MPVKit 二进制，避免每次重下几百 MB）。
3. 模拟器跑 `WeBoxTests`，再截一张启动图（新增的玻璃外观肉眼可见）。
4. `archive` → 组 `Payload` → `WeBox-unsigned.ipa`。
5. 输出 `evidence.md`：Xcode 版本、`DTSDKName`、`MinimumOSVersion`、`LC_BUILD_VERSION`、体积、架构。
6. 打 `v*` tag 时自动发 Release，免登录直接下 IPA。
