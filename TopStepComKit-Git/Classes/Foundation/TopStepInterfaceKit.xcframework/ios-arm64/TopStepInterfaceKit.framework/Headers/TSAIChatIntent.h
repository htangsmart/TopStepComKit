//
//  TSAIChatIntent.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/5/18.
//

#import <Foundation/Foundation.h>
#import "TSAIDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Recognized command-style intent within an AI chat session
 * @chinese AI 对话会话中识别到的指令型意图
 *
 * @discussion
 * [EN]: A "command" extracted from the user's utterance that the host App is
 *       expected to execute (e.g. "turn up the volume", "start navigation").
 *       The `intentId` is a string defined by the AI provider — the App
 *       routes by intentId, while `value` / `valueDictionary` carry the
 *       extracted slot data (e.g. target volume level, destination name).
 *
 *       Intents are delivered through `onContent` with
 *       `contentType = TSAIChatContentTypeIntent` so they remain temporally
 *       aligned with the question / answer text and audio of the same round.
 *
 * [CN]: 从用户话语中抽取出的"指令"，需要 App 真正去执行
 *       （如"调高音量"、"开始导航"）。
 *       `intentId` 是 AI 提供方定义的字符串，App 据此路由；
 *       `value` / `valueDictionary` 携带抽出的槽位信息（如目标音量、目的地名称）。
 *
 *       意图通过 `onContent` 以 `contentType = TSAIChatContentTypeIntent` 下发，
 *       与同一轮的问题 / 回答文本和音频在时序上保持对齐。
 */
@interface TSAIChatIntent : NSObject

/**
 * @brief Recognized intent type
 * @chinese 识别到的意图类型
 *
 * @discussion
 * [EN]: Strongly-typed intent for `switch`-based dispatch. When the vendor
 *       returns an intent outside the protocol-layer enum, this is set to
 *       `TSAIChatIntentTypeUnknown` and the raw vendor string is available
 *       in `intentId`.
 * [CN]: 强类型意图，便于 `switch` 分发。
 *       当 vendor 抛出协议层枚举未覆盖的意图时，此字段为
 *       `TSAIChatIntentTypeUnknown`，vendor 原始字符串可在 `intentId` 中获取。
 */
@property (nonatomic, assign) TSAIChatIntentType type;

/**
 * @brief Vendor-defined raw intent identifier (fallback)
 * @chinese vendor 定义的原始意图标识（兜底字段）
 *
 * @discussion
 * [EN]: Raw intent string from the underlying AI provider. Acts as a fallback
 *       channel: when `type` is `Unknown`, callers may still react based on
 *       this string. For values already covered by `type`, this field is
 *       informational only.
 * [CN]: 底层 AI 提供方返回的原始意图字符串。
 *       作为兜底通道：当 `type` 为 `Unknown` 时，调用方可基于此字符串自行处理；
 *       对于已被 `type` 覆盖的取值，本字段仅作信息字段。
 */
@property (nonatomic, copy, nullable) NSString *intentId;

/**
 * @brief User utterance that triggered this intent
 * @chinese 触发该意图的用户原句
 *
 * @discussion
 * [EN]: The verbatim user query that the AI classified into this intent.
 *       Intent callbacks typically arrive *after* the corresponding Question
 *       text (ASR text comes first, intent classification follows). Carrying
 *       `query` on the intent itself spares callers from maintaining a
 *       round-to-question lookup just to know which utterance fired the
 *       command.
 * [CN]: 被 AI 归类到该意图的用户原句。
 *       意图回调通常**晚于**对应的 Question 文本到达（ASR 文本先到，意图分类后到），
 *       将 `query` 直接挂在意图上，调用方就无需为了"是哪句话触发了这个指令"
 *       而额外维护一份轮次到问题文本的映射。
 */
@property (nonatomic, copy) NSString *query;

/**
 * @brief Extracted scalar value, if any
 * @chinese 抽取出的标量值（若有）
 *
 * @discussion
 * [EN]: Plain string slot (e.g. `"80"` for "set volume to 80"). Use
 *       `valueDictionary` for structured multi-slot data.
 * [CN]: 纯字符串槽位（如"音量调到 80"中的 `"80"`）。
 *       多槽位结构化数据请使用 `valueDictionary`。
 */
@property (nonatomic, copy, nullable) NSString *value;

/**
 * @brief Extracted multi-slot value dictionary, if any
 * @chinese 抽取出的多槽位字典（若有）
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *valueDictionary;

@end

NS_ASSUME_NONNULL_END
