//
//  TSEpoConsoleView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief EPO operation log type
 * @chinese EPO 操作日志类型
 */
typedef NS_ENUM(NSInteger, TSEpoLogType) {
    /** Normal info / 普通信息（蓝） */
    TSEpoLogTypeInfo = 0,
    /** Success / 成功（绿） */
    TSEpoLogTypeSuccess,
    /** Warning / 警告（橙，如 NotNecessary） */
    TSEpoLogTypeWarning,
    /** Error / 错误（红） */
    TSEpoLogTypeError,
};

/**
 * @brief EPO debug console card
 * @chinese EPO 调试日志控制台卡片
 *
 * @discussion
 * [EN]: A self-contained dark-terminal card that appends timestamped, color-coded log lines for EPO
 *       operations. Height is fixed; the host only lays out its frame and calls appendLog:type:.
 * [CN]: 自包含的深色终端卡片，为 EPO 操作追加带时间戳、按类型着色的日志行。高度固定，
 *       宿主只需布局其 frame 并调用 appendLog:type:。
 */
@interface TSEpoConsoleView : UIView

/**
 * @brief The fixed height of the console card
 * @chinese 控制台卡片的固定高度
 *
 * @return
 * EN: The height in points the host should use when laying out this card
 * CN: 宿主布局此卡片时应使用的高度（点）
 */
+ (CGFloat)cardHeight;

/**
 * @brief Append a timestamped log line
 * @chinese 追加一条带时间戳的日志
 *
 * @param message
 * EN: The log message text (timestamp is added automatically)
 * CN: 日志文本（时间戳自动添加）
 *
 * @param type
 * EN: The log type deciding the line color
 * CN: 日志类型，决定该行颜色
 */
- (void)appendLog:(NSString *)message type:(TSEpoLogType)type;

@end

NS_ASSUME_NONNULL_END
