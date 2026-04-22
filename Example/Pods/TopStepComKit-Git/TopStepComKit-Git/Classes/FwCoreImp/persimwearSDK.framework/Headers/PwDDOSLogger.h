// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2023, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.

#import <Foundation/Foundation.h>

// Disable legacy macros
#ifndef PW_DD_LEGACY_MACROS
    #define PW_DD_LEGACY_MACROS 0
#endif

#import "PwDDLog.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * This class provides a logger for the Apple os_log facility.
 **/

PW_DD_SENDABLE
@interface PWOSLogger : PWAbstractLogger <PWLogger>

/**
 *  Singleton method
 *
 *  @return the shared instance with OS_LOG_DEFAULT.
 */
@property (nonatomic, class, readonly, strong) PWOSLogger *sharedInstance;

/**
 Designated initializer
 
 @param subsystem Desired subsystem in log. E.g. "org.example"
 @param category Desired category in log. E.g. "Point of interests."
 @return New instance of PWOSLogger.
 
 @discussion This method requires either both or no parameter to be set. Much like `(String, String)?` in Swift.
 If both parameters are nil, this method will return a logger configured with `OS_LOG_DEFAULT`.
 If both parameters are non-nil, it will return a logger configured with `os_log_create(subsystem, category)`
 */
- (instancetype)initWithSubsystem:(nullable NSString *)subsystem category:(nullable NSString *)category NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
