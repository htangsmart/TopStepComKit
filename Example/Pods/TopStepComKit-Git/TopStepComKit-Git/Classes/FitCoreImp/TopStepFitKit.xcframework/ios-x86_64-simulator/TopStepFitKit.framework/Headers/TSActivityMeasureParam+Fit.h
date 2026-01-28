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
 * @brief Convert TSMeasureParam to FitCloudRealTimeHealthMeasuringParam
 * @chinese 将TSMeasureParam转换为FitCloudRealTimeHealthMeasuringParam
 *
 * @param measureParam
 * EN: TSMeasureParam object to be converted
 * CN: 需要转换的TSMeasureParam对象
 *
 * @return
 * EN: Converted FitCloudRealTimeHealthMeasuringParam object
 * CN: 转换后的FitCloudRealTimeHealthMeasuringParam对象
 */
+ (FitCloudRealTimeHealthMeasuringParam *)startFitCloudMeasuringParamFromParam:(TSActivityMeasureParam *)measureParam;

+ (FitCloudRealTimeHealthMeasuringParam *)stopFitCloudMeasuringParam;

@end

NS_ASSUME_NONNULL_END
