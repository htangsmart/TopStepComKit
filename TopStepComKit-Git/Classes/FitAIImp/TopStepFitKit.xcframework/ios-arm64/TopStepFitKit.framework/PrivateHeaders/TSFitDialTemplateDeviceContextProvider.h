//
//  TSFitDialTemplateDeviceContextProvider.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Provides current Fit device parameters for dial-template requests
 * @chinese 提供当前 Fit 设备的表盘模板请求参数
 */
@interface TSFitDialTemplateDeviceContextProvider : NSObject

/**
 * @brief Request current device parameters for a dial-template request
 * @chinese 请求当前设备的表盘模板参数
 *
 * @param completion
 * EN: Completion containing the parameter dictionary or an error.
 * CN: 返回参数字典或错误的完成回调。
 */
+ (void)requestDialTemplateParametersCompletion:(void (^)(NSDictionary *_Nullable parameters,
                                                            NSError *_Nullable error))completion;

/**
 * @brief Whether the connected device uses the NextGUI watch-face architecture
 * @chinese 当前连接设备是否使用 NextGUI 表盘架构
 *
 * @return
 * EN: YES when the connected firmware reports the NextGUI architecture.
 * CN: 当前固件声明使用 NextGUI 架构时返回 YES。
 */
+ (BOOL)isNextGUI;

@end

NS_ASSUME_NONNULL_END
