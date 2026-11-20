//
//  TSFitEqualizer.h
//  TopStepFitKit
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Adapts FitCloud earbuds presets to the unified equalizer interface.
 * @chinese 将 FitCloud 耳机预设适配到统一均衡器接口。
 *
 * @discussion
 * [EN]: Supports six built-in presets. Gain curves are not exposed by FitCloud;
 *       preset models contain an empty gain array. Custom equalizers are rejected.
 *       Read and write requests are submitted on the caller's thread;
 *       completions are delivered asynchronously on the main queue, including validation failures.
 * [CN]: 支持六档内置预设。FitCloud 不公开增益曲线，预设模型的增益数组为空；
 *       不接受自定义均衡器。读写请求在调用线程提交，完成回调（包括校验失败）均在主队列异步交付。
 */
@interface TSFitEqualizer : TSFitKitBase <TSEqualizerInterface>

@end

NS_ASSUME_NONNULL_END
