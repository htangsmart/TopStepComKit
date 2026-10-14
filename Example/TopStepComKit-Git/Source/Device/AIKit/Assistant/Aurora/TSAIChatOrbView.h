//
//  TSAIChatOrbView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Orb state (drives morph / spin speed and scale)
 * @chinese 光球状态（决定形变 / 旋转速度与缩放）
 */
typedef NS_ENUM(NSInteger, TSAIChatOrbState) {
    /// 常态
    TSAIChatOrbStateIdle = 0,
    /// 连接中：scale .7 α.6
    TSAIChatOrbStateConnecting,
    /// 监听：常态（涟漪由外层容器绘制）
    TSAIChatOrbStateListening,
    /// 听到了：scale 1.18，形变 1.4s
    TSAIChatOrbStateHearing,
    /// 想一想：scale .82，内层旋转 1.2s
    TSAIChatOrbStateThinking,
    /// 播放：形变 2.2s + 1s 呼吸
    TSAIChatOrbStateSpeaking,
    /// 已结束：scale .7，去色，α.5
    TSAIChatOrbStateEnded,
};

/**
 * @brief The aurora orb: conic glow, morphing gradient body and highlight
 * @chinese 极光光球：圆锥辉光 + 形变渐变球体 + 高光
 *
 * @discussion
 * [EN]: Spec §2.7. Diameter 150 renders four layers (glow / orb / conic / highlight);
 *       diameters ≤ 24 render the mini variant (conic + circle clip, 5s spin).
 * [CN]: 规范 §2.7。直径 150 渲染四层（辉光 / 球体 / 圆锥 / 高光）；
 *       直径 ≤ 24 为迷你版（圆锥 + 圆形裁剪，5s 旋转）。
 */
@interface TSAIChatOrbView : UIView

/**
 * @brief Create an orb
 * @chinese 创建光球
 * @param diameter EN: Orb diameter in points (150 / 16). CN: 光球直径（150 / 16）。
 */
- (instancetype)initWithDiameter:(CGFloat)diameter;

/** @brief Current state @chinese 当前状态 */
@property (nonatomic, assign) TSAIChatOrbState state;

/**
 * @brief Change state
 * @chinese 切换状态
 * @param state EN: New state. CN: 新状态。
 * @param animated EN: Animate scale with the .5s spring. CN: 是否以 .5s 弹性过渡缩放。
 */
- (void)setState:(TSAIChatOrbState)state animated:(BOOL)animated;

/**
 * @brief Restart looping animations (call after the view returns to a window)
 * @chinese 重启循环动画（视图回到窗口后调用）
 */
- (void)restartAnimations;

@end

NS_ASSUME_NONNULL_END
