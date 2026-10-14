//
//  TSCmdDataHandleInterface.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/24.
//

#import <Foundation/Foundation.h>
#import "TSParsedPacket.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Command data processing interface
 * @chinese 命令数据处理接口
 *
 * @discussion
 * [EN]: This protocol defines a unified interface for command data processing.
 *       All command data handlers should implement this protocol.
 * [CN]: 此协议定义命令数据处理的统一接口。
 *       所有命令数据处理器都应该实现此协议。
 */
@protocol TSPackageHandleInterface <NSObject>

/**
 * @brief Check if can handle parsed packet
 * @chinese 检查是否能处理解析后的数据包
 *
 * @param parsedPacket
 * [EN]: Parsed data packet to be checked
 * [CN]: 要检查的解析后数据包
 *
 * @return
 * [EN]: YES if this handler can process the packet, NO otherwise
 * [CN]: 如果可以处理返回YES，否则返回NO
 *
 * @discussion
 * [EN]: This method is called before handleParsedPacket to determine if the handler
 *       should process the packet. This allows for efficient routing of packets
 *       to appropriate handlers.
 * [CN]: 此方法在handleParsedPacket之前调用，用于确定处理器是否应该处理该数据包。
 *       这允许高效地将数据包路由到适当的处理器。
 */
- (BOOL)canHandleParsedPacket:(TSParsedPacket *)parsedPacket;

/**
 * @brief Handle parsed packet
 * @chinese 处理解析后的数据包
 *
 * @param parsedPacket
 * [EN]: Parsed data packet to be processed
 * [CN]: 要处理的解析后数据包
 *
 * @discussion
 * [EN]: This method is called when the handler is determined to be capable of
 *       processing the packet. The handler should implement its specific logic
 *       for handling the parsed packet data.
 * [CN]: 当确定处理器能够处理数据包时调用此方法。
 *       处理器应该实现其处理解析后数据包数据的具体逻辑。
 */
- (void)handleParsedPacket:(TSParsedPacket *)parsedPacket;

@end

NS_ASSUME_NONNULL_END
