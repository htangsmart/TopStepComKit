//
//  TSReminderEditorVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSRemindersModel;

@interface TSReminderEditorVC : UIViewController

/**
 * 初始化编辑器
 * @param reminder 要编辑的提醒模型（新增时传入空模板）
 * @param completion 保存或删除后的回调
 */
- (instancetype)initWithReminder:(TSRemindersModel *)reminder
                      completion:(void(^)(BOOL didSave))completion;

@end

NS_ASSUME_NONNULL_END
