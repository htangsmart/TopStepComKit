//
//  WMAlarmAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMAlarmModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMAlarmAppModel : NSObject<WMSupportProtocol>

/// 设备端闹钟列表改变订阅 （The alarm list on the device changes the subscription）
@property (nonatomic, strong) RACSignal<NSArray<WMAlarmModel*> *> *alarmList;
/// 当前闹钟列表（设备端、APP修改配置成功时更新数据）（Current alarm list (Update data when the configuration is successfully modified on the device and APP)）
@property (nonatomic, strong, readonly) NSArray<WMAlarmModel*> *alarmListValue;
           
/// 同步闹钟列表 （Sync alarm List）
- (RACSignal<NSArray<WMAlarmModel*> *> *)wm_getAlarmList;

/// 同步闹钟列表 （Sync alarm List）
/// - Parameter contact: 闹钟列表 （Alarm clock list）
- (RACSignal<NSArray<WMAlarmModel*> *> *)syncAlarmList:(NSArray<WMAlarmModel*> *)list;


@end

NS_ASSUME_NONNULL_END
