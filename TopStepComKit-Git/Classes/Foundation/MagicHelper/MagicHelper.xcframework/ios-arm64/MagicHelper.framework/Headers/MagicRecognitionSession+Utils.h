//
//  MagicRecognitionSession+Utils.h
//  MagicHelper
//
//  Created by ymz on 2026/5/12.
//

#import <MagicHelper/MagicHelper.h>
#import "MagicConversationModels.h"
#import "MagicPetConfigModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface MagicRecognitionSession (Utils)

#pragma mark - 记忆 (Memory)

/// 记忆类型：fact-事实, card-卡证, order-订单
typedef NSString * MagicMemoryType NS_STRING_ENUM;
///事实类记忆，如⽤户偏好、设备状态等
FOUNDATION_EXPORT MagicMemoryType const MagicMemoryTypeFact;
///卡证类记忆，如身份证、银⾏卡信息
FOUNDATION_EXPORT MagicMemoryType const MagicMemoryTypeCard;
///订单类记忆，如购物记录、服务订单
FOUNDATION_EXPORT MagicMemoryType const MagicMemoryTypeOrder;

/// 记忆来源：dialogue-对话, image-图像, page-页面
typedef NSString * MagicMemorySource NS_STRING_ENUM;
///来自ai对话
FOUNDATION_EXPORT MagicMemorySource const MagicMemorySourceDialogue;
///来自图片识别
FOUNDATION_EXPORT MagicMemorySource const MagicMemorySourceImage;
///来自用户创建
FOUNDATION_EXPORT MagicMemorySource const MagicMemorySourcePage;

/// 添加记忆
- (void)addMemoryWithTopic:(NSString *)topic
                   content:(NSString *)content
                      type:(MagicMemoryType)type
                    source:(MagicMemorySource)source
                 onSuccess:(void (^)(NSString *memoryId))onSuccess
                   onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 编辑记忆
- (void)editeMemoryWithMemoryId:(NSString *)memoryId
                          topic:(NSString *)topic
                        content:(NSString *)content
                      onSuccess:(void (^)(void))onSuccess
                        onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 删除记忆
- (void)deleteMemoryWithMemoryId:(NSString *)memoryId
                       onSuccess:(void (^)(void))onSuccess
                         onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 拉取记忆列表，list 元素为 MagicMemoryData
- (void)fetchMemoryWithSource:(nullable MagicMemorySource)source
                         type:(nullable MagicMemoryType)type
                      pageNum:(NSInteger)pageNum
                     pageSize:(NSInteger)pageSize
                    onSuccess:(void (^)(NSArray<MagicMemoryData *> *list))onSuccess
                      onError:(void (^)(NSString *msg, NSInteger code))onError;

#pragma mark - 会话 (Conversation)

/// 获取所有的会话记录
/// @param userId 用户 ID，可选；传 nil 或空时不传该查询参数（仅按设备查）。
/// @param onSuccess 成功回调，`list` 元素为 `MagicConversationItem`。
/// @param onError 失败回调。
- (void)fetchConversationListWithUserId:(nullable NSString *)userId
                              onSuccess:(void (^)(NSArray<MagicConversationItem *> *list))onSuccess
                                onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 历史消息分页查询
/// @param conversationId 会话 ID，必填。
/// @param userId 用户 IM ID，可选。
/// @param cursorId 游标，首次为 0, 否则传上一次返回的nextCursorId；传 nil 时按 0 处理。
/// @param pageSize 每页条数；传 nil 时按 20 处理；传入 ≤0 的 NSNumber 时仍按 20 处理。
/// @param onSuccess 成功回调，结果为 `MagicConversationHistoryResult`。
/// @param onError 失败回调。
- (void)fetchConversationHistoryWithConversationId:(NSString *)conversationId
                                            userId:(nullable NSString *)userId
                                          cursorId:(nullable NSNumber *)cursorId
                                          pageSize:(nullable NSNumber *)pageSize
                                         onSuccess:(void (^)(MagicConversationHistoryResult *result))onSuccess
                                           onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 全文搜索历史消息
/// @param keyword 搜索关键词，必填。
/// @param userId 用户 IM ID，可选；传 nil 或空时不传该查询参数。
/// @param conversationIds 会话 ID 列表，逗号分隔；传 nil 表示不按会话过滤（搜全部）。
/// @param startTime 起始时间戳（毫秒）；传 nil 表示 0（不限）。
/// @param endTime 结束时间戳（毫秒）；传 nil 表示 0（不限）。
/// @param pageIndex 页码，从 1 起；传 nil 表示 1。
/// @param pageSize 每页条数；传 nil 表示 20。
/// @param onSuccess 成功回调，结果为 `MagicConversationSearchResult`。
/// @param onError 失败回调。
- (void)searchConversationMessagesWithKeyword:(NSString *)keyword
                                       userId:(nullable NSString *)userId
                            conversationIds:(nullable NSString *)conversationIds
                                  startTime:(nullable NSNumber *)startTime
                                    endTime:(nullable NSNumber *)endTime
                                  pageIndex:(nullable NSNumber *)pageIndex
                                   pageSize:(nullable NSNumber *)pageSize
                                  onSuccess:(void (^)(MagicConversationSearchResult *result))onSuccess
                                    onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 按天分组获取会话列表
/// @param date 日期，格式 `yyyy-MM-dd`，必填。
/// @param pageNo 页码,从1开始；传 nil 表示 1。
/// @param pageSize 每页条数；传 nil 表示 10。
/// @param onSuccess 成功回调，结果为 `MagicConversationListByDayResult`（会话列表字段为 `conversations`）。
/// @param onError 失败回调。
- (void)fetchConversationListByDayWithDate:(NSString *)date
                                    pageNo:(nullable NSNumber *)pageNo
                                  pageSize:(nullable NSNumber *)pageSize
                                 onSuccess:(void (^)(MagicConversationListByDayResult *result))onSuccess
                                   onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 逻辑删除会话
/// @param conversationId 会话 ID；传 nil 或空表示删除该设备下全部会话。
/// @param onSuccess 成功回调，参数为服务端返回的删除结果描述。
/// @param onError 失败回调。
- (void)deleteConversationWithConversationId:(nullable NSString *)conversationId
                                   onSuccess:(void (^)(NSString *resultMessage))onSuccess
                                     onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 月度聊天统计
/// @param date 月份 `yyyy-MM`；传 nil 或空时不传该参数，由服务端使用当月。
/// @param onSuccess 成功回调，键为日期字符串，值为 `@(YES)` / `@(NO)`。
/// @param onError 失败回调。
- (void)fetchConversationMonthlyStatsWithDate:(nullable NSString *)date
                                    onSuccess:(void (^)(NSDictionary<NSString *, NSNumber *> *dayStats))onSuccess
                                      onError:(void (^)(NSString *msg, NSInteger code))onError;

#pragma mark - 宠物配置 (Pet)


///  宠物配置: 设置音色
- (void)setPetVoice:(NSString *)voice
           onSuccess:(void (^)(MagicPetSetVoiceResult *data))onSuccess
             onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 宠物配置: 获取已设置音色
- (void)getPetVoiceOnSuccess:(void (^)(MagicPetGetVoiceResult *data))onSuccess
                     onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 获取支持的音色列表
- (void)listPetVoicesOnSuccess:(void (^)(NSArray<MagicPetVoiceInfo *> *list))onSuccess
                       onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 宠物配置: 设置智能体
- (void)setPetPersonalityWithPersonalityCode:(NSString *)personalityCode
                                  onSuccess:(void (^)(MagicPetSetPersonalityResult *data))onSuccess
                                    onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 宠物配置: 获取已设置智能体
- (void)getPetPersonalityOnSuccess:(void (^)(MagicPetGetPersonalityResult *data))onSuccess
                           onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 获取支持的智能体列表
- (void)listPetPersonalitiesOnSuccess:(void (^)(NSArray<MagicPetPersonalityInfo *> *list))onSuccess
                              onError:(void (^)(NSString *msg, NSInteger code))onError;

/// 获取当前设备设置的智能体和音色，返回值MagicDevicePetConfig，如果为null，则未设置
- (void)getPetConfigOnSuccess:(void (^)(MagicDevicePetConfig * _Nullable config))onSuccess
                      onError:(void (^)(NSString *msg, NSInteger code))onError;

@end

NS_ASSUME_NONNULL_END
