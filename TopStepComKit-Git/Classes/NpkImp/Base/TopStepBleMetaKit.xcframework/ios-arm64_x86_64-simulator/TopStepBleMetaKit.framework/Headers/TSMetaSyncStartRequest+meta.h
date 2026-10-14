//
//  TSMetaSyncStartRequest+meta.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import <TopStepBleMetaKit/TopStepBleMetaKit.h>
#import "TSMetaHealthDataDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaSyncStartRequest (meta)

- (NSString *)typeName;

+ (int32_t)requestTypeWithDataType:(TSMetaDataOpetions)dataOptions;

+ (TSMetaSyncStartRequest *)requestWithStart:(NSTimeInterval)start end:(NSTimeInterval)end dataOptions:(TSMetaDataOpetions)dataOptions;

@end

NS_ASSUME_NONNULL_END
