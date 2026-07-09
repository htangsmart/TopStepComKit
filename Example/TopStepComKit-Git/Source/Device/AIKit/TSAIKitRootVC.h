//
//  TSAIKitRootVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI Kit test entry list
 * @chinese AI Kit 测试入口列表
 *
 * @discussion
 * [EN]: Grouped table view that lists all AI capability test screens grouped
 *       by `TopStepInterfaceKit` AI protocol — Assistant / Interpreter /
 *       Speech / Translate. Each row pushes the corresponding capability VC.
 * [CN]: Grouped 列表，按 `TopStepInterfaceKit` 的 AI 协议分组列出所有能力
 *       测试页 —— Assistant / Interpreter / Speech / Translate。点击每行
 *       推入对应的能力 VC。
 */
@interface TSAIKitRootVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
