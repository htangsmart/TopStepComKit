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
/// 页面内 Toast 展示时长
static const NSTimeInterval kTSToastDisplayDuration = 2.0;
/// 全局 Toast 展示时长（跨页面提示，略长以便用户注意到）
static const NSTimeInterval kTSGlobalToastDisplayDuration = 2.5;

@implementation UIViewController (TSToast)

/// 展示短暂 Toast
- (void)ts_showToast:(NSString *)message {
    [UIViewController ts_presentToast:message inView:self.view duration:kTSToastDisplayDuration];
}

/// 在 key window 上展示全局 Toast
+ (void)ts_showGlobalToast:(NSString *)message {
    if (message.length == 0) return;
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ts_showGlobalToast:message];
        });
        return;
    }
    UIWindow *window = [self ts_activeKeyWindow];
    if (!window) return;
    [self ts_presentToast:message inView:window duration:kTSGlobalToastDisplayDuration];
}

/// 取当前前台场景的 key window，找不到时退回任意 key window
+ (UIWindow *)ts_activeKeyWindow {
    UIWindow *fallback = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        UIWindow *keyWindow = ((UIWindowScene *)scene).keyWindow;
        if (!keyWindow) continue;
        if (scene.activationState == UISceneActivationStateForegroundActive) return keyWindow;
        if (!fallback) fallback = keyWindow;
    }
    return fallback;
}

/// 在指定容器顶部居中展示胶囊 Toast，同一容器同一时刻只保留一个
+ (void)ts_presentToast:(NSString *)message inView:(UIView *)container duration:(NSTimeInterval)duration {
    if (message.length == 0 || !container) return;

    // 移除已有 Toast，保证同一时刻只有一个
    UIView *existing = [container viewWithTag:kTSToastViewTag];
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
    [container addSubview:label];

    // 计算尺寸与顶部居中位置
    CGFloat maxWidth = container.bounds.size.width - 64.f;
    CGSize textSize = [label sizeThatFits:CGSizeMake(maxWidth - 32.f, CGFLOAT_MAX)];
    CGFloat width = MIN(maxWidth, textSize.width + 32.f);
    CGFloat height = MAX(36.f, textSize.height + 18.f);
    CGFloat top = container.safeAreaInsets.top + 12.f;
    label.frame = CGRectMake((container.bounds.size.width - width) / 2.f, top, width, height);

    [UIView animateWithDuration:0.25 animations:^{
        label.alpha = 1.f;
    }];

    __weak typeof(label) weakLabel = label;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            weakLabel.alpha = 0.f;
        } completion:^(BOOL finished) {
            [weakLabel removeFromSuperview];
        }];
    });
}

@end
