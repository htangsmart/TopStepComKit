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

// Disable legacy macros
#ifndef PW_DD_LEGACY_MACROS
    #define PW_DD_LEGACY_MACROS 0
#endif

#import "PwDDLog.h"

/**
 * The constant/variable/method responsible for controlling the current log level.
 **/
#ifndef PW_LOG_LEVEL_DEF
    #define PW_LOG_LEVEL_DEF ddLogLevel
#endif

/**
 * Whether async should be used by log messages, excluding error messages that are always sent sync.
 **/
#ifndef PW_LOG_ASYNC_ENABLED
    #define PW_LOG_ASYNC_ENABLED YES
#endif

/**
 * These are the two macros that all other macros below compile into.
 * These big multiline macros makes all the other macros easier to read.
 **/
#define PW_LOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [PWLog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]

#define PW_LOG_MACRO_TO_DDLOG(ddlog, isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [ddlog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]

/**
 * Define version of the macro that only execute if the log level is above the threshold.
 * The compiled versions essentially look like this:
 *
 * if (logFlagForThisLogMsg & ddLogLevel) { execute log message }
 *
 * When PW_LOG_LEVEL_DEF is defined as ddLogLevel.
 *
 * As shown further below, Lumberjack actually uses a bitmask as opposed to primitive log levels.
 * This allows for a great amount of flexibility and some pretty advanced fine grained logging techniques.
 *
 * Note that when compiler optimizations are enabled (as they are for your release builds),
 * the log messages above your logging threshold will automatically be compiled out.
 *
 * (If the compiler sees PW_LOG_LEVEL_DEF/ddLogLevel declared as a constant, the compiler simply checks to see
 *  if the 'if' statement would execute, and if not it strips it from the binary.)
 *
 * We also define shorthand versions for asynchronous and synchronous logging.
 **/
#define PW_LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { if((lvl & flg) != 0) PW_LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define PW_LOG_MAYBE_TO_DDLOG(ddlog, async, lvl, flg, ctx, tag, fnct, frmt, ...) \
        do { if((lvl & flg) != 0) PW_LOG_MACRO_TO_DDLOG(ddlog, async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

/**
 * Ready to use log macros with no context or tag.
 **/
#define PWLogError(frmt, ...)   PW_LOG_MAYBE(NO,                PW_LOG_LEVEL_DEF, PWLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PWLogWarn(frmt, ...)    PW_LOG_MAYBE(PW_LOG_ASYNC_ENABLED, PW_LOG_LEVEL_DEF, PWLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PWLogInfo(frmt, ...)    PW_LOG_MAYBE(PW_LOG_ASYNC_ENABLED, PW_LOG_LEVEL_DEF, PWLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PWLogDebug(frmt, ...)   PW_LOG_MAYBE(PW_LOG_ASYNC_ENABLED, PW_LOG_LEVEL_DEF, PWLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PWLogVerbose(frmt, ...) PW_LOG_MAYBE(PW_LOG_ASYNC_ENABLED, PW_LOG_LEVEL_DEF, PWLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define PWLogErrorToDDLog(ddlog, frmt, ...)   PW_LOG_MAYBE_TO_DDLOG(ddlog, NO,                PW_LOG_LEVEL_DEF, PWLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PWLogWarnToDDLog(ddlog, frmt, ...)    PW_LOG_MAYBE_TO_DDLOG(ddlog, PW_LOG_ASYNC_ENABLED, PW_LOG_LEVEL_DEF, PWLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PWLogInfoToDDLog(ddlog, frmt, ...)    PW_LOG_MAYBE_TO_DDLOG(ddlog, PW_LOG_ASYNC_ENABLED, PW_LOG_LEVEL_DEF, PWLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PWLogDebugToDDLog(ddlog, frmt, ...)   PW_LOG_MAYBE_TO_DDLOG(ddlog, PW_LOG_ASYNC_ENABLED, PW_LOG_LEVEL_DEF, PWLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define PWLogVerboseToDDLog(ddlog, frmt, ...) PW_LOG_MAYBE_TO_DDLOG(ddlog, PW_LOG_ASYNC_ENABLED, PW_LOG_LEVEL_DEF, PWLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
