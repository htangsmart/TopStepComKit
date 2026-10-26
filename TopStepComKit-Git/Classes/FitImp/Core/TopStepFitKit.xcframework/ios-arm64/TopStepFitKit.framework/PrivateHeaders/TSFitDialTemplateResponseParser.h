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
 * @brief Parser for new and legacy dial-template responses
 * @chinese 新旧表盘模板响应解析器
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

/**
 * @brief Parse a response using the protocol of the actual request
 * @chinese 按实际请求使用的协议解析响应
 *
 * @param responseObject
 * EN: JSON response object.
 * CN: JSON 响应对象。
 *
 * @param context
 * EN: Device request context.
 * CN: 设备请求上下文。
 *
 * @param usesNewAPI
 * EN: YES for getCustomDial; NO for a legacy request or fallback.
 * CN: getCustomDial 请求传 YES，旧接口或回退请求传 NO。
 *
 * @param error
 * EN: Parse or validation error; EmptyData indicates a valid empty catalog.
 * CN: 解析或校验错误；EmptyData 表示合法空目录。
 *
 * @return
 * EN: Valid resources, or nil on failure or an empty catalog.
 * CN: 有效资源；失败或目录为空时返回 nil。
 */
- (nullable NSArray<TSFitDialTemplateResource *> *)parseResourcesFromResponseObject:(id)responseObject
                                                                             context:(TSFitDialTemplateRequestContext *)context
                                                                          usesNewAPI:(BOOL)usesNewAPI
                                                                               error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
