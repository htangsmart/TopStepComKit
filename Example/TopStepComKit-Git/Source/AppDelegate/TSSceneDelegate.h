//
//  TSSceneDelegate.h
//  TopStepComKit
//
//  Created by Codex on 2026/8/26.
//  Copyright (c) 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Application scene lifecycle delegate
 * @chinese 应用场景生命周期代理
 */
@interface TSSceneDelegate : UIResponder <UIWindowSceneDelegate>

/**
 * @brief Window associated with the current application scene
 * @chinese 与当前应用场景关联的窗口
 */
@property (nonatomic, strong) UIWindow *window;

@end

NS_ASSUME_NONNULL_END
