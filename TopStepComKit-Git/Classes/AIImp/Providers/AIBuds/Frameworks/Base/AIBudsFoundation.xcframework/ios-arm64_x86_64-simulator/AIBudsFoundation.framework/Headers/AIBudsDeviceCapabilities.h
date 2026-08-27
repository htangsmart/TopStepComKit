//
//  AIBudsDeviceCapabilities.h
//  AIBuds
//
//  Created by pcjbird on 2026-02-25.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#ifndef AIBudsDeviceCapabilities_h
#define AIBudsDeviceCapabilities_h

#import <Foundation/Foundation.h>

/// Device capabilities
typedef NS_OPTIONS(NSUInteger, AIBudsDeviceCapabilities) {
    /// Support TWS
    AIBudsDeviceCapabilitiesSupportTws            = 1 << 0,
    /// Support Spatial Audio
    AIBudsDeviceCapabilitiesSupportSpatialAudio   = 1 << 1,
    /// Support Multipoint Connection
    AIBudsDeviceCapabilitiesSupportMultipoint       = 1 << 2,
    /// Support ANC
    AIBudsDeviceCapabilitiesSupportAnc            = 1 << 3,
    /// Support On-device Voice Assistant
    AIBudsDeviceCapabilitiesSupportOnDeviceVoiceAssistant = 1 << 4,
    /// Support Bass Engine
    AIBudsDeviceCapabilitiesSupportBassEngine       = 1 << 5,
    /// Support Live Streaming
    AIBudsDeviceCapabilitiesSupportLiveStreaming    = 1 << 6,
    /// Indicates to whether should hide Ximalaya in app
    AIBudsDeviceCapabilitiesShouldHideXimalayaInApp    = 1 << 7,
    /// Support Factory Test Prompt Tone Chirp
    AIBudsDeviceCapabilitiesSupportFactoryTestPromptToneChirp    = 1 << 8,
};

#endif /* AIBudsDeviceCapabilities_h */
