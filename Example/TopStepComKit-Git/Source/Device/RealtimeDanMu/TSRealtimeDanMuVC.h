//
//  TSRealtimeDanMuVC.h
//  TopStepComKit_Example
//

#import "TSBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Runtime danmaku demo page.
 * @chinese 实时弹幕演示页。
 *
 * @discussion
 * [EN]: Builds a queue of danmaku items, previews them against the connected device's real
 *       screen shape, and sends or clears them through `TSRealtimeDanMuInterface`.
 *       The page stays reachable on providers that do not support runtime danmaku so the
 *       "not supported" error path can be verified end to end.
 * [CN]: 构建弹幕队列，按已连接设备的真实屏幕形状预览，并通过 `TSRealtimeDanMuInterface`
 *       发送或清除。在不支持实时弹幕的 Provider 上页面同样可进入，以便端到端验证
 *       「不支持」错误链路。
 */
@interface TSRealtimeDanMuVC : TSBaseVC

@end

NS_ASSUME_NONNULL_END
