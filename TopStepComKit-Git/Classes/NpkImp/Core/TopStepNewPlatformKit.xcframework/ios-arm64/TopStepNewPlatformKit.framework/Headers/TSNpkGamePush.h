//
//  TSNpkGamePush.h
//  TopStepNewPlatformKit
//

#import "TSNpkKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK public game queries and GUI579X game installation.
 * @chinese NPK 公版游戏查询及 GUI579X 游戏安装。
 *
 * @discussion
 * [EN]: Uses the authenticated connection for each operation. Installation accepts
 *       a complete TOPSTEP game container and finishes on a valid successful END_ACK.
 *       Callers may refresh games independently after transfer completion.
 * [CN]: 每次操作绑定已认证连接；接受完整 TOPSTEP 游戏容器，以有效成功 END_ACK 结束推送。
 *       调用方可在推送完成后独立刷新已有游戏。
 */
@interface TSNpkGamePush : TSNpkKitBase <TSGamePushInterface>
@end

NS_ASSUME_NONNULL_END
