#import "TSAIDeviceBridge.h"
#import "TSAIDeviceCommandResult.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Optional existing device command execution capability
 * @chinese 可选的设备现有指令执行能力
 */
@protocol TSAIDeviceCommandBridge <TSAIDeviceBridge>

/**
 * @brief Query commands supported by the current device and firmware
 * @chinese 查询当前设备及固件支持的指令
 * @return
 * EN: Supported command enum values.
 * CN: 支持的指令枚举集合。
 */
- (NSSet<NSNumber *> *)supportedDeviceCommandTypes;

/**
 * @brief Execute a validated command using existing device APIs
 * @chinese 使用现有设备 API 执行已校验的指令
 * @param request
 * EN: Command including the activation identity.
 * CN: 含激活身份的指令。
 * @param validation
 * EN: Recheck immediately before every write.
 * CN: 每次写入前立即复核。
 * @param completion
 * EN: One main-thread device outcome.
 * CN: 主线程单次设备结果。
 */
- (void)executeDeviceCommand:(TSAIDeviceCommandRequest *)request
                  validation:(BOOL (^)(void))validation
                  completion:(void (^)(TSAIDeviceCommandResult *result))completion;

@end

NS_ASSUME_NONNULL_END
