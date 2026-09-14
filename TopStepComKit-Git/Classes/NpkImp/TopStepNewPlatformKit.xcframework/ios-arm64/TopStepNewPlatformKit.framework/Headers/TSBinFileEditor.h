//
//  TSBinFileEditor.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSBinImageTableItem;
@class TSImageWriteItem;


NS_ASSUME_NONNULL_BEGIN

// 常量定义
/// 图片索引表在 Bin 文件中的起始偏移
FOUNDATION_EXTERN const int64_t kTSBinImageTableOffset;
/// 每张图片数据前的固定头大小（写入/读取时需跳过）
FOUNDATION_EXTERN const int64_t kTSBinImageHeaderSize;
/// 单个图片索引表项的大小（地址4字节 + 大小4字节）
FOUNDATION_EXTERN const NSInteger kTSBinImageTableItemSize;


/**
 * Bin 文件编辑器（纯类方法版）
 * 核心功能：
 * 1. 读取 Bin 文件
 * 2. 解析 IMAGE_TABLE（图片地址/大小）
 * 3. 读取指定索引图片的 RGBA 字节数组
 * 4. 写入 RGBA 数据到指定索引图片（跳过 24 字节头）
 */
@interface TSBinFileEditor : NSObject

/**
 * 读取指定索引的图片索引表项（地址+大小）
 * @param binFilePath Bin 文件路径
 * @param imageIndex 图片索引（0=预览图，1=第1张背景...）
 * @param error 错误信息（如索引越界、读取失败）
 * @return 图片索引表项（失败返回 nil）
 */
+ (nullable TSBinImageTableItem *)readImageTableItemAtPath:(NSString *)binFilePath
                                                imageIndex:(NSInteger)imageIndex
                                                     error:(NSError **)error;


/**
 * 批量写入多个图片数据到 Bin 文件（一次性打开文件，循环写入）
 * @param writeItems 图片写入项数组（包含压缩数据和索引表项）
 * @param binFilePath Bin 文件路径
 * @param error 错误信息（如大小不匹配、写入失败）
 * @return 是否写入成功
 */
+ (BOOL)writeImageWriteItems:(NSArray<TSImageWriteItem *> *)writeItems
                     toPath:(NSString *)binFilePath
                      error:(NSError **)error;

@end


NS_ASSUME_NONNULL_END
