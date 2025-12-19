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
    /// 推送中
    eTSDialPushResultProgress = 0,
    /// 推送成功
    eTSDialPushResultSuccess,
    /// 推送失败
    eTSDialPushResultFailed,
    /// 安装中
    eTSDialPushResultOnInstalling,
    /// 安装成功
    eTSDialPushResultOnInstallSuccess,
    /// 安装失败
    eTSDialPushResultOnInstallFailed,
    /// 推送完成（无论成功失败）
    eTSDialPushResultCompleted
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



NS_ASSUME_NONNULL_END
