//
//  TSContactEditVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Callback block called when the user finishes selecting contacts.
 * @chinese 用户完成选择联系人时的回调
 *
 * @param selectedContacts
 * EN: Array of selected contacts converted to TopStepContactModel.
 * CN: 用户选中的联系人数组，已转换为 TopStepContactModel。
 */
typedef void(^TSContactPickerCompletion)(NSArray<TopStepContactModel *> *selectedContacts);

/**
 * @brief Contact picker page that reads from the system address book.
 * @chinese 从系统通讯录中选择联系人的页面
 *
 * @discussion
 * EN: Displays all contacts from the system address book in a searchable list.
 *     Contacts already in `selectedContacts` are pre-checked.
 *     The right bar button "Save" highlights only when the selection changes.
 *     On save, the completion block is called with the new selection and the page pops.
 *     Pass maxSelectCount = 1 for single-select (e.g. emergency contact).
 * CN: 以可搜索列表展示系统通讯录中的所有联系人。
 *     `selectedContacts` 中已有的联系人将显示为选中状态。
 *     右上角「保存」按钮仅在选中状态发生变化时高亮。
 *     保存后回调 completion 并返回上一页。
 *     maxSelectCount = 1 时为单选模式（如紧急联系人）。
 */
@interface TSContactEditVC : UIViewController

/**
 * @brief Initialize the contact picker.
 * @chinese 初始化联系人选择页
 *
 * @param selectedContacts
 * EN: Already-selected contacts to pre-check. Matched by phone number.
 * CN: 已选中的联系人，会按电话号码匹配并显示为选中状态。
 *
 * @param maxSelectCount
 * EN: Maximum number of contacts the user can select. Pass NSIntegerMax for unlimited.
 * CN: 用户最多可选择的联系人数量，传 NSIntegerMax 表示不限。
 *
 * @param completion
 * EN: Block called on the main thread with the final selected contacts when the user saves.
 * CN: 用户保存时在主线程回调，传入最终选中的联系人数组。
 */
- (instancetype)initWithSelectedContacts:(NSArray<TopStepContactModel *> *)selectedContacts
                          maxSelectCount:(NSInteger)maxSelectCount
                              completion:(TSContactPickerCompletion)completion;

@end

NS_ASSUME_NONNULL_END
