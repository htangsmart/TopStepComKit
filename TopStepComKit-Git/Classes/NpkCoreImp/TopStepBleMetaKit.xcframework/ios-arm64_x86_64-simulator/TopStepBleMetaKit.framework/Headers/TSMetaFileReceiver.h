//
//  TSMetaFileReceiver.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/10.
//

#import "TSBusinessBase.h"
#import "TSFileTransferDefines.h"
#import "PbStreamParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaFileReceiver : TSBusinessBase

@property (nonatomic, assign) TSFileTransferStatus state;

@property (nonatomic, assign) NSInteger retryCount;

@property (nonatomic, copy, nullable) TSFileTransferProgressCallback progressBlock;

@property (nonatomic, copy, nullable) TSReceiveFileSuccessCallback transferSuccessBlock;

@property (nonatomic, copy, nullable) TSReceiveFileFailureCallback transferFailureBlock;

+ (instancetype)sharedInstance ;

- (void)startReceiveWithPath:(TSMetaFilePath *)filePath
                    progress:(TSFileTransferProgressCallback _Nullable)progress
                     success:(TSReceiveFileSuccessCallback)success
                     failure:(TSReceiveFileFailureCallback)failure;

/// 取消当前接收任务（可选）
- (void)cancel;

/// 重置到空闲状态（可选）
- (void)resetToIdle;

- (BOOL)isTransfering;


@end

NS_ASSUME_NONNULL_END
