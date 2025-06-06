//
//  TSKitInitInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/11.
//

#import "TSKitBaseInterface.h"
#import "TSKitConfigOptions.h"


@protocol TSKitInitDelegate <NSObject>

/**
 * @brief Execute Kit callback
 * @chinese 执行Kit回调
 * 
 * @param params 
 * EN: Callback parameter dictionary containing the following keys:
 *     - kTSMethodName: Method name to execute
 *     - kTSInstanceName: Instance name for method execution
 *     - kTSMethodParams: Method parameters (optional)
 * CN: 回调参数字典，包含以下键值：
 *     - kTSMethodName: 要执行的方法名
 *     - kTSInstanceName: 执行方法的实例名
 *     - kTSMethodParams: 方法参数（可选）
 */
- (void)performKitCallBackWithParams:(NSDictionary *_Nonnull)params;

@end

@protocol TSKitInitInterface <TSKitBaseInterface>


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
- (void)initSDKWithConfigOptions:(TSKitConfigOptions *_Nullable)options completion:(TSCompletionBlock)completion;



@end


