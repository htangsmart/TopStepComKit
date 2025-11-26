//
//  TSMetaWatchFace.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/4.
//

#import "TSBusinessBase.h"
#import <TopStepBleMetaKit/PbSettingParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaWatchFace : TSBusinessBase

/**
 * @brief Fetch all watch faces
 * @chinese 获取所有表盘
 */
+ (void)fetchAllDialsWithCompletion:(void(^)(TSMetaDialList *_Nullable list, NSError *_Nullable error))completion;

/**
 * @brief Select a watch face
 * @chinese 选中表盘
 */
+ (void)selectDial:(TSMetaDialId *)dialId
        completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Delete a watch face
 * @chinese 删除表盘
 */
+ (void)deleteDial:(TSMetaDialId *)dialId
        completion:(TSMetaCompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
