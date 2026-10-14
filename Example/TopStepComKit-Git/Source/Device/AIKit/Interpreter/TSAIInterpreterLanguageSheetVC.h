//
//  TSAIInterpreterLanguageSheetVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepAIKit/TSAIDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Full-screen language picker (the prototype's "language" screen)
 * @chinese 全屏语言选择页（原型中的「语言」屏）
 *
 * @discussion
 * [EN]: Custom top bar (back / title), a search field, "recently used"
 *       chips (last four picks, persisted in NSUserDefaults), and the full
 *       list with localized + native names and a cobalt check on the
 *       current item. Tapping a row or chip moves the selection in place;
 *       "确定" and the back button both dismiss and report the selection
 *       through `onPick` when it changed. Present it full screen.
 * [CN]: 自绘顶栏（返回 / 标题）、搜索框、「最近使用」chips（最近四次选择，
 *       存于 NSUserDefaults），以及带本地化名 + 原生名、当前项钴蓝 √ 的
 *       全部语言列表。点行或 chip 只移动选中项；「确定」与返回都会关闭页面，
 *       选择有变化时通过 `onPick` 回传。请以全屏方式 present。
 */
@interface TSAIInterpreterLanguageSheetVC : UIViewController

/**
 * @brief Initialize a language picker
 * @chinese 初始化语言选择页
 *
 * @param title
 * EN: Page title (e.g. "对方说" / "译成")
 * CN: 页面标题（如「对方说」/「译成」）
 *
 * @param languages
 * EN: Array of TSAILanguage values (boxed in NSNumber) to display
 * CN: 待展示的 TSAILanguage 值数组（NSNumber 包装）
 *
 * @param current
 * EN: Currently selected language (marked with √)
 * CN: 当前选中语言（标 √）
 *
 * @param onPick
 * EN: Called after dismiss with the final selection when it differs from `current`
 * CN: 关闭后回调最终选择，仅在与 `current` 不同时触发
 *
 * @return
 * EN: A modal-presentable view controller
 * CN: 可 modal 展示的视图控制器
 */
- (instancetype)initWithTitle:(NSString *)title
                     languages:(NSArray<NSNumber *> *)languages
                       current:(TSAILanguage)current
                        onPick:(void (^)(TSAILanguage picked))onPick;

@end

NS_ASSUME_NONNULL_END
