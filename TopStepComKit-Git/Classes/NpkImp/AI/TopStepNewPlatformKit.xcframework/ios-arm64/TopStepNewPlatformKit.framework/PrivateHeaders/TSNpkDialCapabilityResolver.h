#import <Foundation/Foundation.h>
@class TSDialCapability, TSDialDraft, TSNpkDialDeviceProfile;
NS_ASSUME_NONNULL_BEGIN

/** @brief Shared implementation/device rules for capability and build validation.
 * @chinese 能力查询与造包前置校验共用的实现和设备约束。
 */
@interface TSNpkDialCapabilityResolver : NSObject
/** @brief Resolve public capabilities. @chinese 解析公开能力。
 * @param profile EN: Validated device facts. CN: 有效设备事实。
 * @return EN: Capability snapshot. CN: 能力快照。
 */
+ (TSDialCapability *)capabilityForProfile:(TSNpkDialDeviceProfile *)profile;
/** @brief Normalize a copied draft and validate before I/O. @chinese 归一草稿副本，在媒体或网络操作前校验。
 * @param draft EN: Caller draft. CN: 调用方草稿。
 * @param profile EN: Device facts. CN: 设备事实。
 * @param error EN: Validation failure. CN: 校验错误。
 * @return EN: Independent working copy, or nil. CN: 独立工作副本或 nil。
 */
+ (nullable TSDialDraft *)normalizedDraft:(TSDialDraft *)draft
                                 profile:(TSNpkDialDeviceProfile *)profile
                                   error:(NSError *_Nullable *_Nullable)error;
@end
NS_ASSUME_NONNULL_END
