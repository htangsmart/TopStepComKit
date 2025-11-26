//
//  TSFileTransferModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File Transfer model
 * @chinese 文件传输模型
 *
 * @discussion 
 * EN: This model contains information needed for file Transfer upgrade
 * CN: 该模型包含文件传输升级所需的信息
 */
@interface TSFileTransferModel : TSKitBaseModel

/**
 * @brief Local file path for file transfer
 * @chinese 文件传输的本地文件路径
 *
 * @discussion 
 * EN: The path to the firmware file that needs to be uploaded
 * CN: 需要上传的固件文件路径
 */
@property (nonatomic, copy) NSString *localFilePath;

/**
 * @brief Create a file transfer model with local file path
 * @chinese 使用本地文件路径创建模型
 * 
 * @param localFilePath 
 * EN: Local file path for file transfer
 * CN: 文件传输的本地文件路径
 *
 * @return 
 * EN: A new file transfer model instance
 * CN: 新的文件传输模型实例
 */
+ (instancetype)modelWithLocalFilePath:(NSString *)localFilePath;



@end

NS_ASSUME_NONNULL_END
