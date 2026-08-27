//
//  AIBudsAuthorizedServices.h
//  AIBuds
//
//  Created by pcjbird on 2026-02-12.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#ifndef AIBudsAuthorizedServices_h
#define AIBudsAuthorizedServices_h

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, AIBudsAuthorizedServices) {
    // 无授权（必须显式定义0值）
    AIBudsAuthorizedServicesNone = 0,
    // 星芒AI（1 << 0）
    AIBudsAuthorizedServicesStarBurst = 1 << 0,
    // 离线语音助手（1 << 1）
    AIBudsAuthorizedServicesOnDeviceVoiceAssistant = 1 << 1,
};

#endif /* AIBudsAuthorizedServices_h */
