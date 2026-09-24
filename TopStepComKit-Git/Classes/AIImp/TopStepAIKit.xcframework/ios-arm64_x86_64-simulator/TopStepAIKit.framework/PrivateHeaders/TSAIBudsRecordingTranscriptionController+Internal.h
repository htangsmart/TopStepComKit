#import <Foundation/Foundation.h>
#import "TSAIAudioRecordConfig.h"
#import "TSAIAudioRecordSessionResult.h"
@protocol TSAINetworkStatusProvider, AIBudsAIAudioRecordingServiceAPI;
NS_ASSUME_NONNULL_BEGIN

/** @brief Recording-wide cloud recovery and transcript ledger @chinese 整次录音的云端恢复与转写账本 */
@interface TSAIBudsRecordingTranscriptionController : NSObject
/** @brief Injectable monotonic clock @chinese 可注入的单调时钟，默认使用系统运行时间 */
@property (nonatomic, copy) NSTimeInterval (^clock)(void);
/** @brief Resolve the original owner's currently authorized service @chinese 解析原归属当前已鉴权的服务 */
@property (nonatomic, copy, nullable) id<AIBudsAIAudioRecordingServiceAPI> _Nullable (^serviceResolver)(void);
/** @brief Create a recording controller @chinese 创建录音转写控制器
 * @param config EN: Frozen configuration. CN: 冻结配置。
 * @param network EN: Shared network source. CN: 共用网络来源。
 * @param handler EN: Main-queue results. CN: 主队列结果。
 * @return EN: Controller. CN: 控制器。
 */
- (instancetype)initWithConfig:(TSAIAudioRecordConfig *)config
                       network:(nullable id<TSAINetworkStatusProvider>)network
                       handler:(nullable TSAIAudioRecordSessionResultHandler)handler;
/** @brief Begin recovery scheduling @chinese 开始恢复调度 */
- (void)start;
/** @brief Re-evaluate current environment @chinese 环境事实变化后重新评估 */
- (void)environmentChanged;
/** @brief Re-evaluate after authorization changes @chinese 鉴权变化后重新评估，不等待新的网络事件 */
- (void)authorizationChanged;
/** @brief Accept PCM after local persistence @chinese 本地写入后接收 PCM
 * @param data EN: 16 kHz mono Int16 PCM. CN: 16 kHz 单声道 Int16 PCM。
 */
- (void)appendPCM:(NSData *)data;
/** @brief Close recovery while preserving tail results @chinese 关闭恢复并保留尾部结果 */
- (void)finish;
/** @brief Read the current completeness snapshot @chinese 读取当前完整性快照
 * @return EN: Snapshot. CN: 状态快照。
 */
- (TSAIAudioRecordSessionResult *)snapshot;
/** @brief Extract plain text from vendor report items @chinese 从厂商报告条目提取纯文本：JSON 包装对象只取 transcript 字段，空正文丢弃
 * @param transcripts EN: Raw report items; nil is treated as empty. CN: 原始报告条目，nil 按空数组处理。
 * @return EN: Non-empty plain texts in original order. CN: 保持原顺序的非空纯文本。
 */
+ (NSArray<NSString *> *)plainTranscriptsFromReportTranscripts:(nullable NSArray<NSString *> *)transcripts;
@end
NS_ASSUME_NONNULL_END
