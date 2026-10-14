//
//  TSAIChatBannerView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Banner style
 * @chinese 横幅样式
 */
typedef NS_ENUM(NSInteger, TSAIChatBannerStyle) {
    /// 信息：ink α.94
    TSAIChatBannerStyleInfo = 0,
    /// 警告：#6B4A00 → #3A2A05
    TSAIChatBannerStyleWarn,
    /// 错误：#7A1E33 → #3A1220
    TSAIChatBannerStyleError,
};

/**
 * @brief Top banner with optional action (spec §2.5)
 * @chinese 顶部横幅，可带动作按钮（规范 §2.5）
 */
@interface TSAIChatBannerView : UIView

/**
 * @brief Show the banner
 * @chinese 显示横幅
 * @param text EN: Message. CN: 文案。
 * @param symbol EN: SF Symbol name. CN: 图标名。
 * @param style EN: Style. CN: 样式。
 * @param actionTitle EN: Optional action title. CN: 可选动作标题。
 * @param action EN: Action handler. CN: 动作回调。
 * @param duration EN: Auto-dismiss delay; 0 keeps it until dismissed. CN: 自动收起延时；0 为常驻。
 */
- (void)showText:(NSString *)text
          symbol:(NSString *)symbol
           style:(TSAIChatBannerStyle)style
     actionTitle:(nullable NSString *)actionTitle
          action:(nullable void (^)(void))action
        duration:(NSTimeInterval)duration;

/** @brief Dismiss @chinese 收起 */
- (void)dismiss;

/** @brief Whether visible @chinese 是否正在显示 */
@property (nonatomic, assign, readonly) BOOL isShowing;

@end

NS_ASSUME_NONNULL_END
