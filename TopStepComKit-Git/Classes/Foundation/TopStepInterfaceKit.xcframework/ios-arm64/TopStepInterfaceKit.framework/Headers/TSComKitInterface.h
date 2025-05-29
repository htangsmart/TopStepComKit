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
- (void)initSDKWithConfigOptions:(TSKitConfigOptions *_Nonnull)options completion:(TSCompletionBlock)completion;;


- (void)clearAllInstance;

@end

NS_ASSUME_NONNULL_END
