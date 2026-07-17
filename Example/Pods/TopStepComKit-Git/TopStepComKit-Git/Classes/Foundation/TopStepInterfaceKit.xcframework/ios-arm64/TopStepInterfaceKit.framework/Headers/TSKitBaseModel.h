//
//  TSKitBaseModel.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/8/29.
//

#import <Foundation/Foundation.h>
#import <TopStepToolKit/TopStepToolKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TSKitBaseModel : NSObject

/**
 * @brief Check if the model has validation errors
 * @chinese 检查模型是否有验证错误
 *
 * @return
 * EN: NSError object if validation fails, nil if all validations pass
 * CN: 如果验证失败返回 NSError 对象，如果所有验证通过返回 nil
 */
- (NSError * _Nullable)doesModelHasError;

@end

NS_ASSUME_NONNULL_END
