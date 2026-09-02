//
//  TSDialModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/18.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face information model
 * @chinese 表盘信息模型
 *
 * @discussion
 * [EN]: Describes a watch face already known to the SDK or device, including id, name,
 *       type, current state, device slot and version.
 * [CN]: 描述 SDK 或设备已知的表盘，包括 id、名称、类型、当前状态、设备槽位、
 *       版本。
 */
@interface TSDialModel : TSKitBaseModel

/**
 * @brief Watch face id
 * @chinese 表盘 id
 *
 * @discussion
 * [EN]: Opaque identifier assigned by the device, server or SDK.
 * [CN]: 由设备、服务端或 SDK 分配的不透明标识符。
 */
@property (nonatomic, strong) NSString *dialId;

/**
 * @brief Watch face display name
 * @chinese 表盘显示名称
 *
 * @discussion
 * [EN]: Human-readable name for UI display.
 * [CN]: 用于 UI 展示的可读名称。
 */
@property (nonatomic, strong) NSString *dialName;

/**
 * @brief Watch face type
 * @chinese 表盘类型
 *
 * @discussion
 * [EN]: Built-in, custom, or cloud watch face.
 * [CN]: 内置、自定义或云端表盘。
 */
@property (nonatomic, assign) TSDialType dialType;

/**
 * @brief Indicates whether this is the current watch face
 * @chinese 指示这是否是当前表盘
 *
 * @discussion
 * [EN]: YES when this watch face is currently selected on the device.
 * [CN]: 当前设备正在使用该表盘时为 YES。
 */
@property (nonatomic, assign) BOOL isCurrent;

/**
 * @brief Location index of the watch face on the device
 * @chinese 表盘在设备上的位置索引
 *
 * @discussion
 * [EN]: Device storage slot index. Valid range depends on device capability.
 * [CN]: 设备端存储槽位索引，有效范围取决于设备能力。
 */
@property (nonatomic, assign) UInt8 locationIndex;

/**
 * @brief Watch face version
 * @chinese 表盘版本
 *
 * @discussion
 * [EN]: Optional version string for comparison or display.
 * [CN]: 用于比较或展示的可选版本字符串。
 */
@property (nonatomic, strong ) NSString * version;

/**
 * @brief Debug description
 * @chinese 调试描述
 *
 * @return 
 * EN: Human-readable watch face information for logs.
 * CN: 用于日志的人类可读表盘信息。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
