//
//  TSFwRealtimeDanMu.h
//  TopStepPersimwearKit
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Persimwear runtime danmaku adapter (unsupported).
 * @chinese Persimwear 实时弹幕适配器（不支持）。
 *
 * @discussion
 * [EN]: The Persimwear provider has no runtime danmaku channel. Every API returns
 *       a "not support" error so callers get a deterministic result.
 * [CN]: Persimwear 平台没有实时弹幕通道。所有接口均返回"不支持"错误，保证调用方拿到确定结果。
 */
@interface TSFwRealtimeDanMu : TSFwKitBase <TSRealtimeDanMuInterface>

@end

NS_ASSUME_NONNULL_END
