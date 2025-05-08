//
//  TSFileOTAModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File OTA model
 * @chinese 文件OTA模型
 * 
 * @discussion 
 * EN: This model contains information needed for file OTA upgrade
 * CN: 该模型包含文件OTA升级所需的信息
 */
@interface TSFileOTAModel : NSObject

/**
 * @brief Local file path for OTA upgrade
 * @chinese OTA升级的本地文件路径
 * 
 * @discussion 
 * EN: The path to the firmware file that needs to be uploaded
 * CN: 需要上传的固件文件路径
 */
@property (nonatomic, copy) NSString *localFilePath;



/**
 * @brief Create a file OTA model with local file path
 * @chinese 使用本地文件路径创建文件OTA模型
 * 
 * @param localFilePath 
 * EN: Local file path for OTA upgrade
 * CN: OTA升级的本地文件路径
 * 
 * @return 
 * EN: A new file OTA model instance
 * CN: 新的文件OTA模型实例
 */
+ (instancetype)modelWithLocalFilePath:(NSString *)localFilePath;



@end

NS_ASSUME_NONNULL_END
