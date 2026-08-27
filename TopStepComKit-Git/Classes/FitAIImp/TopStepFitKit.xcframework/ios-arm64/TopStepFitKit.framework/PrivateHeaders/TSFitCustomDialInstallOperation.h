//
//  TSFitCustomDialInstallOperation.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSFitCustomDialTemplateResolver;

NS_ASSUME_NONNULL_BEGIN

/** @brief Pushes a created custom-dial binary @chinese 推送已创建的自定义表盘二进制 */
typedef void (^TSFitCustomDialPushHandler)(NSString *filePath,
                                           TSDialProgressBlock _Nullable progressBlock,
                                           TSDialCompletionBlock completion);

/**
 * @brief Owns one Fit custom-dial resolve, create and push flow
 * @chinese 持有一次 Fit 自定义表盘解析、组盘与推送流程
 */
@interface TSFitCustomDialInstallOperation : NSObject

/**
 * @brief Initialize one installation operation
 * @chinese 初始化一次安装操作
 * @param customDial EN: Custom-dial input. CN: 自定义表盘输入模型。
 * @param resolver EN: Fit template resolver. CN: Fit 模板解析器。
 * @param isNextGUI EN: Whether the device uses NextGUI. CN: 设备是否使用 NextGUI。
 * @param backgroundImage EN: Prepared background image. CN: 已准备的背景图。
 * @param previewImage EN: Prepared preview image. CN: 已准备的预览图。
 * @param positionValue EN: Fit time position. CN: Fit 时间位置。
 * @param styleValue EN: Optional Fit style value. CN: 可选的 Fit 样式值。
 * @param progressBlock EN: Dial-push progress. CN: 表盘推送进度回调。
 * @param pushHandler EN: Provider push handler. CN: Provider 推送处理器。
 * @param completion EN: Main-thread final completion. CN: 主线程最终完成回调。
 * @return EN: Initialized operation, or nil. CN: 初始化后的操作，参数无效时为 nil。
 */
- (nullable instancetype)initWithCustomDial:(TSCustomDial *)customDial
                                   resolver:(TSFitCustomDialTemplateResolver *)resolver
                                  isNextGUI:(BOOL)isNextGUI
                            backgroundImage:(UIImage *)backgroundImage
                               previewImage:(UIImage *)previewImage
                              positionValue:(NSInteger)positionValue
                                 styleValue:(nullable NSNumber *)styleValue
                              progressBlock:(nullable TSDialProgressBlock)progressBlock
                                pushHandler:(TSFitCustomDialPushHandler)pushHandler
                                 completion:(TSDialCompletionBlock)completion NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/** @brief Start the operation once @chinese 启动一次操作 */
- (void)start;
/** @brief Cancel the active phase @chinese 取消当前阶段 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
