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
@property (nonatomic, readonly) TSPeriphShape shape;

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
@property (nonatomic, readonly) CGFloat screenWidth;

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
@property (nonatomic, readonly) CGFloat screenHeight;

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
@property (nonatomic, readonly) CGFloat screenBorderRadius;

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
@property (nonatomic, readonly) CGFloat previewWidth;

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
@property (nonatomic, readonly) CGFloat previewHeight;

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
@property (nonatomic, readonly) CGFloat previewBorderRadius;


/**
 * @brief Initialize a new TSPeripheralDial instance with all required parameters
 * @chinese 使用所有必需参数初始化一个新的TSPeripheralDial实例

 * @return
 * [EN]: A new TSPeripheralDial instance initialized with the specified parameters
 * [CN]: 使用指定参数初始化的新TSPeripheralDial实例
 *
 * @discussion
 * [EN]: This is the designated initializer for TSPeripheralDial.
 * All parameters are required and must be valid values.
 * The screen dimensions and preview dimensions should be positive numbers,
 * while the border radius values should be non-negative numbers.
 *
 * [CN]: 这是TSPeripheralDial的指定初始化方法。
 * 所有参数都是必需的，且必须是有效值。
 * 屏幕尺寸和预览图尺寸应为正数，
 * 而圆角半径值应为非负数。
 *
 * @note
 * [EN]: This method is marked as NS_DESIGNATED_INITIALIZER,
 * meaning it must be called by any other initialization methods.
 * [CN]: 此方法被标记为NS_DESIGNATED_INITIALIZER，
 * 意味着任何其他初始化方法都必须调用此方法。
 */
- (instancetype)initWithShape:(TSPeriphShape)shape
                  screenWidth:(CGFloat)screenWidth
                 screenHeight:(CGFloat)screenHeight
           screenBorderRadius:(CGFloat)screenBorderRadius
                 previewWidth:(CGFloat)previewWidth
                previewHeight:(CGFloat)previewHeight
          previewBorderRadius:(CGFloat)previewBorderRadius NS_DESIGNATED_INITIALIZER;

/**
 * @brief Disable default initialization method
 * @chinese 禁用默认初始化方法
 *
 * @discussion
 * [EN]: This method is unavailable. Use initWithShape:screenWidth:screenHeight:screenBorderRadius:previewWidth:previewHeight:previewBorderRadius: instead.
 * [CN]: 此方法不可用。请使用initWithShape:screenWidth:screenHeight:screenBorderRadius:previewWidth:previewHeight:previewBorderRadius:代替。
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable copy method
 * @chinese 禁用复制方法
 *
 * @discussion
 * [EN]: This method is unavailable. TSPeripheralDial instances should not be copied.
 * [CN]: 此方法不可用。TSPeripheralDial实例不应被复制。
 */
- (instancetype)copy NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用new方法
 *
 * @discussion
 * [EN]: This method is unavailable. Use initWithShape:screenWidth:screenHeight:screenBorderRadius:previewWidth:previewHeight:previewBorderRadius: instead.
 * [CN]: 此方法不可用。请使用initWithShape:screenWidth:screenHeight:screenBorderRadius:previewWidth:previewHeight:previewBorderRadius:代替。
 */
- (instancetype)new NS_UNAVAILABLE;



@end

NS_ASSUME_NONNULL_END
