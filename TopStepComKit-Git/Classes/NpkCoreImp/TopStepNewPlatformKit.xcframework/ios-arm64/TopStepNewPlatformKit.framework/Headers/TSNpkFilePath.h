//
//  TSNpkFilePath.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File path utility class for NPK dial creation
 * @chinese NPK表盘创建的文件路径工具类
 *
 * @discussion
 * [EN]: This class provides methods to generate and create file paths for custom dial operations.
 *       All paths are relative to Documents/TopStepComKit/Dial/CustomeDials.
 *       MAC address is automatically retrieved from the currently connected peripheral.
 * [CN]: 此类提供用于自定义表盘操作的文件路径生成和创建方法。
 *       所有路径都相对于 Documents/TopStepComKit/Dial/CustomeDials。
 *       MAC地址会自动从当前连接的外设获取。
 */
@interface TSNpkFilePath : NSObject

/**
 * @brief Get root path for custom dials
 * @chinese 获取自定义表盘的根路径
 *
 * @return
 * EN: Root directory path: /Documents/TopStepComKit/Dial/CustomeDials
 * CN: 根目录路径：/Documents/TopStepComKit/Dial/CustomeDials
 */
+ (NSString *)rootPathForCustomDials;

/**
 * @brief Get template folder path for a dial
 * @chinese 获取表盘的模板文件夹路径
 *
 * @param dialId
 * EN: Dial ID
 * CN: 表盘ID
 *
 * @return
 * EN: Template folder path: /Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/Templates
 * CN: 模板文件夹路径：/Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/Templates
 */
+ (NSString *)templatePathForDialId:(NSString *)dialId;

/**
 * @brief Get base type folder path for a dial
 * @chinese 获取表盘的Base类型文件夹路径
 *
 * @param dialId
 * EN: Dial ID
 * CN: 表盘ID
 *
 * @return
 * EN: Base folder path: /Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/Base
 * CN: Base文件夹路径：/Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/Base
 */
+ (NSString *)basePathForDialId:(NSString *)dialId;

/**
 * @brief Get mult type folder path for a dial
 * @chinese 获取表盘的Mult类型文件夹路径
 *
 * @param dialId
 * EN: Dial ID
 * CN: 表盘ID
 *
 * @return
 * EN: Mult folder path: /Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/Mult
 * CN: Mult文件夹路径：/Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/Mult
 */
+ (NSString *)multPathForDialId:(NSString *)dialId;

/**
 * @brief Get video type folder path for a dial
 * @chinese 获取表盘的Video类型文件夹路径
 *
 * @param dialId
 * EN: Dial ID
 * CN: 表盘ID
 *
 * @return
 * EN: Video folder path: /Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/Video
 * CN: Video文件夹路径：/Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/Video
 */
+ (NSString *)videoPathForDialId:(NSString *)dialId;

+ (NSString *)dialContentPathWithName:(NSString *)fileName dialId:(NSString *)dialId;


/**
 * @brief Get dial package file path (final tar file)
 * @chinese 获取表盘包文件路径（最终的tar文件）
 *
 * @param dialId
 * EN: Dial ID
 * CN: 表盘ID
 *
 * @return
 * EN: Package file path: /Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/{dialId}.tar
 * CN: 包文件路径：/Documents/TopStepComKit/Dial/CustomeDials/{mac}/{dialId}/{dialId}.tar
 */
+ (NSString *)dialPackageFilePathForDialId:(NSString *)dialId;

/**
 * @brief Get video output file path (0.hex) in video folder
 * @chinese 获取视频文件夹中的视频输出文件路径（0.hex）
 *
 * @param dialContentPath
 * EN: Dial content folder path (e.g., {mac}/{dialId}/Video)
 * CN: 表盘内容文件夹路径（例如：{mac}/{dialId}/Video）
 *
 * @return
 * EN: Video output file path: {dialContentPath}/video/0.hex
 * CN: 视频输出文件路径：{dialContentPath}/video/0.hex
 *
 * @discussion
 * [EN]: This method creates the video subdirectory and returns the path to the output video file.
 *       The file will be named "0.hex" as required by the device.
 * [CN]: 此方法创建video子目录并返回输出视频文件路径。
 *       文件将命名为"0.hex"（设备要求的格式）。
 */
+ (nullable NSString *)videoOutputFilePathForDialContentPath:(NSString *)dialContentPath;

@end

NS_ASSUME_NONNULL_END
