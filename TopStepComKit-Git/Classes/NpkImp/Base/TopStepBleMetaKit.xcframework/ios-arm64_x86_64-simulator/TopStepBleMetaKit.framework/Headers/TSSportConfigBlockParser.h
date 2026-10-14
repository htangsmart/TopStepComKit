//
//  TSSportConfigBlockParser.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>
#import "TSSportBlockParser.h"

NS_ASSUME_NONNULL_BEGIN

/// Parses block type 0x00 (configuration), fills context.config intervals.
@interface TSSportConfigBlockParser : NSObject <TSSportBlockParser>
@end

NS_ASSUME_NONNULL_END
