//
//  TSAIDailyGuidanceResult.h
//  TopStepInterfaceKit
//

#import <Foundation/Foundation.h>
#import "TSAIDailyGuidanceDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI daily guidance result model
 * @chinese AI每日健康引导结果模型
 *
 * @discussion
 * [EN]: This class represents the user-facing daily health guidance result.
 * It contains only content that apps can display or store directly.
 *
 * [CN]: 该类表示面向用户的每日健康引导结果。
 * 仅包含App可直接展示或存储的内容。
 */
@interface TSAIDailyGuidanceResult : NSObject <NSCopying>

/**
 * @brief Guidance date
 * @chinese 健康引导日期
 *
 * @discussion
 * [EN]: Date for which this guidance result was generated.
 *
 * [CN]: 本次健康引导结果对应的日期。
 */
@property (nonatomic, strong, nullable) NSDate *date;

/**
 * @brief Main guidance text
 * @chinese 主引导文案
 *
 * @discussion
 * [EN]: Main conclusion generated from the current daily health status.
 * Usually displayed as the primary text in a card or popup.
 *
 * [CN]: 根据当日健康状态生成的主结论。
 * 通常作为卡片或弹窗中的主要文案展示。
 */
@property (nonatomic, copy) NSString *mainText;

/**
 * @brief Action item list
 * @chinese 行动建议列表
 *
 * @discussion
 * [EN]: Specific lifestyle suggestions generated for the user.
 * Usually contains 2-3 short action items.
 *
 * [CN]: 为用户生成的具体生活方式建议。
 * 通常包含2-3条简短行动建议。
 */
@property (nonatomic, copy) NSArray<NSString *> *actionItems;

/**
 * @brief Health guidance disclaimer
 * @chinese 健康引导免责声明
 *
 * @discussion
 * [EN]: Disclaimer text for the generated guidance.
 * This guidance is not intended for medical diagnosis or treatment.
 *
 * [CN]: 生成结果对应的免责声明文案。
 * 该建议不作为医疗诊断或治疗依据。
 */
@property (nonatomic, copy) NSString *disclaimer;

@end

NS_ASSUME_NONNULL_END
