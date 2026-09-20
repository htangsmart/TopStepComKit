//
//  TSRealtimeDanMuInterface.h
//  TopStepInterfaceKit
//

#import "TSKitBaseInterface.h"
#import "TSDanMuItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Runtime danmaku interface.
 * @chinese 实时弹幕接口。
 *
 * @discussion
 * [EN]: Provides immediate danmaku commands for a supported watch. This interface is
 *       separate from TSPeripheralDialInterface, whose danmaku APIs build watch face packages.
 * [CN]: 为支持的手表提供即时弹幕指令。此接口与用于生成弹幕表盘包的 TSPeripheralDialInterface 独立。
 */
@protocol TSRealtimeDanMuInterface <TSKitBaseInterface>

/**
 * @brief Sends runtime danmaku items to the device.
 * @chinese 向设备发送实时弹幕项。
 * @param items EN: Items to send. CN: 要发送的弹幕项。
 * @param completion EN: Completion callback. CN: 完成回调。
 *
 * @discussion
 * [EN]: An empty array is a successful no-op. Completion is delivered on the main thread.
 * [CN]: 空数组视为成功无操作。完成回调在主线程执行。
 */
- (void)addDanMuItems:(NSArray<TSDanMuItem *> *)items
           completion:(nullable TSCompletionBlock)completion;

/**
 * @brief Clears runtime danmaku by scope.
 * @chinese 按范围清除实时弹幕。
 * @param scope EN: Clear scope. CN: 清除范围。
 * @param completion EN: Completion callback. CN: 完成回调。
 */
- (void)clearDanMuWithScope:(TSDanMuClearScope)scope
                  completion:(nullable TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
