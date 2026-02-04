//
//  TSECGValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/4/17.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Electrocardiogram data model
 * @chinese 心电图数据模型
 *
 * @discussion
 * [EN]: This model represents electrocardiogram (ECG/EKG) data, which records the electrical activity of the heart.
 * ECG data is used to detect heart abnormalities, arrhythmias, and assess overall cardiac health.
 * [CN]: 该模型表示心电图(ECG/EKG)数据，记录心脏的电活动。
 * 心电图数据用于检测心脏异常、心律不齐和评估整体心脏健康状况。
 */
@interface TSECGValueItem : TSHealthValueItem

/**
 * @brief Raw ECG waveform data points
 * @chinese 原始心电图波形数据点
 *
 * @discussion
 * [EN]: Array of numerical values representing the ECG waveform. 
 * These values represent the electrical potential measured in millivolts (mV).
 * [CN]: 表示心电图波形的数值数组。
 * 这些值表示以毫伏(mV)为单位测量的电位。
 */
@property (nonatomic, strong) NSArray<NSNumber *> *waveformData;

/**
 * @brief Sampling rate of the ECG recording in Hz
 * @chinese 心电图记录的采样率(Hz)
 *
 * @discussion
 * [EN]: The number of samples recorded per second, typically 125Hz, 250Hz, or 500Hz for consumer devices.
 * [CN]: 每秒记录的样本数，消费级设备通常为125Hz、250Hz或500Hz。
 */
@property (nonatomic, assign) NSInteger samplingRate;

/**
 * @brief Heart rate calculated from the ECG in beats per minute (BPM)
 * @chinese 从心电图计算的心率，单位为每分钟心跳次数(BPM)
 *
 * @discussion
 * [EN]: The average heart rate calculated from the R-R intervals in the ECG recording.
 * [CN]: 从心电图记录中的R-R间隔计算的平均心率。
 */
@property (nonatomic, assign) NSInteger heartRate;

/**
 * @brief Heart rate variability metrics derived from the ECG
 * @chinese 从心电图派生的心率变异性指标
 *
 * @discussion
 * [EN]: Dictionary containing various HRV metrics such as SDNN, RMSSD, pNN50, etc.
 * [CN]: 包含各种HRV指标的字典，如SDNN、RMSSD、pNN50等。
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *hrvMetrics;

/**
 * @brief Duration of the ECG recording in seconds
 * @chinese 心电图记录的持续时间(秒)
 */
@property (nonatomic, assign) NSTimeInterval recordingDuration;

/**
 * @brief Classification of the ECG rhythm
 * @chinese 心电图节律的分类
 *
 * @discussion
 * [EN]: The algorithm's interpretation of the heart rhythm (e.g., "Normal Sinus Rhythm", "Atrial Fibrillation", etc.)
 * [CN]: 算法对心律的解释(例如，"正常窦性心律"、"心房颤动"等)
 */
@property (nonatomic, copy) NSString *rhythmClassification;

/**
 * @brief Confidence level of the rhythm classification (0.0 to 1.0)
 * @chinese 节律分类的置信度(0.0到1.0)
 */
@property (nonatomic, assign) CGFloat classificationConfidence;

/**
 * @brief QT interval in milliseconds
 * @chinese QT间隔，单位为毫秒
 *
 * @discussion
 * [EN]: The time from the start of the Q wave to the end of the T wave, representing ventricular depolarization and repolarization.
 * [CN]: 从Q波开始到T波结束的时间，表示心室去极化和复极化。
 */
@property (nonatomic, assign) NSInteger qtInterval;

/**
 * @brief Corrected QT interval (QTc) in milliseconds
 * @chinese 校正QT间隔(QTc)，单位为毫秒
 *
 * @discussion
 * [EN]: QT interval corrected for heart rate, typically using Bazett's formula.
 * [CN]: 针对心率校正的QT间隔，通常使用Bazett公式。
 */
@property (nonatomic, assign) NSInteger qtcInterval;

/**
 * @brief PR interval in milliseconds
 * @chinese PR间隔，单位为毫秒
 *
 * @discussion
 * [EN]: The time from the start of the P wave to the start of the QRS complex.
 * [CN]: 从P波开始到QRS波群开始的时间。
 */
@property (nonatomic, assign) NSInteger prInterval;

/**
 * @brief QRS duration in milliseconds
 * @chinese QRS持续时间，单位为毫秒
 *
 * @discussion
 * [EN]: The duration of the QRS complex, representing ventricular depolarization.
 * [CN]: QRS波群的持续时间，表示心室去极化。
 */
@property (nonatomic, assign) NSInteger qrsDuration;

/**
 * @brief ST segment elevation/depression in millimeters
 * @chinese ST段抬高/压低，单位为毫米
 *
 * @discussion
 * [EN]: The deviation of the ST segment from the baseline, positive for elevation, negative for depression.
 * [CN]: ST段相对于基线的偏差，正值表示抬高，负值表示压低。
 */
@property (nonatomic, assign) CGFloat stDeviation;

/**
 * @brief Additional notes or observations about the ECG
 * @chinese 关于心电图的附加说明或观察
 */
@property (nonatomic, copy, nullable) NSString *notes;

/**
 * @brief Flag indicating if the recording has been reviewed by a healthcare professional
 * @chinese 标志，表示记录是否已由医疗专业人员审查
 */
@property (nonatomic, assign) BOOL isReviewed;


/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 *
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic,assign) BOOL isUserInitiated;

@end

NS_ASSUME_NONNULL_END
