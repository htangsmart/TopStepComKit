//
//  TSFwGamePush.h
//  TopStepPersimwearKit
//

#import "TSFwKitBase.h"
#import <TopStepInterfaceKit/TSGamePushInterface.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Game installation adapter for the Fw Provider.
 * @chinese Fw Provider 的游戏推送适配。
 *
 * @discussion
 * [EN]: This SDK release does not integrate Fw game installation;
 *       all business operations explicitly return unsupported errors.
 * [CN]: 当前 SDK 版本未接入 Fw 游戏推送，全部业务方法明确返回不支持。
 */
@interface TSFwGamePush : TSFwKitBase <TSGamePushInterface>
@end

NS_ASSUME_NONNULL_END
