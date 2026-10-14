//
//  TSFitMediaFileCallbackGuard.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One-shot guard for vendor completion callbacks
 * @chinese 厂商回调一次性守卫
 *
 * FitCloudKit 在“命令等待超时”与“BLE 断连清理”同一时刻发生时，会对同一条命令各回调一次失败
 * （FitCloudCommunicator commandExecuteTimeOut 与 clearExecutingCommandQueue 之间没有互斥）。
 * TSMediaFileInterface 承诺 completion 恰好回调一次，所以 TSFitMediaFile 内所有厂商回调
 * 都必须先经过该守卫，重复回调只记录告警并丢弃。
 */
@interface TSFitMediaFileCallbackGuard : NSObject

/**
 * @brief Create a guard for one vendor operation
 * @chinese 为一次厂商操作创建守卫
 *
 * @param operation EN: Operation name used in the duplicate-callback log
 *                  CN: 用于重复回调日志的操作名
 */
- (instancetype)initWithOperation:(NSString *)operation;

/**
 * @brief Claim the single delivery right
 * @chinese 占用唯一一次回调权
 *
 * @param error EN: Vendor error of this callback, only used for logging
 *              CN: 本次回调携带的厂商错误，仅用于日志
 * @return EN: YES on the first call, NO for every later call
 *         CN: 首次调用返回 YES，之后始终返回 NO
 */
- (BOOL)acceptCallbackWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
