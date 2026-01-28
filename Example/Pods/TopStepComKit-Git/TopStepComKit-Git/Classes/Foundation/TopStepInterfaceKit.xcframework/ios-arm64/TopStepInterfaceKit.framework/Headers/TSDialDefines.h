//
//  TSDialDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face type enumeration
 * @chinese 表盘类型枚举
 *
 * @discussion
 * EN: Defines different types of watch faces:
 *     - eDialTypeLocal: Built-in watch faces that come with the device
 *     - eDialTypeCustomer: Custom watch faces created by users
 *     - eDialTypeCloud: Watch faces downloaded from the cloud server
 * CN: 定义不同类型的表盘：
 *     - eDialTypeLocal: 设备自带的内置表盘
 *     - eDialTypeCustomer: 用户创建的自定义表盘
 *     - eDialTypeCloud: 从云服务器下载的表盘
 */
typedef NS_ENUM(UInt8, TSDialType) {
    eTSDialTypeBuiltIn = 0,      // Local watch face  / 本地表盘
    eTSDialTypeCustomer = 1,     // Custom watch face / 自定义表盘
    eTSDialTypeCloud = 2,        // Cloud watch face  / 云端表盘
};



typedef NS_ENUM(NSUInteger, TSDialTimePosition) {
    
    eTSDialTimePositionTop = 0,         //上方
    eTSDialTimePositionBottom = 1,      //下方
    eTSDialTimePositionLeft = 2,        //左方
    eTSDialTimePositionRight = 3,       //右方
    
    eTSDialTimePositionTopLeft = 4,     // 左上
    eTSDialTimePositionBottomLeft = 5,  // 左下
    eTSDialTimePositionTopRight = 6,    // 右上
    eTSDialTimePositionBottomRight = 7, // 右下
    
    eTSDialTimePositionCenter = 8,        //中间
};


/**
 * @brief Watch face push result type
 * @chinese 表盘推送结果类型
 */
typedef NS_ENUM(NSInteger, TSDialPushResult) {
    /// 开始
    eTSDialPushResultStart = 0,
    /// 推送中
    eTSDialPushResultProgress = 0,
    /// 推送成功
    eTSDialPushResultSuccess,
    /// 推送失败
    eTSDialPushResultFailed,
};


/**
 * @brief Custom dial type enumeration
 * @chinese 自定义表盘类型枚举
 *
 * @discussion
 * [EN]: Defines the type of custom watch face:
 *       - eTSCustomDialSingleImage: Single image-based custom watch face
 *       - eTSCustomDialMultipleImage: Multiple images-based custom watch face
 *       - eTSCustomDialVideo: Video-based custom watch face
 * [CN]: 定义自定义表盘的类型：
 *       - eTSCustomDialSingleImage: 单图片自定义表盘
 *       - eTSCustomDialMultipleImage: 多图片自定义表盘
 *       - eTSCustomDialVideo: 视频自定义表盘
 */
typedef NS_ENUM(NSInteger, TSCustomDialType) {
    /// 单图片自定义表盘（Single image custom dial）
    eTSCustomDialSingleImage = 1,
    /// 多图片自定义表盘（Multiple images custom dial）
    eTSCustomDialMultipleImage = 2,
    /// 视频自定义表盘（Video custom dial）
    eTSCustomDialVideo = 3
};

/**
 * @brief Time display style enumeration
 * @chinese 时间显示样式枚举
 *
 * @discussion
 * [EN]: Defines 7 different style options for time display appearance:
 *       - eTSDialTimeStyle1: Style 1
 *       - eTSDialTimeStyle2: Style 2
 *       - eTSDialTimeStyle3: Style 3
 *       - eTSDialTimeStyle4: Style 4
 *       - eTSDialTimeStyle5: Style 5
 *       - eTSDialTimeStyle6: Style 6
 *       - eTSDialTimeStyle7: Style 7
 * [CN]: 定义7种不同的时间显示外观样式选项：
 *       - eTSDialTimeStyle1: 样式1
 *       - eTSDialTimeStyle2: 样式2
 *       - eTSDialTimeStyle3: 样式3
 *       - eTSDialTimeStyle4: 样式4
 *       - eTSDialTimeStyle5: 样式5
 *       - eTSDialTimeStyle6: 样式6
 *       - eTSDialTimeStyle7: 样式7
 */
typedef NS_ENUM(NSInteger, TSDialTimeStyle) {
    /// 时间样式-无样式（unknow style）
    eTSDialTimeStyleUnknow = 0,
    /// 时间样式1（Time style 1）
    eTSDialTimeStyle1 = 1,
    /// 时间样式2（Time style 2）
    eTSDialTimeStyle2 = 2,
    /// 时间样式3（Time style 3）
    eTSDialTimeStyle3 = 3,
    /// 时间样式4（Time style 4）
    eTSDialTimeStyle4 = 4,
    /// 时间样式5（Time style 5）
    eTSDialTimeStyle5 = 5,
    /// 时间样式6（Time style 6）
    eTSDialTimeStyle6 = 6,
    /// 时间样式7（Time style 7）
    eTSDialTimeStyle7 = 7
};



NS_ASSUME_NONNULL_END
