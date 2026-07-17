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

NS_ASSUME_NONNULL_BEGIN

typedef NSString *PWLoggerName NS_EXTENSIBLE_STRING_ENUM;

FOUNDATION_EXPORT PWLoggerName const PWLoggerNameOS NS_SWIFT_NAME(PWLoggerName.os);     // PWOSLogger
FOUNDATION_EXPORT PWLoggerName const PWLoggerNameFile NS_SWIFT_NAME(PWLoggerName.file); // PWFileLogger

FOUNDATION_EXPORT PWLoggerName const PWLoggerNameTTY NS_SWIFT_NAME(PWLoggerName.tty);   // DDTTYLogger

API_DEPRECATED("Use PWOSLogger instead", macosx(10.4, 10.12), ios(2.0, 10.0), watchos(2.0, 3.0), tvos(9.0, 10.0))
FOUNDATION_EXPORT PWLoggerName const PWLoggerNameASL NS_SWIFT_NAME(PWLoggerName.asl);   // DDASLLogger

NS_ASSUME_NONNULL_END
