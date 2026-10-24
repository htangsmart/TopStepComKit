#import "TSKitBaseInterface.h"
#import "TSDeviceAudioRecordState.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Latest device-reported audio state callback, on the main queue.
 * @chinese 最近一次设备上报的录音状态回调，主线程执行。
 * @param state
 * EN: Audio state; unknown when unavailable.
 * CN: 录音状态，不可用时为 unknown。
 * @param error
 * EN: Query error; nil on success.
 * CN: 查询错误，成功时为 nil。
 */
typedef void(^TSDeviceAudioRecordStateBlock)(TSDeviceAudioRecordState state, NSError * _Nullable error);

/**
 * @brief Maximum audio duration callback, on the main queue.
 * @chinese 最大录音时长回调，主线程执行。
 * @param maximumDuration
 * EN: Minutes, 1 to 240; zero only on error.
 * CN: 分钟数，1～240；错误时为 0。
 * @param error
 * EN: Error; nil when a valid cached value is available.
 * CN: 错误；取得有效缓存时为 nil。
 */
typedef void(^TSDeviceAudioRecordDurationBlock)(NSUInteger maximumDuration, NSError * _Nullable error);

/**
 * @brief Ordinary audio recording stored on the device.
 * @chinese 保存在设备上的普通录音。
 * @discussion
 * EN: Completions run on the main queue. Command acceptance is not a state change
 *     or confirmation that a file has been saved. State queries read the latest device report.
 * CN: 回调在主线程执行。命令确认不代表状态已改变或文件已落盘；状态查询读取最近的设备上报。
 */
@protocol TSDeviceAudioRecordInterface <TSKitBaseInterface>

/**
 * @brief Whether maximum duration can be adjusted.
 * @chinese 是否支持调整最大录音时长，与普通录音能力分开判断。
 * @return
 * EN: YES when the ready device advertises duration adjustment.
 * CN: 就绪设备声明支持时长调整时返回 YES。
 */
- (BOOL)isSupportMaxAudioRecordDuration;

/**
 * @brief Start ordinary audio recording.
 * @chinese 开始普通录音。
 * @param completion
 * EN: Command acceptance or error, including any vendor status code.
 * CN: 命令确认或错误，错误保留厂商状态码。
 */
- (void)startAudioRecording:(TSCompletionBlock)completion;

/**
 * @brief Stop ordinary audio recording.
 * @chinese 停止普通录音。
 * @param completion
 * EN: Command acceptance or a confirmed stopped state, not file persistence confirmation.
 *     Buds waits for a new inactive report after a stop response indicating a file write in progress,
 *     within the original 15-second command timeout. Other errors are returned normally.
 * CN: 命令确认或停止状态确认，不表示文件已保存。
 *     Buds 停止回复为正在写文件时，等待本次请求后的有效未录音上报，仍受原 15 秒命令超时限制。
 *     其他错误正常返回。
 */
- (void)stopAudioRecording:(TSCompletionBlock)completion;

/**
 * @brief Read the latest device-reported recording state.
 * @chinese 读取设备最近上报的录音状态，不发送主动查询指令。
 * @param completion
 * EN: State or error on the main queue.
 * CN: 主线程返回状态或错误。
 */
- (void)getAudioRecordingState:(TSDeviceAudioRecordStateBlock)completion;

/**
 * @brief Replace the state listener and immediately deliver the current snapshot.
 * @chinese 替换状态监听器并立即回传当前快照。
 * @param handler
 * EN: Main-queue listener; nil unregisters it. Disconnect emits unknown.
 * CN: 主线程监听器，nil 取消注册；断开时上报 unknown。
 */
- (void)registerAudioRecordingStateChangedBlock:(nullable TSDeviceAudioRecordStateBlock)handler;

/**
 * @brief Set the maximum audio recording duration.
 * @chinese 设置最大录音时长。
 * @param maximumDuration
 * EN: Minutes, inclusive range 1 to 240.
 * CN: 分钟数，闭区间 1～240。
 * @param completion
 * EN: Setting result on the main queue.
 * CN: 主线程返回设置结果。
 */
- (void)setMaxAudioRecordDuration:(NSUInteger)maximumDuration completion:(TSCompletionBlock)completion;

/**
 * @brief Read the cached maximum duration reported by the device.
 * @chinese 读取设备上报的最大时长缓存。
 * @param completion
 * EN: Minutes or error; a missing value is an error, not zero minutes.
 * CN: 分钟数或错误，缓存缺失返回错误，不作为 0 分钟成功返回。
 */
- (void)getMaxAudioRecordDuration:(TSDeviceAudioRecordDurationBlock)completion;

@end

NS_ASSUME_NONNULL_END
