//
//  TSPeripheralDial.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

#import <Foundation/Foundation.h>

/**
 * 外设形状枚举
 * 用于描述外设设备的物理形状特征
 */
typedef NS_ENUM(NSUInteger, TSPeriphShape) {
    /** 未知形状 */
    eTSPeriphShapeUnknow,
    /** 圆形设备，如圆形手表等 */
    eTSPeriphShapeCircle,
    /** 正方形设备，如方形手表等 */
    eTSPeriphShapeSquare,
    /** 纵向长方形设备，如竖屏显示器等 */
    eTSPeriphShapeVerticalRectangle,
    /** 横向长方形设备，如横屏显示器等 */
    eTSPeriphShapeTransverseRectangle,
};

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheralDial : NSObject

#pragma mark - 屏幕相关属性

/**
 * @brief Device shape used to identify the shape characteristics of the device.
 * @chinese 设备外形，用于标识设备的形状特征
 *
 * @discussion
 * [EN]: Used to describe the physical shape characteristics of the peripheral device.
 * [CN]: 用于描述外设设备的物理形状特征。
 *
 * @note
 * [EN]: This value should be a valid TSPeriphShape enumeration value.
 * [CN]: 该值应为有效的TSPeriphShape枚举值。
 */
@property (nonatomic, assign) TSPeriphShape shape;

/**
 * @brief Screen width of the device in pixels.
 * @chinese 设备屏幕宽度，单位像素
 *
 * @discussion
 * [EN]: This value represents the width of the actual display area of the device.
 * [CN]: 该值表示设备实际显示区域的宽度。
 *
 * @note
 * [EN]: This value should be a positive number.
 * [CN]: 该值应为正数。
 */
@property (nonatomic, assign) float screenWidth;

/**
 * @brief Screen height of the device in pixels.
 * @chinese 设备屏幕高度，单位像素
 *
 * @discussion
 * [EN]: This value represents the height of the actual display area of the device.
 * [CN]: 该值表示设备实际显示区域的高度。
 *
 * @note
 * [EN]: This value should be a positive number.
 * [CN]: 该值应为正数。
 */
@property (nonatomic, assign) float screenHeight;

/**
 * @brief Screen border radius of the device in pixels.
 * @chinese 设备屏幕圆角半径，单位像素
 *
 * @discussion
 * [EN]: Used to consider the screen border radius when drawing the UI.
 * [CN]: 用于绘制UI时考虑屏幕圆角。
 *
 * @note
 * [EN]: This value should be a non-negative number.
 * [CN]: 该值应为非负数。
 */
@property (nonatomic, assign) float screenBorderRadius;

/**
 * @brief Width of the dial preview image in pixels.
 * @chinese 表盘预览图宽度，单位像素
 *
 * @discussion
 * [EN]: Used to display the width of the dial preview image.
 * [CN]: 用于显示表盘预览图的宽度。
 *
 * @note
 * [EN]: This value should be a positive number.
 * [CN]: 该值应为正数。
 */
@property (nonatomic, assign) CGFloat dialPreviewWidth;

/**
 * @brief Height of the dial preview image in pixels.
 * @chinese 表盘预览图高度，单位像素
 *
 * @discussion
 * [EN]: Used to display the height of the dial preview image.
 * [CN]: 用于显示表盘预览图的高度。
 *
 * @note
 * [EN]: This value should be a positive number.
 * [CN]: 该值应为正数。
 */
@property (nonatomic, assign) CGFloat dialPreviewHeight;

/**
 * @brief Corner radius of the dial preview image in pixels.
 * @chinese 表盘预览图圆角大小，单位像素
 *
 * @discussion
 * [EN]: Used for corner processing when displaying the dial preview image.
 * [CN]: 用于显示表盘预览图时的圆角处理。
 *
 * @note
 * [EN]: This value should be a non-negative number.
 * [CN]: 该值应为非负数。
 */
@property (nonatomic, assign) CGFloat dialPreviewCorner;

/**
 * @brief Get a string representation of the device shape
 * @chinese 获取设备形状的字符串表示
 *
 * @return 
 * [EN]: A human-readable string describing the device shape (e.g., "Circle", "Square")
 * [CN]: 描述设备形状的可读字符串（例如，"Circle"、"Square"）
 *
 * @discussion
 * [EN]: Converts the TSPeriphShape enumeration value to a human-readable string.
 * Useful for debugging, logging, and UI display purposes.
 * Returns "Unknown Shape" if the shape is not recognized.
 *
 * [CN]: 将TSPeriphShape枚举值转换为人类可读的字符串。
 * 适用于调试、日志记录和UI显示目的。
 * 如果形状无法识别，则返回"Unknown Shape"。
 */
- (NSString *)shapeString;

@end

NS_ASSUME_NONNULL_END
