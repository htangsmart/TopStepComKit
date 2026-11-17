#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/// @brief Demo page for NPK realtime logs. @chinese NPK 实时日志示例页面。
@interface TSDeviceRealtimeLogVC : TSBaseVC

/// @brief Initialize with the selected log provider. @chinese 使用当前日志能力实例初始化。
/// @param peripheralLog Current log interface / 当前日志接口。
/// @return The initialized page / 初始化后的页面。
- (instancetype)initWithPeripheralLog:(id<TSPeripheralLogInterface>)peripheralLog;

@end

NS_ASSUME_NONNULL_END
