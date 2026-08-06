//
//  TSWorkoutPushVC+Transfer.m
//  TopStepComKit_Example
//

#import "TSWorkoutPushVC+Internal.h"

@implementation TSWorkoutPushVC (Transfer)

#pragma mark - 云端下载

/** 下载云端运动，完成后交给 SDK 安装 */
- (void)installCloudResource:(TSWorkoutCloudResource *)resource toSlot:(TSWorkoutSlotModel *)slot {
    self.downloading = YES;
    self.installing = NO;
    self.operationCancelled = NO;
    self.selectedSlot = slot;
    [self showOperationWithTitle:TSLocalizedString(@"workout_push.preparing")
                          detail:[NSString stringWithFormat:TSLocalizedString(@"workout_push.cloud_to_slot"),
                                  resource.name, (long)slot.slotIndex + 1]];
    [self updateRecentTitle:TSLocalizedString(@"workout_push.preparing") detail:resource.name];

    __weak typeof(self) weakSelf = self;
    [self.cloudService downloadResource:resource completion:^(NSURL *localURL, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.downloading = NO;
        if (strongSelf.isOperationCancelled) {
            strongSelf.operationCancelled = NO;
            [strongSelf hideOperation];
            [strongSelf updateRecentTitle:TSLocalizedString(@"workout_push.cancelled")
                                   detail:TSLocalizedString(@"workout_push.slot_unchanged")];
            return;
        }
        if (error || !localURL) {
            [strongSelf hideOperation];
            [strongSelf updateRecentTitle:TSLocalizedString(@"workout_push.download_failed")
                                   detail:error.localizedDescription ?: @""];
            [strongSelf showAlertWithMsg:error.localizedDescription ?: TSLocalizedString(@"workout_push.download_failed")];
            return;
        }
        strongSelf.downloadedCloudURL = localURL;
        TSWorkoutResourceModel *workout = [[TSWorkoutResourceModel alloc] init];
        workout.path = localURL.path;
        workout.size = resource.binSize;
        workout.workoutName = resource.name;
        [strongSelf installWorkout:workout toSlot:slot];
    }];
}

#pragma mark - SDK 安装

/** 调用 SDK 将本地 bin 安装到目标槽位 */
- (void)installWorkout:(TSWorkoutResourceModel *)workout toSlot:(TSWorkoutSlotModel *)slot {
    self.installing = YES;
    self.downloading = NO;
    self.operationCancelled = NO;
    self.selectedSlot = slot;
    [self showOperationWithTitle:TSLocalizedString(@"workout_push.pushing")
                          detail:[NSString stringWithFormat:TSLocalizedString(@"workout_push.local_to_slot"),
                                  workout.workoutName ?: workout.path.lastPathComponent,
                                  (long)slot.slotIndex + 1]];
    [self updateRecentTitle:TSLocalizedString(@"workout_push.pushing")
                     detail:workout.workoutName ?: workout.path.lastPathComponent];

    NSURL *downloadedURL = self.downloadedCloudURL;
    __weak typeof(self) weakSelf = self;
    [[self workoutInterface] installWorkout:workout
                                     toSlot:slot
                                   progress:^(TSFileTransferStatus status, NSInteger progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.progressView.progress = progress / 100.f;
        strongSelf.operationDetailLabel.text = [NSString stringWithFormat:
            TSLocalizedString(@"workout_push.progress"), (long)slot.slotIndex + 1, (long)progress];
    } completion:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (downloadedURL) {
            [[NSFileManager defaultManager] removeItemAtURL:downloadedURL error:nil];
        }
        if (!strongSelf) {
            return;
        }
        BOOL wasCancelled = strongSelf.isOperationCancelled || error.code == eTSErrorUserCancelled;
        strongSelf.installing = NO;
        strongSelf.operationCancelled = NO;
        strongSelf.downloadedCloudURL = nil;
        [strongSelf hideOperation];
        if (success) {
            [strongSelf updateRecentTitle:TSLocalizedString(@"workout_push.install_success")
                                   detail:[NSString stringWithFormat:TSLocalizedString(@"workout_push.installed_slot"),
                                           workout.workoutName ?: workout.path.lastPathComponent,
                                           (long)slot.slotIndex + 1]];
            [strongSelf reloadWorkoutData];
        } else if (wasCancelled) {
            [strongSelf updateRecentTitle:TSLocalizedString(@"workout_push.cancelled")
                                   detail:TSLocalizedString(@"workout_push.slot_unchanged")];
        } else {
            [strongSelf updateRecentTitle:TSLocalizedString(@"workout_push.install_failed")
                                   detail:error.localizedDescription ?: @""];
            [strongSelf showAlertWithMsg:error.localizedDescription ?: TSLocalizedString(@"workout_push.install_failed")];
        }
    }];
}

/** 取消 Demo 下载或 SDK 安装 */
- (void)cancelButtonTapped {
    if (self.isDownloading) {
        self.operationCancelled = YES;
        [self.cloudService cancelDownload];
        self.operationDetailLabel.text = TSLocalizedString(@"workout_push.cancelling");
        return;
    }
    if (!self.isInstalling) {
        [self hideOperation];
        return;
    }
    self.operationCancelled = YES;
    self.operationDetailLabel.text = TSLocalizedString(@"workout_push.cancelling");
    __weak typeof(self) weakSelf = self;
    [[self workoutInterface] cancelWorkoutInstallation:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || success) {
            return;
        }
        strongSelf.operationCancelled = NO;
        strongSelf.operationDetailLabel.text = error.localizedDescription ?: TSLocalizedString(@"workout_push.cancel_failed");
    }];
}

@end
