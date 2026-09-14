//
//  TSMediaFileModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/8/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief FitCloud conversion helpers for device media files
 * @chinese 设备媒体文件的 FitCloud 转换辅助方法
 */
@interface TSMediaFileModel (Fit)

/**
 * @brief Validate a FitCloud device file name
 * @chinese 校验 FitCloud 设备文件名
 *
 * @param fileName EN: Device file name
 *                 CN: 设备文件名
 * @return EN: YES when the name is safe and supported by FitCloudKit
 *         CN: 文件名安全且满足 FitCloudKit 约束时返回 YES
 */
+ (BOOL)isValidFitCloudFileName:(nullable NSString *)fileName;

/**
 * @brief Convert FitCloud file information to a unified model
 * @chinese 将 FitCloud 文件信息转换为统一模型
 *
 * @param fileInfo EN: FitCloud file information
 *                 CN: FitCloud 文件信息
 * @return EN: Unified model; nil when vendor data is invalid
 *         CN: 统一模型；厂商数据非法时返回 nil
 */
+ (nullable instancetype)modelWithFitCloudFileInfo:(FitCloudFileInfoModel *)fileInfo;

@end

NS_ASSUME_NONNULL_END
