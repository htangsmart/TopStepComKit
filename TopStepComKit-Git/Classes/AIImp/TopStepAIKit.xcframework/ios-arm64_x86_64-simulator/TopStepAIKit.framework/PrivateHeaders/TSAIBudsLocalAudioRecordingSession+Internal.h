#import <Foundation/Foundation.h>
#import "TSAIAudioRecordConfig.h"
#import "TSAIAudioRecordSessionResult.h"
#import "TSAudioRecordInterface.h"

@protocol TSAINetworkStatusProvider;
@protocol TSAISystemAudioDriver;
@protocol AIBudsAIAudioRecordingServiceAPI;

NS_ASSUME_NONNULL_BEGIN

/** @brief Local capture with an optional cloud consumer @chinese 本地收音会话，云端仅作为可选的 PCM 消费者 */
@interface TSAIBudsLocalAudioRecordingSession : NSObject

/** @brief Whether an earlier cloud recording still owns its physical session
 * @chinese 之前的云端录音是否仍占用物理会话
 * @return EN: Whether the cloud recording is occupied. CN: 云端录音是否仍被占用。
 */
+ (BOOL)isCloudRecordingOccupied;

/** @brief Whether local input is active @chinese 本地输入是否仍在收音 */
@property (nonatomic, assign, readonly) BOOL isCapturing;

/** @brief Resolve the frozen owner's currently authorized cloud service
 * @chinese 动态解析冻结归属当前已鉴权的云服务；只用于显式开启的恢复策略
 */
@property (nonatomic, copy, nullable) id<AIBudsAIAudioRecordingServiceAPI> _Nullable (^serviceResolver)(void);

/** @brief Forward a real authorization change @chinese 转发真实鉴权状态变化 */
- (void)authorizationChanged;

/**
 * @brief Create an independent recording; call lifecycle methods on the main queue
 * @chinese 创建独立录音；生命周期方法在主队列调用
 * @param config EN: Frozen recording config. CN: 本次录音配置。
 * @param network EN: Shared network source. CN: 共用网络来源。
 * @param driver EN: Independent local input driver. CN: 独立本地输入驱动。
 * @param service EN: Authorized external-PCM service, or nil. CN: 已鉴权的外部 PCM 服务，允许为 nil。
 * @param audioHandler EN: Local PCM sink. CN: 本地 PCM 接收方。
 * @param resultHandler EN: Semantic result sink. CN: 语义结果接收方。
 * @param finishHandler EN: Local input completion. CN: 本地收音结束回调。
 * @return EN: Recording instance. CN: 录音实例。
 */
- (instancetype)initWithConfig:(TSAIAudioRecordConfig *)config
                       network:(nullable id<TSAINetworkStatusProvider>)network
                        driver:(id<TSAISystemAudioDriver>)driver
                       service:(nullable id<AIBudsAIAudioRecordingServiceAPI>)service
                  audioHandler:(nullable TSAudioRecordDataReceivedBlock)audioHandler
                 resultHandler:(nullable TSAIAudioRecordSessionResultHandler)resultHandler
                 finishHandler:(nullable TSAudioRecordFinishHandler)finishHandler;

/** @brief Start local input only @chinese 仅启动本地输入
 * @param error EN: Local input error. CN: 本地输入错误。
 * @return EN: Whether input started. CN: 本地输入是否启动成功。
 */
- (BOOL)startWithError:(NSError * _Nullable * _Nullable)error;
/** @brief Start optional transcription after local startup @chinese 本地启动后尝试转写，不影响收音 */
- (void)startTranscription;
/** @brief Append decoded device PCM @chinese 传入设备解码后的 PCM
 * @param data EN: 16 kHz mono Int16LE samples. CN: 16 kHz 单声道 Int16LE 数据。
 */
- (void)appendDevicePCM:(NSData *)data;
/** @brief Stop and seal local input exactly once @chinese 一次性结束本地输入
 * @param reason EN: Capture stop reason. CN: 收音结束原因。
 * @param error EN: Local capture error, if any. CN: 本地收音错误，可为空。
 */
- (void)stopWithReason:(TSAudioRecordStopReason)reason error:(nullable NSError *)error;

@end
NS_ASSUME_NONNULL_END
