//
//  TSAIChatToastView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Single-line toast, 160pt above the bottom, 1.8s (spec §2.6)
 * @chinese 单行轻提示，距底 160，停留 1.8s（规范 §2.6）
 */
@interface TSAIChatToastView : UIView

/**
 * @brief Show a toast in the given view (replaces any visible one)
 * @chinese 在指定视图中显示轻提示（替换正在显示的）
 * @param text EN: Message. CN: 文案。
 * @param view EN: Host view. CN: 宿主视图。
 */
+ (void)showText:(NSString *)text inView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
