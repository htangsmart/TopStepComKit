//
//  TSApplicationModel.h
//  Pods
//
//  Created by 磐石 on 2025/12/3.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Application type enumeration
 * @chinese 应用类型枚举
 *
 * @discussion
 * [EN]: Defines different types of applications on the watch device:
 *       - eTSApplicationTypeSystem: Built-in system applications (cannot be uninstalled)
 *       - eTSApplicationTypeUserInstalled: User-installed applications (can be uninstalled)
 * [CN]: 定义手表设备上不同类型的应用：
 *       - eTSApplicationTypeSystem: 系统应用（不可卸载）
 *       - eTSApplicationTypeUserInstalled: 用户安装的应用（可卸载）
 */
typedef NS_ENUM(NSInteger, TSApplicationType) {
    /// 系统应用（System application - cannot be uninstalled）
    eTSApplicationTypeSystem = 0,
    /// 用户安装的应用（User-installed application - can be uninstalled）
    eTSApplicationTypeUserInstalled = 1
};

/**
 * @brief Watch device application model
 * @chinese 手表设备应用模型
 *
 * @discussion
 * [EN]: This model represents an application installed on the watch device.
 *       It contains information about the application including identifier, name, version,
 *       installation status, and other metadata.
 * [CN]: 该模型表示安装在手表设备上的应用。
 *       包含应用的标识符、名称、版本、安装状态和其他元数据信息。
 */
@interface TSApplicationModel : TSKitBaseModel

/**
 * @brief Application identifier
 * @chinese 应用标识符
 *
 * @discussion
 * [EN]: Unique identifier for the application on the watch device.
 *       Used to distinguish different applications in the system.
 * [CN]: 手表设备上应用的唯一标识符。
 *       用于在系统中区分不同的应用。
 */
@property (nonatomic, copy, nullable) NSString *appId;

/**
 * @brief Application name
 * @chinese 应用名称
 *
 * @discussion
 * [EN]: Display name of the application.
 *       Used for user interface display and identification.
 * [CN]: 应用的显示名称。
 *       用于界面显示和识别。
 */
@property (nonatomic, copy, nullable) NSString *appName;

/**
 * @brief Application type
 * @chinese 应用类型
 *
 * @discussion
 * [EN]: Type of the application (system/user-installed).
 *       Determines how the application is managed and displayed.
 *       System applications cannot be uninstalled, while user-installed applications can be uninstalled.
 *       Default is eTSApplicationTypeSystem.
 * [CN]: 应用的类型（系统/用户安装）。
 *       决定应用如何被管理和显示。
 *       系统应用不可卸载，用户安装的应用可以卸载。
 *       默认为 eTSApplicationTypeSystem。
 */
@property (nonatomic, assign) TSApplicationType appType;

/**
 * @brief Application version
 * @chinese 应用版本
 *
 * @discussion
 * [EN]: Version string of the application (e.g., "1.0.0").
 *       Used to identify the application version for updates and compatibility checks.
 * [CN]: 应用的版本字符串（例如 "1.0.0"）。
 *       用于识别应用版本以进行更新和兼容性检查。
 */
@property (nonatomic, copy, nullable) NSString *version;

/**
 * @brief Application icon path
 * @chinese 应用图标路径
 *
 * @discussion
 * [EN]: Local file path or URL to the application icon image.
 *       Used for displaying the application icon in the UI.
 *       May be nil if icon is not available.
 * [CN]: 应用图标图像的本地文件路径或URL。
 *       用于在UI中显示应用图标。
 *       如果图标不可用可能为nil。
 */
@property (nonatomic, copy, nullable) NSString *iconPath;

/**
 * @brief Application size in bytes
 * @chinese 应用大小（字节）
 *
 * @discussion
 * [EN]: The size of the application in bytes.
 *       Represents the storage space occupied by the application on the device.
 *       May be 0 if size is unknown or not yet determined.
 * [CN]: 应用的大小（字节）。
 *       表示应用在设备上占用的存储空间。
 *       如果大小未知或尚未确定可能为0。
 */
@property (nonatomic, assign) NSUInteger size;

/**
 * @brief Whether the application is installed
 * @chinese 应用是否已安装
 *
 * @discussion
 * [EN]: Indicates whether the application is currently installed on the watch device.
 *       YES means the application is installed, NO means it's not installed or has been uninstalled.
 *       Default is NO.
 * [CN]: 表示应用是否已安装在手表设备上。
 *       YES表示应用已安装，NO表示未安装或已被卸载。
 *       默认为NO。
 */
@property (nonatomic, assign) BOOL isInstalled;

/**
 * @brief Whether the application is enabled
 * @chinese 应用是否启用
 *
 * @discussion
 * [EN]: Indicates whether the application is currently enabled and can be used.
 *       YES means the application is enabled, NO means it's disabled.
 *       Default is YES.
 * [CN]: 表示应用当前是否启用并可以使用。
 *       YES表示应用已启用，NO表示应用已禁用。
 *       默认为YES。
 */
@property (nonatomic, assign) BOOL isEnabled;

/**
 * @brief Application path on device
 * @chinese 应用在设备上的路径
 *
 * @discussion
 * [EN]: File system path where the application is located on the watch device.
 *       Used for accessing application files and resources.
 *       May be nil if path is not available.
 * [CN]: 应用在手表设备上的文件系统路径。
 *       用于访问应用文件和资源。
 *       如果路径不可用可能为nil。
 */
@property (nonatomic, copy, nullable) NSString *appPath;

/**
 * @brief Application description
 * @chinese 应用描述
 *
 * @discussion
 * [EN]: Description or summary of the application's functionality.
 *       Used to provide information about what the application does.
 *       May be nil if description is not available.
 * [CN]: 应用功能的描述或摘要。
 *       用于提供关于应用功能的信息。
 *       如果描述不可用可能为nil。
 */
@property (nonatomic, copy, nullable) NSString *appDescription;

/**
 * @brief Application package name
 * @chinese 应用包名
 *
 * @discussion
 * [EN]: Package name or bundle identifier of the application.
 *       Used for uniquely identifying the application package.
 *       May be nil if package name is not available.
 * [CN]: 应用的包名或Bundle标识符。
 *       用于唯一标识应用包。
 *       如果包名不可用可能为nil。
 */
@property (nonatomic, copy, nullable) NSString *packageName;

/**
 * @brief Application installation timestamp
 * @chinese 应用安装时间戳
 *
 * @discussion
 * [EN]: Timestamp when the application was installed on the device (seconds since 1970-01-01).
 *       Used to track when the application was installed.
 *       May be 0 if installation time is unknown.
 * [CN]: 应用在设备上安装的时间戳（自1970-01-01起的秒数）。
 *       用于跟踪应用的安装时间。
 *       如果安装时间未知可能为0。
 */
@property (nonatomic, assign) NSTimeInterval installTime;

/**
 * @brief Application update timestamp
 * @chinese 应用更新时间戳
 *
 * @discussion
 * [EN]: Timestamp when the application was last updated (seconds since 1970-01-01).
 *       Used to track when the application was last modified or updated.
 *       May be 0 if update time is unknown.
 * [CN]: 应用最后更新的时间戳（自1970-01-01起的秒数）。
 *       用于跟踪应用的最后修改或更新时间。
 *       如果更新时间未知可能为0。
 */
@property (nonatomic, assign) NSTimeInterval updateTime;

@end

NS_ASSUME_NONNULL_END
