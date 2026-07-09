//
//  TSAIInterpreterLanguageSheetVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Bottom-sheet style language picker
 * @chinese 底部抽屉式语言选择器
 *
 * @discussion
 * [EN]: White rounded list of language options with current selection check;
 *       Auto item carries an extra "backend detects" hint. Bottom red Cancel
 *       button dismisses without selection. Built to match the prototype's
 *       custom modal style instead of the system action sheet.
 * [CN]: 白色圆角语言列表，当前选项右侧带 √；Auto 项额外显示
 *       "backend detects" 提示。底部红色 Cancel 直接关闭。样式严格
 *       对齐原型自定义弹窗，不使用系统 ActionSheet。
 */
@interface TSAIInterpreterLanguageSheetVC : UIViewController

/**
 * @brief Initialize a language picker sheet
 * @chinese 初始化语言选择抽屉
 *
 * @param title
 * EN: Sheet title (e.g. "Select Source Language")
 * CN: 抽屉标题（如 "选择源语言"）
 *
 * @param languages
 * EN: Array of TSAILanguage values (boxed in NSNumber) to display
 * CN: 待展示的 TSAILanguage 值数组（NSNumber 包装）
 *
 * @param current
 * EN: Currently selected language (used to mark √)
 * CN: 当前选中语言（用于标 √）
 *
 * @param onPick
 * EN: Called with the picked language; sheet auto-dismisses afterwards
 * CN: 选中回调，回调后抽屉自动关闭
 *
 * @return
 * EN: A modal-presentable sheet view controller
 * CN: 可作 modal 展示的抽屉视图控制器
 */
- (instancetype)initWithTitle:(NSString *)title
                     languages:(NSArray<NSNumber *> *)languages
                       current:(TSAILanguage)current
                        onPick:(void (^)(TSAILanguage picked))onPick;

@end

NS_ASSUME_NONNULL_END
