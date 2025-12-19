//
//  TSAppStoreInterface.h
//
//  Created by 磐石 on 2025/12/3.
//

#import "TSKitBaseInterface.h"
#import "TSApplicationModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Application list callback block type
 * @chinese 应用列表回调块类型
 *
 * @param applications
 * EN: Array of application models, empty array if retrieval fails
 * CN: 应用模型数组，获取失败时为空数组
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 获取失败时的错误信息，成功时为nil
 */
typedef void (^TSApplicationListBlock)(NSArray<TSApplicationModel *> *_Nullable applications, NSError *_Nullable error);

/**
 * @brief Application status enumeration
 * @chinese 应用状态枚举
 *
 * @discussion
 * [EN]: Defines different types of application status:
 *       - eTSApplicationStatusInstalled: Application was installed
 *       - eTSApplicationStatusUninstalled: Application was uninstalled/deleted
 *       - eTSApplicationStatusDisabled: Application was disabled
 *       - eTSApplicationStatusEnabled: Application was enabled
 * [CN]: 定义不同类型的应用状态：
 *       - eTSApplicationStatusInstalled: 应用被安装
 *       - eTSApplicationStatusUninstalled: 应用被卸载/删除
 *       - eTSApplicationStatusDisabled: 应用被禁用
 *       - eTSApplicationStatusEnabled: 应用被启用
 */
typedef NS_ENUM(NSInteger, TSApplicationStatus) {
    /// 应用被安装（Application was installed）
    eTSApplicationStatusUnknow = 0,
    /// 应用被安装（Application was installed）
    eTSApplicationStatusInstalled = 1,
    /// 应用被卸载/删除（Application was uninstalled/deleted）
    eTSApplicationStatusUninstalled = 2,
    /// 应用被禁用（Application was disabled）
    eTSApplicationStatusDisabled = 3,
    /// 应用被启用（Application was enabled）
    eTSApplicationStatusEnabled = 4
};

/**
 * @brief Application change notification callback block type
 * @chinese 应用变化通知回调块类型
 *
 * @param application
 * EN: Application model that changed, nil if notification fails
 * CN: 发生变化的应用模型，通知失败时为nil
 *
 * @param changeType
 * EN: Type of change that occurred (installed, uninstalled, disabled, enabled)
 * CN: 发生的变化类型（安装、卸载、禁用、启用）
 *
 * @param error
 * EN: Error information if notification fails, nil if successful
 * CN: 通知失败时的错误信息，成功时为nil
 */
typedef void (^TSApplicationChangeBlock)(TSApplicationModel *_Nullable application, TSApplicationStatus changeType, NSError *_Nullable error);

/**
 * @brief Watch device application store management interface
 * @chinese 手表设备应用商店管理接口
 *
 * @discussion
 * [EN]: This interface defines all operations related to application management on the watch device, including:
 *       1. Fetch application list
 *       2. Monitor application list changes
 * [CN]: 该接口定义了与手表设备应用管理相关的所有操作，包括：
 *       1. 获取应用列表
 *       2. 监听应用列表变化
 */
@protocol TSAppStoreInterface <TSKitBaseInterface>

/**
 * @brief Fetch all installed applications on the device
 * @chinese 获取设备上所有已安装的应用列表
 *
 * @param completion
 * EN: Completion callback with array of all installed application models
 * CN: 完成回调，返回所有已安装的应用模型数组
 *
 * @discussion
 * [EN]: This method retrieves information about all applications that are currently installed on the watch device.
 *       Only returns applications where isInstalled is YES.
 *       Including both system applications and user-installed applications.
 *       The callback will be called on the main thread.
 * [CN]: 此方法获取设备上所有当前已安装应用的信息。
 *       只返回 isInstalled 为 YES 的应用。
 *       包括系统应用和用户安装的应用。
 *       回调将在主线程执行。
 */
- (void)fetchAllInstalledApplications:(TSApplicationListBlock)completion;

/**
 * @brief Check if a specific application is installed on the device
 * @chinese 检查指定应用是否已安装在设备上
 *
 * @param application
 * EN: Application model to check. Must contain appId or packageName for identification.
 * CN: 要检查的应用模型。必须包含appId或packageName用于识别。
 *
 * @param completion
 * EN: Completion callback
 *     - isInstalled: YES if the application is installed, NO otherwise
 *     - error: Error information if check fails, nil if successful
 * CN: 检查完成的回调
 *     - isInstalled: 如果应用已安装返回YES，否则返回NO
 *     - error: 检查失败时的错误信息，成功时为nil
 *
 * @discussion
 * [EN]: This method checks whether a specific application is currently installed on the watch device.
 *       The application is identified by appId or packageName from the provided TSApplicationModel.
 *       Returns YES if the application is found and isInstalled is YES, NO otherwise.
 *       The callback will be called on the main thread.
 * [CN]: 此方法检查指定应用是否已安装在手表设备上。
 *       应用通过提供的TSApplicationModel中的appId或packageName进行识别。
 *       如果找到应用且isInstalled为YES则返回YES，否则返回NO。
 *       回调将在主线程执行。
 *
 * @note
 * [EN]: - The application parameter must contain at least appId or packageName
 *       - If both appId and packageName are provided, appId takes precedence
 *       - Returns NO if the application is not found on the device
 * [CN]: - application参数必须至少包含appId或packageName
 *       - 如果同时提供了appId和packageName，优先使用appId
 *       - 如果设备上未找到应用则返回NO
 */
- (void)checkApplicationInstalled:(TSApplicationModel *)application completion:(void (^)(BOOL isInstalled, NSError * _Nullable error))completion;

/**
 * @brief Register application list change listener
 * @chinese 注册应用列表变化监听
 *
 * @param completion
 * EN: Callback when the application list changes on the device
 *     Returns the updated application list and optional error
 * CN: 当设备上的应用列表发生变化时的回调
 *     返回更新后的应用列表和可选错误信息
 *
 * @discussion
 * [EN]: This callback will be triggered when applications are installed, uninstalled, enabled, or disabled on the device.
 *       The callback provides the updated application list snapshot.
 *       Use this to keep the UI synchronized with device state changes.
 *       The callback will be called on the main thread.
 *       
 *       To stop receiving notifications, call unregisterApplicationListDidChanged.
 * [CN]: 当设备上的应用被安装、卸载、启用或禁用时，此回调会被触发。
 *       回调提供更新后的应用列表快照。
 *       使用此方法保持UI与设备状态变化同步。
 *       回调将在主线程执行。
 *       
 *       要停止接收通知，请调用 unregisterApplicationListDidChanged。
 *
 * @note
 * [EN]: Multiple registrations will override previous ones.
 *       Remember to call unregisterApplicationListDidChanged when done to avoid memory leaks.
 * [CN]: 多次注册会覆盖之前的注册。
 *       使用完毕后记得调用 unregisterApplicationListDidChanged 以避免内存泄漏。
 */
- (void)registerApplicationListDidChanged:(TSApplicationListBlock)completion;

/**
 * @brief Unregister application list change listener
 * @chinese 取消注册应用列表变化监听
 *
 * @discussion
 * [EN]: Removes the registered application list change listener.
 *       After calling this method, no more change notifications will be received.
 * [CN]: 移除已注册的应用列表变化监听器。
 *       调用此方法后，将不再接收变化通知。
 *
 * @note
 * [EN]: If no listener is currently registered, calling this method has no effect.
 * [CN]: 如果当前没有注册监听器，调用此方法不会有任何效果。
 */
- (void)unregisterApplicationListDidChanged;

/**
 * @brief Register application change notification listener
 * @chinese 注册应用变化通知监听
 *
 * @param completion
 * EN: Callback when an application state changes on the device
 *     - application: Application model that changed
 *     - changeType: Type of change (installed, uninstalled, disabled, enabled)
 *     - error: Error information if notification fails, nil if successful
 * CN: 当设备上的应用状态发生变化时的回调
 *     - application: 发生变化的应用模型
 *     - changeType: 变化类型（安装、卸载、禁用、启用）
 *     - error: 通知失败时的错误信息，成功时为nil
 *
 * @discussion
 * [EN]: This callback will be triggered when a specific application's state changes on the device:
 *       - Installed: When an application is newly installed
 *       - Uninstalled: When an application is removed/deleted
 *       - Disabled: When an application is disabled (but still installed)
 *       - Enabled: When a disabled application is re-enabled
 *       
 *       Unlike registerApplicationListDidChanged which provides the entire application list,
 *       this method provides granular notifications for individual application changes.
 *       The callback will be called on the main thread.
 *       
 *       To stop receiving notifications, call unregisterApplicationDidChanged.
 * [CN]: 当设备上特定应用的状态发生变化时，此回调会被触发：
 *       - Installed: 当应用被新安装时
 *       - Uninstalled: 当应用被移除/删除时
 *       - Disabled: 当应用被禁用时（但仍已安装）
 *       - Enabled: 当被禁用的应用被重新启用时
 *       
 *       与 registerApplicationListDidChanged 提供整个应用列表不同，
 *       此方法提供单个应用变化的细粒度通知。
 *       回调将在主线程执行。
 *       
 *       要停止接收通知，请调用 unregisterApplicationDidChanged。
 *
 * @note
 * [EN]: Multiple registrations will override previous ones.
 *       Remember to call unregisterApplicationDidChanged when done to avoid memory leaks.
 *       The callback provides detailed information about which application changed and how.
 * [CN]: 多次注册会覆盖之前的注册。
 *       使用完毕后记得调用 unregisterApplicationDidChanged 以避免内存泄漏。
 *       回调提供关于哪个应用发生变化以及如何变化的详细信息。
 */
- (void)registerApplicationDidChanged:(TSApplicationChangeBlock)completion;

/**
 * @brief Unregister application change notification listener
 * @chinese 取消注册应用变化通知监听
 *
 * @discussion
 * [EN]: Removes the registered application change notification listener.
 *       After calling this method, no more change notifications will be received.
 * [CN]: 移除已注册的应用变化通知监听器。
 *       调用此方法后，将不再接收变化通知。
 *
 * @note
 * [EN]: If no listener is currently registered, calling this method has no effect.
 * [CN]: 如果当前没有注册监听器，调用此方法不会有任何效果。
 */
- (void)unregisterApplicationDidChanged;

@end

NS_ASSUME_NONNULL_END
