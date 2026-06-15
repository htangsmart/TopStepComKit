//
//  TSANCInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/28.
//

#import "TSKitBaseInterface.h"
#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief ANC mode
 * @chinese ANC 模式
 */
typedef NS_ENUM(NSUInteger, TSANCMode) {
    TSANCModeUnknown = 0,             ///< 未知模式
    TSANCModeOff,                     ///< 关闭
    TSANCModeNoiseCancellation,       ///< 主动降噪
    TSANCModeTransparency,            ///< 通透模式
    TSANCModeAdaptive                 ///< 自适应模式
};

/**
 * @brief Noise cancellation level
 * @chinese 降噪强度等级
 */
typedef NS_ENUM(NSUInteger, TSANCNoiseCancellationLevel) {
    TSANCNoiseCancellationLevelUnknown = 0,   ///< 未知等级
    TSANCNoiseCancellationLevelLow,           ///< 低强度
    TSANCNoiseCancellationLevelMedium,        ///< 中强度
    TSANCNoiseCancellationLevelHigh           ///< 高强度
};

/**
 * @brief ANC model
 * @chinese ANC 模型
 *
 * @discussion
 * EN: This model describes the current ANC configuration of the device,
 *     including mode, noise cancellation level and optional enhancement states.
 * CN: 此模型描述设备当前的 ANC 配置，包括模式、降噪强度等级和可选增强状态。
 */
@interface TSANCModel : TSKitBaseModel

/**
 * @brief ANC mode
 * @chinese ANC 模式
 */
@property (nonatomic, assign) TSANCMode mode;

/**
 * @brief Noise cancellation level
 * @chinese 降噪强度等级
 *
 * @discussion
 * EN: This property is only meaningful when the current mode is noise cancellation.
 * CN: 该属性仅在当前模式为主动降噪时有效。
 */
@property (nonatomic, assign) TSANCNoiseCancellationLevel noiseCancellationLevel;

/**
 * @brief Wind noise reduction enabled state
 * @chinese 风噪抑制开关状态
 */
@property (nonatomic, assign, getter=isWindNoiseReductionEnabled) BOOL windNoiseReductionEnabled;

/**
 * @brief Voice enhancement enabled state
 * @chinese 人声增强开关状态
 */
@property (nonatomic, assign, getter=isVoiceEnhancementEnabled) BOOL voiceEnhancementEnabled;

@end

/**
 * @brief ANC model result callback
 * @chinese ANC 模型结果回调
 *
 * @param ancModel
 * EN: Current ANC model, nil if retrieval fails
 * CN: 当前 ANC 模型，获取失败时为 nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSANCModelResultBlock)(TSANCModel * _Nullable ancModel, NSError * _Nullable error);

/**
 * @brief ANC strength result callback
 * @chinese ANC 强度结果回调
 *
 * @param strength
 * EN: Current noise cancellation strength, range 0~100, 0 if retrieval fails
 * CN: 当前降噪强度值，范围 0~100，获取失败时为 0
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSANCStrengthResultBlock)(NSInteger strength, NSError * _Nullable error);

/**
 * @brief Device ANC management interface
 * @chinese 设备 ANC 管理接口
 *
 * @discussion
 * EN: This interface defines all ANC related operations, including:
 *     1. Get current ANC configuration
 *     2. Set ANC configuration
 *     3. Set ANC mode or noise cancellation level separately
 *     4. Check whether optional ANC features are supported
 *     5. Register ANC change notifications
 * CN: 该接口定义了与 ANC 相关的全部操作，包括：
 *     1. 获取当前 ANC 配置
 *     2. 设置 ANC 配置
 *     3. 单独设置 ANC 模式或降噪强度等级
 *     4. 检查可选 ANC 功能是否支持
 *     5. 注册 ANC 变化监听
 */
@protocol TSANCInterface <TSKitBaseInterface>

/**
 * @brief Get current ANC model
 * @chinese 获取当前 ANC 模型
 *
 * @param completion
 * EN: Completion callback
 *     - ancModel: Current ANC model, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - ancModel: 当前 ANC 模型，获取失败时为 nil
 *     - error: 获取失败时的错误信息，成功时为 nil
 */
- (void)getANCModel:(nullable TSANCModelResultBlock)completion;

/**
 * @brief Set ANC model
 * @chinese 设置 ANC 模型
 *
 * @param ancModel
 * EN: ANC model to set
 * CN: 要设置的 ANC 模型
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 */
- (void)setANCModel:(TSANCModel *)ancModel
         completion:(TSCompletionBlock)completion;

/**
 * @brief Set ANC mode
 * @chinese 设置 ANC 模式
 *
 * @param mode
 * EN: ANC mode to set
 * CN: 要设置的 ANC 模式
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 */
- (void)setANCMode:(TSANCMode)mode
        completion:(TSCompletionBlock)completion;

/**
 * @brief Set noise cancellation level
 * @chinese 设置降噪强度等级
 *
 * @param level
 * EN: Noise cancellation level to set
 * CN: 要设置的降噪强度等级
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: This method is only meaningful when the current mode is noise cancellation.
 * CN: 该方法仅在当前模式为主动降噪时有效。
 */
- (void)setNoiseCancellationLevel:(TSANCNoiseCancellationLevel)level
                       completion:(TSCompletionBlock)completion;

/**
 * @brief Set raw ANC gain
 * @chinese 直接设置原始 ANC 增益值
 *
 * @param gain
 * EN: Raw ANC gain value to set, range 0~100
 * CN: 要设置的原始 ANC 增益值，范围 0~100
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: This method is intended for advanced scenarios that require direct access
 *     to the raw ANC gain parameter provided by the underlying device API.
 * CN: 该方法用于需要直接访问底层设备 API 原始 ANC 增益参数的高级场景。
 */
- (void)setANCGain:(NSInteger)gain
        completion:(TSCompletionBlock)completion;

/**
 * @brief Set transparency gain
 * @chinese 设置通透增益值
 *
 * @param gain
 * EN: Transparency gain value to set, range 0~100
 * CN: 要设置的通透增益值，范围 0~100
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 *
 * @discussion
 * EN: This method is intended for advanced scenarios that require direct control
 *     of transparency gain provided by the underlying device API.
 * CN: 该方法用于需要直接控制底层设备 API 提供的通透增益参数的高级场景。
 */
- (void)setTransparencyGain:(NSInteger)gain
                 completion:(TSCompletionBlock)completion;

/**
 * @brief Set ANC mode switch fade effect enabled state
 * @chinese 设置 ANC 模式切换淡入淡出效果开关
 *
 * @param enabled
 * EN: YES to enable fade effect when switching ANC mode, NO to disable it
 * CN: 传 YES 表示开启 ANC 模式切换时的淡入淡出效果，NO 表示关闭
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 */
- (void)setANCModeSwitchFadeEffectEnabled:(BOOL)enabled
                               completion:(TSCompletionBlock)completion;


/**
 * @brief Check whether ANC mode is supported
 * @chinese 检查 ANC 模式是否支持
 *
 * @param mode
 * EN: ANC mode
 * CN: ANC 模式
 *
 * @return
 * EN: YES if supported, otherwise NO
 * CN: 支持返回 YES，否则返回 NO
 */
- (BOOL)isANCModeSupported:(TSANCMode)mode;

/**
 * @brief Check whether noise cancellation level adjustment is supported
 * @chinese 检查是否支持降噪强度等级调节
 *
 * @return
 * EN: YES if supported, otherwise NO
 * CN: 支持返回 YES，否则返回 NO
 */
- (BOOL)isNoiseCancellationLevelSupported;

/**
 * @brief Check whether wind noise reduction is supported
 * @chinese 检查是否支持风噪抑制
 *
 * @return
 * EN: YES if supported, otherwise NO
 * CN: 支持返回 YES，否则返回 NO
 */
- (BOOL)isWindNoiseReductionSupported;

/**
 * @brief Check whether voice enhancement is supported
 * @chinese 检查是否支持人声增强
 *
 * @return
 * EN: YES if supported, otherwise NO
 * CN: 支持返回 YES，否则返回 NO
 */
- (BOOL)isVoiceEnhancementSupported;

/**
 * @brief Register ANC changed notify
 * @chinese 注册 ANC 变化监听
 *
 * @param completion
 * EN: completion invoked when device ANC configuration changes
 *     - ancModel: Latest ANC model, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 设备 ANC 配置变化时回调
 *     - ancModel: 最新 ANC 模型，获取失败时为 nil
 *     - error: 获取失败时的错误信息，成功时为 nil
 */
- (void)registerANCDidChanged:(nullable TSANCModelResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
