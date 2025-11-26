//
//  TSFileTransferDefines.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/10.
//

#import <Foundation/Foundation.h>
#import "TSBusinessBase.h"


#define kMaxFileFrameRetryCount 3

/**
 * @brief File transfer status enumeration
 * @chinese 文件传输状态枚举
 */
typedef NS_ENUM(NSInteger, TSFileTransferStatus) {
    eTSFileTransferIdle          = 0,  // 空闲/待机状态
    eTSFileTransferStart         = 1,  // 开始传输
    eTSFileTransferInProgress    = 2,  // 传输中
    eTSFileTransferSuccess       = 3,  // 传输成功
    eTSFileTransferFailed        = 4,  // 传输失败
    eTSFileTransferCanceled      = 5,  // 传输取消
};

/**
 * @brief File head response result
 * @chinese 文件头响应结果
 *
 * @discussion
 * [EN]: Result codes used in file head response from device.
 * [CN]: 设备返回的文件头响应中的结果码。
 */
typedef NS_ENUM(NSInteger, TSFileHeadResponseResult) {
    eTSFileHeadResponseOK       = 0,  //正常
    eTSFileHeadResponseNoSpace  = 1,  //设备空间不足
    eTSFileHeadResponseBusy     = 2,  //设备忙
};

/**
 * @brief File data response result
 * @chinese 文件数据响应结果
 *
 * @discussion
 * [EN]: Result codes reported by device when errors/end/ack-window reached during data transfer.
 * [CN]: 设备在数据传输过程中发生错误/结束/达到回复窗口时上报的结果码。
 */
typedef NS_ENUM(NSInteger, TSFileDataResponseResult) {
    eTSFileDataResponseOK                = 0,  //正常
    eTSFileDataResponseOffsetError       = 1,  //offset错误，需从上一帧重传
    eTSFileDataResponseInvalidFile       = 2,  //文件不合法（如OTA文件不适配），需中断传输
    eTSFileDataResponsePeerNotReady      = 3,  //对端未进入接收流程，需中断传输
};

/**
 * @brief File transfer progress callback
 * @chinese 文件传输进度回调
 *
 * @param status
 * EN: Current transfer status
 * CN: 当前传输状态
 *
 * @param progress
 * EN: Transfer progress, range 0.00-100.00 (percentage with 2 decimal places)
 * CN: 传输进度，范围 0.00-100.00（百分比，保留两位小数）
 *
 * @discussion
 * [EN]: The progress parameter represents completion percentage (0.00 = 0%, 100.00 = 100%)
 * [CN]: progress 参数表示完成百分比（0.00 = 0%，100.00 = 100%）
 */
typedef void(^TSFileTransferProgressCallback)(TSFileTransferStatus status, float progress);

#pragma mark - File Receiver
/**
 * @brief File transfer completion callback
 * @chinese 文件接收成功回调
 */
typedef void(^TSReceiveFileSuccessCallback)(TSFileTransferStatus status,NSString *_Nullable fileLocalPath);
/**
 * @brief File transfer completion callback
 * @chinese 文件接收失败回调
 */
typedef void(^TSReceiveFileFailureCallback)(TSFileTransferStatus status, NSError * _Nullable error);


#pragma mark - File Sender
/**
 * @brief File transfer completion callback
 * @chinese 文件推送成功回调
 */
typedef void(^TSSendFileSuccessCallback)(TSFileTransferStatus status);
/**
 * @brief File transfer completion callback
 * @chinese 文件推送失败回调
 */
typedef void(^TSSendFileFailureCallback)(TSFileTransferStatus status, NSError * _Nullable error);





NS_ASSUME_NONNULL_BEGIN

@protocol TSFileTransferDefines <NSObject>

@end

NS_ASSUME_NONNULL_END
