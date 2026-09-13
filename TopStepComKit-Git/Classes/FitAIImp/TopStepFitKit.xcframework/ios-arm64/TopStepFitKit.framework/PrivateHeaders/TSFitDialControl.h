//
//  TSFitDialControl.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief A 32-byte TBUI control record. @chinese 32 字节 TBUI 控件记录。 */
@interface TSFitDialControl : NSObject <NSCopying>
/** @brief Stored slot; encoding uses the array position. @chinese 原始槽位；打包时写数组位置。 */
@property (nonatomic, assign) NSUInteger index;
/** @brief Control family: image 0, icon 6, animation 7. @chinese 控件大类：图片 0，图标 6，动画 7。 */
@property (nonatomic, assign) NSUInteger controlType;
/** @brief Enable byte; defaults to 1. @chinese 启用字节，默认 1。 */
@property (nonatomic, assign) NSUInteger enable;
/** @brief Control subtype. @chinese 控件子类型。 */
@property (nonatomic, assign) NSUInteger subType;
/** @brief Unsigned 16-bit horizontal position. @chinese 16 位无符号横坐标。 */
@property (nonatomic, assign) NSUInteger x;
/** @brief Unsigned 16-bit vertical position. @chinese 16 位无符号纵坐标。 */
@property (nonatomic, assign) NSUInteger y;
/** @brief Unsigned 16-bit width field. @chinese 16 位无符号宽度字段。 */
@property (nonatomic, assign) NSUInteger width;
/** @brief Unsigned 16-bit height field. @chinese 16 位无符号高度字段。 */
@property (nonatomic, assign) NSUInteger height;
/** @brief Unsigned 16-bit resource identifier. @chinese 16 位无符号资源编号。 */
@property (nonatomic, assign) NSUInteger resourceID;
/** @brief Alignment or mode byte; Android retains its low byte. @chinese 对齐或模式，按 Android 保留低字节。 */
@property (nonatomic, assign) NSUInteger align;
/** @brief Interval or speed byte; Android retains its low byte. @chinese 间隔或速度，按 Android 保留低字节。 */
@property (nonatomic, assign) NSUInteger speed;
/** @brief Count byte; Android retains its low byte. @chinese 数量字段，按 Android 保留低字节。 */
@property (nonatomic, assign) NSUInteger number;
/** @brief Module byte; Android retains its low byte. @chinese 模块字段，按 Android 保留低字节。 */
@property (nonatomic, assign) NSUInteger module;
/** @brief Style byte; Android retains its low byte. @chinese 样式字段，按 Android 保留低字节。 */
@property (nonatomic, assign) NSUInteger style;
/** @brief Reserved byte; Android retains its low byte. @chinese 保留字段，按 Android 保留低字节。 */
@property (nonatomic, assign) NSUInteger reservedC;
/** @brief Up to six unsigned 16-bit resource identifiers. @chinese 最多六个 16 位无符号附加资源编号。 */
@property (nonatomic, copy) NSArray<NSNumber *> *extraIDs;
@end

NS_ASSUME_NONNULL_END
