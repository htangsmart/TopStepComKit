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
 * @brief Watch face install result type
 * @chinese 表盘安装结果类型
 */
typedef NS_ENUM(NSInteger, TSDialInstallResult) {
    /// 开始（Start）
    eTSDialInstallResultStart = 0,
    /// 安装中（Installing）
    eTSDialInstallResultProgress = 1,
    /// 安装成功（Success）
    eTSDialInstallResultSuccess = 2,
    /// 安装失败（Failed）
    eTSDialInstallResultFailed = 3,
    /// 安装完成，无论成功失败（Completed, regardless of success or failure）
    eTSDialInstallResultCompleted = 4,
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
 * @brief Dial draft type enumeration
 * @chinese 表盘草稿类型枚举
 *
 * @discussion
 * [EN]: Defines the custom watch face package shape accepted by TSDialDraft.
 * [CN]: 定义 TSDialDraft 可接受的自定义表盘造包形态。
 */
typedef NS_ENUM(NSInteger, TSDialDraftType) {
    /// Single image dial draft / 单图表盘草稿
    TSDialDraftTypeSingleImage = 1,
    /// Multiple image dial draft / 多图表盘草稿
    TSDialDraftTypeMultipleImage = 2,
    /// Video dial draft / 视频表盘草稿
    TSDialDraftTypeVideo = 3
};

/**
 * @brief Dial draft item resource type
 * @chinese 表盘草稿资源项类型
 *
 * @discussion
 * [EN]: Describes whether one TSDialDraftItem carries an image or a video resource.
 * [CN]: 描述一个 TSDialDraftItem 承载的是图片资源还是视频资源。
 */
typedef NS_ENUM(NSInteger, TSDialDraftItemType) {
    /// Image draft item / 图片草稿资源项
    TSDialDraftItemTypeImage = 1,
    /// Video draft item / 视频草稿资源项
    TSDialDraftItemTypeVideo = 2
};

/**
 * @brief Dial validation error code
 * @chinese 表盘校验错误码
 *
 * @discussion
 * [EN]: Stable NSError.code values for kTSErrorDomainDialName validation failures.
 * [CN]: kTSErrorDomainDialName 下稳定的校验错误码。
 */
typedef NS_ENUM(NSInteger, TSDialErrorCode) {
    /// Invalid draft type / 草稿类型无效
    TSDialErrorInvalidDraftType = 31001,
    /// Missing template file path / 模板路径为空
    TSDialErrorMissingTemplateFilePath = 31002,
    /// Template file does not exist / 模板文件不存在
    TSDialErrorTemplateFileNotFound = 31003,
    /// Draft items are empty / 草稿资源项为空
    TSDialErrorEmptyDraftItems = 31004,
    /// Invalid draft item count / 草稿资源项数量无效
    TSDialErrorInvalidDraftItemCount = 31005,
    /// Invalid draft item type / 草稿资源项类型无效
    TSDialErrorInvalidDraftItemType = 31006,
    /// Missing draft item time / 草稿资源项时间配置为空
    TSDialErrorMissingDraftItemTime = 31007,
    /// Missing image resource / 图片资源为空
    TSDialErrorMissingImageResource = 31008,
    /// Missing video file path / 视频文件路径为空
    TSDialErrorMissingVideoFilePath = 31009,
    /// Video file does not exist / 视频文件不存在
    TSDialErrorVideoFileNotFound = 31010,
    /// Screen size is zero / 屏幕尺寸为空
    TSDialErrorInvalidScreenSize = 31011,
    /// Image size mismatch / 图片尺寸不匹配
    TSDialErrorImageSizeMismatch = 31012,
    /// Missing artifact dial id / 产物表盘 id 为空
    TSDialErrorMissingArtifactDialId = 31013,
    /// Missing artifact package path / 产物表盘包路径为空
    TSDialErrorMissingArtifactFilePath = 31014,
    /// Artifact package file does not exist / 产物表盘包文件不存在
    TSDialErrorArtifactFileNotFound = 31015,
    /// Missing preview background image / 预览底图为空
    TSDialErrorMissingPreviewBackgroundImage = 31018,
    /// Invalid artifact dial type / 产物表盘类型无效
    TSDialErrorInvalidArtifactDialType = 31019
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
    /// 时间样式-无样式（none style）
    eTSDialTimeStyleNone = 0,
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
