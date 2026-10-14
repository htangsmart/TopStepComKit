//
//  TSHsdParentalControlVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Advanced parental mode page (parental control)
 * @chinese 家长模式（进阶版）：总开关 + 8 个受控功能项，每项可设开关、时段内行为与最多 N 个生效时段
 *
 * @discussion
 * [EN]: Backed by TSHuashengdaInterface.fetchParentalControl: / setParentalControl:completion:
 *       (isSupportParentalControl, NPK). The basic variant (isSupportParentalMode, FitCloud) is TSHsdParentalModeVC.
 *       Explicit save + automatic readback comparison; the whole item list is sent on every save and the watch
 *       replaces its configuration.
 * [CN]: 走 fetchParentalControl: / setParentalControl:completion:（isSupportParentalControl，NPK）；
 *       基础版（isSupportParentalMode，FitCloud）见 TSHsdParentalModeVC。
 *       显式保存 + 自动回读比对；每次保存下发完整功能项列表，手表整体替换。
 */
@interface TSHsdParentalControlVC : TSHsdBaseVC

@end

NS_ASSUME_NONNULL_END
