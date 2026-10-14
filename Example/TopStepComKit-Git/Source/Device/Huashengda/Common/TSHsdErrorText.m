//
//  TSHsdErrorText.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdErrorText.h"
#import "TSRootVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>

@implementation TSHsdErrorText

+ (NSString *)messageForError:(nullable NSError *)error {
    if (!error) { return TSLocalizedString(@"general.unknown_error"); }
    if ([self isMissingFragmentsError:error]) { return TSLocalizedString(@"hsd.error.missing_fragments"); }

    switch (error.code) {
        case eTSErrorNotSupport:      return TSLocalizedString(@"hsd.error.not_support");
        case eTSErrorInvalidParam:
        case eTSErrorParamError:
        case eTSErrorInvalidTypeError:
        case eTSErrorParamSizeError:  return TSLocalizedString(@"hsd.error.invalid_param");
        case eTSErrorDataSetFailed:   return TSLocalizedString(@"hsd.error.set_failed");
        case eTSErrorDataGetFailed:   return TSLocalizedString(@"hsd.error.get_failed");
        case eTSErrorUnConnected:     return TSLocalizedString(@"hsd.error.disconnected");
        case eTSErrorNotReady:        return TSLocalizedString(@"hsd.error.not_ready");
        case eTSErrorIsBusy:          return TSLocalizedString(@"hsd.error.busy");
        case eTSErrorTimeoutError:    return TSLocalizedString(@"hsd.error.timeout");
        case eTSErrorTransmissionInterrupted:
        case eTSErrorConnectionReset: return TSLocalizedString(@"hsd.error.disconnected");
        default: break;
    }
    return error.localizedDescription.length ? error.localizedDescription : TSLocalizedString(@"general.unknown_error");
}

+ (NSString *)detailForError:(nullable NSError *)error {
    if (!error) { return @""; }
    NSString *domain = error.domain.length ? error.domain : @"-";
    // 分包不连续时附上原始描述，方便定位是哪个指令
    if ([self isMissingFragmentsError:error]) {
        return [NSString stringWithFormat:@"%@ / %@ (%ld) · %@", domain, [self codeNameForCode:error.code], (long)error.code, error.localizedDescription ?: @""];
    }
    NSString *detail = [NSString stringWithFormat:@"%@ / %@ (%ld)", domain, [self codeNameForCode:error.code], (long)error.code];
    NSNumber *failedIndex = error.userInfo[@"failedIndex"] ?: error.userInfo[@"index"];
    if (failedIndex) {
        detail = [detail stringByAppendingFormat:@" · #%@", failedIndex];
    }
    return detail;
}

+ (NSString *)codeNameForCode:(NSInteger)code {
    static NSDictionary<NSNumber *, NSString *> *names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @{
            @(eTSErrorUnknown): @"UNKNOWN",
            @(eTSErrorSDKInitFailed): @"SDK_INIT_FAILED",
            @(eTSErrorLicenseIncorrect): @"LICENSE_INCORRECT",
            @(eTSErrorSDKConfigError): @"SDK_CONFIG_ERROR",
            @(eTSErrorNotReady): @"NOT_READY",
            @(eTSErrorLowBattery): @"LOW_BATTERY",
            @(eTSErrorUnConnected): @"UNCONNECTED",
            @(eTSErrorNotSupport): @"NOTSUPPORT",
            @(eTSErrorNoSpace): @"NO_SPACE",
            @(eTSErrorIsBusy): @"BUSY",
            @(eTSErrorInvalidParam): @"INVALID_PARAM",
            @(eTSErrorParamError): @"PARAM_ERROR",
            @(eTSErrorInvalidTypeError): @"INVALID_TYPE",
            @(eTSErrorParamSizeError): @"PARAM_SIZE",
            @(eTSErrorDataGetFailed): @"DATA_GET_FAILED",
            @(eTSErrorDataSetFailed): @"DATA_SET_FAILED",
            @(eTSErrorDataFormatError): @"DATA_FORMAT",
            @(eTSErrorDataIsEmpty): @"DATA_EMPTY",
            @(eTSErrorPreTaskExecuting): @"TASK_EXECUTING",
            @(eTSErrorTaskExecutionFailed): @"TASK_FAILED",
            @(eTSErrorTaskNotStarted): @"TASK_NOT_STARTED",
            @(eTSErrorTimeoutError): @"TIMEOUT",
            @(eTSErrorTransmissionInterrupted): @"TRANSMISSION_INTERRUPTED",
            @(eTSErrorSignalInterference): @"SIGNAL_INTERFERENCE",
            @(eTSErrorPacketLoss): @"PACKET_LOSS",
            @(eTSErrorProtocolMismatch): @"PROTOCOL_MISMATCH",
            @(eTSErrorConnectionReset): @"CONNECTION_RESET",
            @(eTSErrorBufferOverflow): @"BUFFER_OVERFLOW",
        };
    });
    NSString *name = names[@(code)];
    return name ?: [NSString stringWithFormat:@"%ld", (long)code];
}

+ (BOOL)isMissingFragmentsError:(nullable NSError *)error {
    if (!error) { return NO; }
    NSString *description = error.localizedDescription ?: @"";
    if ([description rangeOfString:@"missing some fragments" options:NSCaseInsensitiveSearch].location != NSNotFound) { return YES; }
    NSString *reason = error.userInfo[NSLocalizedFailureReasonErrorKey];
    return [reason isKindOfClass:[NSString class]] && [reason rangeOfString:@"missing some fragments" options:NSCaseInsensitiveSearch].location != NSNotFound;
}

+ (NSString *)summaryForError:(nullable NSError *)error {
    if (!error) { return TSLocalizedString(@"general.unknown_error"); }
    return [NSString stringWithFormat:@"%@（%@）", [self messageForError:error], [self detailForError:error]];
}

@end
