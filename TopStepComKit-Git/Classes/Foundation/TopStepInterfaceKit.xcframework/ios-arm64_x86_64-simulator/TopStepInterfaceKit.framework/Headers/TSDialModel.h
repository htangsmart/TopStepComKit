//
//  TSDialModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/18.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face model (Abstract Base Class)
 * @chinese 表盘模型（抽象基类）
 * 
 * @discussion 
 * EN: This is an abstract base class for watch face models.
 *     DO NOT instantiate this class directly.
 *     Instead, use one of its concrete subclasses:
 *     - TSFitDialModel: For Fit series devices
 *     - TSFwDialModel:  For Firmware series devices
 *     - TSSJDialModel:  For SJ series devices
 * 
 * CN: 这是一个表盘模型的抽象基类。
 *     不要直接实例化此类。
 *     请使用以下具体子类之一：
 *     - TSFitDialModel: 用于 中科、瑞煜系列设备
 *     - TSFwDialModel:  用于 恒玄 系列设备
 *     - TSSJDialModel:  用于 伸聚 系列设备
 */
@interface TSDialModel : TSKitBaseModel


/**
 * @brief Watch face identifier
 * @chinese 表盘标识符
 * 
 * @discussion 
 * EN: Unique identifier for the watch face
 *     Used to distinguish different watch faces in the system
 * CN: 表盘的唯一标识符
 *     用于在系统中区分不同的表盘
 */
@property(nonatomic, strong) NSString* dialId;

/**
 * @brief Watch face name
 * @chinese 表盘名称
 * 
 * @discussion 
 * EN: Display name of the watch face
 *     Used for user interface display and identification
 * CN: 表盘的显示名称
 *     用于界面显示和识别
 */
@property(nonatomic, strong) NSString* dialName;

/**
 * @brief Watch face type
 * @chinese 表盘类型
 * 
 * @discussion 
 * EN: Type of the watch face (local/custom/cloud)
 *     Determines how the watch face is managed and displayed
 * CN: 表盘的类型（本地/自定义/云端）
 *     决定表盘如何被管理和显示
 */
@property (nonatomic,assign) TSDialType dialType;

/**
 * @brief Current watch face flag
 * @chinese 当前表盘标志
 *
 * @discussion
 * EN: Indicates whether this is the currently selected watch face.
 *     YES: This is the current watch face
 *     NO: This is not the current watch face
 *     Used for UI highlighting and state management.
 *
 * CN: 指示这是否是当前选中的表盘。
 *     YES: 这是当前表盘
 *     NO: 这不是当前表盘
 *     用于UI高亮显示和状态管理。
 */
@property (nonatomic, assign) BOOL isCurrent;

/**
 * @brief Watch face file path
 * @chinese 表盘文件路径
 * 
 * @discussion 
 * EN: Local file system path to the watch face resources
 *     Used for accessing watch face files during operations
 *     For cloud watch faces, this will be the downloaded file path
 * CN: 表盘资源在本地文件系统中的路径
 *     用于在操作过程中访问表盘文件
 *     对于云端表盘，这将是下载后的文件路径
 */
@property(nonatomic, strong) NSString* filePath;

/**
 * @brief Watch face template bin file local path
 * @chinese 表盘模版bin文件本地路径
 *
 * @discussion
 * [EN]: Local file system path to the watch face template bin file.
 *       Used for accessing watch face template files during operations.
 *       This is the local path of the template bin file that will be pushed to the device.
 * [CN]: 表盘模版bin文件在本地文件系统中的路径。
 *       用于在操作过程中访问表盘模版文件。
 *       这是将要推送到设备的模版bin文件的本地路径。
 */
@property (nonatomic, strong, nullable) NSString *templateFilePath;


/**
 * @brief Watch face size
 * @chinese 表盘尺寸
 * 
 * @discussion 
 * EN: The actual size of the watch face in pixels (width x height)
 *     Used for rendering and displaying the watch face on the device
 *     Must match the device's screen resolution
 * CN: 表盘的实际像素尺寸（宽 x 高）
 *     用于在设备上渲染和显示表盘
 *     必须与设备的屏幕分辨率相匹配
 */
@property (nonatomic,assign) CGSize dialSize;

/**
 * @brief Watch face preview size
 * @chinese 表盘预览尺寸
 * 
 * @discussion 
 * EN: The size of the watch face preview image in pixels (width x height)
 *     Used for displaying watch face thumbnails in the App
 *     Usually smaller than the actual dialSize for better performance
 * CN: 表盘预览图的像素尺寸（宽 x 高）
 *     用于在App中显示表盘缩略图
 *     通常比实际dialSize小，以获得更好的性能
 */
@property (nonatomic,assign) CGSize dialPreviewSize;


@end

NS_ASSUME_NONNULL_END
