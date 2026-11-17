#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sources requested from the peripheral during one capture.
 * @chinese 本次抓取请求设备开启的日志来源，可按位组合。
 */
typedef NS_OPTIONS(NSUInteger, TSPeripheralRealtimeLogTypes) {
    /**
     * @brief Receive unsolicited logs only.
     * @chinese 只接收设备主动上报。
     */
    TSPeripheralRealtimeLogTypeNone = 0,
    /**
     * @brief Full device log. Wire command 0x01.
     * @chinese 设备全量日志，协议命令 0x01。
     */
    TSPeripheralRealtimeLogTypeFullLog = 1UL << 0,
    /**
     * @brief Raw sleep data. Wire command 0x02.
     * @chinese 睡眠原始数据，协议命令 0x02。
     */
    TSPeripheralRealtimeLogTypeSleepRaw = 1UL << 1,
    /**
     * @brief Raw step data. Wire command 0x03.
     * @chinese 计步原始数据，协议命令 0x03。
     */
    TSPeripheralRealtimeLogTypeStepRaw = 1UL << 2,
    /**
     * @brief Raw heart rate data. Wire command 0x04.
     * @chinese 心率原始数据，协议命令 0x04。
     */
    TSPeripheralRealtimeLogTypeHeartRateRaw = 1UL << 3,
    /**
     * @brief Power usage statistics. Wire command 0x05.
     * @chinese 电量使用统计，协议命令 0x05。
     */
    TSPeripheralRealtimeLogTypePowerStatistics = 1UL << 4,
    /**
     * @brief PCM audio data. Wire command 0x06.
     * @chinese 音频 PCM 数据，协议命令 0x06。
     */
    TSPeripheralRealtimeLogTypeAudioPCM = 1UL << 5,
    /**
     * @brief Device dump information. Wire command 0x07.
     * @chinese 设备 Dump 信息，协议命令 0x07。
     */
    TSPeripheralRealtimeLogTypeDumpInfo = 1UL << 6,
};

/**
 * @brief Realtime log capability of the selected BLE connection.
 * @chinese 当前选中 BLE 连接的实时日志能力。
 */
typedef NS_ENUM(NSUInteger, TSPeripheralRealtimeLogCapability) {
    /**
     * @brief The UART service or usable Notify characteristic is absent.
     * @chinese 缺少 UART 服务或可用的 Notify 特征。
     */
    TSPeripheralRealtimeLogCapabilityUnsupported = 0,
    /**
     * @brief The peripheral can send unsolicited logs through Notify.
     * @chinese 可通过 Notify 接收设备主动上报。
     */
    TSPeripheralRealtimeLogCapabilityReceiveOnly,
    /**
     * @brief The connection supports Notify and a usable Write characteristic.
     * @chinese 有可用的 Notify 与 Write 特征，可接收并下发控制命令。
     */
    TSPeripheralRealtimeLogCapabilityReceiveAndControl,
};

/**
 * @brief Current capture state on a peripheral log interface instance.
 * @chinese 单个外设日志接口实例的当前实时抓取状态。
 */
typedef NS_ENUM(NSUInteger, TSPeripheralRealtimeLogState) {
    /**
     * @brief No capture owns this instance.
     * @chinese 当前实例没有抓取占用。
     */
    TSPeripheralRealtimeLogStateIdle = 0,
    /**
     * @brief A start has been accepted and is being prepared.
     * @chinese 启动已受理，正在准备抓取。
     */
    TSPeripheralRealtimeLogStateStarting,
    /**
     * @brief Subscription and requested startup writes are ready.
     * @chinese 订阅和所选开启命令已完成 SDK 可观察的步骤。
     */
    TSPeripheralRealtimeLogStateRunning,
    /**
     * @brief The capture is cleaning up, delivering its terminal event, or releasing its slot.
     * @chinese 抓取正在清理、交付终态或释放占用。
     */
    TSPeripheralRealtimeLogStateStopping,
};

/**
 * @brief Lifecycle events for a single start request.
 * @chinese 一次启动请求的生命周期事件。
 */
typedef NS_ENUM(NSUInteger, TSPeripheralRealtimeLogEvent) {
    /**
     * @brief Confirms that a capture is active. For a newly started capture, Notify and the selected writes have completed their observable startup steps.
     * @chinese 确认抓取已开启。首次启动需完成 Notify 和所选命令中 SDK 可观察的启动步骤。
     */
    TSPeripheralRealtimeLogEventStarted = 0,
    /**
     * @brief A voluntary stop finished cleanup and drained accepted data.
     * @chinese 主动停止已完成收尾，已接收数据交付完毕。
     */
    TSPeripheralRealtimeLogEventStopped,
    /**
     * @brief The capture ended with an error. This is a terminal event.
     * @chinese 抓取因错误结束，为终态事件。
     */
    TSPeripheralRealtimeLogEventFailed,
};

/**
 * @brief Asynchronous result of a realtime log capability query.
 * @chinese 实时日志能力查询的异步结果。
 *
 * @param capability
 * EN: Verified capability. On error, its placeholder value is Unsupported.
 * CN: 已核实的能力等级。发生错误时以 Unsupported 作为占位值。
 * @param error
 * EN: Nil for a verified result. A nonnull error takes precedence over capability.
 * CN: 得到已核实的结果时为 nil。非空时，以错误为准。
 */
typedef void (^TSPeripheralRealtimeLogCapabilityBlock)(TSPeripheralRealtimeLogCapability capability,
                                                       NSError * _Nullable error);

/**
 * @brief Handler for a raw notification payload.
 * @chinese 一次 UART Notify 原始数据的回调。
 *
 * @param deviceIdentifier
 * EN: CBPeripheral.identifier.UUIDString captured when the request starts. Use it for local file grouping.
 * CN: 启动时冻结的 CBPeripheral.identifier.UUIDString，可用于划分本地文件目录。
 * @param data
 * EN: Owned snapshot of the notification bytes, in receive order.
 * CN: 按接收顺序交付的 Notify 字节副本。
 */
typedef void (^TSPeripheralRealtimeLogDataBlock)(NSString *deviceIdentifier, NSData *data);

/**
 * @brief Handler for capture lifecycle events.
 * @chinese 抓取生命周期事件回调。
 *
 * @param deviceIdentifier
 * EN: Original peripheral UUID string. Nil if the start request did not capture a ready connection.
 * CN: 原外设 UUID 字符串。启动请求未捕获到就绪连接时为 nil。
 * @param event
 * EN: The request that owns the capture receives at most one Started and exactly one terminal Stopped or Failed. A repeated start on an active capture receives only one Started. A rejected request receives only Failed.
 * CN: 建立抓取的请求最多收到一次 Started，并收到一次 Stopped 或 Failed。抓取已开启时重复启动只收到一次 Started。被拒绝的请求只收到 Failed。
 * @param error
 * EN: Present for Failed and nil for Started or Stopped.
 * CN: Failed 时非空，Started 和 Stopped 时为 nil。
 */
typedef void (^TSPeripheralRealtimeLogEventBlock)(NSString * _Nullable deviceIdentifier,
                                                 TSPeripheralRealtimeLogEvent event,
                                                 NSError * _Nullable error);

NS_ASSUME_NONNULL_END
