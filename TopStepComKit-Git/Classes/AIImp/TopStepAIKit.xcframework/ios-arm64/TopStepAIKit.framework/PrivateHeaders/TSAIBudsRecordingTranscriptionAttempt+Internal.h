#import <Foundation/Foundation.h>
#import "TSAIAudioRecordConfig.h"

@protocol AIBudsAIAudioRecordingServiceAPI;
@class AIBudsStreamSpeechASRModel, AIBudsAIAudioRecordingReportModel;
NS_ASSUME_NONNULL_BEGIN

/** @brief One exclusively owned cloud recording attempt @chinese 独占云端资源的一次录音转写尝试 */
@interface TSAIBudsRecordingTranscriptionAttempt : NSObject
/** @brief Unique runtime owner @chinese 唯一的运行时所有者标识 */
@property (nonatomic, copy, readonly) NSString *identifier;
/** @brief First accepted PCM sample @chinese 首个接收的 PCM 样本位置 */
@property (nonatomic, assign, readonly) NSUInteger startSample;
/** @brief Whether any PCM has been accepted @chinese 是否已接收 PCM */
@property (nonatomic, assign, readonly) BOOL hasPCM;
/** @brief Session available callback @chinese 厂商会话可输入回调，不代表识别就绪 */
@property (nonatomic, copy, nullable) void (^startedHandler)(void);
/** @brief Transcript callback on main queue @chinese 主队列文字回调 */
@property (nonatomic, copy, nullable) void (^transcriptHandler)(AIBudsStreamSpeechASRModel *model);
/** @brief Failure callback on main queue @chinese 主队列错误回调 */
@property (nonatomic, copy, nullable) void (^failureHandler)(NSError *error);
/** @brief Terminal report after queue drain @chinese 队列排空后的真实终态报告 */
@property (nonatomic, copy, nullable) void (^releasedHandler)(AIBudsAIAudioRecordingReportModel * _Nullable report);
/** @brief Create a cloud attempt @chinese 创建云端尝试
 * @param service EN: Fixed vendor service. CN: 固定厂商实例。
 * @param config EN: Frozen config. CN: 冻结配置。
 * @return EN: Attempt. CN: 云端尝试。
 */
- (instancetype)initWithService:(id<AIBudsAIAudioRecordingServiceAPI>)service config:(TSAIAudioRecordConfig *)config;
/** @brief Acquire and start @chinese 获取识别租约并启动
 * @return EN: Whether the runtime was acquired. CN: 是否取得租约。
 */
- (BOOL)start;
/** @brief Reserve bounded PCM before dispatch @chinese 在派发前预留有限 PCM
 * @param data EN: PCM bytes. CN: PCM 字节。
 * @param sampleOffset EN: Recording sample offset. CN: 录音样本偏移。
 * @return EN: Whether accepted. CN: 是否接收成功。
 */
- (BOOL)appendPCM:(NSData *)data sampleOffset:(NSUInteger)sampleOffset;
/** @brief Stop once without releasing before terminal @chinese 请求一次停止，真实终态前不释放
 * @param discard EN: Drop unsent audio on failure. CN: 故障时丢弃未发送音频。
 */
- (void)stopDiscardingPendingPCM:(BOOL)discard;
/** @brief Query recording runtime ownership @chinese 查询录音云端资源占用
 * @return EN: Whether owned. CN: 是否被占用。
 */
+ (BOOL)isOccupied;
@end
NS_ASSUME_NONNULL_END
