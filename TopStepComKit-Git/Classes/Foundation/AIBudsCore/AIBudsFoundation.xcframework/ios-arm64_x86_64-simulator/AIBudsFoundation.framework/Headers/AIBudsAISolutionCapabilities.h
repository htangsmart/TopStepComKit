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
    AIBudsAISolutionCapabilitiesMltCloud = 1 << 1
};

#endif /* AIBudsAISolutionCapabilities_h */
