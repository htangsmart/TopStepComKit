//
//  TSWorkoutPushVC+Table.m
//  TopStepComKit_Example
//

#import "TSWorkoutPushVC+Internal.h"

typedef NS_ENUM(NSInteger, TSWorkoutPushSection) {
    TSWorkoutPushSectionCloud = 0,
    TSWorkoutPushSectionDevice,
    TSWorkoutPushSectionRecent,
    TSWorkoutPushSectionCount,
};

@implementation TSWorkoutPushVC (Table)

#pragma mark - UITableViewDataSource

/** 返回页面分区数量 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TSWorkoutPushSectionCount;
}

/** 返回每个分区的行数 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == TSWorkoutPushSectionCloud) {
        return MAX(1, (NSInteger)self.cloudResources.count);
    }
    if (section == TSWorkoutPushSectionDevice) {
        return MAX(1, (NSInteger)self.workoutSlots.count);
    }
    return 1;
}

/** 返回分区标题 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == TSWorkoutPushSectionCloud) {
        return TSLocalizedString(@"workout_push.cloud_section");
    }
    if (section == TSWorkoutPushSectionDevice) {
        return TSLocalizedString(@"workout_push.device_section");
    }
    return TSLocalizedString(@"workout_push.recent_section");
}

/** 构建运动资源、设备槽位和最近操作单元格 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"WorkoutPush-%ld", (long)indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.imageView.image = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = TSColor_TextPrimary;
    cell.detailTextLabel.textColor = TSColor_TextSecondary;

    if (indexPath.section == TSWorkoutPushSectionCloud) {
        [self configureCloudCell:cell row:indexPath.row];
    } else if (indexPath.section == TSWorkoutPushSectionDevice) {
        [self configureDeviceCell:cell row:indexPath.row];
    } else {
        cell.textLabel.text = self.recentTitle;
        cell.detailTextLabel.text = self.recentDetail;
        cell.imageView.image = [UIImage systemImageNamed:@"clock.arrow.circlepath"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

/** 处理云端运动或设备槽位点击 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == TSWorkoutPushSectionCloud && indexPath.row < (NSInteger)self.cloudResources.count) {
        [self selectCloudResource:self.cloudResources[indexPath.row]];
    } else if (indexPath.section == TSWorkoutPushSectionDevice && indexPath.row < (NSInteger)self.workoutSlots.count) {
        [self selectDeviceSlot:self.workoutSlots[indexPath.row]];
    }
}

/** 返回分区底部说明 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == TSWorkoutPushSectionCloud) {
        return TSLocalizedString(@"workout_push.cloud_footer");
    }
    if (section == TSWorkoutPushSectionDevice) {
        return TSLocalizedString(@"workout_push.device_footer");
    }
    return nil;
}

#pragma mark - 私有方法

/** 配置云端运动行 */
- (void)configureCloudCell:(UITableViewCell *)cell row:(NSInteger)row {
    if (self.isCloudLoading) {
        cell.textLabel.text = TSLocalizedString(@"workout_push.loading_cloud");
        cell.detailTextLabel.text = TSLocalizedString(@"workout_push.wait");
        return;
    }
    if (self.cloudResources.count == 0) {
        cell.textLabel.text = TSLocalizedString(@"workout_push.no_cloud");
        cell.detailTextLabel.text = TSLocalizedString(@"workout_push.pull_refresh");
        return;
    }
    TSWorkoutCloudResource *resource = self.cloudResources[row];
    cell.textLabel.text = resource.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:TSLocalizedString(@"workout_push.cloud_meta"),
                                 [self formattedSize:resource.binSize]];
    cell.imageView.image = [UIImage systemImageNamed:@"figure.run.circle.fill"];
    cell.imageView.tintColor = TSColor_Primary;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
}

/** 配置设备运动槽位行 */
- (void)configureDeviceCell:(UITableViewCell *)cell row:(NSInteger)row {
    if (self.isSlotLoading) {
        cell.textLabel.text = TSLocalizedString(@"workout_push.loading_slots");
        cell.detailTextLabel.text = TSLocalizedString(@"workout_push.wait");
        return;
    }
    if (self.workoutSlots.count == 0) {
        cell.textLabel.text = TSLocalizedString(@"workout_push.no_slots");
        cell.detailTextLabel.text = TSLocalizedString(@"workout_push.check_device");
        return;
    }
    TSWorkoutSlotModel *slot = self.workoutSlots[row];
    cell.textLabel.text = [NSString stringWithFormat:TSLocalizedString(@"workout_push.slot_name"),
                           (long)slot.slotIndex + 1, [self displayNameForSlot:slot]];
    cell.detailTextLabel.text = slot.isReplaceable ? TSLocalizedString(@"workout_push.replaceable")
                                                   : TSLocalizedString(@"workout_push.built_in");
    cell.imageView.image = [UIImage systemImageNamed:slot.isReplaceable ? @"arrow.triangle.2.circlepath.circle.fill"
                                                                       : @"lock.circle.fill"];
    cell.imageView.tintColor = slot.isReplaceable ? TSColor_Success : TSColor_TextSecondary;
    cell.accessoryType = slot.isReplaceable ? UITableViewCellAccessoryDisclosureIndicator
                                            : UITableViewCellAccessoryNone;
    cell.selectionStyle = slot.isReplaceable ? UITableViewCellSelectionStyleDefault
                                             : UITableViewCellSelectionStyleNone;
}

@end
