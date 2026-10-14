//
//  TSFitActiveMeasure.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/3/5.
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitActiveMeasure : TSFitKitBase<TSActiveMeasureInterface>

/**
 * @brief Start a measurement with a single terminal callback.
 * @chinese 启动有终态回调的测量，回调在主线程执行且终态最多一次。
 * @param param Measurement parameters / 测量参数。
 * @param startHandler Start result / 启动结果，提前结束时返回失败。
 * @param endHandler Terminal result / 结束结果，未佩戴使用 TSErrorDeviceNotWorn。
 * @return No return value / 无返回值。
 */
+ (void)startManagedMeasureWithParam:(TSActivityMeasureParam *)param
                        startHandler:(nullable TSCompletionBlock)startHandler
                          endHandler:(nullable TSCompletionBlock)endHandler;

/**
 * @brief Stop only the matching active measurement, coalescing pending stops.
 * @chinese 只停止匹配类型的当前测量，并合并正在进行的停止请求。
 * @param param Measurement type / 测量类型。
 * @param completion Stop command result / 停止指令结果。
 * @return No return value / 无返回值。
 */
+ (void)stopManagedMeasureWithParam:(TSActivityMeasureParam *)param
                        completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Forward a FitCloud measurement error to the active session.
 * @chinese 将 FitCloud 测量错误传给当前会话，无活跃会话时忽略。
 * @param errorCode Vendor reason / 厂商原因码。
 * @return No return value / 无返回值。
 */
+ (void)handleMeasurementError:(FitCloudRealTimeDataMeasurementErrorCode)errorCode;


@end

NS_ASSUME_NONNULL_END
