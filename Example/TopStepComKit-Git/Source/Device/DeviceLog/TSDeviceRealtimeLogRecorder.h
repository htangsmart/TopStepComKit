#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TSPeripheralLogInterface.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Posted on the main thread after the recorder changes.
 * @chinese 抓取状态或文件结果变化后在主线程发送。
 */
FOUNDATION_EXPORT NSNotificationName const TSDeviceRealtimeLogRecorderDidChangeNotification;

/**
 * @brief Owns a Demo capture independently of view controller lifetimes. Use on the main thread.
 * @chinese 在页面之外管理一次 Demo 抓取。请在主线程使用。
 */
@interface TSDeviceRealtimeLogRecorder : NSObject

/** @brief Types selected in the Demo. @chinese Demo 中选择的日志类型。 */
@property (nonatomic, assign, readonly) TSPeripheralRealtimeLogTypes selectedTypes;
/** @brief Last capture error. @chinese 最近一次抓取错误。 */
@property (nonatomic, strong, readonly, nullable) NSError *lastError;
/** @brief Effective types on the current capture. @chinese 本次抓取实际生效的日志类型。 */
@property (nonatomic, assign, readonly) TSPeripheralRealtimeLogTypes captureTypes;
/** @brief Bytes received for the current or last capture. @chinese 当前或上一次抓取收到的字节数。 */
@property (atomic, assign, readonly) uint64_t receivedBytes;
/** @brief Files created for the current or last capture. @chinese 当前或上一次抓取创建的文件数。 */
@property (atomic, assign, readonly) NSUInteger savedFileCount;
/** @brief Elapsed capture time in seconds. @chinese 当前或上一次抓取的时长，单位为秒。 */
@property (nonatomic, assign, readonly) NSTimeInterval elapsedDuration;
/** @brief Whether the last capture finished. @chinese 当前是否已有抓取结果。 */
@property (nonatomic, assign, readonly) BOOL hasCaptureResult;

/**
 * @brief Return the recorder shared by Demo pages.
 * @chinese 获取 Demo 各页面共享的抓取器。
 *
 * @return Shared recorder / 共享抓取器。
 */
+ (instancetype)sharedRecorder;

/**
 * @brief Start a capture using the selected type mask for the current device.
 * @chinese 按当前设备可用的类型启动抓取。
 *
 * @param peripheralLog Current log interface / 当前日志能力实例。
 * @param types Effective types for this capture / 本次抓取生效的类型。
 */
- (void)startWithPeripheralLog:(id<TSPeripheralLogInterface>)peripheralLog
                        types:(TSPeripheralRealtimeLogTypes)types;

/**
 * @brief Apply the type selection and restart an active capture after a successful stop.
 * @chinese 修改选中的类型，抓取中则在停止成功后重新开启。
 *
 * @param types New type selection / 新选中的类型。
 * @param peripheralLog Current log interface / 当前日志接口。
 */
- (void)updateSelectedTypes:(TSPeripheralRealtimeLogTypes)types
              peripheralLog:(id<TSPeripheralLogInterface>)peripheralLog;

/**
 * @brief Stop the current capture and cancel any pending restart.
 * @chinese 停止当前抓取并取消待执行的重启。
 */
- (void)stopRecording;

/**
 * @brief Clear the displayed capture error.
 * @chinese 清除界面显示的抓取错误。
 */
- (void)clearError;

@end

NS_ASSUME_NONNULL_END
