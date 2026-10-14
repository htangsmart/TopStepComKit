//
//  TSNpkRealtimeDanMu.h
//  TopStepNewPlatformKit
//

#import "TSNpkKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK runtime danmaku adapter (unsupported).
 * @chinese NPK 实时弹幕适配器（不支持）。
 *
 * @discussion
 * [EN]: The NewPlatform provider has no runtime danmaku channel. Every API returns
 *       a "not support" error so callers get a deterministic result.
 * [CN]: NewPlatform 平台没有实时弹幕通道。所有接口均返回"不支持"错误，保证调用方拿到确定结果。
 */
@interface TSNpkRealtimeDanMu : TSNpkKitBase <TSRealtimeDanMuInterface>

@end

NS_ASSUME_NONNULL_END
