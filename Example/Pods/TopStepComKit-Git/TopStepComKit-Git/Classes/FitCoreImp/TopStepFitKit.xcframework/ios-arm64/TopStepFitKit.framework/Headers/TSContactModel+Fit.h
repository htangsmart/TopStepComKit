//
//  TSContactModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/12.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief [中文]: TSContactModel的Fit类别，提供与FitCloud相关的转换方法
 *        [EN]: Fit category of TSContactModel, providing conversion methods related to FitCloud
 */
@interface TSContactModel (Fit)

/**
 * @brief [中文]: 将FitCloudEmergencyContactObject对象转换为TSContactModel对象
 *        [EN]: Convert FitCloudEmergencyContactObject to TSContactModel
 *
 * @param fitObject [中文]: FitCloudEmergencyContactObject对象
 *                  [EN]: FitCloudEmergencyContactObject instance
 *
 * @return [中文]: 转换后的TSContactModel对象，如果转换失败返回nil
 *         [EN]: Converted TSContactModel instance, returns nil if conversion fails
 *
 * @discussion [中文]: 该方法将FitCloud设备的联系人对象转换为通用的TSContactModel对象
 *            [EN]: This method converts FitCloud device's contact object to generic TSContactModel
 */
+ (nullable TSContactModel *)modelWithFitCloudEmergencyContact:(nullable FitCloudEmergencyContactObject *)fitObject;

/**
 * @brief [中文]: 将FitCloudEmergencyContactObject对象数组转换为TSContactModel对象数组
 *        [EN]: Convert array of FitCloudEmergencyContactObject to array of TSContactModel
 *
 * @param fitObjects [中文]: FitCloudEmergencyContactObject对象数组
 *                   [EN]: Array of FitCloudEmergencyContactObject instances
 *
 * @return [中文]: 转换后的TSContactModel对象数组，如果输入为nil则返回nil
 *         [EN]: Array of converted TSContactModel instances, returns nil if input is nil
 *
 * @discussion [中文]: 该方法将FitCloud设备的联系人对象数组批量转换为通用的TSContactModel对象数组
 *                    如果数组中某个元素转换失败，该元素将被忽略
 *            [EN]: This method converts an array of FitCloud device's contact objects to an array of generic TSContactModel objects
 *                 If conversion fails for any element in the array, that element will be ignored
 */
+ (nullable NSArray<TSContactModel *> *)modelsWithFitCloudEmergencyContacts:(nullable NSArray<FitCloudEmergencyContactObject *> *)fitObjects;


/**
 * @brief [中文]: 将FitCloudContactObject对象转换为TSContactModel对象
 *        [EN]: Convert FitCloudContactObject to TSContactModel
 *
 * @param fitObject [中文]: FitCloudContactObject对象
 *                  [EN]: FitCloudContactObject instance
 *
 * @return [中文]: 转换后的TSContactModel对象，如果转换失败返回nil
 *         [EN]: Converted TSContactModel instance, returns nil if conversion fails
 *
 * @discussion [中文]: 该方法将FitCloud设备的联系人对象转换为通用的TSContactModel对象
 *            [EN]: This method converts FitCloud device's contact object to generic TSContactModel
 */
+ (nullable TSContactModel *)modelWithFitCloudContact:(nullable FitCloudContactObject *)fitObject ;

/**
 * @brief [中文]: 将FitCloudContactObject对象数组转换为TSContactModel对象数组
 *        [EN]: Convert array of FitCloudContactObject to array of TSContactModel
 *
 * @param fitObjects [中文]: FitCloudContactObject对象数组
 *                   [EN]: Array of FitCloudEmergencyContactObject instances
 *
 * @return [中文]: 转换后的TSContactModel对象数组，如果输入为nil则返回nil
 *         [EN]: Array of converted TSContactModel instances, returns nil if input is nil
 *
 * @discussion [中文]: 该方法将FitCloud设备的联系人对象数组批量转换为通用的TSContactModel对象数组
 *                    如果数组中某个元素转换失败，该元素将被忽略
 *            [EN]: This method converts an array of FitCloud device's contact objects to an array of generic TSContactModel objects
 *                 If conversion fails for any element in the array, that element will be ignored
 */
+ (nullable NSArray<TSContactModel *> *)modelsWithFitCloudContacts:(nullable NSArray<FitCloudContactObject *> *)fitObjects ;



/**
 * @brief [中文]: 将TSContactModel对象转换为FitCloudEmergencyContactObject对象
 *        [EN]: Convert TSContactModel to FitCloudEmergencyContactObject
 *
 * @param model [中文]: TSContactModel对象
 *             [EN]: TSContactModel instance
 *
 * @return [中文]: 转换后的FitCloudEmergencyContactObject对象，如果转换失败返回nil
 *         [EN]: Converted FitCloudEmergencyContactObject instance, returns nil if conversion fails
 *
 * @discussion [中文]: 该方法将通用的TSContactModel对象转换为FitCloud设备的联系人对象
 *            [EN]: This method converts generic TSContactModel object to FitCloud device's contact object
 */
+ (nullable FitCloudEmergencyContactObject *)fitCloudEmergencyContactWithModel:(nullable TSContactModel *)model;

/**
 * @brief [中文]: 将TSContactModel对象数组转换为FitCloudEmergencyContactObject对象数组
 *        [EN]: Convert array of TSContactModel to array of FitCloudEmergencyContactObject
 *
 * @param models [中文]: TSContactModel对象数组
 *              [EN]: Array of TSContactModel instances
 *
 * @return [中文]: 转换后的FitCloudEmergencyContactObject对象数组，如果输入为nil则返回nil
 *         [EN]: Array of converted FitCloudEmergencyContactObject instances, returns nil if input is nil
 *
 * @discussion [中文]: 该方法将通用的TSContactModel对象数组批量转换为FitCloud设备的联系人对象数组
 *                    如果数组中某个元素转换失败，该元素将被忽略
 *            [EN]: This method converts an array of generic TSContactModel objects to an array of FitCloud device's contact objects
 *                 If conversion fails for any element in the array, that element will be ignored
 */
+ (nullable NSArray<FitCloudEmergencyContactObject *> *)fitCloudEmergencyContactsWithModels:(nullable NSArray<TSContactModel *> *)models;


/**
 * @brief [中文]: 将TSContactModel对象转换为FitCloudEmergencyContactObject对象
 *        [EN]: Convert TSContactModel to FitCloudEmergencyContactObject
 *
 * @param model [中文]: TSContactModel对象
 *             [EN]: TSContactModel instance
 *
 * @return [中文]: 转换后的FitCloudEmergencyContactObject对象，如果转换失败返回nil
 *         [EN]: Converted FitCloudEmergencyContactObject instance, returns nil if conversion fails
 *
 * @discussion [中文]: 该方法将通用的TSContactModel对象转换为FitCloud设备的联系人对象
 *            [EN]: This method converts generic TSContactModel object to FitCloud device's contact object
 */
+ (nullable FitCloudContactObject *)fitCloudContactWithModel:(nullable TSContactModel *)model;

/**
 * @brief [中文]: 将TSContactModel对象数组转换为FitCloudEmergencyContactObject对象数组
 *        [EN]: Convert array of TSContactModel to array of FitCloudEmergencyContactObject
 *
 * @param models [中文]: TSContactModel对象数组
 *              [EN]: Array of TSContactModel instances
 *
 * @return [中文]: 转换后的FitCloudEmergencyContactObject对象数组，如果输入为nil则返回nil
 *         [EN]: Array of converted FitCloudEmergencyContactObject instances, returns nil if input is nil
 *
 * @discussion [中文]: 该方法将通用的TSContactModel对象数组批量转换为FitCloud设备的联系人对象数组
 *                    如果数组中某个元素转换失败，该元素将被忽略
 *            [EN]: This method converts an array of generic TSContactModel objects to an array of FitCloud device's contact objects
 *                 If conversion fails for any element in the array, that element will be ignored
 */
+ (nullable NSArray<FitCloudContactObject *> *)fitCloudContactsWithModels:(nullable NSArray<TSContactModel *> *)models;

@end

NS_ASSUME_NONNULL_END
