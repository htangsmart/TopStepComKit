//
//  MagicCardDefines.h
//  MagicHelper
//
//  卡片智能体协议常量定义，与《卡片协议.md》及 Android CardType / CardDisplayType / CardErrorCode 对齐。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Card Event Type（WebSocket 事件 type 字段）

/// 卡片数据事件：同时下发播报文本（broadcast.text）与卡片结构化数据（card_data）
FOUNDATION_EXPORT NSString * const MagicCardEventTypeData;
/// 卡片加载中事件：MCP/工具调用发起时下发，后续必跟随 Data 或 Error
FOUNDATION_EXPORT NSString * const MagicCardEventTypeLoading;
/// 卡片错误事件：卡片数据获取失败，不阻断 response.text.delta 降级播报
FOUNDATION_EXPORT NSString * const MagicCardEventTypeError;

#pragma mark - Session Mode（session.create config.session_mode）

/// 默认会话模式：纯语音对话，行为与接入卡片协议前完全一致
FOUNDATION_EXPORT NSString * const MagicCardSessionModeDefault;
/// 卡片智能体模式：服务端可下发 response.card.* 旁路事件
FOUNDATION_EXPORT NSString * const MagicCardSessionModeCard;

#pragma mark - Card Type（card_type，P0 第一批）

FOUNDATION_EXPORT NSString * const MagicCardTypeWeather;       ///< 天气查询
FOUNDATION_EXPORT NSString * const MagicCardTypeLocation;      ///< 位置查询（需经纬度）
FOUNDATION_EXPORT NSString * const MagicCardTypeScenicIntro;     ///< 景区介绍
FOUNDATION_EXPORT NSString * const MagicCardTypePoiSearch;     ///< 附近 POI 搜索（需经纬度）
FOUNDATION_EXPORT NSString * const MagicCardTypeNavigation;    ///< 导航（需经纬度）
FOUNDATION_EXPORT NSString * const MagicCardTypeMusic;         ///< 听音乐
FOUNDATION_EXPORT NSString * const MagicCardTypeStock;         ///< 股票行情

#pragma mark - Display Type（display_type，决定 card_data Schema 与渲染模板）

FOUNDATION_EXPORT NSString * const MagicCardDisplayTypeInfoDetail; ///< 信息详情卡：键值对列表
FOUNDATION_EXPORT NSString * const MagicCardDisplayTypeList;       ///< 列表卡：POI/商户条目
FOUNDATION_EXPORT NSString * const MagicCardDisplayTypeRoute;      ///< 路线卡：起终点 + 路线属性
FOUNDATION_EXPORT NSString * const MagicCardDisplayTypeMedia;      ///< 媒体卡：曲目/章节列表
FOUNDATION_EXPORT NSString * const MagicCardDisplayTypeProgress;   ///< 进度/状态卡：排队、物流等

#pragma mark - Error Code（response.card.error error_code）

FOUNDATION_EXPORT NSString * const MagicCardErrorCodeMcpTimeout;          ///< MCP/工具调用超时
FOUNDATION_EXPORT NSString * const MagicCardErrorCodeMcpError;           ///< MCP/工具调用返回错误
FOUNDATION_EXPORT NSString * const MagicCardErrorCodeLocationRequired;  ///< 需要经纬度但会话未提供
FOUNDATION_EXPORT NSString * const MagicCardErrorCodeLocationFailed;    ///< 定位服务异常
FOUNDATION_EXPORT NSString * const MagicCardErrorCodeUnsupportedCard;   ///< 服务端不支持该 card_type
FOUNDATION_EXPORT NSString * const MagicCardErrorCodeDataEmpty;          ///< 查询无结果
FOUNDATION_EXPORT NSString * const MagicCardErrorCodeRateLimited;         ///< 请求频率超限
FOUNDATION_EXPORT NSString * const MagicCardErrorCodeServiceUnavailable;  ///< 后端服务不可用

/**
 * P0 默认 card_capabilities 白名单。
 * 用于 session.create 时声明端上可渲染的 card_type，与服务端能力取交集。
 * @return 包含 weather/location/poi_search/scenic_intro/navigation/stock/music 的数组
 */
FOUNDATION_EXPORT NSArray<NSString *> * MagicCardDefaultCapabilities(void);

NS_ASSUME_NONNULL_END
