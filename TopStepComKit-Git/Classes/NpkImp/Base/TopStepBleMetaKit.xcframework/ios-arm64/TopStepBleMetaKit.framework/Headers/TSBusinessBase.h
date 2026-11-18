//
//  TSBusinessBase.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/8/17.
//

#import "TSMetaBase.h"
#import "TSCommand.h"
#import "TSCommandDefines.h"
#import <TopStepToolKit/TopStepToolKit.h>
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Encode a complete list message from a snapshot of its records.
 * @chinese 将记录快照编码为一个完整列表消息。
 * @param items EN: Copied records for one message. CN: 当前消息的记录副本。
 * @return EN: Encoded message, or nil on failure. CN: 编码消息，失败返回 nil。
 */
typedef NSData * _Nullable (^TSMetaListPayloadEncoder)(NSArray<GPBMessage *> *items);

@interface TSBusinessBase : TSMetaBase


+ (void)handleComonRespondWithResult:(BOOL)isSuccess
                             respond:(NSData *)respondData
                               error:(NSError *)error
                              domain:(NSString *)errorDomain
                          completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Encode all list messages before transmission, bounded by record count and 1024 data bytes.
 * @chinese 发送前编码全部列表消息，同时满足条数上限与 1024 字节数据区上限。
 * @param items EN: Records to copy; an empty array encodes one empty message. CN: 待复制记录，空数组编码一个空消息。
 * @param maxItemsPerMessage EN: Protocol record capacity of one message. CN: 单消息协议记录容量。
 * @param errorDomain EN: Business error domain. CN: 业务错误域。
 * @param encoder EN: Complete-message encoder; must preserve record order. CN: 保持记录顺序的完整消息编码器。
 * @param error EN: Encoding or capacity error. CN: 编码或容量错误。
 * @return EN: Complete immutable payloads, or nil without sending anything. CN: 完整不可变负载数组，失败返回 nil 且不发送数据。
 */
+ (nullable NSArray<NSData *> *)listPayloadsForItems:(NSArray<GPBMessage *> *)items
                               maxItemsPerMessage:(NSUInteger)maxItemsPerMessage
                                           domain:(NSString *)errorDomain
                                          encoder:(TSMetaListPayloadEncoder)encoder
                                            error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Validate every actual CommonResponse in a completed command response.
 * @chinese 校验指令实际返回的全部 CommonResponse。
 * @param isSuccess EN: Transport result. CN: 传输结果。
 * @param responses EN: Ordered response messages; empty data is a valid default response. CN: 有序应答消息，零字节数据为合法默认应答。
 * @param error EN: Transport error. CN: 传输错误。
 * @param errorDomain EN: Business error domain. CN: 业务错误域。
 * @param completion EN: Completion called once when provided. CN: 非空时调用一次的完成回调。
 */
+ (void)handleCommonResponsesWithResult:(BOOL)isSuccess
                             responses:(nullable NSArray<NSData *> *)responses
                                 error:(nullable NSError *)error
                                domain:(NSString *)errorDomain
                            completion:(nullable TSMetaCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
