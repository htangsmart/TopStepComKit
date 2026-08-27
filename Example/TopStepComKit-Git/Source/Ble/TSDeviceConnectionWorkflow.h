//
//  TSDeviceConnectionWorkflow.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/27.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Workflow executed immediately after a device connection succeeds
 * @chinese 设备连接成功后立即执行的准备流程
 *
 * @discussion
 * [EN]: Runs required device operations in order before the Demo continues its connection-success flow.
 * [CN]: 在 Demo 继续处理连接成功逻辑前，按顺序执行必要的设备操作。
 */
@interface TSDeviceConnectionWorkflow : NSObject

/**
 * @brief Prepare the connected device and invoke completion on the main thread
 * @chinese 准备已连接设备，并在主线程回调完成结果
 *
 * @param completion
 * EN: Callback invoked after all preparation steps finish, regardless of an individual step result.
 * CN: 所有准备步骤结束后调用；单个步骤失败时仍会继续并回调。
 */
+ (void)prepareConnectedDeviceWithCompletion:(nullable void (^)(void))completion;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
