//
//  MagicCardEnvelope.h
//  MagicHelper
//
//  卡片智能体 Card Envelope 数据模型，对应协议 response.card.data / loading / error 及 session.created card_config。
//  与 Android com.artillery.eyeEar.data.CardEnvelope 字段对齐。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 卡片操作按钮，用于 footer.actions 或 list 条目 actions
@interface MagicCardAction : NSObject

@property (nonatomic, copy, nullable) NSString *label;        ///< 按钮文案
@property (nonatomic, copy, nullable) NSString *action_type;  ///< navigation / tel / url / copy / share
@property (nonatomic, copy, nullable) NSString *url;          ///< 操作目标 URL、deeplink 或电话号码

/// @param dict JSON 字典，通常来自 actions[] 元素
+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

/// 卡片 header 段，各 display_type 通用
@interface MagicCardHeader : NSObject

@property (nonatomic, copy, nullable) NSString *title;                 ///< 主标题
@property (nonatomic, copy, nullable) NSString *subtitle;              ///< 副标题或状态描述
@property (nonatomic, copy, nullable) NSString *icon;                  ///< 图标标识，端上映射本地资源
@property (nonatomic, copy, nullable) NSArray<NSString *> *tags;       ///< 标签列表
@property (nonatomic, copy, nullable) NSDictionary *extra;             ///< 扩展字段，如 poi_category、起终点坐标

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

/// 卡片 footer 段，各 display_type 通用
@interface MagicCardFooter : NSObject

@property (nonatomic, copy, nullable) NSString *text;                          ///< 底部说明文案
@property (nonatomic, copy, nullable) NSArray<MagicCardAction *> *actions;     ///< 操作按钮列表
@property (nonatomic, copy, nullable) NSString *disclaimer;                    ///< 免责声明（如股票场景必填）
@property (nonatomic, copy, nullable) NSDictionary *extra;                     ///< 扩展字段

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

/**
 * 卡片业务数据 card_data。
 * 通用三段式结构 header + items + footer，items 内部 Schema 由 display_type 决定。
 */
@interface MagicCardData : NSObject

@property (nonatomic, strong, nullable) MagicCardHeader *header;
/// items 条目结构随 display_type 变化（键值对 / POI 列表 / 曲目等），保留字典数组便于协议扩展
@property (nonatomic, copy, nullable) NSArray<NSDictionary *> *items;
@property (nonatomic, strong, nullable) MagicCardFooter *footer;

/// @param dict card_data JSON 对象，或已序列化的 JSON 字符串解析后的字典
+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

/// 播报内容，仅在 response.card.data 中原子下发
@interface MagicCardBroadcast : NSObject

@property (nonatomic, copy, nullable) NSString *text; ///< 完整播报文本；TTS 音频仍走二进制帧，通过 response_id 关联

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

/**
 * 系列卡片分组信息 card_group。
 * 同一 group_id 的多张卡片聚合展示，按 sequence 排序，共 total 张。
 */
@interface MagicCardGroup : NSObject

@property (nonatomic, copy, nullable) NSString *group_id;     ///< 系列唯一 ID，组内所有卡片共享
@property (nonatomic, copy, nullable) NSString *group_title;  ///< 系列标题，可选
@property (nonatomic, assign) NSInteger sequence;             ///< 当前卡片在系列中的序号，从 1 开始
@property (nonatomic, assign) NSInteger total;                ///< 系列卡片总数

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

/**
 * session.created 响应中的 card_config，回显卡片能力协商结果。
 */
@interface MagicCardConfig : NSObject

@property (nonatomic, copy, nullable) NSString *session_mode;              ///< 生效的会话模式，如 @"card"
@property (nonatomic, copy, nullable) NSArray<NSString *> *supported_cards;  ///< 服务端实际支持的 card_type 列表

+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;
/// @param value card_config 字段，支持 NSDictionary 或 JSON 字符串
+ (nullable instancetype)modelWithJSONValue:(id)value;

@end

/**
 * 卡片事件信封 Card Envelope。
 * 统一承载 response.card.data / response.card.loading / response.card.error 三类事件。
 * 不同事件类型下部分字段为空，例如 loading 无 card_data，error 无 broadcast。
 */
@interface MagicCardEnvelope : NSObject

@property (nonatomic, copy, nullable) NSString *type;              ///< 事件类型，见 MagicCardEventType*
@property (nonatomic, copy, nullable) NSString *event_id;          ///< 服务端事件唯一 ID
@property (nonatomic, copy, nullable) NSString *session_id;        ///< 会话 ID
@property (nonatomic, copy, nullable) NSString *response_id;       ///< 本轮响应 ID，关联 TTS 音频帧
@property (nonatomic, copy, nullable) NSString *card_type;         ///< 业务类型，见 MagicCardType*
@property (nonatomic, copy, nullable) NSString *display_type;      ///< 展示类型，见 MagicCardDisplayType*（仅 card.data）
@property (nonatomic, copy, nullable) NSString *card_version;       ///< Schema 语义化版本号，如 @"1.0"
@property (nonatomic, copy, nullable) NSString *card_id;         ///< 卡片实例唯一 ID，用于去重或更新
@property (nonatomic, copy, nullable) NSString *display_title;     ///< 卡片顶部标题（data / loading）
@property (nonatomic, strong, nullable) MagicCardBroadcast *broadcast;  ///< 播报内容（仅 card.data）
@property (nonatomic, strong, nullable) MagicCardGroup *card_group;     ///< 系列分组（仅 card.data，单卡为 nil）
@property (nonatomic, strong, nullable) MagicCardData *card_data;       ///< 结构化业务数据（仅 card.data）
@property (nonatomic, copy, nullable) NSString *error_code;        ///< 错误码，见 MagicCardErrorCode*（仅 card.error）
@property (nonatomic, copy, nullable) NSString *error_message;   ///< 人类可读错误描述（仅 card.error）

/// @param dict WebSocket 文本消息解析后的 JSON 字典
+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;

/// @return type 是否为 response.card.data
- (BOOL)isCardData;
/// @return type 是否为 response.card.loading
- (BOOL)isCardLoading;
/// @return type 是否为 response.card.error
- (BOOL)isCardError;

@end

NS_ASSUME_NONNULL_END
