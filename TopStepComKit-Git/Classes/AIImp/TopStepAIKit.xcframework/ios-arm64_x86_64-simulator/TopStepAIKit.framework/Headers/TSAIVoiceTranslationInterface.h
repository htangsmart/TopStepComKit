#import <Foundation/Foundation.h>
#import "TSAIContractDefines.h"
#import "TSAIVoiceTranslationModels.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Snapshot observer for phone translation
 * @chinese 手机翻译记录快照观察者
 * @param records
 * EN: Latest records; entries may be revised later.
 * CN: 最新记录，内容后续仍可能修订。
 */
typedef void (^TSAIVoiceTranslationRecordsBlock)(NSArray<TSAIVoiceTranslationRecord *> *records);

/**
 * @brief Phone-microphone two-language translation
 * @chinese 使用手机麦克风的双语翻译
 */
@protocol TSAIVoiceTranslationInterface <NSObject>
/**
 * @brief Whether the service is enabled for the current identity
 * @chinese 当前身份是否已开通该服务
 * @return
 * EN: YES when available.
 * CN: 可用时返回 YES。
 */
- (BOOL)isVoiceTranslationSupported;
/**
 * @brief Return the currently allowed language codes
 * @chinese 返回当前允许使用的语种代码
 * @return
 * EN: Service codes, or an empty list when unavailable.
 * CN: 服务语种代码，不可用时为空列表。
 */
- (NSArray<NSString *> *)supportedLanguages;
/**
 * @brief Start one source-side translation turn
 * @chinese 启动一个方向的翻译轮次
 * @param config
 * EN: Languages and speaking side, copied on entry.
 * CN: 语种和发言方向，调用时复制。
 * @param onRecords
 * EN: Main-thread snapshot updates, or nil.
 * CN: 主线程快照更新回调，可空。
 * @param completion
 * EN: Main-thread logical stop or failure, called once; late service records are not a final-result guarantee.
 * CN: 主线程调用一次的逻辑停止或失败通知，不保证服务端迟到结果已经排空。
 * @return
 * EN: Client task identifier.
 * CN: 客户端任务标识。
 */
- (NSString *)startTranslationWithConfig:(TSAIVoiceTranslationConfig *)config
                               onRecords:(nullable TSAIVoiceTranslationRecordsBlock)onRecords
                              completion:(nullable TSAICompletionBlock)completion;
/**
 * @brief Stop the matching turn
 * @chinese 停止匹配的翻译轮次
 * @param taskId
 * EN: Task returned by start; unknown tasks have no side effects.
 * CN: start 返回的任务标识，未知任务无副作用。
 */
- (void)stopTranslationWithTaskId:(NSString *)taskId;
/**
 * @brief Delete explicitly selected local records
 * @chinese 删除明确选中的本地记录
 * @param records
 * EN: Records to remove.
 * CN: 需要删除的记录。
 * @param completion
 * EN: Main-thread operation result.
 * CN: 主线程操作结果。
 */
- (void)deleteTranslationRecords:(NSArray<TSAIVoiceTranslationRecord *> *)records
                       completion:(nullable TSAICompletionBlock)completion;
/**
 * @brief Request native playback of one historical translation
 * @chinese 请求原生播放一条历史翻译
 * @param record
 * EN: Record from this identity.
 * CN: 当前身份的记录。
 * @param completion
 * EN: Whether playback was accepted, not an audio-ended notification.
 * CN: 播放是否被接受，不表示音频已播放完。
 * @discussion
 * [EN]: The SDK provides no playback-ended callback. Explicitly stop playback before switching businesses.
 * [CN]: SDK 没有播放完成回调，切换业务前必须显式停止播放。
 */
- (void)playTranslationRecord:(TSAIVoiceTranslationRecord *)record
                    completion:(nullable TSAICompletionBlock)completion;
/**
 * @brief Stop this service's historical playback
 * @chinese 停止本服务的历史播报
 */
- (void)stopTranslationPlayback;
@end

NS_ASSUME_NONNULL_END
