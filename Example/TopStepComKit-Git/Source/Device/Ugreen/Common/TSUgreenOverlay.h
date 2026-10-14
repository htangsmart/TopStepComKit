//
//  TSUgreenOverlay.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 弹窗按钮样式（原型 .alert .bs button）
typedef NS_ENUM(NSInteger, TSUgreenAlertActionStyle) {
    /// 灰底
    TSUgreenAlertActionStyleNormal = 0,
    /// 墨色主按钮
    TSUgreenAlertActionStyleStrong,
    /// 红色危险按钮
    TSUgreenAlertActionStyleDestructive,
};

/**
 * @brief Alert button
 * @chinese 弹窗按钮
 */
@interface TSUgreenAlertAction : NSObject
/// 标题
@property (nonatomic, copy, readonly) NSString *title;
/// 样式
@property (nonatomic, assign, readonly) TSUgreenAlertActionStyle style;
/// 点击回调（弹窗关闭后执行）
@property (nonatomic, copy, readonly, nullable) void (^handler)(void);
/// 创建按钮
+ (instancetype)actionWithTitle:(NSString *)title style:(TSUgreenAlertActionStyle)style handler:(nullable void (^)(void))handler;
@end

/**
 * @brief Centered alert card (.alert)
 * @chinese 居中弹窗：图标块 + 标题 + 说明 + 等宽错误码 + 一行按钮（与 HTML 原型一致）
 */
@interface TSUgreenAlertController : UIViewController
/// 创建弹窗
+ (instancetype)alertWithSymbol:(NSString *)symbol
                           tint:(UIColor *)tint
                          title:(NSString *)title
                        message:(nullable NSString *)message
                           code:(nullable NSString *)code
                        actions:(NSArray<TSUgreenAlertAction *> *)actions;
/// 从某个页面弹出
- (void)presentFrom:(UIViewController *)presenter;
@end

/**
 * @brief Blocking HUD (.hud)
 * @chinese 阻断式 HUD：转圈 + 文字 + 等宽步骤小字，覆盖整个导航容器
 */
@interface TSUgreenHUD : UIView
/// 显示
+ (instancetype)showInView:(UIView *)view text:(NSString *)text detail:(nullable NSString *)detail hue:(UIColor *)hue;
/// 更新文字
- (void)updateText:(NSString *)text detail:(nullable NSString *)detail;
/// 隐藏
- (void)dismiss;
@end

/**
 * @brief Top toast (.toast)
 * @chinese 顶部胶囊提示：左侧对勾 / 叉号圆点 + 文字，约 2.3 秒后消失
 */
@interface TSUgreenToast : NSObject
/// 显示一条提示（同一视图内只保留最新一条）
+ (void)showText:(NSString *)text bad:(BOOL)bad inView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
