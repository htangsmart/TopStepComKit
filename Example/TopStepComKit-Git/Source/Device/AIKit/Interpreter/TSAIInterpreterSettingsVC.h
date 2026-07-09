//
//  TSAIInterpreterSettingsVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAILogView;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bottom-sheet settings drawer for the interpreter test page
 * @chinese 同传测试页的半屏抽屉式会话设置
 *
 * @discussion
 * [EN]: Presented modally as an iOS 15+ sheet (medium / large detent +
 *       grabber). Three switch / pill rows for `enableVoiceOutput`,
 *       `autoPlayVoice`, `speakerId`, plus an embedded `TSAILogView`
 *       and a full-width red Done button at the bottom. The host VC
 *       passes its existing `logView` instance — the drawer reparents
 *       it for display and returns it on dismiss so the host keeps
 *       owning the buffered lines.
 * [CN]: 以 iOS 15+ sheet（medium / large detent + grabber）modal 弹出。
 *       三行 Switch / 胶囊预设分别对应 `enableVoiceOutput`、`autoPlayVoice`、
 *       `speakerId`，并内嵌一个 `TSAILogView`，底部红色全宽 Done 按钮。
 *       宿主 VC 传入已有 `logView` 实例——抽屉仅在展示时 reparent，
 *       dismiss 时归还，宿主始终持有日志缓冲。
 */
@interface TSAIInterpreterSettingsVC : UIViewController

/**
 * @brief Current value of "Voice Output (TTS)" toggle
 * @chinese 当前「TTS 译文音频」开关值
 */
@property (nonatomic, assign, readonly) BOOL enableVoiceOutput;

/**
 * @brief Current value of "Auto Play on Device" toggle
 * @chinese 当前「设备自动播放」开关值
 */
@property (nonatomic, assign, readonly) BOOL autoPlayVoice;

/**
 * @brief Current speaker id (nil = backend default)
 * @chinese 当前发音人 ID（nil = 后端默认）
 */
@property (nonatomic, copy, readonly, nullable) NSString *speakerId;

/**
 * @brief Invoked once when this VC is being dismissed
 * @chinese 抽屉 dismiss 时调用一次
 *
 * @discussion
 * [EN]: Fires both for the explicit Done button and for swipe-down dismiss.
 *       Use it to read back the three settings into the host VC.
 * [CN]: Done 按钮和下滑关闭都会触发。用于宿主 VC 把三项配置回读。
 */
@property (nonatomic, copy, nullable) void (^onDismiss)(void);

/**
 * @brief Build a drawer with initial values and an external log view
 * @chinese 用初始值与外部日志视图构造抽屉
 *
 * @param enableVoiceOutput
 * EN: Initial value for the TTS Voice Output switch
 * CN: TTS 译文音频开关初始值
 *
 * @param autoPlayVoice
 * EN: Initial value for the Auto Play switch
 * CN: 自动播放开关初始值
 *
 * @param speakerId
 * EN: Initial speaker id; nil shown as "(default)"
 * CN: 发音人 ID 初始值；nil 显示为"(默认)"
 *
 * @param logView
 * EN: Host-owned log view; re-parented to this VC for display
 * CN: 宿主持有的日志视图；展示期间 reparent 到本 VC
 *
 * @return
 * EN: A configured settings VC, ready to be presented as a sheet
 * CN: 配置好的设置 VC，可作为 sheet 弹出
 */
- (instancetype)initWithEnableVoiceOutput:(BOOL)enableVoiceOutput
                             autoPlayVoice:(BOOL)autoPlayVoice
                                 speakerId:(nullable NSString *)speakerId
                                   logView:(TSAILogView *)logView;

@end

NS_ASSUME_NONNULL_END
