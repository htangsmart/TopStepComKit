//
//  TSFwHRSyncHandler.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//
//  文件说明:
//  心率异构 handler：Fw 端心率需先拉普通心率、再串行拉静息心率，合并进同一 TSHealthData
//  回调一次（App 靠 valueType==Resting 区分）；静息心率独立入库、不参与 lastSyncTime 推进。

#import "TSFwSyncHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFwHRSyncHandler : TSFwSyncHandler

@end

NS_ASSUME_NONNULL_END
