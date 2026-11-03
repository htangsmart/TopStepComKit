//
//  AIBudsAIChatContentCapabilities.h
//  AIBuds
//
//  Created by pcjbird on 2026-02-25.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#ifndef AIBudsAIChatContentCapabilities_h
#define AIBudsAIChatContentCapabilities_h

#import <Foundation/Foundation.h>

/// AI chat content capabilities
typedef NS_OPTIONS(NSUInteger, AIBudsAIChatContentCapabilities) {
    /// Support chat
    AIBudsAIChatContentCapabilitiesChat          = 1 << 0,
    /// Support photo understanding
    AIBudsAIChatContentCapabilitiesPhotoUnderstand = 1 << 1
};

#endif /* AIBudsAIChatContentCapabilities_h */
