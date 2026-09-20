//
//  TSFitDialHeader.h
//  TopStepFitKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief TBUI target platforms. @chinese TBUI 目标平台。 */
typedef NS_ENUM(NSUInteger, TSFitDialPlatform) {
    TSFitDialPlatformGUI = 0,
    TSFitDialPlatformRealtek = 2,
    TSFitDialPlatformAB568X = 3,
    TSFitDialPlatformAB579X = 4,
};

/** @brief TBUI screen shapes. @chinese TBUI 屏幕形状。 */
typedef NS_ENUM(NSUInteger, TSFitDialShape) {
    TSFitDialShapeRectangle = 1,
    TSFitDialShapeCircle = 2,
};

/** @brief TBUI header parameters; defaults match Android 3410b969. @chinese TBUI 头参数，默认值对齐 Android 3410b969。 */
@interface TSFitDialHeader : NSObject <NSCopying>
/** @brief Unsigned 24-bit dial identifier. @chinese 24 位无符号表盘编号。 */
@property (nonatomic, assign) NSUInteger dialID;
/** @brief Dial version, 1...100; defaults to 1. @chinese 表盘版本 1...100，默认 1。 */
@property (nonatomic, assign) NSUInteger version;
/** @brief Target platform code. @chinese 目标平台代码。 */
@property (nonatomic, assign) NSUInteger platform;
/** @brief Unsigned 16-bit LCD identifier. @chinese 16 位无符号屏幕编号。 */
@property (nonatomic, assign) NSUInteger lcd;
/** @brief Positive screen width in pixels. @chinese 大于零的屏幕像素宽度。 */
@property (nonatomic, assign) NSUInteger width;
/** @brief Positive screen height in pixels. @chinese 大于零的屏幕像素高度。 */
@property (nonatomic, assign) NSUInteger height;
/** @brief Shape code: rectangle 1, circle 2. @chinese 形状代码：矩形 1，圆形 2。 */
@property (nonatomic, assign) NSUInteger shape;
/** @brief Unsigned byte corner radius; packers write zero. @chinese 单字节圆角半径，打包器写零。 */
@property (nonatomic, assign) NSUInteger corner;
/** @brief Rotation code: 0, 1, 2, 3 for 0, 90, 180, 270 degrees. @chinese 旋转代码 0、1、2、3 对应 0、90、180、270 度。 */
@property (nonatomic, assign) NSUInteger rotate;
/** @brief Ten-byte language bitmap, initially 0A followed by zeros. @chinese 十字节语言位图，默认首字节 0A，其余为零。 */
@property (nonatomic, copy) NSData *language;
/** @brief Four-byte tool version, initially 01 00 00 00. @chinese 四字节工具版本，默认 01 00 00 00。 */
@property (nonatomic, copy) NSData *toolVersion;
@end

NS_ASSUME_NONNULL_END
