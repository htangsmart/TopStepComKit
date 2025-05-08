//
//  TSComKitInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/21.
//
#import "TSKitBaseInterface.h"
#import "TSPeripheral.h"
#import "TopStepInterfaceKit.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TSComKitInterface <TSKitBaseInterface>


@required
/**
 * @brief 根据协议创建或获取对应的实例
 * @chinese 根据协议创建或获取对应的实例
 *
 * @param protocol 
 * EN: Protocol to create instance for. The protocol must:
 *     1. Conform to TSKitBaseInterface
 *     2. Have a corresponding implementation class
 *     3. Be registered in the SDK
 * CN: 需要创建实例的协议，该协议必须：
 *     1. 遵循TSKitBaseInterface协议
 *     2. 有对应的实现类
 *     3. 在SDK中已注册
 *
 * @return 
 * EN: Returns an instance conforming to TSKitBaseInterface:
 *     - If instance exists in cache, returns cached instance
 *     - If instance doesn't exist, creates new instance
 *     - Returns nil if creation fails
 * CN: 返回遵循TSKitBaseInterface的实例：
 *     - 如果实例在缓存中存在，返回缓存的实例
 *     - 如果实例不存在，创建新实例
 *     - 如果创建失败返回nil
 *
 * @discussion 
 * EN: This method is the core factory method for creating interface instances:
 *     1. Validates protocol name and parameters
 *     2. Generates target class name based on protocol and SDK prefix
 *     3. Checks instance cache first
 *     4. Creates new instance if needed
 *     5. Configures instance with current SDK options
 *     6. Caches instance for future use
 * CN: 此方法是创建接口实例的核心工厂方法：
 *     1. 验证协议名称和参数
 *     2. 根据协议和SDK前缀生成目标类名
 *     3. 优先检查实例缓存
 *     4. 必要时创建新实例
 *     5. 使用当前SDK选项配置实例
 *     6. 缓存实例以供将来使用
 */
- (id<TSKitBaseInterface>)instancetWithProtocol:(Protocol *)protocol;

/**
 * @brief Initialize SDK
 * @chinese 初始化SDK
 *
 * @param options
 * EN: SDK initialization configuration parameters
 * CN: SDK初始化配置参数
 *
 * @discussion
 * EN: Must be called before using other SDK functions
 * CN: 在使用SDK其他功能之前必须先调用此方法进行初始化
 */
- (void)initSDKWithConfigOptions:(TSKitConfigOptions *_Nonnull)options completion:(nullable TSCompletionBlock)completion;;


- (void)clearAllInstance;

@end

NS_ASSUME_NONNULL_END
