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
 * @brief Watch face information model
 * @chinese 表盘信息模型
 *
 * @discussion
 * [EN]: This class encapsulates all information related to a watch face,
 *       including identification, type, status, location, version, and file path.
 * [CN]: 该类封装了表盘的所有相关信息，包括标识、类型、状态、位置、版本和文件路径。
 */
@interface TSDialModel : TSKitBaseModel

/**
 * @brief Unique identifier for the watch face
 * @chinese 表盘唯一标识符
 *
 * @discussion
 * [EN]: A unique string identifier used to distinguish different watch faces.
 *       This ID is typically assigned by the system or server.
 * [CN]: 用于区分不同表盘的唯一字符串标识符，通常由系统或服务器分配。
 */
@property (nonatomic, strong) NSString *dialId;

/**
 * @brief Display name of the watch face
 * @chinese 表盘显示名称
 *
 * @discussion
 * [EN]: The name displayed to users for this watch face.
 *       This is the human-readable name shown in the UI.
 * [CN]: 表盘显示给用户的名称，这是在UI中显示的可读名称。
 */
@property (nonatomic, strong) NSString *dialName;

/**
 * @brief Type of the watch face
 * @chinese 表盘类型
 *
 * @discussion
 * [EN]: Indicates the type of watch face:
 *       - eTSDialTypeBuiltIn: Built-in watch face that comes with the device
 *       - eTSDialTypeCustomer: Custom watch face created by users
 *       - eTSDialTypeCloud: Watch face downloaded from cloud server
 * [CN]: 指示表盘的类型：
 *       - eTSDialTypeBuiltIn: 设备自带的内置表盘
 *       - eTSDialTypeCustomer: 用户创建的自定义表盘
 *       - eTSDialTypeCloud: 从云服务器下载的表盘
 */
@property (nonatomic, assign) TSDialType dialType;

/**
 * @brief Indicates whether this is the current watch face
 * @chinese 指示这是否是当前表盘
 *
 * @discussion
 * [EN]: YES if this watch face is currently active on the device,
 *       NO otherwise. Used for UI highlighting and state management.
 * [CN]: YES表示此表盘是当前表盘，NO表示不是当前表盘。
 *       用于UI高亮显示和状态管理。
 */
@property (nonatomic, assign) BOOL isCurrent;

/**
 * @brief Location index of the watch face on the device
 * @chinese 表盘在设备上的位置索引
 *
 * @discussion
 * [EN]: The position index where this watch face is stored on the device.
 *       Used to identify the slot location for watch face management operations.
 * [CN]: 表盘在设备上存储的位置索引，用于标识表盘管理操作中的槽位位置。
 *
 * @note
 * [EN]: Valid range depends on device capabilities, typically 0-9 or 0-19.
 * [CN]: 有效范围取决于设备能力，通常为0-9或0-19。
 */
@property (nonatomic, assign) UInt8 locationIndex;

/**
 * @brief Version number of the watch face
 * @chinese 表盘版本号
 *
 * @discussion
 * [EN]: Version number of the watch face, used for version control and update management.
 *       Higher version numbers indicate newer versions.
 * [CN]: 表盘的版本号，用于版本控制和更新管理。版本号越大表示版本越新。
 */
@property (nonatomic, assign) NSInteger version;

/**
 * @brief Local file system path to the watch face resources
 * @chinese 表盘资源在本地文件系统中的路径
 *
 * @discussion
 * [EN]: The file path where watch face resources are stored locally.
 *       For cloud watch faces, this will be the downloaded file path.
 *       For built-in watch faces, this may be nil or point to system resources.
 * [CN]: 表盘资源在本地文件系统中的存储路径。
 *       对于云端表盘，这是下载后的文件路径。
 *       对于内置表盘，可能为nil或指向系统资源。
 *
 * @note
 * [EN]: This path should be a valid file system path. Use nil if the watch face
 *       is not stored locally or is a built-in system watch face.
 * [CN]: 此路径应为有效的文件系统路径。如果表盘未本地存储或是内置系统表盘，则使用nil。
 */
@property (nonatomic, strong, nullable) NSString *filePath;

/**
 * @brief Get detailed debug description of the watch face model
 * @chinese 获取表盘模型的详细调试描述信息
 *
 * @return 
 * EN: A formatted string containing all properties of the watch face model,
 *     including dialId, dialName, dialType, isCurrent, locationIndex, version, and filePath.
 *     Used for debugging and logging purposes.
 * CN: 包含表盘模型所有属性的格式化字符串，包括dialId、dialName、dialType、
 *     isCurrent、locationIndex、version和filePath。用于调试和日志记录。
 *
 * @discussion
 * [EN]: This method returns a human-readable string representation of all
 *       watch face properties, formatted for easy debugging. The output includes
 *       memory address, all property values, and their descriptions.
 * [CN]: 此方法返回所有表盘属性的人类可读字符串表示，格式化为便于调试。
 *       输出包括内存地址、所有属性值及其描述。
 */
- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
