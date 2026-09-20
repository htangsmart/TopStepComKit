//
//  TSFitDialTemplateSelector.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSFitDialTemplateRequestContext;
@class TSFitDialTemplateResource;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Selects a Fit template for a custom-dial time style
 * @chinese 根据自定义表盘时间样式选择 Fit 模板
 */
@interface TSFitDialTemplateSelector : NSObject

/**
 * @brief Select a compatible template resource
 * @chinese 选择兼容的模板资源
 * @param resources EN: Parsed cloud catalog. CN: 解析后的云端目录。
 * @param context EN: Current device context. CN: 当前设备上下文。
 * @param style EN: Requested custom-dial time style. CN: 请求的自定义表盘时间样式。
 * @param error EN: Selection error. CN: 选择错误。
 * @return EN: Selected resource, or nil. CN: 选中的资源，失败时为 nil。
 */
- (nullable TSFitDialTemplateResource *)selectResourceFromResources:
    (NSArray<TSFitDialTemplateResource *> *)resources
    context:(TSFitDialTemplateRequestContext *)context
    timeStyle:(TSDialTimeStyle)style
    error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
