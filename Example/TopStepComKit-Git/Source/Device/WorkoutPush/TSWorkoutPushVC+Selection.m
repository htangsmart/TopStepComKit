//
//  TSWorkoutPushVC+Selection.m
//  TopStepComKit_Example
//

#import "TSWorkoutPushVC+Internal.h"

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation TSWorkoutPushVC (Selection)

#pragma mark - 用户选择

/** 从首屏选择云端运动 */
- (void)selectCloudResource:(TSWorkoutCloudResource *)resource {
    [self presentSlotPickerForCloudResource:resource];
}

/** 从设备槽位反向选择云端或本地资源 */
- (void)selectDeviceSlot:(TSWorkoutSlotModel *)slot {
    if (!slot.isReplaceable) {
        [self showAlertWithMsg:TSLocalizedString(@"workout_push.slot_locked")];
        return;
    }
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:
        [NSString stringWithFormat:TSLocalizedString(@"workout_push.replace_slot"), (long)slot.slotIndex + 1]
                                                                  message:TSLocalizedString(@"workout_push.choose_source")
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"workout_push.local_file")
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
        weakSelf.selectedSlot = slot;
        [weakSelf presentLocalFilePicker];
    }]];
    for (TSWorkoutCloudResource *resource in self.cloudResources) {
        [sheet addAction:[UIAlertAction actionWithTitle:resource.name
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
            [weakSelf installCloudResource:resource toSlot:slot];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [self configurePopoverForSheet:sheet sourceView:self.workoutTableView];
    [self presentViewController:sheet animated:YES completion:nil];
}

/** 选择本地运动文件 */
- (void)localFileButtonTapped {
    self.selectedSlot = nil;
    [self presentLocalFilePicker];
}

/** 展示系统文件选择器 */
- (void)presentLocalFilePicker {
    UIDocumentPickerViewController *picker = nil;
    if (@available(iOS 14.0, *)) {
        picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeData]
                                                                             asCopy:YES];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                                        inMode:UIDocumentPickerModeImport];
#pragma clang diagnostic pop
    }
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:picker animated:YES completion:nil];
}

/** 处理本地文件选择结果 */
- (void)documentPicker:(UIDocumentPickerViewController *)controller
 didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *fileURL = urls.firstObject;
    if (!fileURL || ![fileURL.pathExtension.lowercaseString isEqualToString:@"bin"]) {
        self.selectedSlot = nil;
        [self showAlertWithMsg:TSLocalizedString(@"workout_push.bin_only")];
        return;
    }
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil];
    TSWorkoutResourceModel *workout = [[TSWorkoutResourceModel alloc] init];
    workout.path = fileURL.path;
    workout.size = [attributes[NSFileSize] unsignedIntegerValue];
    workout.workoutName = fileURL.lastPathComponent.stringByDeletingPathExtension;
    TSWorkoutSlotModel *targetSlot = self.selectedSlot;
    self.selectedSlot = nil;
    if (targetSlot) {
        [self installWorkout:workout toSlot:targetSlot];
    } else {
        [self presentSlotPickerForWorkout:workout];
    }
}

/** 展示本地资源的槽位选择器 */
- (void)presentSlotPickerForWorkout:(TSWorkoutResourceModel *)workout {
    UIAlertController *sheet = [self newSlotSheetWithTitle:workout.workoutName ?: workout.path.lastPathComponent];
    __weak typeof(self) weakSelf = self;
    for (TSWorkoutSlotModel *slot in [self replaceableSlots]) {
        NSString *title = [self slotActionTitle:slot];
        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf installWorkout:workout toSlot:slot];
        }]];
    }
    [self presentSlotSheet:sheet];
}

/** 展示云端资源的槽位选择器 */
- (void)presentSlotPickerForCloudResource:(TSWorkoutCloudResource *)resource {
    UIAlertController *sheet = [self newSlotSheetWithTitle:resource.name];
    __weak typeof(self) weakSelf = self;
    for (TSWorkoutSlotModel *slot in [self replaceableSlots]) {
        NSString *title = [self slotActionTitle:slot];
        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf installCloudResource:resource toSlot:slot];
        }]];
    }
    [self presentSlotSheet:sheet];
}

#pragma mark - 私有方法

/** 返回全部可替换槽位 */
- (NSArray<TSWorkoutSlotModel *> *)replaceableSlots {
    return [self.workoutSlots filteredArrayUsingPredicate:
        [NSPredicate predicateWithBlock:^BOOL(TSWorkoutSlotModel *slot, NSDictionary *bindings) {
            return slot.isReplaceable;
        }]];
}

/** 创建槽位选择菜单 */
- (UIAlertController *)newSlotSheetWithTitle:(NSString *)title {
    return [UIAlertController alertControllerWithTitle:title
                                               message:TSLocalizedString(@"workout_push.choose_slot")
                                        preferredStyle:UIAlertControllerStyleActionSheet];
}

/** 返回槽位操作标题 */
- (NSString *)slotActionTitle:(TSWorkoutSlotModel *)slot {
    return [NSString stringWithFormat:TSLocalizedString(@"workout_push.slot_action"),
            (long)slot.slotIndex + 1, [self displayNameForSlot:slot]];
}

/** 展示槽位菜单 */
- (void)presentSlotSheet:(UIAlertController *)sheet {
    if ([self replaceableSlots].count == 0) {
        [self showAlertWithMsg:TSLocalizedString(@"workout_push.no_replaceable_slot")];
        return;
    }
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                             style:UIAlertActionStyleCancel handler:nil]];
    [self configurePopoverForSheet:sheet sourceView:self.workoutTableView];
    [self presentViewController:sheet animated:YES completion:nil];
}

/** 配置 iPad ActionSheet 锚点 */
- (void)configurePopoverForSheet:(UIAlertController *)sheet sourceView:(UIView *)sourceView {
    sheet.popoverPresentationController.sourceView = sourceView;
    sheet.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(sourceView.bounds),
                                                                 CGRectGetMidY(sourceView.bounds), 1.f, 1.f);
}

@end
