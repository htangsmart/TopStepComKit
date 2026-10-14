//
//  TSAIQALogSheet.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Page sheet listing the ordered question-answer callbacks
 * @chinese 按顺序展示问答回调的页面弹层
 */
@interface TSAIQALogSheet : UIViewController

/**
 * @brief Create the sheet with existing lines
 * @chinese 用已有日志行创建弹层
 *
 * @param lines
 * EN: Existing lines, oldest first
 * CN: 已有日志行，按时间正序
 *
 * @return
 * EN: A sheet ready to present
 * CN: 可直接弹出的弹层
 */
- (instancetype)initWithLines:(NSArray<NSString *> *)lines;

/**
 * @brief Append one line while presented
 * @chinese 弹层展示期间追加一行
 *
 * @param line
 * EN: Log line
 * CN: 日志行
 */
- (void)appendLine:(NSString *)line;

@end

NS_ASSUME_NONNULL_END
