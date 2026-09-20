//
//  TSAIInterpreterSettingsVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIAudioRouteConfiguration;
@class TSAIInterpreterConfig;
@class TSAILogView;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bottom-sheet settings drawer for the interpreter test page
 * @chinese 同传测试页的半屏抽屉式会话设置
 *
 * @discussion
 * [EN]: Presented modally as an iOS 15+ sheet (medium / large detent +
 *       grabber). Audio input/output routes are selected inline before the
 *       `enableVoiceOutput`, `autoPlayVoice`, and `speakerId` controls. An
 *       embedded `TSAILogView` remains available for diagnostics. The host VC
 *       passes its existing `logView` instance — the drawer reparents it for
 *       display and returns it on dismiss so the host keeps owning the
 *       buffered lines.
 * [CN]: 以 iOS 15+ sheet（medium / large detent + grabber）modal 弹出。
 *       音频输入 / 输出路由在页内直接选择，下方保留 `enableVoiceOutput`、
 *       `autoPlayVoice`、`speakerId` 控件，并内嵌 `TSAILogView` 供调试。
 *       宿主 VC 传入已有 `logView` 实例——抽屉仅在展示时 reparent，
 *       dismiss 时归还，宿主始终持有日志缓冲。
 */
@interface TSAIInterpreterSettingsVC : UIViewController

/**
 * @brief Current audio route selected for the next interpretation session
 * @chinese 下一次同传会话使用的当前音频路由
 */
@property (nonatomic, copy, readonly) TSAIAudioRouteConfiguration *audioRouteConfiguration;

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
 *       Use it to read the audio route and voice settings back into the host VC.
 * [CN]: Done 按钮和下滑关闭都会触发。用于宿主 VC 回读音频路由与语音配置。
 */
@property (nonatomic, copy, nullable) void (^onDismiss)(void);

/**
 * @brief Build a drawer from an interpreter config and an external log view
 * @chinese 使用同传配置与外部日志视图构造抽屉
 *
 * @param config
 * EN: Initial interpreter configuration copied into the form
 * CN: 拷贝到表单中的同传初始配置
 *
 * @param logView
 * EN: Host-owned log view; re-parented to this VC for display
 * CN: 宿主持有的日志视图；展示期间 reparent 到本 VC
 *
 * @return
 * EN: A configured settings VC, ready to be presented as a sheet
 * CN: 配置好的设置 VC，可作为 sheet 弹出
 */
- (instancetype)initWithConfig:(TSAIInterpreterConfig *)config
                       logView:(TSAILogView *)logView;

@end

NS_ASSUME_NONNULL_END
