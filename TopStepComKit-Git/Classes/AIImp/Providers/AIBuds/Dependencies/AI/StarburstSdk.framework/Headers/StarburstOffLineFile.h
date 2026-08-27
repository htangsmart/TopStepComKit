//
//  StarburstOffLineFile.h
//  StarburstSdk
//
//  Created by incar on 2024/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 离线文件
@interface StarburstOffLineFile : NSObject

@property (nonatomic, assign) uint8_t fileType;/// 0x00所有文件、0x01左耳列表、0x02右耳列表
@property (nonatomic, assign) NSInteger fileId;/// 文件id
@property (nonatomic, assign) NSInteger fileSize;/// 文件大小
@end

NS_ASSUME_NONNULL_END
