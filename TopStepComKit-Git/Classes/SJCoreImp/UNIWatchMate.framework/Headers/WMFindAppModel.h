//
//  WMFindAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"
#import "WMDeviceFindModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 查找 （Look up）
@interface WMFindAppModel : NSObject<WMSupportProtocol>

/// 手表端查找手机 （Watch terminal search mobile phone）
@property (nonatomic, strong) RACSignal<WMDeviceFindModel *> *findPhone;

/// 手表端停止查找手机 （The watch terminal stops looking for the phone）
@property (nonatomic, strong) RACSignal<NSNumber *> *closeFindPhone;

/// 手表端停止查找手表 （The watch terminal stops looking for the watch）
@property (nonatomic, strong) RACSignal<NSNumber *> *closeFindWatch;

/// 关闭查找手表 （Turn off Find Watch）
- (RACSignal<NSNumber *> *)phoneCloseFindWatch;
/// 关闭查找手机 （Turn off Find Phone）
- (RACSignal<NSNumber *> *)phoneCloseFindPhone;
/// 查找手表 （Find a watch）
/// - Parameter : 响铃次数 （Number of ringing）
- (RACSignal<NSNumber *> *)findWatch:(WMDeviceFindModel *)model;

@end

NS_ASSUME_NONNULL_END
