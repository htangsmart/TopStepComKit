//
//  TSMetaFileUploader.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>
#import <TopStepBleMetaKit/TSFileTransferDefines.h>

@class TSMetaFileUploadRequest;
NS_ASSUME_NONNULL_BEGIN

/** @brief TP upload error domain. @chinese TP 文件上传错误域。 */
FOUNDATION_EXPORT NSErrorDomain const TSMetaFileUploadErrorDomain;

/** @brief Upload lifecycle errors. @chinese 上传生命周期错误。 */
typedef NS_ENUM(NSInteger, TSMetaFileUploadErrorCode) {
    TSMetaFileUploadErrorInvalidState = 41001,
    TSMetaFileUploadErrorConnectionChanged = 41002,
    TSMetaFileUploadErrorTimeout = 41003,
    TSMetaFileUploadErrorInvalidAcknowledgement = 41004,
    TSMetaFileUploadErrorDeviceRejected = 41005,
    TSMetaFileUploadErrorRetryExhausted = 41006,
    TSMetaFileUploadErrorCommitInProgress = 41007,
    TSMetaFileUploadErrorLowBattery = 41008,
    TSMetaFileUploadErrorNoSpace = 41009,
};

/** @brief Terminal callback delivered once on the main queue.
 *  @chinese 主线程上仅调用一次的上传终态回调。 */
typedef void (^TSMetaFileUploadCompletionBlock)(TSMetaFileTransferStatus status, NSError * _Nullable error);

/** @brief One TP file upload transaction; retain the instance to cancel it.
 *  @chinese 单次 TP 文件上传事务；保留本次实例以取消对应任务。
 *  @discussion Progress is confirmed body bytes, capped at 99 until END_ACK succeeds.
 *  进度按已确认的正文计算，END_ACK 成功之前最高为 99。 */
@interface TSMetaFileUploader : NSObject

/** @brief Current BLE connection generation. @chinese 当前 BLE 连接代次。
 *  @return Generation to capture before business preparation. / 业务准备前捕获的连接代次。 */
+ (NSUInteger)currentConnectionGeneration;

/** @brief Current connected peripheral identity. @chinese 当前已连接设备标识。
 *  @return Identifier, or nil when disconnected. / 已断连时返回 nil。 */
+ (nullable NSUUID *)currentPeripheralIdentifier;

/** @brief Create a single-use upload. @chinese 创建仅能启动一次的上传任务。
 *  @param request Immutable input and captured connection. / 不可变文件输入及连接上下文。
 *  @return Upload handle. / 上传句柄。 */
- (instancetype)initWithRequest:(TSMetaFileUploadRequest *)request NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Use a file guard operation reserved by a realtime handoff
 * @chinese 使用实时通道交接时预留的文件门闩登记
 * @param operationIdentifier
 * EN: File operation returned by the realtime handoff. CN: 实时交接返回的文件事务。
 */
- (void)setPreacquiredOperationIdentifier:(nullable NSUUID *)operationIdentifier;

/** @brief Prepare and start the upload. @chinese 准备文件并开始上传。
 *  @param progress Main-queue progress in percent. / 主线程百分比进度。
 *  @param completion Main-queue terminal result. / 主线程终态结果。 */
- (void)startWithProgress:(nullable TSFileTransferProgressCallback)progress
              completion:(TSMetaFileUploadCompletionBlock)completion;

/** @brief Cancel this upload before END is submitted. @chinese END 提交前取消本次上传。
 *  @param completion Main-queue cancellation result; a rejected cancellation keeps the upload alive.
 *  主线程取消结果；取消被拒绝时原上传继续。设备清场未获确认时需重连后才能继续文件传输。 */
- (void)cancelWithCompletion:(void (^)(BOOL success, NSError * _Nullable error))completion;

@end
NS_ASSUME_NONNULL_END
