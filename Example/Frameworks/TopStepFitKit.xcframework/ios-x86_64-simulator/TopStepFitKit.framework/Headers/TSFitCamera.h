//
//  TSFitCamera.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/12.
//

#import "TSFitKitBase.h"
#import <TopStepInterfaceKit/TSCameraInterface.h>

NS_ASSUME_NONNULL_BEGIN





/**
 * @brief [中文]: 相机控制类
 *        [EN]: Camera control class
 *
 * @discussion [中文]: 该类负责处理App与外设之间的相机相关交互，包括：
 *                    1. 相机模式的进入/退出控制
 *                    2. 远程拍照功能
 *                    3. 状态同步与管理
 *                    4. 错误处理
 *
 *            [EN]: This class handles camera-related interactions between App and peripheral devices, including:
 *                  1. Camera mode entry/exit control
 *                  2. Remote photo capture
 *                  3. State synchronization and management
 *                  4. Error handling
 */
@interface TSFitCamera : TSFitKitBase<TSCameraInterface>


@end

NS_ASSUME_NONNULL_END
