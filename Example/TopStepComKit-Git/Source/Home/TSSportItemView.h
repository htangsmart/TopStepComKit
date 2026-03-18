//
//  TSSportItemView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSSportSummaryModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sport item view for displaying a single sport session summary
 * @chinese 运动条目视图，用于显示单条运动会话总结
 *
 * @discussion
 * [EN]: Displays sport icon, name, start time, duration, and distance/calories
 * [CN]: 显示运动图标、名称、开始时间、时长、距离/卡路里
 */
@interface TSSportItemView : UIView

/**
 * @brief Update view with sport summary data
 * @chinese 使用运动总结数据更新视图
 *
 * @param summary
 * EN: Sport session summary model to display
 * CN: 要显示的运动会话总结模型
 */
- (void)updateWithSummary:(TSSportSummaryModel *)summary;

@end

NS_ASSUME_NONNULL_END
