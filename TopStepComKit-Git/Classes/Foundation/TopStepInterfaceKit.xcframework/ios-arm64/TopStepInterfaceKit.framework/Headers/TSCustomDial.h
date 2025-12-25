//
//  TSCustomDial.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/12/3.
//

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"
#import "TSCustomDialItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Custom watch face model
 * @chinese 自定义表盘模型
 *
 * @discussion
 * [EN]: Represents a custom watch face created by the user, containing dial identifier,
 *       name, type, and an array of dial items (resources).
 * [CN]: 表示用户创建的自定义表盘，包含表盘标识符、名称、类型和表盘项数组（资源）。
 */
@interface TSCustomDial : TSKitBaseModel

/**
 * @brief Watch face identifier
 * @chinese 表盘标识符
 *
 * @discussion
 * [EN]: Unique identifier for the custom watch face.
 *       Used to distinguish different custom watch faces in the system.
 * [CN]: 自定义表盘的唯一标识符。
 *       用于在系统中区分不同的自定义表盘。
 */
@property (nonatomic, copy, nullable) NSString *dialId;

/**
 * @brief Custom dial type
 * @chinese 自定义表盘类型
 *
 * @discussion
 * [EN]: Type of the custom watch face:
 *       - eTSCustomDialSingleImage (1): Single image-based custom watch face
 *       - eTSCustomDialMultipleImage (2): Multiple images-based custom watch face
 *       - eTSCustomDialVideo (3): Video-based custom watch face
 * [CN]: 自定义表盘的类型：
 *       - eTSCustomDialSingleImage (1): 单图片自定义表盘
 *       - eTSCustomDialMultipleImage (2): 多图片自定义表盘
 *       - eTSCustomDialVideo (3): 视频自定义表盘
 */
@property (nonatomic, assign) TSCustomDialType dialType;

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
 * @brief Preview image item for the watch face
 * @chinese 表盘预览图片项
 *
 * @discussion
 * [EN]: Preview image item that represents the watch face.
 *       Used for displaying a preview of the custom watch face in the user interface.
 *       This property is optional. If set to nil, the SDK will automatically generate
 *       a preview image based on the resourceItems and dial configuration.
 *       May be nil, and SDK will handle preview image generation internally.
 * [CN]: 表示表盘的预览图片项。
 *       用于在用户界面中显示自定义表盘的预览。
 *       此属性是可选的。如果设置为nil，SDK将根据resourceItems和表盘配置自动生成预览图片。
 *       可以为nil，SDK会在内部处理预览图片的生成。
 */
@property (nonatomic, strong, nullable) TSCustomDialItem *previewImageItem;

/**
 * @brief Background image items array
 * @chinese 背景图片项数组
 *
 * @discussion
 * [EN]: Array of background image items that make up this custom watch face.
 *       Each item contains resource path, time position, time color, and item type.
 *       Used for displaying background images or videos in the watch face.
 *       This property is required and cannot be nil or empty.
 *       Must contain at least one TSCustomDialItem for the watch face to be valid.
 * [CN]: 组成此自定义表盘的背景图片项数组。
 *       每个项包含资源路径、时间位置、时间颜色和项类型。
 *       用于在表盘中显示背景图片或视频。
 *       此属性是必需的，不能为nil或空。
 *       必须包含至少一个TSCustomDialItem，表盘才能有效。
 */
@property (nonatomic, strong, nonnull) NSArray<TSCustomDialItem *> *resourceItems;


@end

NS_ASSUME_NONNULL_END
