//
//  TSAIInterpreterSettingsVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIInterpretationRequest;
@class TSAILogView;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Session info + log drawer for the interpreter test page
 * @chinese 同传测试页的会话信息与日志抽屉
 *
 * @discussion
 * [EN]: Read-only. Shows the parameters of the current (or last) session —
 *       pickup, languages, voice output, speaker — and the host's
 *       `TSAILogView`. Session parameters are chosen in
 *       `TSAIInterpreterSetupSheetVC` before start and cannot change
 *       mid-session, so this drawer no longer edits anything. The log view is
 *       re-parented for display and returned on dismiss; the host keeps the
 *       buffered lines.
 * [CN]: 只读。展示当前（或上一次）会话参数——拾音设备、语言、译文语音、发音人——
 *       以及宿主的 `TSAILogView`。会话参数在开始前由 `TSAIInterpreterSetupSheetVC`
 *       选定，中途不可修改，因此本抽屉不再编辑任何设置。日志视图展示期间
 *       reparent，dismiss 时归还，宿主始终持有日志缓冲。
 */
@interface TSAIInterpreterSettingsVC : UIViewController

/**
 * @brief Build the drawer from the session request and an external log view
 * @chinese 使用会话请求与外部日志视图构造抽屉
 *
 * @param request
 * EN: Current or last session request; nil shows placeholders
 * CN: 当前或上一次会话请求；nil 时显示占位
 *
 * @param logView
 * EN: Host-owned log view; re-parented to this VC for display
 * CN: 宿主持有的日志视图；展示期间 reparent 到本 VC
 */
- (instancetype)initWithRequest:(nullable TSAIInterpretationRequest *)request
                        logView:(TSAILogView *)logView;

@end

NS_ASSUME_NONNULL_END
