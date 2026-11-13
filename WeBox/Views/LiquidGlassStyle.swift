import SwiftUI

/// Liquid Glass 适配层（Xcode 26 / iOS 26 SDK）。
///
/// 设计思路：
/// - 系统控件（TabView、导航栏、Form、搜索栏、sheet、alert）不需要任何额外代码，
///   只要用 iOS 26 SDK 构建，就会自动获得 Liquid Glass 外观。
/// - 自绘表面（卡片、胶囊、浮层、播放器控件）通过本文件的封装改用系统玻璃材质，
///   并用 `#available` 保留 iOS 17–18 的语义卡片外观，保证旧系统不崩、不丑。
/// - 刻意不写 `UIDesignRequiresCompatibility`，避免退回旧设计。

@available(iOS 26.0, *)
private func wbGlassValue(tint: Color?, interactive: Bool) -> Glass {
    var glass = Glass.regular
    if let tint { glass = glass.tint(tint) }
    if interactive { glass = glass.interactive() }
    return glass
}

extension View {
    /// 给任意形状套上玻璃表面。iOS 26 以下回落到不透明卡片色。
    @ViewBuilder
    func wbGlass<S: Shape>(
        _ shape: S,
        tint: Color? = nil,
        interactive: Bool = false,
        fallbackFill: Color? = nil
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(wbGlassValue(tint: tint, interactive: interactive), in: shape)
        } else {
            self.background(fallbackFill ?? WeBoxTheme.card, in: shape)
        }
    }

    /// 卡片默认圆角玻璃。
    func wbGlassCard(cornerRadius: CGFloat = WeBoxTheme.radius, tint: Color? = nil, interactive: Bool = false) -> some View {
        wbGlass(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous), tint: tint, interactive: interactive)
    }

    /// 胶囊玻璃，用于 chip、搜索框、工具按钮。
    func wbGlassCapsule(tint: Color? = nil, interactive: Bool = false) -> some View {
        wbGlass(Capsule(), tint: tint, interactive: interactive)
    }

    /// iOS 26 用系统玻璃按钮，旧系统继续用 bordered 系列。
    @ViewBuilder
    func wbGlassButton(prominent: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if prominent { self.buttonStyle(.glassProminent) } else { self.buttonStyle(.glass) }
        } else if prominent {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

/// 相邻玻璃元素放进同一个容器，iOS 26 会让它们在靠近时互相吸附融合。
struct WeBoxGlassGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
    }
}

/// 让玻璃有东西可以折射：系统底色 + 两团很淡的光晕。
/// 只在内容页最底层用一次，避免影响滚动性能。
struct WeBoxBackdrop: View {
    var body: some View {
        ZStack {
            WeBoxTheme.background
            RadialGradient(
                colors: [WeBoxTheme.accent.opacity(0.30), WeBoxTheme.accent.opacity(0)],
                center: .topLeading, startRadius: 0, endRadius: 520
            )
            RadialGradient(
                colors: [Color(red: 0.42, green: 0.36, blue: 0.92).opacity(0.20), Color.clear],
                center: .bottomTrailing, startRadius: 0, endRadius: 460
            )
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}
