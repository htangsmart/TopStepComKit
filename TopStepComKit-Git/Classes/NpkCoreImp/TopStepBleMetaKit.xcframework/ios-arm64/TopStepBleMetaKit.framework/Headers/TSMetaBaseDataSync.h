//
//  TSMetaBaseDataSync.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSBusinessBase.h"
#import "TSMetaHealthData.h"
#import "TSMetaTools.h"
#import "PbDataParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Data synchronization completion callback block
 * @chinese 数据同步完成回调块
 *
 * @discussion
 * [EN]: Callback block that is invoked when data synchronization is completed.
 *       No parameters are passed as the result is handled through the data collector.
 * [CN]: 数据同步完成时调用的回调块。不传递参数，因为结果通过数据收集器处理。
 */
typedef void(^TSMetaDataSyncCompletion)(void);

/**
 * @brief Base class for data synchronization
 * @chinese 数据同步基类
 *
 * @discussion
 * [EN]: Abstract base class for implementing data synchronization functionality.
 *       Uses chain of responsibility pattern to process multiple data types sequentially.
 *       Subclasses should implement currentDataType and registerConcreteDataSyncCompletion
 *       to handle specific data type synchronization.
 * [CN]: 实现数据同步功能的抽象基类。
 *       使用责任链模式按顺序处理多种数据类型。
 *       子类应实现 currentDataType 和 registerConcreteDataSyncCompletion 来处理特定数据类型的同步。
 */
@interface TSMetaBaseDataSync : TSBusinessBase

/**
 * @brief Next responder in the chain of responsibility
 * @chinese 责任链中的下一个响应者
 *
 * @discussion
 * [EN]: Reference to the next data sync handler in the chain.
 *       When current handler completes, it passes control to the next responder.
 * [CN]: 责任链中下一个数据同步处理器的引用。
 *       当前处理器完成后，将控制权传递给下一个响应者。
 */
@property (nonatomic,strong) TSMetaBaseDataSync * nextRespond;

/**
 * @brief Begin data synchronization with specified options
 * @chinese 开始使用指定选项进行数据同步
 *
 * @param dataOptions
 * [EN]: Data types to synchronize (bitmask combination).
 * [CN]: 要同步的数据类型（位掩码组合）。
 *
 * @param startTime
 * [EN]: Start time for synchronization (timestamp since 2000).
 * [CN]: 同步开始时间（以2000年开始的时间戳）。
 *
 * @param endTime
 * [EN]: End time for synchronization (timestamp since 2000).
 * [CN]: 同步结束时间（以2000年开始的时间戳）。
 *
 * @param dataCollector
 * [EN]: Mutable array to collect synchronized health data.
 * [CN]: 用于收集同步健康数据的可变数组。
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55")
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）
 *
 * @param completion
 * [EN]: Completion callback block invoked when synchronization is finished.
 * [CN]: 同步完成时调用的完成回调块。
 *
 * @discussion
 * [EN]: Initiates data synchronization process. This method checks if the current
 *       data type should be synchronized based on dataOptions. If not, it passes
 *       control to the next responder in the chain. Subclasses should override
 *       this method to implement specific synchronization logic.
 * [CN]: 启动数据同步过程。此方法根据 dataOptions 检查当前数据类型是否应该同步。
 *       如果不应该，则将控制权传递给链中的下一个响应者。子类应重写此方法以实现特定的同步逻辑。
 */
- (void)beginSyncWithOptions:(TSMetaDataOpetions)dataOptions
                   startTime:(NSTimeInterval)startTime
                     endTime:(NSTimeInterval)endTime
               dataCollector:(NSMutableArray *)dataCollector
                 macAddress:(NSString *)macAddress
                  completion:(TSMetaDataSyncCompletion)completion;

/**
 * @brief Synchronize next responder in the chain
 * @chinese 同步责任链中的下一个响应者
 *
 * @param dataOptions
 * [EN]: Data types to synchronize (bitmask combination).
 * [CN]: 要同步的数据类型（位掩码组合）。
 *
 * @param startTime
 * [EN]: Start time for synchronization (timestamp since 2000).
 * [CN]: 同步开始时间（以2000年开始的时间戳）。
 *
 * @param endTime
 * [EN]: End time for synchronization (timestamp since 2000).
 * [CN]: 同步结束时间（以2000年开始的时间戳）。
 *
 * @param dataCollector
 * [EN]: Mutable array to collect synchronized health data.
 * [CN]: 用于收集同步健康数据的可变数组。
 *
 * @param completion
 * [EN]: Completion callback block invoked when synchronization is finished.
 * [CN]: 同步完成时调用的完成回调块。
 *
 * @discussion
 * [EN]: Passes synchronization request to the next responder in the chain.
 *       If there is no next responder, the completion block is called immediately.
 *       This method implements the chain of responsibility pattern.
 * [CN]: 将同步请求传递给链中的下一个响应者。
 *       如果没有下一个响应者，则立即调用完成回调块。
 *       此方法实现了责任链模式。
 */
- (void)syncNextRespondWithOptions:(TSMetaDataOpetions)dataOptions
                         startTime:(NSTimeInterval)startTime
                           endTime:(NSTimeInterval)endTime
                     dataCollector:(NSMutableArray *)dataCollector
                        macAddress:(NSString *)macAddress
                        completion:(nonnull TSMetaDataSyncCompletion)completion;

/**
 * @brief Initialize with next responder in the chain
 * @chinese 使用链中的下一个响应者初始化
 *
 * @param nextDataSync
 * [EN]: Next data sync handler in the chain. Can be nil if this is the last handler.
 * [CN]: 链中的下一个数据同步处理器。如果是最后一个处理器，可以为nil。
 *
 * @return
 * [EN]: Initialized TSMetaBaseDataSync instance.
 * [CN]: 初始化后的 TSMetaBaseDataSync 实例。
 *
 * @discussion
 * [EN]: Designated initializer for creating a data sync handler with a reference
 *       to the next handler in the chain. This enables the chain of responsibility pattern.
 * [CN]: 用于创建数据同步处理器的指定初始化方法，包含对链中下一个处理器的引用。
 *       这实现了责任链模式。
 */
- (TSMetaBaseDataSync *)initWithNextRespond:(TSMetaBaseDataSync *)nextDataSync;

/**
 * @brief Synchronize data between start and end time
 * @chinese 在开始时间和结束时间之间同步数据
 *
 * @param startTime
 * [EN]: Start time for synchronization (timestamp since 2000).
 * [CN]: 同步开始时间（以2000年开始的时间戳）。
 *
 * @param endTime
 * [EN]: End time for synchronization (timestamp since 2000).
 * [CN]: 同步结束时间（以2000年开始的时间戳）。
 *
 * @param completion
 * [EN]: Completion callback block that returns the synchronized health data or error.
 * [CN]: 完成回调块，返回同步的健康数据或错误。
 *
 * @discussion
 * [EN]: Core data synchronization method that performs the following steps:
 *       1. Creates a sync request with the specified time range
 *       2. Opens the data sync channel with the device
 *       3. Receives and processes data from the device
 *       4. Calls completion when synchronization is finished
 *       
 *       This method handles the complete synchronization flow including error handling
 *       and data parsing. Subclasses should not override this method directly.
 * [CN]: 核心数据同步方法，执行以下步骤：
 *       1. 创建指定时间范围的同步请求
 *       2. 打开与设备的数据同步通道
 *       3. 接收并处理来自设备的数据
 *       4. 同步完成时调用完成回调
 *       
 *       此方法处理完整的同步流程，包括错误处理和数据解析。子类不应直接重写此方法。
 */
+ (void)syncDataBetweenStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime
                      completion:(nonnull void(^)(TSMetaHealthData *_Nullable healthData))completion;

/**
 * @brief Get current data type for this sync handler
 * @chinese 获取此同步处理器的当前数据类型
 *
 * @return
 * [EN]: Data type option that this handler is responsible for synchronizing.
 * [CN]: 此处理器负责同步的数据类型选项。
 *
 * @discussion
 * [EN]: Abstract method that must be implemented by subclasses to return the specific
 *       data type they handle (e.g., TSMetaDataOpetionHeartRate, TSMetaDataOpetionBloodOxygen).
 *       The base class returns TSMetaDataOpetionNone as a default.
 * [CN]: 必须由子类实现的抽象方法，返回它们处理的特定数据类型
 *       （例如：TSMetaDataOpetionHeartRate、TSMetaDataOpetionBloodOxygen）。
 *       基类默认返回 TSMetaDataOpetionNone。
 */
+ (TSMetaDataOpetions)currentDataType;

/**
 * @brief Register completion handler for concrete data sync
 * @chinese 注册具体数据同步的完成处理器
 *
 * @param completion
 * [EN]: Completion callback block that receives the synchronized health data.
 * [CN]: 接收同步健康数据的完成回调块。
 *
 * @discussion
 * [EN]: Registers a callback handler for receiving synchronized data of the current type.
 *       Subclasses should override this method to register specific data type handlers
 *       using TSCommand. The base implementation returns an error indicating unsupported operation.
 * [CN]: 注册用于接收当前类型同步数据的回调处理器。
 *       子类应重写此方法，使用 TSCommand 注册特定的数据类型处理器。
 *       基类实现返回表示不支持操作的错误。
 */
+ (void)registerConcreteDataSyncCompletion:(nonnull void(^)(TSMetaHealthData *_Nullable healthData))completion;

/**
 * @brief Create health data object with error
 * @chinese 创建包含错误的健康数据对象
 *
 * @param error
 * [EN]: Error object describing the failure reason.
 * [CN]: 描述失败原因的错误对象。
 *
 * @return
 * [EN]: TSMetaHealthData object with error information and empty data array.
 * [CN]: 包含错误信息和空数据数组的 TSMetaHealthData 对象。
 *
 * @discussion
 * [EN]: Factory method for creating a TSMetaHealthData object that represents
 *       a failed synchronization attempt. The data type is determined by currentDataType.
 * [CN]: 用于创建表示同步失败尝试的 TSMetaHealthData 对象的工厂方法。
 *       数据类型由 currentDataType 确定。
 */
+ (TSMetaHealthData *)healthDataWithError:(NSError *)error;

/**
 * @brief Create health data object with synchronized data
 * @chinese 使用同步数据创建健康数据对象
 *
 * @param datas
 * [EN]: Array of synchronized data objects (e.g., TSMetaHeartRateDay, TSMetaBloodOxygenDay).
 * [CN]: 同步数据对象数组（例如：TSMetaHeartRateDay、TSMetaBloodOxygenDay）。
 *
 * @return
 * [EN]: TSMetaHealthData object with synchronized data and no error.
 * [CN]: 包含同步数据且无错误的 TSMetaHealthData 对象。
 *
 * @discussion
 * [EN]: Factory method for creating a TSMetaHealthData object that represents
 *       a successful synchronization. The data type is determined by currentDataType.
 * [CN]: 用于创建表示成功同步的 TSMetaHealthData 对象的工厂方法。
 *       数据类型由 currentDataType 确定。
 */
+ (TSMetaHealthData *)healthDataWithDatas:(NSArray *)datas;

/**
 * @brief Set last sync start time for a specific data type
 * @chinese 设置指定数据类型的最后同步开始时间
 *
 * @param startTime
 * [EN]: Start time in timestamp format (seconds since 2000)
 * [CN]: 开始时间，时间戳格式（以2000年开始的秒数）
 *
 * @param dataOption
 * [EN]: Data type option
 * [CN]: 数据类型选项
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55")
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）
 */
+ (void)setLastStartTime:(NSTimeInterval)startTime option:(TSMetaDataOpetions)dataOption macAddress:(NSString *)macAddress;

/**
 * @brief Get last sync time for current data type, or 7 days ago if not found
 * @chinese 获取当前数据类型的上次同步时间，如果未找到则返回7天前的时间
 *
 * @param dataOption
 * [EN]: Data type option
 * [CN]: 数据类型选项
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55")
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）
 *
 * @return
 * [EN]: Last sync time in timestamp format (seconds since 2000).
 *       Returns 7 days ago if no sync time is found (returns 0).
 * [CN]: 最后同步时间，时间戳格式（以2000年开始的秒数）。
 *       如果未找到同步时间（返回0），则返回7天前的时间。
 *
 * @discussion
 * [EN]: This method retrieves the last synchronization time for the current data type
 *       (determined by currentDataType). If no sync time is found (returns 0), it calculates
 *       and returns the time 7 days ago (timestamp since 2000).
 * [CN]: 此方法获取当前数据类型（由currentDataType确定）的最后同步时间。
 *       如果未找到同步时间（返回0），则计算并返回7天前的时间（以2000年开始的时间戳）。
 */
+ (NSTimeInterval)lastSyncTimeWithOption:(TSMetaDataOpetions)dataOption macAddress:(NSString *)macAddress;

/**
 * @brief Get concrete start sync time
 * @chinese 获取具体的开始同步时间
 *
 * @param startTime
 * [EN]: Start time in timestamp format (seconds since 2000). If > 0, returns this value directly.
 * [CN]: 开始时间，时间戳格式（以2000年开始的秒数）。如果 > 0，直接返回此值。
 *
 * @param macAddress
 * [EN]: MAC address of the device (e.g., "00:11:22:33:44:55")
 * [CN]: 设备的MAC地址（例如："00:11:22:33:44:55"）
 *
 * @return
 * [EN]: Start time. If startTime > 0, returns startTime; otherwise returns last sync time or 7 days ago.
 * [CN]: 开始时间。如果 startTime > 0，返回 startTime；否则返回上次同步时间或7天前。
 */
+ (NSTimeInterval)concreteStartSyncTimeWithStart:(NSTimeInterval)startTime macAddress:(NSString *)macAddress;

+ (NSTimeInterval)concreteEndSyncTimeWithEnd:(NSTimeInterval)endTime;


- (void)updateSyncTime:(TSMetaHealthData *)healthData macAddress:(NSString *)macAddress;

@end

NS_ASSUME_NONNULL_END
