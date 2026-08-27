//
//  SBFileTaskResult.h
//  IOT
//
//  Created by ByteDance on 2026/1/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBAudioPiece : NSObject
@property(nonatomic, copy) NSString *text;
@property(nonatomic, assign) long long startTime;   // start_time
@property(nonatomic, assign) long long endTime;     // end_time
@property(nonatomic, assign) NSInteger speaker;     // additions.speaker，解析不到则 -1
@end

@interface FileTaskResult : NSObject
@property(nonatomic, assign) NSInteger code;
@property(nonatomic, copy) NSString *msg;
@property(nonatomic, copy) NSString *taskId;
@property(nonatomic, copy) NSString *requestId;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *summary;
@property(nonatomic, strong) NSArray<SBAudioPiece *> *pieces;

+ (nullable instancetype)fromJSONData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
