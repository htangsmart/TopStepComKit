#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Physical product category, independent of providers @chinese 与 Provider 无关的物理产品类型 */
typedef NS_ENUM(NSInteger, TSAIDeviceProductKind) {
    TSAIDeviceProductKindUnknown,
    TSAIDeviceProductKindWatch,
    TSAIDeviceProductKindRing,
    TSAIDeviceProductKindGlasses,
    TSAIDeviceProductKindChargingCase,
    TSAIDeviceProductKindEarbuds,
    TSAIDeviceProductKindSpeaker,
    TSAIDeviceProductKindHeadphones,
};

/** @brief Immutable identity from a verified physical connection @chinese 已校验物理连接的不可变身份 */
@interface TSAIDeviceIdentitySnapshot : NSObject <NSCopying>

/** @brief Platform device identifier @chinese 平台设备标识 */
@property (nonatomic, copy, readonly) NSString *deviceIdentifier;
/** @brief Real hardware MAC, never a Bluetooth UUID @chinese 真实硬件 MAC，不是蓝牙 UUID */
@property (nonatomic, copy, readonly) NSString *MACAddress;
/** @brief Native product category; unknown remains unknown @chinese 原生产品类型，未知不推断 */
@property (nonatomic, assign, readonly) TSAIDeviceProductKind productKind;
/** @brief Native device display name @chinese 原生设备显示名称 */
@property (nonatomic, copy, readonly, nullable) NSString *displayName;

/**
 * @brief Create an immutable connection identity
 * @chinese 创建不可变的连接身份
 * @param identifier EN: Device identifier. CN: 设备标识。
 * @param MACAddress EN: Verified hardware address. CN: 已校验硬件地址。
 * @param productKind EN: Native product category. CN: 原生产品类型。
 * @param displayName EN: Optional native name. CN: 可选原生名称。
 * @return EN: Identity snapshot; it does not imply AI capability. CN: 身份快照，不代表 AI 能力。
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                        MACAddress:(NSString *)MACAddress
                       productKind:(TSAIDeviceProductKind)productKind
                       displayName:(nullable NSString *)displayName NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
