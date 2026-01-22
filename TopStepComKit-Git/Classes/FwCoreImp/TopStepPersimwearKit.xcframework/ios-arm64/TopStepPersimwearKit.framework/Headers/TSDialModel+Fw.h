//
//  TSDialModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

static NSString *kCustomDialId = @"com.realthread.superDial";

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief TSDialModel category for Fw platform dial conversion
 * @chinese TSDialModel 的 Fw 平台表盘转换分类
 *
 * @discussion
 * [EN]: This category provides methods to convert Fw platform dial dictionary data
 *       to TSDialModel objects. It handles the mapping between Fw platform specific
 *       dictionary keys and standard TSDialModel properties.
 * [CN]: 该分类提供将 Fw 平台表盘字典数据转换为 TSDialModel 对象的方法。
 *       它处理 Fw 平台特定字典键与标准 TSDialModel 属性之间的映射。
 */
@interface TSDialModel (Fw)

/**
 * @brief Convert Fw platform dial dictionary to TSDialModel
 * @chinese 将 Fw 平台的表盘字典转换为 TSDialModel
 *
 * @param fwDial
 * EN: The Fw platform dial dictionary containing dial information.
 *     Expected keys: id, alias, group, icon, isEditable, isHide, version.
 * CN: 包含表盘信息的 Fw 平台表盘字典。
 *     期望的键: id, alias, group, icon, isEditable, isHide, version。
 *
 * @return
 * EN: Converted TSDialModel object, nil if conversion fails or input is invalid.
 * CN: 转换后的 TSDialModel 对象，如果转换失败或输入无效则返回 nil。
 *
 * @discussion
 * [EN]: Mapping rules:
 *       - id -> dialId
 *       - alias -> dialName
 *       - group (system/custom/cloud) -> dialType
 *       - icon -> filePath
 *       - version (e.g. "v1.0.0") -> version (integer: 10000)
 * [CN]: 映射规则:
 *       - id -> dialId
 *       - alias -> dialName
 *       - group (system/custom/cloud) -> dialType
 *       - icon -> filePath
 *       - version (如 "v1.0.0") -> version (整数: 10000)
 */
+ (nullable TSDialModel *)dialModelWithFwDialDict:(NSDictionary *)fwDial;

/**
 * @brief Convert Fw platform dial dictionaries array to TSDialModel array
 * @chinese 将 Fw 平台的表盘字典数组转换为 TSDialModel 数组
 *
 * @param fwDials
 * EN: Array of Fw platform dial dictionaries. Each dictionary should contain
 *     dial information with keys: id, alias, group, icon, isEditable, isHide, version.
 * CN: Fw 平台表盘字典数组。每个字典应包含表盘信息，
 *     键包括: id, alias, group, icon, isEditable, isHide, version。
 *
 * @return
 * EN: Array of converted TSDialModel objects. Returns empty array if input is invalid
 *     or no valid dials found. Hidden dials (isHide=1) are filtered out.
 * CN: 转换后的 TSDialModel 对象数组。如果输入无效或没有找到有效表盘则返回空数组。
 *     隐藏的表盘（isHide=1）会被过滤掉。
 *
 * @note
 * [EN]: The locationIndex property of each model is set based on its position in the array.
 * [CN]: 每个模型的 locationIndex 属性根据其在数组中的位置设置。
 */
+ (NSArray<TSDialModel *> *)dialModelsWithFwDialDicts:(NSArray<NSDictionary *> *)fwDials;

@end

NS_ASSUME_NONNULL_END
