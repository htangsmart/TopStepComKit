//
//  TSAIChatConfigSheet.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIChatConfig;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bottom sheet to edit `TSAIChatConfig` before starting a session
 * @chinese 启动会话前编辑 `TSAIChatConfig` 的底部弹层
 *
 * @discussion
 * [EN]: Modally presents a form covering all `TSAIChatConfig` fields:
 *       language hint, agent / speaker IDs, initial prompt, voice-output and
 *       interrupt switches, VAD silence threshold, auto-end timeout. Returns
 *       the edited config via `onApply` so the host VC can pass it directly
 *       into `startChatWithConfig:`.
 * [CN]: 模态弹层，覆盖 `TSAIChatConfig` 全部字段：语言提示、Agent / Speaker
 *       ID、初始 prompt、语音输出 / 打断开关、VAD 静默阈值、超时时长。
 *       点击「应用」时通过 `onApply` 回传编辑后的配置，宿主 VC 可直接
 *       传入 `startChatWithConfig:`。
 */
@interface TSAIChatConfigSheet : UIViewController

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param config
 * EN: Initial config to populate the form; if nil, defaults are used
 * CN: 表单初始值；为 nil 时使用 `defaultConfig`
 */
- (instancetype)initWithConfig:(nullable TSAIChatConfig *)config NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                          bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 * @brief Apply callback; invoked once with the edited config
 * @chinese 应用回调；用编辑后的配置触发一次
 */
@property (nonatomic, copy, nullable) void(^onApply)(TSAIChatConfig *config);

/**
 * @brief Cancel callback; invoked once when user taps "Cancel"
 * @chinese 取消回调；用户点击「取消」时触发一次
 *
 * @discussion
 * [EN]: Fired after the sheet has finished dismissing, so the host VC can
 *       safely perform its own navigation (e.g. pop) inside the callback.
 * [CN]: 在弹层完成 dismiss 之后回调一次，宿主 VC 可在回调里安全地执行
 *       自己的导航操作（如 pop）。
 */
@property (nonatomic, copy, nullable) void(^onCancel)(void);

@end

NS_ASSUME_NONNULL_END
