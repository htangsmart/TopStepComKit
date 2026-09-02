//
//  TSAIAudioRecordVC+Views.h
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordVC.h"

NS_ASSUME_NONNULL_BEGIN

/// @brief Private view construction helpers for the AI recording page.
/// @chinese AI 录音页面的私有视图构建辅助方法。
@interface TSAIAudioRecordVC (Views)

/// @brief Builds the complete page hierarchy and constraints.
/// @chinese 构建完整页面层级与约束。
- (void)buildPageViews;

/// @brief Updates a compact bottom route button.
/// @chinese 更新底部紧凑路径按钮。
/// @param button EN: Route button. CN: 路径按钮。
/// @param label EN: Route type label. CN: 路径类型标签。
/// @param value EN: Selected route value. CN: 已选择的路径值。
- (void)updateRouteButton:(UIButton *)button label:(NSString *)label value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
