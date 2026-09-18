//
//  TSRespondModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/1/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSRespondModel (Fw)

/**
 * @brief Convert TSRespondModel to dictionary
 * @chinese 将TSRespondModel转换为字典
 *
 * @return
 * EN: Dictionary containing response data with keys: cmd, key, id, func, content, error, errorMsg
 * CN: 包含响应数据的字典，键包括: cmd, key, id, func, content, error, errorMsg
 */
- (NSDictionary *)toDictionaryWithPushSuccess:(BOOL)isPushSuccess;

@end

NS_ASSUME_NONNULL_END
