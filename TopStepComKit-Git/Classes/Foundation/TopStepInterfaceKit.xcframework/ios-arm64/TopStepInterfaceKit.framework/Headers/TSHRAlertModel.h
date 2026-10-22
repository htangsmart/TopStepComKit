//
//  TSHRAlertModel.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Heart rate alert types
 * @chinese 心率告警类型
 *
 * @discussion
 * [EN]: Types may be combined for capability queries. An alert event contains one type or Unknown.
 *       Values are independent of vendor command values.
 * [CN]: 能力查询时可组合多个类型；一次告警事件只能包含一个类型或 Unknown。
 *       枚举值与厂商指令值无关。
 */
typedef NS_OPTIONS(NSUInteger, TSHRAlertType) {
    /**
     * @brief Unknown heart rate alert type
     * @chinese 未知心率告警类型
     */
    TSHRAlertTypeUnknown     = 0,

    /**
     * @brief Dynamic heart rate too high
     * @chinese 动态心率过高
     */
    TSHRAlertTypeDynamicHigh = 1UL << 0,

    /**
     * @brief Dynamic heart rate too low
     * @chinese 动态心率过低
     */
    TSHRAlertTypeDynamicLow  = 1UL << 1,

    /**
     * @brief Static heart rate too high
     * @chinese 静态心率过高
     */
    TSHRAlertTypeStaticHigh  = 1UL << 2,

    /**
     * @brief Static heart rate too low
     * @chinese 静态心率过低
     */
    TSHRAlertTypeStaticLow   = 1UL << 3
};

/**
 * @brief An immutable heart rate alert reported by a device.
 * @chinese 设备上报的一次心率告警，只读事件快照。
 */
@interface TSHRAlertModel : TSKitBaseModel

/**
 * @brief Alert receipt time
 * @chinese 告警接收时间
 *
 * @discussion
 * [EN]: The time when the SDK receives the alert, expressed as a Unix timestamp in seconds.
 * [CN]: SDK 接收到告警的时间，使用 Unix 时间戳，单位为秒。
 *
 * @note
 * [EN]: Must be finite and positive. This is not the start time of the abnormal heart rate.
 * [CN]: 必须为有限正数；此时间不表示心率异常开始时间。
 */
@property (nonatomic, assign, readonly) NSTimeInterval receiveTime;

/**
 * @brief Heart rate alert type
 * @chinese 心率告警类型
 *
 * @discussion
 * [EN]: Identifies a dynamic or static heart rate alert and whether it is too high or too low.
 * [CN]: 表示本次设备上报的动态或静态心率过高、过低告警。
 *
 * @note
 * [EN]: Must be one known type or Unknown. Combined types are invalid for an event.
 * [CN]: 只能为一个已知类型或 Unknown；一次事件不允许组合多个类型。
 */
@property (nonatomic, assign, readonly) TSHRAlertType type;

/**
 * @brief Heart rate value
 * @chinese 心率值
 *
 * @discussion
 * [EN]: The heart rate reported with the alert, measured in beats per minute (BPM).
 * [CN]: 本次告警上报的心率值，单位为每分钟心跳次数（BPM）。
 *
 * @note
 * [EN]: A value of 0 is invalid.
 * [CN]: 0 为无效值。
 */
@property (nonatomic, assign, readonly) UInt8 hrValue;

/**
 * @brief Heart rate alert threshold
 * @chinese 心率告警阈值
 *
 * @discussion
 * [EN]: The threshold for this alert, in BPM. Fit uses the trigger threshold reported in the event.
 *       Providers without an event threshold may supply the latest confirmed configuration for this type;
 *       that fallback may differ from the trigger threshold.
 * [CN]: 本次告警对应的阈值，单位为每分钟心跳次数（BPM）。Fit 使用事件中设备上报的触发阈值。
 *       未上报阈值的平台可补充最近确认的对应类型的配置值，该补充值不保证等于触发阈值。
 *
 * @note
 * [EN]: Nil if unavailable or invalid. A supplied value must be a finite positive integer.
 * [CN]: 未取得或无效时为 nil；提供的数值必须为有限正整数。
 */
@property (nonatomic, copy, readonly, nullable) NSNumber *threshold;

/**
 * @brief Create an alert snapshot; use doesModelHasError to validate its values.
 * @chinese 创建告警快照；通过 doesModelHasError 校验字段值。
 *
 * @param type
 * EN: One alert type or Unknown; combined types are invalid for an event.
 * CN: 一个告警类型或 Unknown；一次事件不允许组合多个类型。
 *
 * @param hrValue
 * EN: Reported heart rate in BPM.
 * CN: 上报心率，单位次/分。
 *
 * @param threshold
 * EN: Alert threshold, or nil if unknown.
 * CN: 告警阈值，未知为 nil。
 *
 * @param receiveTime
 * EN: SDK receipt time in Unix seconds.
 * CN: SDK 接收时间，Unix 秒。
 *
 * @return
 * EN: Alert snapshot.
 * CN: 告警快照。
 */
- (instancetype)initWithType:(TSHRAlertType)type
                     hrValue:(UInt8)hrValue
                   threshold:(nullable NSNumber *)threshold
                 receiveTime:(NSTimeInterval)receiveTime NS_DESIGNATED_INITIALIZER;

/**
 * @brief Use the designated initializer.
 * @chinese 请使用指定初始化方法。
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Use the designated initializer.
 * @chinese 请使用指定初始化方法。
 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
