//
//  TSNpkDialPlatformValidator.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TSNpkDialDeviceProfile;

/** @brief Validates PB dial contents against the connected platform @chinese 校验 PB 表盘内容与连接平台是否匹配 */
@interface TSNpkDialPlatformValidator : NSObject

/** @brief Validate a captured LVGL platform marker without reading the connection.
 * @chinese 根据已捕获平台校验 LVGL 标记，不读取当前连接。
 * @param binPath EN: res.bin path. CN: res.bin 路径。
 * @param profile EN: Captured profile. CN: 设备快照。
 * @param error EN: Failure. CN: 错误。
 * @return EN: Marker matches. CN: 标记匹配。
 */
+ (BOOL)validateBinAtPath:(NSString *)binPath
                  profile:(TSNpkDialDeviceProfile *)profile
                    error:(NSError *_Nullable *_Nullable)error;

+ (BOOL)validateContentDirectory:(NSString *)directoryPath
                           error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
