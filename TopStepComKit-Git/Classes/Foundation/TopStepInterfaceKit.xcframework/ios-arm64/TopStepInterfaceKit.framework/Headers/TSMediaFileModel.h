//
//  TSMediaFileModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/8/21.
//

#import "TSKitBaseModel.h"
#import "TSMediaFileDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device media file model
 * @chinese 设备媒体文件模型
 */
@interface TSMediaFileModel : TSKitBaseModel

/**
 * @brief Provider-owned opaque file identifier
 * @chinese Provider 维护的不透明文件标识
 */
@property (nonatomic, copy) NSString *identifier;

/**
 * @brief Complete device file name
 * @chinese 完整的设备文件名
 */
@property (nonatomic, copy) NSString *fileName;

/**
 * @brief Device media file type
 * @chinese 设备媒体文件类型
 */
@property (nonatomic, assign) TSMediaFileType type;

/**
 * @brief File size in bytes; nil when unknown
 * @chinese 文件大小，单位为字节；未知时为 nil
 */
@property (nonatomic, copy, nullable) NSNumber *fileSize;

@end

NS_ASSUME_NONNULL_END
