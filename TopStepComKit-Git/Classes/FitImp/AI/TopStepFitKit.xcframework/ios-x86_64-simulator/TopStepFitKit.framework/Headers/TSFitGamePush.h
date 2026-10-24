//
//  TSFitGamePush.h
//  TopStepFitKit
//

#import "TSFitKitBase.h"
#import <TopStepInterfaceKit/TSGamePushInterface.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Game installation adapter for the Fit Provider.
 * @chinese Fit Provider 的游戏推送适配。
 *
 * @discussion
 * [EN]: This SDK release does not integrate Fit game installation;
 *       all business operations explicitly return unsupported errors.
 * [CN]: 当前 SDK 版本未接入 Fit 游戏推送，全部业务方法明确返回不支持。
 */
@interface TSFitGamePush : TSFitKitBase <TSGamePushInterface>
@end

NS_ASSUME_NONNULL_END
