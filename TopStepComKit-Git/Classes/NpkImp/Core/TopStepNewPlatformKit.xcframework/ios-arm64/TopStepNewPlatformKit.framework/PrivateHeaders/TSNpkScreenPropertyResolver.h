//
//  TSNpkScreenPropertyResolver.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>

@class TSNpkScreenDocument;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief One widget property that a preset property definition drives
 * @chinese 预设的一个属性定义所驱动的某个控件属性
 */
@interface TSNpkScreenPropertyBinding : NSObject

/** @brief Name of the definition, e.g. "x" @chinese 属性定义的名字，例如 "x" */
@property (nonatomic, copy, readonly) NSString *definitionName;
/** @brief Id of the widget being driven @chinese 被驱动控件的 Id */
@property (nonatomic, strong, readonly) NSNumber *widgetId;
/** @brief Property path on the widget, e.g. "Style.Position.X" @chinese 控件上的属性路径，例如 "Style.Position.X" */
@property (nonatomic, copy, readonly) NSString *propertyPath;

@end

/**
 * @brief Resolves "TargetPropertyDefinitionId" of a preset value to the widget properties it drives
 * @chinese 把预设值里的 "TargetPropertyDefinitionId" 解析成它实际驱动的控件属性
 *
 * @discussion
 * [EN]: Chain in screen.json: PropertyValues[].TargetPropertyDefinitionId -> ViewModel.PropertyDefinitions[name].Id
 *       -> ViewModel.Properties[] with the same DefinitionName -> WidgetId + WidgetPropertyPath.
 *       One definition may drive several widgets (e.g. one "color" for three texts). Read only.
 * [CN]: screen.json 里的关系链：PropertyValues[].TargetPropertyDefinitionId -> ViewModel.PropertyDefinitions[名字].Id
 *       -> ViewModel.Properties[] 中 DefinitionName 相同的项 -> WidgetId + WidgetPropertyPath。
 *       一个定义可能同时驱动多个控件（例如一个 "color" 对应三个文本）。只读，不修改文档。
 */
@interface TSNpkScreenPropertyResolver : NSObject

- (instancetype)initWithDocument:(TSNpkScreenDocument *)document NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Widget properties driven by a definition id
 * @chinese 查询某个属性定义 Id 驱动的控件属性
 *
 * @param definitionId EN: Value of "TargetPropertyDefinitionId". CN: "TargetPropertyDefinitionId" 的值。
 * @return EN: Bindings; empty when the template carries no such information. CN: 绑定列表；模板里没有相关信息时为空数组。
 */
- (NSArray<TSNpkScreenPropertyBinding *> *)bindingsForDefinitionId:(nullable id)definitionId;

@end

NS_ASSUME_NONNULL_END
