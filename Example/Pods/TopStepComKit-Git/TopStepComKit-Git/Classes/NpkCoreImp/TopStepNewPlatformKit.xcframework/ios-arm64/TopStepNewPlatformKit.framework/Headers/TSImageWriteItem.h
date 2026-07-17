//
//  TSImageWriteItem.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/5.
//

#import <Foundation/Foundation.h>
#import "TSBinImageTableItem.h"
#import "TSCustomDial.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSImageWriteItem : NSObject

@property (nonatomic, assign) NSInteger imageIndex;      // 图片索引（0=预览图，1=第1张背景...）
@property (nonatomic, strong) NSData *compressedData;     // TSC压缩后的数据
@property (nonatomic, strong) TSBinImageTableItem *tableItem; // 索引表项（包含地址和大小）


+ (nullable NSArray<TSImageWriteItem *> *)imageWriteItemsWithDial:(TSCustomDial *)customDial
                                                      binFilePath:(NSString *)binFilePath
                                                            error:(NSError **)error ;

@end

NS_ASSUME_NONNULL_END
