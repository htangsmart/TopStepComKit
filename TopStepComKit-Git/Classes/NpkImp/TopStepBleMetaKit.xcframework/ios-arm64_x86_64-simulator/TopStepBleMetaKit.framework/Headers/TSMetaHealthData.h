//
//  TSMetaHealthData.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/5.
//

#import "TSMetaBaseModel.h"
#import "TSMetaHealthDataDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaHealthData : TSMetaBaseModel

@property (nonatomic,assign) NSTimeInterval syncTime;

@property (nonatomic,assign) TSMetaDataOpetions option;

@property (nonatomic,strong) NSArray * datas;

@property (nonatomic,strong) NSError * error;

+ (TSMetaHealthData *)healDataWithOptions:(TSMetaDataOpetions)dataOptions ;

+ (TSMetaHealthData *)healDataWithOptions:(TSMetaDataOpetions)dataOptions error:(NSError *_Nullable)error;

+ (TSMetaHealthData *)healDataWithOptions:(TSMetaDataOpetions)dataOptions datas:(NSArray * _Nullable)datas error:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
