//
//  WMConfigMotionAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMSportTypeModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMConfigMotionAppModel : NSObject<WMSupportProtocol>

/// 固定运动个数列表改变 （Fixed number of movement list changes）
@property (nonatomic, strong) RACSignal<NSArray<NSNumber*> *> *fixedTypes;
/// 可变运动个数列表改变 （Variable movement list changed）
@property (nonatomic, strong) RACSignal<NSArray<NSNumber*> *> *variableTypes;


/// 同步固定运动个数列表 （Synchronize the number of fixed movements）
/// - Parameter type: 运动列表（Int值）
- (RACSignal<NSNumber *> *)syncFixedActivityType:(NSArray<NSNumber*> *)types;

/// 同步可变运动个数列表 （Synchronizing the variable motion count list）
/// - Parameter type: 运动列表（Int值）（Motion list (Int value)）
- (RACSignal<NSNumber *> *)syncVariableActivityType:(NSArray<NSNumber*> *)types;

/// 获取固定运动列表 （Gets a list of fixed sports）
- (RACSignal<NSArray<NSNumber*> *> *)getFixedActivityTypes;

/// 获取可变运动列表 （Gets a list of variable movements）
- (RACSignal<NSArray<NSNumber*> *> *)getVariableActivityTypes;

/// 获取设备支持所有运动 （Get equipment to support all sports）
- (RACSignal<NSArray<NSNumber*> *> *)getSupportedActivityTypes;

@end

NS_ASSUME_NONNULL_END
