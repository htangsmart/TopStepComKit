//
//  TSFitDialTemplateResponseParser.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

@class TSFitDialTemplateRequestContext;
@class TSFitDialTemplateResource;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Parser for legacy production dial-template responses
 * @chinese 旧版生产表盘模板响应解析器
 */
@interface TSFitDialTemplateResponseParser : NSObject

/**
 * @brief Parse and validate a cloud response
 * @chinese 解析并校验云端响应
 * @param responseObject EN: JSON response object. CN: JSON 响应对象。
 * @param context EN: Device request context. CN: 设备请求上下文。
 * @param error EN: Parse or validation error. CN: 解析或校验错误。
 * @return EN: Valid GUI resource, or nil. CN: 有效 GUI 资源，失败时为 nil。
 * @discussion
 * [EN]: A recognized non-GUI response returns
 * TSFitDialTemplateErrorCodeNonGUIStyleResourceUnavailable until its local style assets are verified.
 * [CN]: 已识别的非 GUI 响应会返回 TSFitDialTemplateErrorCodeNonGUIStyleResourceUnavailable，
 * 直到对应本地样式资源完成确认。
 */
- (nullable TSFitDialTemplateResource *)parseResponseObject:(id)responseObject
                                                    context:(TSFitDialTemplateRequestContext *)context
                                                      error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Parse the complete compatible template catalog
 * @chinese 解析完整兼容模板目录
 * @param responseObject EN: JSON response object. CN: JSON 响应对象。
 * @param context EN: Device request context. CN: 设备请求上下文。
 * @param error EN: Parse or validation error. CN: 解析或校验错误。
 * @return EN: Valid resources in service order, or nil. CN: 按服务端顺序返回资源，失败时为 nil。
 */
- (nullable NSArray<TSFitDialTemplateResource *> *)parseResourcesFromResponseObject:(id)responseObject
                                                                             context:(TSFitDialTemplateRequestContext *)context
                                                                               error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
