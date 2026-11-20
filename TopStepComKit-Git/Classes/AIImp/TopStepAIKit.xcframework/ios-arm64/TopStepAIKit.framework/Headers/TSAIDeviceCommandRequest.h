#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Neutral device command type
 * @chinese 中立设备指令类型
 */
typedef NS_ENUM(NSInteger, TSAIDeviceCommandType) {
    TSAIDeviceCommandTypeUnknown = 0,
    TSAIDeviceCommandTypeCreateAlarm,
    TSAIDeviceCommandTypeCreateItinerary,
    TSAIDeviceCommandTypeStartAudioRecording,
    TSAIDeviceCommandTypeStopAudioRecording,
    TSAIDeviceCommandTypeTakePhoto,
    TSAIDeviceCommandTypeStartVideoRecording,
    TSAIDeviceCommandTypeStopVideoRecording,
    TSAIDeviceCommandTypePlayMusic,
    TSAIDeviceCommandTypeStopMusic,
    TSAIDeviceCommandTypeNextTrack,
    TSAIDeviceCommandTypePreviousTrack,
    TSAIDeviceCommandTypeDecreaseVolume,
    TSAIDeviceCommandTypeIncreaseVolume,
    TSAIDeviceCommandTypeAnswerCall,
    TSAIDeviceCommandTypeEndCall,
};

/**
 * @brief One received device command
 * @chinese 一次接收到的设备指令
 */
@interface TSAIDeviceCommandRequest : NSObject <NSCopying>

/**
 * @brief Client receipt identifier
 * @chinese 客户端本次接收标识
 * @discussion
 * [EN]: Generated once per received callback.
 * [CN]: 每次收到回调时生成。
 * @note
 * [EN]: Not a vendor idempotency key.
 * [CN]: 不等于厂商幂等标识。
 */
@property (nonatomic, copy) NSString *commandIdentifier;

/**
 * @brief Source chat task
 * @chinese 来源聊天任务
 * @discussion
 * [EN]: Bound by the provider callback.
 * [CN]: 由 Provider 回调绑定。
 * @note
 * [EN]: Empty identifiers cannot authorize execution.
 * [CN]: 空标识不能授权执行。
 */
@property (nonatomic, copy) NSString *sourceTaskIdentifier;

/**
 * @brief Source provider identifier
 * @chinese 来源 Provider 标识
 * @discussion
 * [EN]: Must match the current Context.
 * [CN]: 必须匹配当前 Context。
 * @note
 * [EN]: No SDK model type is exposed.
 * [CN]: 不暴露厂商模型类型。
 */
@property (nonatomic, copy) NSString *providerIdentifier;

/**
 * @brief Expected device identifier
 * @chinese 预期设备标识
 * @discussion
 * [EN]: Captured when the command is received.
 * [CN]: 接收指令时捕获。
 * @note
 * [EN]: Rechecked before each device write.
 * [CN]: 每次下发前重新检查。
 */
@property (nonatomic, copy) NSString *deviceIdentifier;

/**
 * @brief Context activation associated with execution
 * @chinese 执行所属的 Context 激活标识
 * @discussion
 * [EN]: Filled by the Core coordinator.
 * [CN]: 由 Core 协调器填写。
 * @note
 * [EN]: Rechecked after asynchronous reads.
 * [CN]: 异步读取后再次检查。
 */
@property (nonatomic, copy, nullable) NSString *activationToken;

/**
 * @brief Parsed command type
 * @chinese 解析后的指令类型
 * @discussion
 * [EN]: Does not imply firmware support.
 * [CN]: 不代表固件支持。
 * @note
 * [EN]: Defaults to Unknown.
 * [CN]: 默认 Unknown。
 */
@property (nonatomic, assign) TSAIDeviceCommandType type;

/**
 * @brief Neutral JSON-compatible parameters
 * @chinese 可 JSON 表示的中立参数
 * @discussion
 * [EN]: Schedule entries use time and content strings.
 * [CN]: 日程条目使用 time 和 content 字符串。
 * @note
 * [EN]: Unsupported extra fields are rejected.
 * [CN]: 不支持的额外字段明确拒绝。
 */
@property (nonatomic, copy) NSDictionary<NSString *, id> *parameters;

/**
 * @brief Host time zone used to interpret a timezone-less schedule
 * @chinese 无时区日程按宿主解释时采用的时区
 * @discussion
 * [EN]: Captured explicitly at receipt time.
 * [CN]: 接收时显式捕获。
 * @note
 * [EN]: This is host policy, not an inferred backend guarantee.
 * [CN]: 属于宿主策略，不冒充后台保证。
 */
@property (nonatomic, copy) NSString *interpretationTimeZoneIdentifier;

/**
 * @brief Parsing failure carried to the public result stream
 * @chinese 传递给公开结果流的解析错误
 * @discussion
 * [EN]: Invalid commands are visible without device effects.
 * [CN]: 非法指令可观察且无设备副作用。
 * @note
 * [EN]: Nil for successfully parsed input.
 * [CN]: 解析成功时为 nil。
 */
@property (nonatomic, strong, nullable) NSError *validationError;

/**
 * @brief Validate exact minute-precision schedule entries
 * @chinese 校验严格的分钟精度日程条目
 * @param now
 * EN: Execution-time reference.
 * CN: 执行时的当前时间。
 * @param error
 * EN: Receives unsupported or invalid fields.
 * CN: 接收不支持或非法字段错误。
 * @return
 * EN: Entries containing date/content, or nil.
 * CN: 包含 date/content 的条目，失败为 nil。
 */
- (nullable NSArray<NSDictionary<NSString *, id> *> *)resolvedScheduleEntriesWithNow:(NSDate *)now
                                                                              error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
