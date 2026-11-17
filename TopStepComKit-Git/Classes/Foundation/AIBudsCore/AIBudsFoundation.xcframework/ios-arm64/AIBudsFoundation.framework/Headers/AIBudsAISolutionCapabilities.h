//
//  AIBudsAISolutionCapabilities.h
//  AIBuds
//
//  Created by pcjbird on 2026-04-18.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#ifndef AIBudsAISolutionCapabilities_h
#define AIBudsAISolutionCapabilities_h

#import <Foundation/Foundation.h>

/// AI solution capabilities
typedef NS_OPTIONS(NSUInteger, AIBudsAISolutionCapabilities) {
    /// StarBurst AI, provided by ByteDance
    AIBudsAISolutionCapabilitiesStarBurst = 1 << 0,
    /// MltCloud AI, provided by MltCloud
    AIBudsAISolutionCapabilitiesMltCloud = 1 << 1,
    /// WatchFun AI, provided by WoQi (沃奇)
    AIBudsAISolutionCapabilitiesWatchFun = 1 << 3,
    /// XKSmart AI, provided by YanJie (岩界)
    AIBudsAISolutionCapabilitiesXKSmart = 1 << 4,
    /// TopStep AI, provided by TopStep (拓步自研)
    AIBudsAISolutionCapabilitiesTopStep = 1 << 5
};

#endif /* AIBudsAISolutionCapabilities_h */
