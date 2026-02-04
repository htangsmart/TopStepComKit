//
//  TSBleConnectDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/1/6.
//

#ifndef TSBleConnectDefines_h
#define TSBleConnectDefines_h


/**
 * @brief Bluetooth connection state enumeration (Enhanced)
 * @chinese 蓝牙连接状态枚举（增强版）
 *
 * @discussion
 * [EN]: Defines the complete states during Bluetooth connection and authentication process.
 *       Provides granular tracking of the connection lifecycle from initial connection
 *       through authentication to full readiness.
 *
 *       Error handling: Any failure at any stage returns to eTSBleStateDisconnected with
 *       error details passed through the completion callback.
 * [CN]: 定义蓝牙连接和认证过程中的完整状态。
 *       提供从初始连接、认证到完全就绪的连接生命周期的细粒度跟踪。
 *
 *       错误处理：任何阶段的失败都会返回到 eTSBleStateDisconnected 状态，
 *       错误详情通过完成回调的 error 参数传递。
 *
 * @note
 * [EN]: State flow: Disconnected → Connecting → Authenticating → PreparingData → Connected
 *                         ↑              ↓              ↓                ↓
 *                         └──────────────┴──────────────┴────────────────┘
 *       Any failure returns to Disconnected state.
 * [CN]: 状态流转：未连接 → 连接中 → 认证中 → 准备数据 → 已连接
 *                    ↑          ↓          ↓            ↓
 *                    └──────────┴──────────┴────────────┘
 *       任何失败都返回未连接状态。
 */
typedef NS_ENUM(NSUInteger, TSBleConnectionState) {
    /// 未连接 （Not connected - initial state or after any failure）
    eTSBleStateDisconnected = 0,
    /// 连接中 （Connecting - establishing BLE physical connection）
    eTSBleStateConnecting,
    /// 认证中 （Authenticating - performing bind/login after connection established）
    eTSBleStateAuthenticating,
    /// 准备数据中 （Preparing data - fetching device information after authentication）
    eTSBleStatePreparingData,    
    /// 已连接且就绪 （Connected and ready - fully functional, can perform data operations）
    eTSBleStateConnected
};

/**
 * @brief Scan complete reasons enumeration
 * @chinese 扫描完成原因枚举
 *
 * @discussion
 * [EN]: Defines various reasons why BLE scanning completes
 * [CN]: 定义蓝牙扫描完成的各种原因
 */
typedef NS_ENUM(NSInteger, TSScanCompletionReason) {
    eTSScanCompleteReasonTimeout = 1000,      // 扫描超时
    eTSScanCompleteReasonBleNotReady,         // 蓝牙未准备好
    eTSScanCompleteReasonPermissionDenied,    // 权限被拒绝
    eTSScanCompleteReasonUserStopped,         // 用户主动停止
    eTSScanCompleteReasonSystemError,         // 系统错误
    eTSScanCompleteReasonNotSupport           // 不支持
};


#endif /* TSBleConnectDefines_h */
