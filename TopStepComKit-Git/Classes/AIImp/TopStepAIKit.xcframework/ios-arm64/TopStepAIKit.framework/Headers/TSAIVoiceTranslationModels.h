#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Phone translation configuration
 * @chinese 手机双向语音翻译配置
 */
@interface TSAIVoiceTranslationConfig : NSObject <NSCopying>
/**
 * @brief Left-side service language code
 * @chinese 左侧服务语种代码
 * @discussion
 * [EN]: Use a code returned by supportedLanguages.
 * [CN]: 使用 supportedLanguages 返回的代码。
 * @note
 * [EN]: Defaults to zh-CN.
 * [CN]: 默认 zh-CN。
 */
@property (nonatomic, copy) NSString *leftLanguage;
/**
 * @brief Right-side service language code
 * @chinese 右侧服务语种代码
 * @discussion
 * [EN]: This is the target when the left side speaks.
 * [CN]: 左侧发言时，此语种为目标语言。
 * @note
 * [EN]: Defaults to en-US.
 * [CN]: 默认 en-US。
 */
@property (nonatomic, copy) NSString *rightLanguage;
/**
 * @brief Whether the right side speaks in this turn
 * @chinese 本轮是否由右侧发言
 * @discussion
 * [EN]: Stop the previous turn before changing direction.
 * [CN]: 更换方向前先停止上一轮。
 * @note
 * [EN]: Defaults to NO.
 * [CN]: 默认 NO。
 */
@property (nonatomic, assign) BOOL rightSideSpeaking;
/**
 * @brief Validate required language codes
 * @chinese 校验必填语言代码
 * @param error
 * EN: Receives a standard invalid-parameter error for empty codes.
 * CN: 空代码时接收标准参数错误。
 * @return
 * EN: YES when both language strings contain non-whitespace text.
 * CN: 两个语言字符串均含非空白内容时返回 YES。
 */
- (BOOL)validateWithError:(NSError *_Nullable *_Nullable)error;
@end

/**
 * @brief Latest snapshot of one phone translation record
 * @chinese 一条手机翻译记录的最新快照
 */
@interface TSAIVoiceTranslationRecord : NSObject <NSCopying>
/**
 * @brief Stable source-record key
 * @chinese 稳定的来源记录键
 * @discussion
 * [EN]: Includes the service session and message identity.
 * [CN]: 包含服务会话和消息身份。
 * @note
 * [EN]: Never use translated text as the key.
 * [CN]: 不能使用译文内容作为记录键。
 */
@property (nonatomic, copy) NSString *recordIdentifier;
/**
 * @brief Capability instance that supplied this record
 * @chinese 提供记录的能力实例范围
 * @discussion
 * [EN]: Prevents reusing another Context's record for playback or deletion.
 * [CN]: 防止使用其他 Context 的记录播放或删除。
 * @note
 * [EN]: Does not prove server-side account isolation.
 * [CN]: 不证明服务端已按账号隔离。
 */
@property (nonatomic, copy) NSString *scopeIdentifier;
/**
 * @brief Recognized source text
 * @chinese 识别出的原文
 * @discussion
 * [EN]: Replace the displayed text when the snapshot changes.
 * [CN]: 快照变化时替换显示内容。
 * @note
 * [EN]: May be revised by later service results.
 * [CN]: 后续服务结果可能修订此值。
 */
@property (nonatomic, copy) NSString *originalText;
/**
 * @brief Translated text
 * @chinese 翻译文本
 * @discussion
 * [EN]: Cumulative text rather than an append-only delta.
 * [CN]: 为累计文本，不是只追加的增量。
 * @note
 * [EN]: No final flag is implied by a nonempty value.
 * [CN]: 非空值不代表文本已经定稿。
 */
@property (nonatomic, copy) NSString *translatedText;
/**
 * @brief Source-side direction of the record
 * @chinese 记录的源语言方向
 * @discussion
 * [EN]: YES denotes right to left.
 * [CN]: YES 表示从右侧翻译到左侧。
 * @note
 * [EN]: Copied from the service record.
 * [CN]: 从服务记录复制。
 */
@property (nonatomic, assign) BOOL rightSideSpeaking;
/**
 * @brief Service timestamp used for record operations
 * @chinese 记录操作使用的服务时间戳
 * @discussion
 * [EN]: Preserve the original identifier without converting units.
 * [CN]: 保留原始标识，不自行换算时间单位。
 * @note
 * [EN]: Empty when absent in the source record.
 * [CN]: 来源记录缺失时为空。
 */
@property (nonatomic, copy) NSString *sourceTimestamp;
@end

NS_ASSUME_NONNULL_END
