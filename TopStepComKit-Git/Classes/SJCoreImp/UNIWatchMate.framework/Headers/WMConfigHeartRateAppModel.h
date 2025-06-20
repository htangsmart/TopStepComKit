//
//  WMConfigHeartRateAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMHeartRateConfigModel.h"
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMConfigHeartRateAppModel : NSObject<WMSupportProtocol>

/// 订阅心率配置 （Subscribe to heart rate configuration）
@property (nonatomic, strong) RACSignal<WMHeartRateConfigModel *> *model;
@property (nonatomic, strong, readonly) WMHeartRateConfigModel *modelValue;


/// 主动获取心率配置 （Actively obtain heart rate Settings）
- (RACSignal<WMHeartRateConfigModel *> *)wm_getHeartRateConfig;

/// 设置心率配置 （Set heart rate Settings）
/// - Parameter model: 心率类型model （Heart rate type model）
- (RACSignal<WMHeartRateConfigModel *> *)wm_setHeartRateConfig:(WMHeartRateConfigModel *)model;

@end

NS_ASSUME_NONNULL_END
