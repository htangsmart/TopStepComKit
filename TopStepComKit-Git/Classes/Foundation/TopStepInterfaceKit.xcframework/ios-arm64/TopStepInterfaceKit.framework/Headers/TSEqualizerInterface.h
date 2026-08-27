//
//  TSEqualizerInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/28.
//

#import "TSKitBaseInterface.h"
#import "TSEqualizerModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Get equalizer model callback
 * @chinese 获取均衡器模型回调
 *
 * @param equalizerModel
 * EN: Current equalizer model, nil if retrieval fails
 * CN: 当前均衡器模型，获取失败时为 nil
 *
 * @param error
 * EN: Error information, nil if successful
 * CN: 错误信息，成功时为 nil
 */
typedef void(^TSEqualizerModelResultBlock)(TSEqualizerModel * _Nullable equalizerModel, NSError * _Nullable error);

/**
 * @brief Device equalizer management interface
 * @chinese 设备均衡器管理接口
 *
 * @discussion
 * EN: This interface defines all equalizer related operations, including:
 *     1. Check whether the device supports equalizer capability
 *     2. Get the current equalizer configuration from the device
 *     3. Set the equalizer configuration to the device
 *     4. Get built-in preset equalizer models for UI display and quick selection
 * CN: 该接口定义了与设备均衡器相关的全部操作，包括：
 *     1. 检查设备是否支持均衡器能力
 *     2. 获取设备当前均衡器配置
 *     3. 设置设备均衡器配置
 *     4. 获取内置均衡器预设，便于 UI 展示与快捷选择
 *
 * @note
 * EN: Use the inherited isSupport method from TSKitBaseInterface to check whether the device supports equalizer.
 * CN: 是否支持均衡器请调用 TSKitBaseInterface 继承的 isSupport 方法。
 */
@protocol TSEqualizerInterface <TSKitBaseInterface>

/**
 * @brief Get current equalizer model
 * @chinese 获取当前均衡器模型
 *
 * @param completion
 * EN: Completion callback
 *     - equalizerModel: Current equalizer model, nil if retrieval fails
 *     - error: Error information if failed, nil if successful
 * CN: 获取完成的回调
 *     - equalizerModel: 当前均衡器模型，获取失败时为 nil
 *     - error: 获取失败时的错误信息，成功时为 nil
 */
- (void)getCurrentEqualizerModel:(nullable TSEqualizerModelResultBlock)completion;

/**
 * @brief Set equalizer model
 * @chinese 设置均衡器模型
 *
 * @param equalizerModel
 * EN: Equalizer model to set
 * CN: 要设置的均衡器模型
 *
 * @param completion
 * EN: Completion callback
 *     - success: Whether the operation was successful
 *     - error: Error information if failed, nil if successful
 * CN: 设置完成的回调
 *     - success: 是否设置成功
 *     - error: 设置失败时的错误信息，成功时为 nil
 */
- (void)setEqualizerModel:(TSEqualizerModel *)equalizerModel
               completion:(TSCompletionBlock)completion;

/**
 * @brief Get built-in preset equalizer models
 * @chinese 获取内置均衡器预设列表
 *
 * @return
 * EN: Built-in preset equalizer model list, including Default, Pop, Rock, Jazz, Classical and Country.
 * CN: 内置均衡器预设列表，包含默认、流行、摇滚、爵士、古典、乡村。
 *
 * @discussion
 * EN: These preset models are local metadata definitions and can be used directly for UI rendering and quick selection.
 * CN: 这些预设模型是本地元数据定义，可直接用于 UI 展示和快捷选择。
 */
- (NSArray<TSEqualizerModel *> *)presetEqualizerModels;

@end

NS_ASSUME_NONNULL_END
