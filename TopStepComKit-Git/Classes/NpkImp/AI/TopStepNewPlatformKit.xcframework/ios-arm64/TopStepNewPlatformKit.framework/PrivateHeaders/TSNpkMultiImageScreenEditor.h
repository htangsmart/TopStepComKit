//
//  TSNpkMultiImageScreenEditor.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSDialDraftItem;
@class TSNpkScreenLocator;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Rebuilds the multi-image presets of screen.json from the user's backgrounds
 * @chinese 按用户的背景图重建 screen.json 里的多图预设
 *
 * @discussion
 * [EN]: Keeps the first preset as a template, clears "Values" and adds one preset per user background:
 *       unique Id (template Id minus position), the actual image table index, and the properties of that
 *       background's time style with position and color applied. Activates the first background.
 * [CN]: 以第一个预设为模板，清空 "Values" 后为每张用户背景重建一个预设：Id 唯一（模板 Id 减序号）、
 *       写入实际的图片索引、并入该背景对应时间样式的属性（位置与颜色已写入）。默认激活第一张背景。
 */
@interface TSNpkMultiImageScreenEditor : NSObject

/**
 * @brief Apply the user's backgrounds
 * @chinese 应用用户的背景图
 *
 * @param items EN: Draft items, one per background, in user order. CN: 草稿项，每张背景一项，按用户顺序。
 * @param tableIndexes EN: Image table index actually written for each item, same order and count as items.
 *                     CN: 每一项实际写入的图片索引，顺序和数量与 items 一致。
 * @param screenSize EN: Screen size in pixels. CN: 屏幕像素尺寸。
 * @param locator EN: Locator of the screen document being edited. CN: 正在编辑的 screen 文档的定位器。
 * @param error EN: Failure reason. CN: 失败原因。
 */
+ (BOOL)applyItems:(NSArray<TSDialDraftItem *> *)items
      tableIndexes:(NSArray<NSNumber *> *)tableIndexes
        screenSize:(CGSize)screenSize
           locator:(TSNpkScreenLocator *)locator
             error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
