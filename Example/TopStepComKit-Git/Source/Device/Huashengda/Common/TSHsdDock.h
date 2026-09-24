//
//  TSHsdDock.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TSHsdDockState) {
    /// 不显示（无修改）
    TSHsdDockStateHidden = 0,
    /// 有未保存的修改：左「有未保存的修改 / 保存后自动回读校验」右主按钮
    TSHsdDockStateDirty,
    /// 保存中：按钮禁用 + 菊花
    TSHsdDockStateSaving,
    /// 只写能力：左「只写能力 / 上次发送 …」右主按钮
    TSHsdDockStateWriteOnly,
    /// 未连接：只显示一枚「未连接，无法保存」胶囊
    TSHsdDockStateOffline,
};

/**
 * @brief Floating dock (.dock)
 * @chinese 浮动保存条：毛玻璃圆角条，左侧两行状态文字、右侧墨色主按钮；未连接时退化为一枚胶囊
 */
@interface TSHsdDock : UIView

@property (nonatomic, assign) TSHsdDockState state;
/// 左侧主文字（nil 用默认）
@property (nonatomic, copy, nullable) NSString *message;
/// 左侧小字
@property (nonatomic, copy, nullable) NSString *small;
/// 主按钮文字
@property (nonatomic, copy) NSString *buttonTitle;
/// 主按钮是否可用（校验不通过、0 条时禁用）
@property (nonatomic, assign) BOOL buttonEnabled;
/// 未连接胶囊文字（保存 / 发送两种）
@property (nonatomic, copy, nullable) NSString *offlineText;
@property (nonatomic, copy, nullable) void (^onTap)(void);

/// 条高（不含底部 20 + 安全区）
+ (CGFloat)barHeight;

@end

NS_ASSUME_NONNULL_END
