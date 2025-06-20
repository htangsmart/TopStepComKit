//
//  WMBaseDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMBaseDataSyncModel<__covariant ObjectType> : NSObject <WMSupportProtocol>

/// 同步数据 （Synchronous data）
/// - Parameter startTime: 从什么时候开始同步数据，传入0表示同步所有数据，设备最多存储7天数据 （When does data synchronization start? Passing in 0 means that all data is synchronized and the device stores data for a maximum of 7 days）
- (RACSignal<NSArray<ObjectType>* > *)syncDataWithStartTime:(NSTimeInterval)startTime;

@end

NS_ASSUME_NONNULL_END
