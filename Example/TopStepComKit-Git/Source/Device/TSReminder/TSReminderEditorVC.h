//
//  TSReminderEditorVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/24.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSRootVC.h"

NS_ASSUME_NONNULL_BEGIN

@class TSRemindersModel;

@interface TSReminderEditorVC : TSRootVC

/**
 * @brief Initialize the reminder editor
 * @chinese 初始化提醒编辑器
 *
 * @param reminder
 * EN: Reminder model to edit; pass a blank template when creating a new one
 * CN: 要编辑的提醒模型，新建时传入空模板
 *
 * @param isNew
 * EN: YES when creating a new reminder (hides the delete button); NO when editing an existing one
 * CN: YES 表示新建（隐藏删除按钮），NO 表示编辑已有提醒
 *
 * @param completion
 * EN: Called after save or delete; didSave is YES on save, NO on delete
 * CN: 保存或删除后回调，保存时 didSave 为 YES，删除时为 NO
 */
- (instancetype)initWithReminder:(TSRemindersModel *)reminder
                           isNew:(BOOL)isNew
                      completion:(void(^)(BOOL didSave))completion;

@end

NS_ASSUME_NONNULL_END
