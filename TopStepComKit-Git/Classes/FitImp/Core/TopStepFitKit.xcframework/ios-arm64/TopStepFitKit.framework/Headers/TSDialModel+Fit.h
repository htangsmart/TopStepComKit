//
//  TSDialModel+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class FitCloudWatchfaceSlot;
@class FitCloudWatchfaceUIInfo;
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Completion for selecting an installable Fit watch-face slot
 * @chinese 选择 Fit 可安装表盘槽位的完成回调
 *
 * @param success
 * EN: Whether an installable slot was found
 * CN: 是否找到可安装槽位
 *
 * @param switchSlotIndex
 * EN: Device slot index used to select the installed watch face
 * CN: 安装后用于切换表盘的设备槽位索引
 *
 * @param pushIndex
 * EN: One-based watch-face index written into the binary before transfer
 * CN: 传输前写入表盘二进制文件的一基推送序号
 *
 * @param error
 * EN: Error returned when selecting the slot fails
 * CN: 选择槽位失败时返回的错误
 */
typedef void (^TSFitDialSlotSelectionCompletion)(BOOL success,
                                                 NSInteger switchSlotIndex,
                                                 NSInteger pushIndex,
                                                 NSError * _Nullable error);

@interface TSDialModel (Fit)

/**
 * @brief Convert the watch-face information using the device's slot capability.
 * @chinese 根据设备是否支持多表盘，将表盘信息转换为统一列表。
 * @param uiInfo EN: Device watch-face information. CN: 设备返回的表盘信息。
 * @param supportsMultipleSlots EN: Both upgrade and multi-watch-face flags are enabled.
 * CN: 固件同时开启表盘升级和多表盘能力。
 * @return EN: Visible slots, or only the reported current face on a single-face device.
 * CN: 多表盘设备返回可见槽位；单表盘设备仅返回设备上报的当前表盘。
 * @discussion EN: A single-face device has no valid slot index; locationIndex is UINT8_MAX.
 * CN: 单表盘设备没有有效槽位索引，locationIndex 使用 UINT8_MAX 表示不可用。
 */
+ (NSArray<TSDialModel *> *)modelsWithFitCloudUIInfo:(FitCloudWatchfaceUIInfo *)uiInfo
                             supportsMultipleSlots:(BOOL)supportsMultipleSlots;

/**
 * @brief Convert FitCloudWatchfaceSlot to TSDialModel
 * @chinese 将FitCloudWatchfaceSlot转换为TSDialModel
 * 
 * @param slot 
 * EN: FitCloudWatchfaceSlot object to be converted
 * CN: 需要转换的FitCloudWatchfaceSlot对象
 * 
 * @return 
 * EN: A new TSDialModel instance with properties set from the slot
 * CN: 根据slot信息设置属性的新TSDialModel实例
 * 
 * @discussion
 * EN: This method converts a FitCloudWatchfaceSlot object to TSDialModel:
 *     - Sets dialId from watchfaceNo
 *     - Sets dialType based on slotType and the Fit custom watch-face identifiers
 *     - Sets locationIndex from slotIndex
 *     - Sets version from watchfaceVersion
 * CN: 此方法将FitCloudWatchfaceSlot对象转换为TSDialModel：
 *     - 从watchfaceNo设置dialId
 *     - 根据slotType和 Fit 自定义表盘编号设置dialType
 *     - 从slotIndex设置locationIndex
 *     - 从watchfaceVersion设置version
 */
+ (nullable instancetype)modelWithFitCloudWatchfaceSlot:(FitCloudWatchfaceSlot *)slot;

/**
 * @brief Convert FitCloudWatchfaceSlot to TSDialModel with UI info
 * @chinese 使用UI信息将FitCloudWatchfaceSlot转换为TSDialModel
 * 
 * @param slot 
 * EN: FitCloudWatchfaceSlot object to be converted
 * CN: 需要转换的FitCloudWatchfaceSlot对象
 * 
 * @param uiInfo 
 * EN: FitCloudWatchfaceUIInfo object containing additional UI information
 * CN: 包含额外UI信息的FitCloudWatchfaceUIInfo对象
 * 
 * @return 
 * EN: A new TSDialModel instance with properties set from both slot and UI info
 * CN: 根据slot和UI信息设置属性的新TSDialModel实例
 * 
 * @discussion 
 * EN: This method extends the basic conversion by adding UI information:
 *     - All basic properties from modelWithFitCloudWatchfaceSlot:
 *     - Sets isCurrent based on the current watch-face number and slot index
 * CN: 此方法通过添加UI信息扩展了基本转换：
 *     - 包含modelWithFitCloudWatchfaceSlot:的所有基本属性
 *     - 根据当前表盘编号和槽位索引设置isCurrent
 */
+ (nullable instancetype)modelWithFitCloudWatchfaceSlot:(FitCloudWatchfaceSlot *)slot
                                                uiInfo:(FitCloudWatchfaceUIInfo *)uiInfo;

/**
 * @brief Whether the connected project is 9804 or 980E
 * @chinese 当前连接项目是否为 9804 或 980E
 *
 * @return
 * EN: YES for project 9804 or 980E
 * CN: 项目号为 9804 或 980E 时返回 YES
 */
+ (BOOL)isProject9804Family;

/**
 * @brief Select an installable device slot for the specified watch-face type
 * @chinese 为指定表盘类型选择可安装的设备槽位
 *
 * @param dialType
 * EN: Custom or cloud watch-face type to install
 * CN: 要安装的自定义或云端表盘类型
 *
 * @param completion
 * EN: Completion containing the real device slot index, binary push index, and error
 * CN: 返回真实设备槽位索引、二进制推送序号及错误的完成回调
 */
+ (void)selectInstallableSlotForDialType:(TSDialType)dialType
                              completion:(TSFitDialSlotSelectionCompletion)completion;

/**
 * @brief Select a slot with sufficient capacity for the package.
 * @chinese 根据表盘文件大小选择容量足够的可用槽位。
 * @param dialType EN: Watch-face type. CN: 表盘类型。
 * @param fileSize EN: Required bytes; zero skips capacity checks for legacy queries. CN: 所需字节数；零仅供旧查询跳过容量检查。
 * @param completion EN: Main-thread callback with slot, push index and error. CN: 主线程返回槽位、推送序号及错误。
 */
+ (void)selectInstallableSlotForDialType:(TSDialType)dialType
                              fileSize:(unsigned long long)fileSize
                            completion:(void (^)(FitCloudWatchfaceSlot * _Nullable slot,
                                                 NSInteger pushIndex,
                                                 NSError * _Nullable error))completion;

/**
 * @brief Whether the connected device uses the NextGUI watch-face architecture
 * @chinese 当前连接设备是否使用 NextGUI 表盘架构
 *
 * @return
 * EN: YES when the connected firmware reports the NextGUI architecture
 * CN: 当前固件声明使用 NextGUI 架构时返回 YES
 */
+ (BOOL)isNextGUI;
@end

NS_ASSUME_NONNULL_END
