//
//  TSMetaAuthParam+Extensions.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import "PbConnectParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Extensions for TSBleConnectParam class
 * @chinese TSBleConnectParam 类的扩展
 *
 * @discussion
 * [EN]: This category provides additional methods and functionality for TSBleConnectParam
 * [CN]: 此分类为 TSBleConnectParam 提供额外的方法和功能
 */
@interface TSMetaAuthParam (Extensions)


+ (BOOL)validateParam:(TSMetaAuthParam *)param ;

/**
 * @brief Get detailed debug description for debugging
 * @chinese 获取详细的调试描述信息
 *
 * @return 
 * EN: Detailed debug description string
 * CN: 详细的调试描述字符串
 */
- (NSString *)debugDescription;


@end

NS_ASSUME_NONNULL_END 
