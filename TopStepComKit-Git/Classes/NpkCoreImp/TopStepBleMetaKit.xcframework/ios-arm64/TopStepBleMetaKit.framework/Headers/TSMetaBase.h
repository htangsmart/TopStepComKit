//
//  TSMetaBase.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/28.
//

#import <Foundation/Foundation.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import "PbCommonParam.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Meta operation result
 * @chinese 元操作结果
 *
 * @discussion
 * [EN]: Result code of meta operations. 0 means success; 1 means failure; other values are reserved for special failure codes (currently undefined).
 * [CN]: 元操作的结果码。0 表示成功；1 表示失败；其他数值保留用于特殊失败码（暂未定义）。
 */
typedef NS_ENUM(int32_t, TSMetaResult) {
    eTSMetaResultSuccess = 0,// 成功
    eTSMetaResultFailed  = 1,// 失败
};

typedef NS_ENUM(int32_t, TSMetaDataRespondResult) {
    eTSMetaDataRespondSuccess = 0,   // 成功
    eTSMetaDataRespondUnRefresh  = 1,// 数据未更新
    eTSMetaDataRespondFailed  = 127, // 其他失败

};


typedef NS_ENUM(NSInteger, TSMetaDataChagnedType) {
    eTSMetaDataChagnedNone      = 0,  // 成功
    eTSMetaDataChagnedAlarm     = 1,  // 失败
    eTSMetaDataChagnedWatchFace = 2,  // 失败
};


typedef void(^TSMetaCompletionBlock)(BOOL isSuccess, NSError *_Nullable error);

@interface TSMetaBase : NSObject

@end

NS_ASSUME_NONNULL_END
