//
//  TSAIChatTranscriptView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSAIChatRoundModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Flow-mode transcript: question / answer lines kept only for the session (spec §4.3)
 * @chinese 畅聊记录视图：仅会话内保留的问题 / 回答行（规范 §4.3）
 */
@interface TSAIChatTranscriptView : UIScrollView

/** @brief Status title shown when empty @chinese 空态显示的状态标题 */
@property (nonatomic, copy, nullable) NSString *emptyText;

/**
 * @brief Re-render rounds (streaming refresh keeps existing rows; new rows pop in)
 * @chinese 按轮次重绘（流式刷新复用已有行；新行弹性入场）
 * @param rounds EN: Rounds in order. CN: 按顺序的轮次。
 * @param thinking EN: Show think dots on the in-progress answer. CN: 进行中回答行显示三色点。
 */
- (void)updateWithRounds:(NSArray<TSAIChatRoundModel *> *)rounds thinking:(BOOL)thinking;

/**
 * @brief Remove all rows
 * @chinese 清空
 */
- (void)clear;

@end

NS_ASSUME_NONNULL_END
