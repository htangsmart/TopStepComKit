//
//  TopStepContactModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/12.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief [中文]: TopStepContactModel的Fit类别，提供与FitCloud相关的转换方法
 *        [EN]: Fit category of TopStepContactModel, providing conversion methods related to FitCloud
 */
@interface TopStepContactModel (Fit)

/**
 * @brief [中文]: 将FitCloudEmergencyContactObject对象转换为TopStepContactModel对象
 *        [EN]: Convert FitCloudEmergencyContactObject to TopStepContactModel
 *
 * @param fitObject [中文]: FitCloudEmergencyContactObject对象
 *                  [EN]: FitCloudEmergencyContactObject instance
 *
 * @return [中文]: 转换后的TopStepContactModel对象，如果转换失败返回nil
 *         [EN]: Converted TopStepContactModel instance, returns nil if conversion fails
 *
 * @discussion [中文]: 该方法将FitCloud设备的联系人对象转换为通用的TopStepContactModel对象
 *            [EN]: This method converts FitCloud device's contact object to generic TopStepContactModel
 */
+ (nullable TopStepContactModel *)modelWithFitCloudEmergencyContact:(nullable FitCloudEmergencyContactObject *)fitObject;

/**
 * @brief [中文]: 将FitCloudEmergencyContactObject对象数组转换为TopStepContactModel对象数组
 *        [EN]: Convert array of FitCloudEmergencyContactObject to array of TopStepContactModel
 *
 * @param fitObjects [中文]: FitCloudEmergencyContactObject对象数组
 *                   [EN]: Array of FitCloudEmergencyContactObject instances
 *
 * @return [中文]: 转换后的TopStepContactModel对象数组，如果输入为nil则返回nil
 *         [EN]: Array of converted TopStepContactModel instances, returns nil if input is nil
 *
 * @discussion [中文]: 该方法将FitCloud设备的联系人对象数组批量转换为通用的TopStepContactModel对象数组
 *                    如果数组中某个元素转换失败，该元素将被忽略
 *            [EN]: This method converts an array of FitCloud device's contact objects to an array of generic TopStepContactModel objects
 *                 If conversion fails for any element in the array, that element will be ignored
 */
+ (nullable NSArray<TopStepContactModel *> *)modelsWithFitCloudEmergencyContacts:(nullable NSArray<FitCloudEmergencyContactObject *> *)fitObjects;


/**
 * @brief [中文]: 将FitCloudContactObject对象转换为TopStepContactModel对象
 *        [EN]: Convert FitCloudContactObject to TopStepContactModel
 *
 * @param fitObject [中文]: FitCloudContactObject对象
 *                  [EN]: FitCloudContactObject instance
 *
 * @return [中文]: 转换后的TopStepContactModel对象，如果转换失败返回nil
 *         [EN]: Converted TopStepContactModel instance, returns nil if conversion fails
 *
 * @discussion [中文]: 该方法将FitCloud设备的联系人对象转换为通用的TopStepContactModel对象
 *            [EN]: This method converts FitCloud device's contact object to generic TopStepContactModel
 */
+ (nullable TopStepContactModel *)modelWithFitCloudContact:(nullable FitCloudContactObject *)fitObject ;

/**
 * @brief [中文]: 将FitCloudContactObject对象数组转换为TopStepContactModel对象数组
 *        [EN]: Convert array of FitCloudContactObject to array of TopStepContactModel
 *
 * @param fitObjects [中文]: FitCloudContactObject对象数组
 *                   [EN]: Array of FitCloudEmergencyContactObject instances
 *
 * @return [中文]: 转换后的TopStepContactModel对象数组，如果输入为nil则返回nil
 *         [EN]: Array of converted TopStepContactModel instances, returns nil if input is nil
 *
 * @discussion [中文]: 该方法将FitCloud设备的联系人对象数组批量转换为通用的TopStepContactModel对象数组
 *                    如果数组中某个元素转换失败，该元素将被忽略
 *            [EN]: This method converts an array of FitCloud device's contact objects to an array of generic TopStepContactModel objects
 *                 If conversion fails for any element in the array, that element will be ignored
 */
+ (nullable NSArray<TopStepContactModel *> *)modelsWithFitCloudContacts:(nullable NSArray<FitCloudContactObject *> *)fitObjects ;



/**
 * @brief [中文]: 将TopStepContactModel对象转换为FitCloudEmergencyContactObject对象
 *        [EN]: Convert TopStepContactModel to FitCloudEmergencyContactObject
 *
 * @param model [中文]: TopStepContactModel对象
 *             [EN]: TopStepContactModel instance
 *
 * @return [中文]: 转换后的FitCloudEmergencyContactObject对象，如果转换失败返回nil
 *         [EN]: Converted FitCloudEmergencyContactObject instance, returns nil if conversion fails
 *
 * @discussion [中文]: 该方法将通用的TopStepContactModel对象转换为FitCloud设备的联系人对象
 *            [EN]: This method converts generic TopStepContactModel object to FitCloud device's contact object
 */
+ (nullable FitCloudEmergencyContactObject *)fitCloudEmergencyContactWithModel:(nullable TopStepContactModel *)model;

/**
 * @brief [中文]: 将TopStepContactModel对象数组转换为FitCloudEmergencyContactObject对象数组
 *        [EN]: Convert array of TopStepContactModel to array of FitCloudEmergencyContactObject
 *
 * @param models [中文]: TopStepContactModel对象数组
 *              [EN]: Array of TopStepContactModel instances
 *
 * @return [中文]: 转换后的FitCloudEmergencyContactObject对象数组，如果输入为nil则返回nil
 *         [EN]: Array of converted FitCloudEmergencyContactObject instances, returns nil if input is nil
 *
 * @discussion [中文]: 该方法将通用的TopStepContactModel对象数组批量转换为FitCloud设备的联系人对象数组
 *                    如果数组中某个元素转换失败，该元素将被忽略
 *            [EN]: This method converts an array of generic TopStepContactModel objects to an array of FitCloud device's contact objects
 *                 If conversion fails for any element in the array, that element will be ignored
 */
+ (nullable NSArray<FitCloudEmergencyContactObject *> *)fitCloudEmergencyContactsWithModels:(nullable NSArray<TopStepContactModel *> *)models;


/**
 * @brief [中文]: 将TopStepContactModel对象转换为FitCloudEmergencyContactObject对象
 *        [EN]: Convert TopStepContactModel to FitCloudEmergencyContactObject
 *
 * @param model [中文]: TopStepContactModel对象
 *             [EN]: TopStepContactModel instance
 *
 * @return [中文]: 转换后的FitCloudEmergencyContactObject对象，如果转换失败返回nil
 *         [EN]: Converted FitCloudEmergencyContactObject instance, returns nil if conversion fails
 *
 * @discussion [中文]: 该方法将通用的TopStepContactModel对象转换为FitCloud设备的联系人对象
 *            [EN]: This method converts generic TopStepContactModel object to FitCloud device's contact object
 */
+ (nullable FitCloudContactObject *)fitCloudContactWithModel:(nullable TopStepContactModel *)model;

/**
 * @brief [中文]: 将TopStepContactModel对象数组转换为FitCloudEmergencyContactObject对象数组
 *        [EN]: Convert array of TopStepContactModel to array of FitCloudEmergencyContactObject
 *
 * @param models [中文]: TopStepContactModel对象数组
 *              [EN]: Array of TopStepContactModel instances
 *
 * @return [中文]: 转换后的FitCloudEmergencyContactObject对象数组，如果输入为nil则返回nil
 *         [EN]: Array of converted FitCloudEmergencyContactObject instances, returns nil if input is nil
 *
 * @discussion [中文]: 该方法将通用的TopStepContactModel对象数组批量转换为FitCloud设备的联系人对象数组
 *                    如果数组中某个元素转换失败，该元素将被忽略
 *            [EN]: This method converts an array of generic TopStepContactModel objects to an array of FitCloud device's contact objects
 *                 If conversion fails for any element in the array, that element will be ignored
 */
+ (nullable NSArray<FitCloudContactObject *> *)fitCloudContactsWithModels:(nullable NSArray<TopStepContactModel *> *)models;

@end

NS_ASSUME_NONNULL_END
