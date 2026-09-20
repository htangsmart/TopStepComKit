//
//  WMMusilinAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2024/7/6.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import "WMMusilinDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMMusilinAppModel : NSObject<WMSupportProtocol>

// 真主收藏更新通知
@property (nonatomic, strong) RACSignal<WMAllahNameCollectModel *> *allahNameCollectModel;
// 祈祷提醒更新通知
@property (nonatomic, strong) RACSignal<WMPrayerTimingsModel *> *prayerTimingsModel;
// 念经提醒更新通知
@property (nonatomic, strong) RACSignal<WMTasbihReminderModel *> *tasbihReminderModel;

// 获取祈祷算法
- (RACSignal<WMPrayerFuncModel *> *)readPrayerFuncModel;
// 获取真主收藏
- (RACSignal<WMAllahNameCollectModel *> *)readAllahNameCollectModel;
// 获取祈祷提醒
- (RACSignal<WMPrayerTimingsModel *> *)readPrayerTimingsModel;
// 获取念经提醒
- (RACSignal<WMTasbihReminderModel *> *)readTasbihReminderModel;


// 更新祈祷算法
- (RACSignal<NSNumber *> *)writePrayerFuncModel:(WMPrayerFuncModel *)model;
// 更新真主收藏
- (RACSignal<NSNumber *> *)writeAllahNameCollectModel:(WMAllahNameCollectModel *)model;
// 更新祈祷提醒
- (RACSignal<NSNumber *> *)writePrayerTimingsModel:(WMPrayerTimingsModel *)model;
// 更新念经提醒
- (RACSignal<NSNumber *> *)writeTasbihReminderModel:(WMTasbihReminderModel *)model;


@end

NS_ASSUME_NONNULL_END
