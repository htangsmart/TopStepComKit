//
//  TSDialInstallSlotPicker.m
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/14.
//

#import "TSDialInstallSlotPicker.h"

// 读取表盘位或选择列表展示期间为 YES，用于忽略连续点击触发的第二次选位
static BOOL sTSDialInstallSlotPicking = NO;

@implementation TSDialInstallSlotPicker

#pragma mark - 公开方法

+ (void)pickFromViewController:(UIViewController *)viewController
                    sourceView:(nullable UIView *)sourceView
                    completion:(TSDialInstallSlotPickerCompletion)rawCompletion {
    if (!rawCompletion) {
        return;
    }
    id<TSPeripheralDialInterface> dial = [TopStepComKit sharedInstance].dial;
    if (!dial || ![dial isSupportInstallToSlot]) {
        rawCompletion(nil, NO);
        return;
    }
    if (sTSDialInstallSlotPicking) {
        rawCompletion(nil, YES);
        return;
    }
    sTSDialInstallSlotPicking = YES;
    TSDialInstallSlotPickerCompletion completion = ^(TSDialInstallOptions *options, BOOL cancelled) {
        sTSDialInstallSlotPicking = NO;
        rawCompletion(options, cancelled);
    };
    __weak UIViewController *weakController = viewController;
    __weak UIView *weakSourceView = sourceView;
    [dial fetchDialSlots:^(NSArray<TSDialSlotModel *> *_Nullable slots, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *controller = weakController;
            NSArray<TSDialSlotModel *> *installableSlots = [self installableSlotsFromSlots:slots];
            if (error || installableSlots.count == 0) {
                completion(nil, NO);
                return;
            }
            // 控制器已释放、离开窗口或正在展示其他页面时无法弹出，按取消处理
            if (!controller || controller.presentedViewController || !controller.viewIfLoaded.window) {
                completion(nil, YES);
                return;
            }
            [self presentSlots:installableSlots
                fromController:controller
                    sourceView:weakSourceView ?: controller.view
                    completion:completion];
        });
    }];
}

#pragma mark - 私有方法

// 只列出允许推送的表盘位
+ (NSArray<TSDialSlotModel *> *)installableSlotsFromSlots:(nullable NSArray<TSDialSlotModel *> *)slots {
    NSMutableArray<TSDialSlotModel *> *result = [NSMutableArray array];
    for (TSDialSlotModel *slot in slots) {
        if (slot.isInstallable) {
            [result addObject:slot];
        }
    }
    return [result copy];
}

// 弹出选位列表：自动选位在最前，指定位置会覆盖该位置上的表盘
+ (void)presentSlots:(NSArray<TSDialSlotModel *> *)slots
      fromController:(UIViewController *)controller
          sourceView:(UIView *)sourceView
          completion:(TSDialInstallSlotPickerCompletion)completion {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择安装位置"
                                                                   message:@"指定位置后会覆盖该位置上的表盘"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [sheet addAction:[UIAlertAction actionWithTitle:@"自动选择（由 SDK 决定）"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        completion(nil, NO);
    }]];
    for (TSDialSlotModel *slot in slots) {
        NSInteger slotIndex = slot.slotIndex;
        [sheet addAction:[UIAlertAction actionWithTitle:[self titleForSlot:slot]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
            completion([TSDialInstallOptions optionsWithTargetSlotIndex:slotIndex], NO);
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action) {
        completion(nil, YES);
    }]];
    sheet.popoverPresentationController.sourceView = sourceView;
    sheet.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(sourceView.bounds),
                                                                CGRectGetMidY(sourceView.bounds), 1.f, 1.f);
    [controller presentViewController:sheet animated:YES completion:nil];
    // 系统拒绝弹出（如控制器正在转场）时不会触发任何按钮，需立即回调以清除防重入标记
    if (!sheet.presentingViewController) {
        completion(nil, YES);
    }
}

// 例如：表盘位 4 · 表盘 5 · 2016 KB；表盘位 5 · 空 · 2048 KB
+ (NSString *)titleForSlot:(TSDialSlotModel *)slot {
    NSString *content = slot.isEmpty || slot.dialId.length == 0
        ? @"空"
        : [NSString stringWithFormat:@"表盘 %@", slot.dialId];
    if (slot.spaceSize == 0) {
        return [NSString stringWithFormat:@"表盘位 %ld · %@", (long)slot.slotIndex, content];
    }
    return [NSString stringWithFormat:@"表盘位 %ld · %@ · %llu KB",
            (long)slot.slotIndex, content, slot.spaceSize / 1024ULL];
}

@end
