//
//  TSActivityMeasureParam+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/3/5.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudRealTimeHealthMeasuringParam;
NS_ASSUME_NONNULL_BEGIN

@interface TSActivityMeasureParam (Fit)

/**
 * @brief Convert legacy measurement parameters using the original minute conversion.
 * @chinese 使用原有分钟换算转换旧版测量参数。
 * @param measureParam Measurement parameters / 测量参数。
 * @return FitCloudKit parameter / FitCloudKit 测量参数。
 */
+ (FitCloudRealTimeHealthMeasuringParam *)startFitCloudMeasuringParamFromParam:(TSActivityMeasureParam *)measureParam;

/**
 * @brief Convert TSMeasureParam to FitCloudRealTimeHealthMeasuringParam
 * @chinese 将TSMeasureParam转换为FitCloudRealTimeHealthMeasuringParam
 *
 * @param measureParam
 * EN: TSMeasureParam object to be converted
 * CN: 需要转换的TSMeasureParam对象
 * @param roundUpDuration
 * EN: Round the device limit up for a host-timed measurement.
 * CN: SDK 定时停止时，将设备端时长上限向上换算为整分钟。
 *
 * @return
 * EN: Converted FitCloudRealTimeHealthMeasuringParam object
 * CN: 转换后的FitCloudRealTimeHealthMeasuringParam对象
 */
+ (FitCloudRealTimeHealthMeasuringParam *)startFitCloudMeasuringParamFromParam:(TSActivityMeasureParam *)measureParam
                                                             roundUpDuration:(BOOL)roundUpDuration;

+ (FitCloudRealTimeHealthMeasuringParam *)stopFitCloudMeasuringParam;

@end

NS_ASSUME_NONNULL_END
