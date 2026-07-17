//
//  TSCommandDataTool.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 命令协议助手类
 * @chinese 专门负责协议相关的工具方法，遵循单一职责原则
 *
 * @discussion
 * EN: This class is dedicated to protocol-related utility methods, following the single responsibility principle.
 * It provides helper functions for protocol operations.
 * CN: 此类专门负责协议相关的工具方法，遵循单一职责原则。
 * 提供协议操作的辅助函数。
 */
@interface TSCommandDataTool : NSObject




/**
 * @brief 验证魔数字节
 * @chinese 验证数据包的魔数字节是否正确
 *
 * @param magicByte 魔数字节
 *        EN: Magic byte
 *        CN: 魔数字节
 *
 * @return 是否有效
 *         EN: Whether the magic byte is valid
 *         CN: 魔数字节是否有效
 */
+ (BOOL)isValidMagicByte:(UInt8)magicByte;

/**
 * @brief 解析标志位字节
 * @chinese 从标志位字节中解析各个标志位
 *
 * @param flags 标志位字节
 *        EN: Flags byte
 *        CN: 标志位字节
 *
 * @return 标志位信息字典
 *         EN: Flags info dictionary
 *         CN: 标志位信息字典
 */
+ (NSDictionary *)parseFlagsByte:(UInt8)flags;



+ (BOOL)validateCompletePacket:(NSData *)packetData ;

@end

NS_ASSUME_NONNULL_END 
