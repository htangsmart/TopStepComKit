//
//  TSNpkW30TscImageEncoder.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import "TSNpkResImageEncoder.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief W30 lossy encoder: TSC12A for images with alpha, TSC12 otherwise
 * @chinese W30 有损编码器：带透明用 TSC12A，否则用 TSC12
 *
 * @discussion
 * [EN]: Reports colorFormat 0x35 for TSC12A and 0x34 for TSC12. Input pixels are alpha-premultiplied, so the
 *       premultiplied flag is reported, matching what the dial tool writes for TSC images.
 * [CN]: TSC12A 报格式编号 0x35，TSC12 报 0x34。输入像素为预乘 alpha，因此上报预乘标志，与表盘工具对 TSC 图片的写法一致。
 */
@interface TSNpkW30TscImageEncoder : NSObject <TSNpkResImageEncoder>
@end

NS_ASSUME_NONNULL_END
