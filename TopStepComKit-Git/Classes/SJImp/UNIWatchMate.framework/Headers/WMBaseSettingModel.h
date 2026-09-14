//
//  WMBaseSettingModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMBaseSettingModel<__covariant ObjectType> : NSObject <WMSupportProtocol>

/// 订阅配置（接收设备端修改配置）（Subscription configuration (modified configuration on the receiving device)）
@property (nonatomic, strong) RACSignal<ObjectType> *model;

/// APP修改配置 （APP Modify configuration）
/// - Parameter model: 配置 （configuration）
- (RACSignal<NSNumber *> *)setConfigModel:(ObjectType)model;

/// APP读取配置 （APP read configuration）
- (RACSignal<ObjectType> *)getConfigModel;

@end

NS_ASSUME_NONNULL_END
