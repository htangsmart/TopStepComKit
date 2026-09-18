//
//  TSDialCreator.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface TSDialCreator : NSObject

/**
 * @brief Build an NPK custom dial package
 * @chinese 构建 NPK 自定义表盘包
 *
 * @param draft
 * EN: Validated dial build draft.
 * CN: 已校验的表盘造包草稿。
 *
 * @param completion
 * EN: Build completion with the generated package path.
 * CN: 返回生成表盘包路径的完成回调。
 */
+ (void)createCustomDial:(TSDialDraft *)draft
              completion:(void (^)(BOOL isSuccess,
                                   NSString *_Nullable resultFilePath,
                                   NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
