//
//  TSBinImageTableItem.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/5.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
/**
 * Bin 文件图片索引表模型
 * 对应 IMAGE_TABLE 中单个图片的「地址+大小」
 */
@interface TSBinImageTableItem : NSObject

/// 图片数据在 Bin 文件中的起始地址（偏移）
@property (nonatomic, assign) uint32_t imageAddress;
/// 图片数据的总大小（字节）
@property (nonatomic, assign) uint32_t imageSize;

@end

NS_ASSUME_NONNULL_END
