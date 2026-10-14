//
//  TSAIChatAudioSheet.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSAIChatAudioPreference.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bottom sheet for pick-up / playback preference of one chat line (spec §2.8)
 * @chinese 某条对话线路的拾音与语音播放设置面板（规范 §2.8）
 *
 * @discussion
 * [EN]: Two radio groups backed by the line's `TSAIChatAudioPreference`
 *       (AI chat and AI flow keep separate selections). A tap applies
 *       immediately. In the browse style "完成" only dismisses; in the confirm
 *       style (shown before an AI flow starts) the scrim does not dismiss and
 *       "完成" dismisses and then calls `onConfirm`. Options that need a link
 *       that is down are greyed out.
 * [CN]: 两组单选，数据源为该线路的 `TSAIChatAudioPreference`（AI 对话与 AI 畅聊各存各的）；
 *       点击即生效。浏览样式下「完成」只是关闭；确认样式（AI 畅聊开始前弹出）下点遮罩不关闭，
 *       「完成」关闭后回调 `onConfirm`。依赖的链路未连接时对应选项置灰。
 */
@interface TSAIChatAudioSheet : UIView

/**
 * @brief Present in a host view (browse style)
 * @chinese 在宿主视图中弹出（浏览样式）
 * @param hostView EN: View to cover. CN: 宿主视图。
 * @param headsetConnected EN: Case BLE link state. CN: 耳机仓是否连接。
 * @param conversationMode EN: Line to edit: SingleRound = AI chat, Continuous = AI flow. CN: 要编辑的线路：SingleRound = AI 对话，Continuous = AI 畅聊。
 * @param onChange EN: Called after every change. CN: 每次更改后回调。
 */
+ (instancetype)showInView:(UIView *)hostView
          headsetConnected:(BOOL)headsetConnected
          conversationMode:(TSAIChatConversationMode)conversationMode
                  onChange:(nullable void (^)(void))onChange;

/**
 * @brief Present in a host view and wait for "完成" (confirm style)
 * @chinese 在宿主视图中弹出并等待点击「完成」（确认样式）
 * @param hostView EN: View to cover. CN: 宿主视图。
 * @param headsetConnected EN: Case BLE link state. CN: 耳机仓是否连接。
 * @param conversationMode EN: Line to edit. CN: 要编辑的线路。
 * @param onChange EN: Called after every change. CN: 每次更改后回调。
 * @param onConfirm EN: Called after "完成" dismissed the sheet. CN: 点击「完成」收起后回调。
 */
+ (instancetype)showConfirmInView:(UIView *)hostView
                 headsetConnected:(BOOL)headsetConnected
                 conversationMode:(TSAIChatConversationMode)conversationMode
                         onChange:(nullable void (^)(void))onChange
                        onConfirm:(nullable void (^)(void))onConfirm;

/**
 * @brief Refresh availability after the headset state changes
 * @chinese 耳机状态变化后刷新可用性
 */
- (void)updateHeadsetConnected:(BOOL)headsetConnected;

/** @brief Dismiss @chinese 收起 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
