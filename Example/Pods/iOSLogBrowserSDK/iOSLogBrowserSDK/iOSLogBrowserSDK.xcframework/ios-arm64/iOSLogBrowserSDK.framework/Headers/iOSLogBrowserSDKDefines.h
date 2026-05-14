//
//  iOSLogBrowserSDKDefines.h
//  iOSLogBrowserSDK
//
//  Created by pcjbird on 11/17/24.
//

#ifndef iOSLogBrowserSDKDefines_h
#define iOSLogBrowserSDKDefines_h
#import <Foundation/Foundation.h>

/// Log level enumeration for SDK logging
/// - Note: Lower values indicate higher verbosity
typedef NS_ENUM(NSInteger, SDKLOGLEVEL) {
    /// Most detailed logging level for debugging purposes
    SDKLOGLEVEL_DEBUG = 0,
    /// Verbose logging level with detailed information
    SDKLOGLEVEL_VERBOSE,
    /// Standard information logging level
    SDKLOGLEVEL_INFO,
    /// Warning messages for potential issues
    SDKLOGLEVEL_WARNING,
    /// Error messages for actual problems
    SDKLOGLEVEL_ERROR,
    /// Exception logging level for caught exceptions
    SDKLOGLEVEL_EXCEPTION,
    /// Critical errors that lead to abortion
    SDKLOGLEVEL_ABORT,
    /// Minimum log level (same as DEBUG)
    SDKLOGLEVEL_MIN = SDKLOGLEVEL_DEBUG,
    /// Maximum log level (same as ABORT)
    SDKLOGLEVEL_MAX = SDKLOGLEVEL_ABORT,
    /// Completely disable logging
    SDKLOGLEVEL_MUTE = NSIntegerMax
};

#endif /* iOSLogBrowserSDKDefines_h */
