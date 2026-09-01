//
//  TSTemperatureVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/4/23.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSTemperatureVC.h"

@interface TSTemperatureVC ()

@end

@implementation TSTemperatureVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Public Methods

- (NSArray *)sourceArray {
    NSString *syncTitle = TSLocalizedString(@"temp.sync_data");
    return @[
        [TSValueModel valueWithName:[NSString stringWithFormat:@"%@ (Raw)", syncTitle]],
        [TSValueModel valueWithName:[NSString stringWithFormat:@"%@ (Raw, Auto Only)", syncTitle]],
        [TSValueModel valueWithName:[NSString stringWithFormat:@"%@ (Daily)", syncTitle]],

        [TSValueModel valueWithName:TSLocalizedString(@"temp.get_monitor_config")],
        [TSValueModel valueWithName:TSLocalizedString(@"temp.set_monitor_config")],
        
        [TSValueModel valueWithName:TSLocalizedString(@"temp.start_measure")],
        [TSValueModel valueWithName:TSLocalizedString(@"temp.stop_measure")]
    ];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self syncRawValue];
    } else if (indexPath.row == 1) {
        [self syncAutomaticRawValue];
    } else if (indexPath.row == 2) {
        [self syncDailyValue];
    } else if (indexPath.row == 3) {
        [self queryAutoMonitorConfigs];
    } else if (indexPath.row == 4) {
        [self setAutoMonitorConfigs];
    } else if (indexPath.row == 5) {
        [self startActivityMeasure];
    } else if (indexPath.row == 6) {
        [self stopActivityMeasure];
    }
}

#pragma mark - Data Sync

- (void)syncRawValue {
    NSTimeInterval endTime = NSDate.date.timeIntervalSince1970;
    NSTimeInterval startTime = endTime - 7 * 24 * 60 * 60;
    [[[TopStepComKit sharedInstance] temperature]
     syncRawDataFromStartTime:startTime
     endTime:endTime
     completion:^(NSArray<TSTempValueItem *> * _Nullable tempItems, NSError * _Nullable error) {
        TSLog(@"[TemperatureDemo] raw sync count: %lu", (unsigned long)tempItems.count);
        for (TSTempValueItem *tempValue in tempItems) {
            TSLog(@"[TemperatureDemo] raw item: %@", tempValue.debugDescription);
        }
        if (error) {
            TSLog(@"[TemperatureDemo] raw sync partial/failure: %@", error.localizedDescription);
        }
    }];
}

- (void)syncAutomaticRawValue {
    NSTimeInterval endTime = NSDate.date.timeIntervalSince1970;
    NSTimeInterval startTime = endTime - 7 * 24 * 60 * 60;
    TSDataSyncConfig *config = [TSDataSyncConfig configForRawDataWithOptions:TSDataSyncOptionTemperature
                                                                  startTime:startTime
                                                                    endTime:endTime];
    config.includeUserInitiated = NO;
    [[[TopStepComKit sharedInstance] dataSync]
     syncDataWithConfig:config
     onHealthData:nil
     completion:^(NSArray<TSHealthData *> * _Nullable results, NSError * _Nullable error) {
        TSHealthData *temperatureData = [TSHealthData findHealthDataWithOption:TSDataSyncOptionTemperature
                                                                     fromArray:results];
        TSLog(@"[TemperatureDemo] automatic raw sync count: %lu", (unsigned long)temperatureData.healthValues.count);
        for (TSTempValueItem *tempValue in temperatureData.healthValues) {
            TSLog(@"[TemperatureDemo] automatic raw item: %@", tempValue.debugDescription);
        }
        NSError *syncError = error ?: temperatureData.fetchError;
        if (syncError) {
            TSLog(@"[TemperatureDemo] automatic raw sync partial/failure: %@",
                  syncError.localizedDescription);
        }
    }];
}

- (void)syncDailyValue {
    NSTimeInterval endTime = NSDate.date.timeIntervalSince1970;
    NSTimeInterval startTime = endTime - 7 * 24 * 60 * 60;
    [[[TopStepComKit sharedInstance] temperature]
     syncDailyDataFromStartTime:startTime
     endTime:endTime
     completion:^(NSArray<TSTempDailyModel *> * _Nullable dailyModels, NSError * _Nullable error) {
        TSLog(@"[TemperatureDemo] daily sync count: %lu", (unsigned long)dailyModels.count);
        for (TSTempDailyModel *dailyModel in dailyModels) {
            TSLog(@"[TemperatureDemo] daily item: %@", dailyModel.debugDescription);
        }
        if (error) {
            TSLog(@"[TemperatureDemo] daily sync partial/failure: %@", error.localizedDescription);
        }
    }];
}

#pragma mark - Monitor Configuration

- (void)queryAutoMonitorConfigs {
    [[[TopStepComKit sharedInstance] temperature] fetchAutoMonitorConfigsWithCompletion:^(TSAutoMonitorConfigs * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            TSLog(@"[TemperatureDemo] fetch monitor config failed: %@", error.localizedDescription);
            return;
        }
        TSLog(@"[TemperatureDemo] monitor config: %@", configuration.debugDescription);
    }];
}

- (void)setAutoMonitorConfigs {
    TSAutoMonitorConfigs *config = [TSAutoMonitorConfigs new];
    config.schedule.enabled = YES;
    config.schedule.startTime = 360;
    config.schedule.endTime = 1200;

    [[[TopStepComKit sharedInstance] temperature] pushAutoMonitorConfig:config completion:^(BOOL isSuccess, NSError * _Nullable error) {
        TSLog(@"[TemperatureDemo] push monitor config success: %d error: %@", isSuccess, error.localizedDescription);
    }];
}

#pragma mark - Active Measurement

- (void)startActivityMeasure {

    TSActivityMeasureParam *measureParam = [TSActivityMeasureParam new];
    measureParam.measureType = TSMeasureTypeTemperature;
    measureParam.maxMeasureDuration = 30;
    measureParam.interval = 10;

    [[[TopStepComKit sharedInstance] temperature] startMeasureWithParam:measureParam startHandler:^(BOOL success, NSError * _Nullable error) {
        TSLog(@"[TemperatureDemo] start measurement success: %d error: %@", success, error.localizedDescription);
    } dataHandler:^(TSTempValueItem * _Nullable data, NSError * _Nullable error) {
        TSLog(@"[TemperatureDemo] measurement data: %@ error: %@", data.debugDescription, error.localizedDescription);
    } endHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        TSLog(@"[TemperatureDemo] measurement ended success: %d error: %@", isSuccess, error.localizedDescription);
    }];
}

- (void)stopActivityMeasure {
    [[[TopStepComKit sharedInstance] temperature] stopMeasureCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        TSLog(@"[TemperatureDemo] stop measurement success: %d error: %@", isSuccess, error.localizedDescription);
    }];
}

@end
