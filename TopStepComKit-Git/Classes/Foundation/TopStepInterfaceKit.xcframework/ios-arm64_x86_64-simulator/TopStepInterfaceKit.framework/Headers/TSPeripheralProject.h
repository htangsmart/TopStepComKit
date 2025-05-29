//
//  TSPeripheralProject.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/20.
//

/**
 * @brief Project information model for peripheral devices
 * @chinese 外设设备项目信息模型
 *
 * @discussion
 * [EN]: This class manages project-related information for peripheral devices, including:
 *       - Project identification and versioning
 *       - Firmware version management
 *       - Device serial number tracking
 *       - Project number hierarchy (main and sub projects)
 * 
 * [CN]: 该类管理外设设备的项目相关信息，包括：
 *       - 项目标识和版本控制
 *       - 固件版本管理
 *       - 设备序列号跟踪
 *       - 项目编号层级（主项目和子项目）
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPeripheralProject : NSObject

/**
 * @brief Project identifier
 * @chinese 项目标识符
 *
 * @discussion
 * [EN]: Unique identifier for the project type, used to distinguish between different device projects.
 *       This identifier is crucial for device compatibility and feature support verification.
 * 
 * [CN]: 项目类型的唯一标识符，用于区分不同的设备项目。
 *       该标识符对于设备兼容性和功能支持验证至关重要。
 *
 * @note
 * [EN]: - This value can be nil
 *       - Format: Usually a string of numbers and letters
 * 
 * [CN]: - 该值可以为nil
 *       - 格式：通常为数字和字母组成的字符串
 */
@property (nonatomic, copy, nullable) NSString *projectId;

/**
 * @brief Firmware version number
 * @chinese 固件版本号
 *
 * @discussion
 * [EN]: The current firmware version running on the device.
 *       Used for version compatibility checks and update management.
 * 
 * [CN]: 设备当前运行的固件版本。
 *       用于版本兼容性检查和更新管理。
 *
 * @note
 * [EN]: - This value can be nil
 *       - Format: Usually follows semantic versioning (e.g., "1.0.0")
 *       - Used for OTA updates and feature compatibility checks
 * 
 * [CN]: - 该值可以为nil
 *       - 格式：通常遵循语义化版本（如"1.0.0"）
 *       - 用于OTA更新和功能兼容性检查
 */
@property (nonatomic, copy, nullable) NSString *firmVersion;

/**
 * @brief Virtual version number
 * @chinese 虚拟版本号
 *
 * @discussion
 * [EN]: Special version number used for internal version control and feature management.
 *       May differ from the actual firmware version for specific project requirements.
 * 
 * [CN]: 用于内部版本控制和功能管理的特殊版本号。
 *       可能因特定项目需求而与实际固件版本不同。
 *
 * @note
 * [EN]: - This value can be nil
 *       - Used for internal version tracking
 *       - May contain additional version information not visible in firmVersion
 * 
 * [CN]: - 该值可以为nil
 *       - 用于内部版本跟踪
 *       - 可能包含在firmVersion中不可见的额外版本信息
 */
@property (nonatomic, copy, nullable) NSString *virtualVersion;

/**
 * @brief Device serial number
 * @chinese 设备序列号
 *
 * @discussion
 * [EN]: Unique identifier for each individual device.
 *       Used for device tracking, warranty management, and user identification.
 * 
 * [CN]: 每个设备的唯一标识符。
 *       用于设备跟踪、保修管理和用户识别。
 *
 * @note
 * [EN]: - This value can be nil
 *       - Format: Usually a combination of letters and numbers
 *       - Should be unique for each device
 * 
 * [CN]: - 该值可以为nil
 *       - 格式：通常为字母和数字的组合
 *       - 每个设备应该是唯一的
 */
@property (nonatomic, copy, nullable) NSString *deviceSN;

/**
 * @brief Main project number
 * @chinese 主项目号
 *
 * @discussion
 * [EN]: Primary project identifier used in FitCloudKit.
 *       Represents the main category or series of the device.
 * 
 * [CN]: FitCloudKit中使用的主项目标识符。
 *       表示设备的主类别或系列。
 *
 * @note
 * [EN]: - This value can be nil
 *       - Only used in FitCloudKit context
 *       - Usually represents a product line or series
 * 
 * [CN]: - 该值可以为nil
 *       - 仅在FitCloudKit上下文中使用
 *       - 通常表示产品线或系列
 */
@property (nonatomic, copy, nullable) NSString *mainProjNum;

/**
 * @brief Sub project number
 * @chinese 子项目号
 *
 * @discussion
 * [EN]: Secondary project identifier used in FitCloudKit.
 *       Represents specific variants or models within the main project.
 * 
 * [CN]: FitCloudKit中使用的次项目标识符。
 *       表示主项目中的特定变体或型号。
 *
 * @note
 * [EN]: - This value can be nil
 *       - Only used in FitCloudKit context
 *       - Used to distinguish between different models in the same series
 * 
 * [CN]: - 该值可以为nil
 *       - 仅在FitCloudKit上下文中使用
 *       - 用于区分同一系列中的不同型号
 */
@property (nonatomic, copy, nullable) NSString *subProjNum;

@end

NS_ASSUME_NONNULL_END
