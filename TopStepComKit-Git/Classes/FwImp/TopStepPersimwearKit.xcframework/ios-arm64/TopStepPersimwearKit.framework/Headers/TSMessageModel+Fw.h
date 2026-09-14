//
//  TSMessageModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMessageModel (Fw)

/**
 * @brief Check whether a message type can be converted by the Fw provider
 * @chinese 检查 Fw Provider 是否可转换指定消息类型
 *
 * @param messageType
 * EN: Message type to check
 * CN: 待检查的消息类型
 *
 * @return
 * EN: YES if the type has a Persimwear configuration key, otherwise NO
 * CN: 类型存在 Persimwear 配置键时返回 YES，否则返回 NO
 */
+ (BOOL)isSupportMessageType:(TSMessageType)messageType;

+ (NSDictionary *)messageValuesFromModels:(NSArray<TSMessageModel *> *)messageModels;

+ (NSArray<TSMessageModel *> *)messageModelsFromFwDicts:(NSDictionary *)messageDicts;

@end

NS_ASSUME_NONNULL_END
