//
//  TSFitBleScanSession.h
//  TopStepFitKit
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class FitCloudPeripheral;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Owns FitCloud scanning, filtering and completion on the main thread.
 * @chinese 在主线程管理 FitCloud 扫描、过滤及结束回调，不决定连接与重试策略。
 */
@interface TSFitBleScanSession : NSObject

/** @brief SDK scan ownership. @chinese 当前扫描是否仍由 SDK 执行。 */
@property (nonatomic, assign, readonly, getter=isScanning) BOOL scanning;

/**
 * @brief Start a scan and replace the previous scan.
 * @chinese 结束上一轮扫描并启动新一轮扫描。
 * @param param Filters and timeout / 过滤条件及超时。
 * @param discovery Discovered peripheral callback / 外设发现回调。
 * @param completion Scan completion / 扫描结束回调。
 */
- (void)startWithParam:(nullable TSPeripheralScanParam *)param
            discovery:(TSScanDiscoveryBlock)discovery
           completion:(TSScanCompletionBlock)completion;

/**
 * @brief Finish the current scan once.
 * @chinese 先清理本轮状态，再停止 SDK 并回调，保证只结束一次。
 * @param reason Completion reason / 结束原因。
 * @param error Underlying error / 错误信息。
 * @param stopSDKScan Whether to stop the SDK scan / 是否停止底层扫描。
 */
- (void)finishWithReason:(TSScanCompletionReason)reason error:(nullable NSError *)error stopSDKScan:(BOOL)stopSDKScan;

/**
 * @brief Queue a discovery for the current scan generation.
 * @chinese 将发现事件投递到当前扫描轮次，旧轮次结果自动失效。
 * @param peripheral SDK peripheral / SDK 外设。
 * @param isUpdate Whether this updates a previous discovery / 是否为设备更新事件。
 */
- (void)handleDiscoveredPeripheral:(FitCloudPeripheral *)peripheral isUpdate:(BOOL)isUpdate;

/** @brief Handle SDK scan stop. @chinese 处理 SDK 主动停止扫描的事件。 */
- (void)handleSDKScanStopped;

/**
 * @brief Handle SDK scan startup failure.
 * @chinese 标记 SDK 已停止，并结束对应扫描轮次。
 * @param error SDK error / SDK 错误。
 */
- (void)handleSDKScanStartError:(nullable NSError *)error;

/**
 * @brief Map a scan result to a unified Bluetooth error.
 * @chinese 将扫描结束原因映射为统一蓝牙错误，保留底层原因。
 * @param reason Completion reason / 结束原因。
 * @param error Underlying error / 底层错误。
 * @return Unified Bluetooth error / 统一蓝牙错误。
 */
+ (NSError *)errorForCompletionReason:(TSScanCompletionReason)reason underlyingError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
