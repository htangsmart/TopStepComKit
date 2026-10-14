//
//  TSAIChatTheme.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Conversation tone that drives the aurora background colors
 * @chinese 驱动极光背景配色的会话"气色"
 */
typedef NS_ENUM(NSInteger, TSAIChatTone) {
    /// 待输入 · 紫 (Idle · violet)
    TSAIChatToneIdle = 0,
    /// 录音 / 监听 · 蓝 (Recording / listening · blue)
    TSAIChatToneRecording,
    /// 识别 / 思考 · 琥珀 (Recognizing / thinking · amber)
    TSAIChatToneThinking,
    /// 播放 · 薄荷 (Speaking · mint)
    TSAIChatToneSpeaking,
    /// 出错 · 玫红 (Error · rose)
    TSAIChatToneError,
};

#pragma mark - 颜色

/// 主文字 #1B1740
static inline UIColor *TSAIChatInkColor(void) {
    return [UIColor colorWithRed:0x1B / 255.0 green:0x17 / 255.0 blue:0x40 / 255.0 alpha:1];
}
/// 次级文字 #5B5880
static inline UIColor *TSAIChatInk2Color(void) {
    return [UIColor colorWithRed:0x5B / 255.0 green:0x58 / 255.0 blue:0x80 / 255.0 alpha:1];
}
/// 弱文字 #9A98B8
static inline UIColor *TSAIChatInk3Color(void) {
    return [UIColor colorWithRed:0x9A / 255.0 green:0x98 / 255.0 blue:0xB8 / 255.0 alpha:1];
}
/// 主色 #7C5CFF
static inline UIColor *TSAIChatVioletColor(void) {
    return [UIColor colorWithRed:0x7C / 255.0 green:0x5C / 255.0 blue:0xFF / 255.0 alpha:1];
}
/// 天蓝 #3EA8FF
static inline UIColor *TSAIChatSkyColor(void) {
    return [UIColor colorWithRed:0x3E / 255.0 green:0xA8 / 255.0 blue:0xFF / 255.0 alpha:1];
}
/// 薄荷 #39D6B4
static inline UIColor *TSAIChatMintColor(void) {
    return [UIColor colorWithRed:0x39 / 255.0 green:0xD6 / 255.0 blue:0xB4 / 255.0 alpha:1];
}
/// 蜜桃 #FFB36B
static inline UIColor *TSAIChatPeachColor(void) {
    return [UIColor colorWithRed:0xFF / 255.0 green:0xB3 / 255.0 blue:0x6B / 255.0 alpha:1];
}
/// 玫红 #FF6B8B
static inline UIColor *TSAIChatRoseColor(void) {
    return [UIColor colorWithRed:0xFF / 255.0 green:0x6B / 255.0 blue:0x8B / 255.0 alpha:1];
}
/// 琥珀 #FFC247
static inline UIColor *TSAIChatAmberColor(void) {
    return [UIColor colorWithRed:0xFF / 255.0 green:0xC2 / 255.0 blue:0x47 / 255.0 alpha:1];
}
/// 页面底色 #F7F5FF
static inline UIColor *TSAIChatPaperColor(void) {
    return [UIColor colorWithRed:0xF7 / 255.0 green:0xF5 / 255.0 blue:0xFF / 255.0 alpha:1];
}
/// 磨砂面板底色 白 α0.72
static inline UIColor *TSAIChatGlassColor(void) {
    return [UIColor colorWithWhite:1 alpha:0.72];
}
/// 磨砂面板描边 白 α0.88
static inline UIColor *TSAIChatGlassLineColor(void) {
    return [UIColor colorWithWhite:1 alpha:0.88];
}
/// 十六进制颜色
static inline UIColor *TSAIChatHexColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1];
}

#pragma mark - 字体

/// 系统圆体
static inline UIFont *TSAIChatFont(CGFloat size, UIFontWeight weight) {
    UIFont *base = [UIFont systemFontOfSize:size weight:weight];
    UIFontDescriptor *descriptor = [base.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
    return descriptor ? [UIFont fontWithDescriptor:descriptor size:size] : base;
}

#pragma mark - 阴影

/// 卡片阴影 (0,10) blur30 #3B2E8A α.08
static inline void TSAIChatApplyCardShadow(CALayer *layer) {
    layer.shadowColor = TSAIChatHexColor(0x3B2E8A).CGColor;
    layer.shadowOpacity = 0.08;
    layer.shadowOffset = CGSizeMake(0, 10);
    layer.shadowRadius = 15;
}
/// 悬浮阴影 (0,18) blur44 #3B2E8A α.13
static inline void TSAIChatApplyFloatShadow(CALayer *layer) {
    layer.shadowColor = TSAIChatHexColor(0x3B2E8A).CGColor;
    layer.shadowOpacity = 0.13;
    layer.shadowOffset = CGSizeMake(0, 18);
    layer.shadowRadius = 22;
}

#pragma mark - 渐变

/// 主渐变 135° violet → sky
static inline CAGradientLayer *TSAIChatPrimaryGradientLayer(void) {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(id)TSAIChatVioletColor().CGColor, (id)TSAIChatSkyColor().CGColor];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1, 1);
    return layer;
}
/// 畅聊渐变 120° sky → mint
static inline CAGradientLayer *TSAIChatFlowGradientLayer(void) {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(id)TSAIChatSkyColor().CGColor, (id)TSAIChatMintColor().CGColor];
    layer.startPoint = CGPointMake(0, 0.2);
    layer.endPoint = CGPointMake(1, 0.8);
    return layer;
}
/// 取消渐变 rose → #FF9A7B
static inline CAGradientLayer *TSAIChatCancelGradientLayer(void) {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(id)TSAIChatRoseColor().CGColor, (id)TSAIChatHexColor(0xFF9A7B).CGColor];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1, 1);
    return layer;
}
/// intent 标签渐变 120° amber → peach
static inline CAGradientLayer *TSAIChatAmberTagGradientLayer(void) {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(id)TSAIChatAmberColor().CGColor, (id)TSAIChatPeachColor().CGColor];
    layer.startPoint = CGPointMake(0, 0.2);
    layer.endPoint = CGPointMake(1, 0.8);
    return layer;
}
/// intent 标签渐变 120° mint → sky
static inline CAGradientLayer *TSAIChatMintTagGradientLayer(void) {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(id)TSAIChatMintColor().CGColor, (id)TSAIChatSkyColor().CGColor];
    layer.startPoint = CGPointMake(0, 0.2);
    layer.endPoint = CGPointMake(1, 0.8);
    return layer;
}
/// 光球圆锥渐变 violet → sky → mint → peach → rose → violet
static inline CAGradientLayer *TSAIChatOrbConicGradientLayer(void) {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.type = kCAGradientLayerConic;
    layer.colors = @[(id)TSAIChatVioletColor().CGColor,
                     (id)TSAIChatSkyColor().CGColor,
                     (id)TSAIChatMintColor().CGColor,
                     (id)TSAIChatPeachColor().CGColor,
                     (id)TSAIChatRoseColor().CGColor,
                     (id)TSAIChatVioletColor().CGColor];
    layer.startPoint = CGPointMake(0.5, 0.5);
    layer.endPoint = CGPointMake(1, 0.5);
    return layer;
}

#pragma mark - 图标

/// SF Symbol 图标（统一字重）
static inline UIImage * _Nullable TSAIChatSymbol(NSString *name, CGFloat pointSize, UIImageSymbolWeight weight) {
    UIImageSymbolConfiguration *configuration =
        [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:weight];
    UIImage *image = [UIImage systemImageNamed:name withConfiguration:configuration];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

#pragma mark - 磨砂面板

/// 把 view 变成磨砂面板：glass 底色 + 模糊 + glassLine 描边
static inline void TSAIChatApplyGlass(UIView *view, CGFloat cornerRadius) {
    view.backgroundColor = TSAIChatGlassColor();
    view.layer.cornerRadius = cornerRadius;
    view.layer.cornerCurve = kCACornerCurveContinuous;
    view.layer.borderWidth = 1;
    view.layer.borderColor = TSAIChatGlassLineColor().CGColor;
}

#pragma mark - 动画

/// 弹性曲线 cubic-bezier(.22,1.3,.36,1)
static inline CAMediaTimingFunction *TSAIChatSpringTiming(void) {
    return [CAMediaTimingFunction functionWithControlPoints:0.22 :1.3 :0.36 :1];
}
/// 平滑曲线 cubic-bezier(.2,.7,.2,1)
static inline CAMediaTimingFunction *TSAIChatEaseTiming(void) {
    return [CAMediaTimingFunction functionWithControlPoints:0.2 :0.7 :0.2 :1];
}
/// 是否应停用循环动画
static inline BOOL TSAIChatReduceMotion(void) {
    return UIAccessibilityIsReduceMotionEnabled();
}
/// 弹性入场：translateY(10) scale(.92) α0 → 原位
static inline void TSAIChatPopIn(UIView *view, NSTimeInterval duration, NSTimeInterval delay) {
    if (TSAIChatReduceMotion()) {
        view.alpha = 1;
        view.transform = CGAffineTransformIdentity;
        return;
    }
    view.alpha = 0;
    view.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.92, 0.92),
                                             CGAffineTransformMakeTranslation(0, 10));
    [UIView animateWithDuration:duration
                          delay:delay
         usingSpringWithDamping:0.62
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        view.alpha = 1;
        view.transform = CGAffineTransformIdentity;
    }
                     completion:nil];
}
/// 无限旋转动画
static inline void TSAIChatAddSpin(CALayer *layer, NSTimeInterval duration) {
    [layer removeAnimationForKey:@"tsai.spin"];
    if (TSAIChatReduceMotion()) return;
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    spin.fromValue = @0;
    spin.toValue = @(M_PI * 2);
    spin.duration = duration;
    spin.repeatCount = HUGE_VALF;
    spin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [layer addAnimation:spin forKey:@"tsai.spin"];
}
/// 时长格式 mm:ss
static inline NSString *TSAIChatClockString(NSTimeInterval seconds) {
    NSInteger total = (NSInteger)MAX(0, floor(seconds));
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(total / 60), (long)(total % 60)];
}

NS_ASSUME_NONNULL_END
