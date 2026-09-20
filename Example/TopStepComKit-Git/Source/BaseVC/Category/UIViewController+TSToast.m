//
//  UIViewController+TSToast.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "UIViewController+TSToast.h"

/// Toast 视图 tag，用于复用同一容器
static const NSInteger kTSToastViewTag = 90210;

@implementation UIViewController (TSToast)

/// 展示短暂 Toast
- (void)ts_showToast:(NSString *)message {
    if (message.length == 0) return;

    // 移除已有 Toast，保证同一时刻只有一个
    UIView *existing = [self.view viewWithTag:kTSToastViewTag];
    [existing removeFromSuperview];

    UILabel *label = [[UILabel alloc] init];
    label.tag = kTSToastViewTag;
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightMedium];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.78f];
    label.layer.cornerRadius = 18.f;
    label.layer.masksToBounds = YES;
    label.alpha = 0.f;
    [self.view addSubview:label];

    // 计算尺寸与顶部居中位置
    CGFloat maxWidth = self.view.bounds.size.width - 64.f;
    CGSize textSize = [label sizeThatFits:CGSizeMake(maxWidth - 32.f, CGFLOAT_MAX)];
    CGFloat width = MIN(maxWidth, textSize.width + 32.f);
    CGFloat height = MAX(36.f, textSize.height + 18.f);
    CGFloat top = self.view.safeAreaInsets.top + 12.f;
    label.frame = CGRectMake((self.view.bounds.size.width - width) / 2.f, top, width, height);

    [UIView animateWithDuration:0.25 animations:^{
        label.alpha = 1.f;
    }];

    __weak typeof(label) weakLabel = label;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            weakLabel.alpha = 0.f;
        } completion:^(BOOL finished) {
            [weakLabel removeFromSuperview];
        }];
    });
}

@end
