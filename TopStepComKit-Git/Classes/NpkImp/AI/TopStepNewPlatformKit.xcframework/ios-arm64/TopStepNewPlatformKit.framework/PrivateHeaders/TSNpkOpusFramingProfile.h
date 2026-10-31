//
//  TSNpkOpusFramingProfile.h
//  TopStepNewPlatformKit
//

#import <Foundation/Foundation.h>

#import "TSNpkOpusDecoder.h"

@class TSNpkBleConnectionInformation;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Resolves a verified NPK Opus framing profile from device identity
 * @chinese 根据设备身份解析已核验的 NPK Opus 分帧配置
 *
 * @discussion
 * [EN]: The profile key uses the NPK ProtoTb protocol family, project identifier and firmware version.
 *       The current connection snapshot has no separate protocol-version field.
 *       A missing or unknown combination returns Unknown; it never falls back to a guessed mode.
 * [CN]: profile key 使用 NPK ProtoTb 协议族、项目号和固件版本；当前连接快照没有独立协议版本字段。
 *       缺失或未知组合返回 Unknown，
 *       不回退到猜测的分帧模式。
 */
@interface TSNpkOpusFramingProfile : NSObject

/**
 * @brief Resolve a framing mode for an authenticated connection
 * @chinese 为已认证连接解析分帧模式
 * @param connectionInformation
 * EN: Authenticated NPK connection snapshot.
 * CN: 已认证的 NPK 连接快照。
 * @return
 * EN: A verified mode, or Unknown when the identity is not mapped.
 * CN: 已核验模式；身份未匹配时返回 Unknown。
 */
+ (TSNpkOpusFramingMode)framingModeForConnectionInformation:(nullable TSNpkBleConnectionInformation *)connectionInformation;

/**
 * @brief Resolve a framing mode from project and firmware values
 * @chinese 根据项目号和固件版本解析分帧模式
 * @param project
 * EN: NPK project identifier.
 * CN: NPK 项目号。
 * @param firmwareVersion
 * EN: Device firmware version.
 * CN: 设备固件版本。
 * @return
 * EN: A verified mode, or Unknown when the pair is not mapped.
 * CN: 已核验模式；组合未映射时返回 Unknown。
 */
+ (TSNpkOpusFramingMode)framingModeForProject:(nullable NSString *)project
                              firmwareVersion:(nullable NSString *)firmwareVersion;

/**
 * @brief Whether an authenticated connection has a verified framing profile
 * @chinese 已认证连接是否存在已核验分帧配置
 * @param connectionInformation
 * EN: Authenticated NPK connection snapshot.
 * CN: 已认证的 NPK 连接快照。
 * @return
 * EN: YES only for a mapped project and firmware combination.
 * CN: 仅项目号和固件版本均匹配映射时返回 YES。
 */
+ (BOOL)hasKnownProfileForConnectionInformation:(nullable TSNpkBleConnectionInformation *)connectionInformation;

/** @brief This utility has no public instances. @chinese 此工具不创建公开实例。 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
