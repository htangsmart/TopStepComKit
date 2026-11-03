//
//  MagicConversationModels.h
//  MagicHelper
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 会话列表项（GET /service/conversation/list）
@interface MagicConversationItem : NSObject
/// 会话 ID
@property (nonatomic, copy) NSString *conversationId;
/// IM 用户 ID
@property (nonatomic, copy) NSString *imUserId;
/// IM 智能体 ID
@property (nonatomic, copy) NSString *imAgentId;
/// 智能体 ID
@property (nonatomic, copy) NSString *agentId;
/// 租户编码
@property (nonatomic, copy) NSString *tenantCode;
/// 设备序列号
@property (nonatomic, copy) NSString *deviceSn;
/// 用户 ID
@property (nonatomic, copy) NSString *userId;
/// 会话状态
@property (nonatomic, copy) NSString *status;
/// 对话轮数
@property (nonatomic, assign) NSInteger turnCount;
/// 最后消息摘要
@property (nonatomic, copy) NSString *lastMessageSummary;
/// 最后消息时间戳
@property (nonatomic, assign) int64_t lastMessageTime;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 消息收发方（MessageFromTo）
@interface MagicMessageFromTo : NSObject
/// 用户 ID
@property (nonatomic, copy) NSString *uid;
/// 类型
@property (nonatomic, copy) NSString *type;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 历史消息项（GET /service/conversation/history）；接口字段 `id` 映射为 messageId
@interface MagicConversationMessageItem : NSObject
/// 消息 ID（对应接口 `id`）
@property (nonatomic, copy) NSString *messageId;
/// 业务类型
@property (nonatomic, copy) NSString *bizType;
/// 消息内容
@property (nonatomic, copy) NSString *content;
/// 时间戳
@property (nonatomic, assign) int64_t timestamp;
/// 发送方
@property (nonatomic, strong, nullable) MagicMessageFromTo *from;
/// 接收方
@property (nonatomic, strong, nullable) MagicMessageFromTo *to;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 历史分页结果（HistoryResult）
@interface MagicConversationHistoryResult : NSObject
/// 消息列表
@property (nonatomic, copy) NSArray<MagicConversationMessageItem *> *messages;
/// 是否还有更多
@property (nonatomic, assign) BOOL hasMore;
/// 下一页游标
@property (nonatomic, assign) int64_t nextCursorId;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 全文搜索发送方信息（SearchFrom）
@interface MagicConversationSearchFrom : NSObject
/// 用户 ID
@property (nonatomic, copy) NSString *userId;
/// 用户名
@property (nonatomic, copy) NSString *userName;
/// 昵称
@property (nonatomic, copy) NSString *nickName;
/// 手机号
@property (nonatomic, copy) NSString *phoneNo;
/// 头像 URL
@property (nonatomic, copy) NSString *avatarUrl;
/// 用户昵称
@property (nonatomic, copy) NSString *userNick;
/// 用户备注
@property (nonatomic, copy) NSString *userMark;
/// 用户渠道
@property (nonatomic, copy) NSString *userChannel;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 搜索结果扩展信息（SearchHitExtInfo）
@interface MagicConversationSearchHitExtInfo : NSObject
/// 免打扰标识
@property (nonatomic, copy) NSString *msgNonDisturb;
/// 业务类型
@property (nonatomic, copy) NSString *bizType;
/// 会话 ID
@property (nonatomic, copy) NSString *conversationId;
/// SDK 类型
@property (nonatomic, copy) NSString *sdkType;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 全文搜索单条命中（SearchHit）
@interface MagicConversationSearchHit : NSObject
/// 会话 ID
@property (nonatomic, copy) NSString *sid;
/// 会话类型
@property (nonatomic, copy) NSString *sessionType;
/// 会话名称
@property (nonatomic, copy) NSString *sessionName;
/// 会话头像
@property (nonatomic, copy) NSString *sessionAvatar;
/// 消息 ID
@property (nonatomic, copy) NSString *msgId;
/// 模板编码
@property (nonatomic, copy) NSString *templateCode;
/// 消息内容
@property (nonatomic, copy) NSString *content;
/// 搜索匹配内容
@property (nonatomic, copy) NSString *searchContent;
/// 发送方信息
@property (nonatomic, strong, nullable) MagicConversationSearchFrom *from;
/// 资源类型
@property (nonatomic, copy) NSString *resourceType;
/// 资源名称
@property (nonatomic, copy) NSString *resourceName;
/// 资源大小
@property (nonatomic, copy) NSString *resourceSize;
/// 时间戳
@property (nonatomic, assign) int64_t timestamp;
/// 扩展信息
@property (nonatomic, strong, nullable) MagicConversationSearchHitExtInfo *extInfo;
/// 引用信息
@property (nonatomic, strong, nullable) id quotedInfo;
/// 引用回复信息
@property (nonatomic, strong, nullable) id quoteReplyInfo;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 全文搜索结果（SearchResult）
@interface MagicConversationSearchResult : NSObject
/// 搜索结果列表
@property (nonatomic, copy) NSArray<MagicConversationSearchHit *> *hits;
/// 当前页码（从 1 开始）
@property (nonatomic, assign) NSInteger pageIndex;
/// 每页大小
@property (nonatomic, assign) NSInteger pageSize;
/// 总条数
@property (nonatomic, assign) NSInteger totalItemCount;
/// 是否还有更多
@property (nonatomic, assign) BOOL hasMore;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 单条聊天记录（ChatRecord）
@interface MagicConversationChatRecord : NSObject
/// 角色（`user` / `assistant`）
@property (nonatomic, copy) NSString *role;
/// 会话 ID
@property (nonatomic, copy) NSString *conversationId;
/// 内容
@property (nonatomic, copy) NSString *content;
/// 时间戳
@property (nonatomic, assign) int64_t timestamp;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 按天分组的会话项（DayConversationItem）
@interface MagicConversationDayItem : NSObject
/// IM 智能体 ID
@property (nonatomic, copy) NSString *imAgentId;
/// 会话 ID
@property (nonatomic, copy) NSString *conversationId;
/// 聊天记录
@property (nonatomic, copy) NSArray<MagicConversationChatRecord *> *chatRecords;
/// 对话轮数
@property (nonatomic, assign) NSInteger turnCount;
/// 最后消息时间戳
@property (nonatomic, assign) int64_t lastMessageTime;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 按天分组会话列表结果（ListByDayResult）；接口字段 date/total/data/pageNo/pageSize，其中 `data` 映射为 conversations
@interface MagicConversationListByDayResult : NSObject
/// 日期（yyyy-MM-dd）
@property (nonatomic, copy) NSString *date;
/// 总会话数
@property (nonatomic, assign) NSInteger total;
/// 会话列表（对应接口 `data`）
@property (nonatomic, copy) NSArray<MagicConversationDayItem *> *conversations;
/// 页码
@property (nonatomic, assign) NSInteger pageNo;
/// 每页大小
@property (nonatomic, assign) NSInteger pageSize;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
