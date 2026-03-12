//
//  TSSportDataCombiner.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

@class TSSportParseContext;
@class TSMetaSportItem;

NS_ASSUME_NONNULL_BEGIN

/// Merges step/calorie/distance arrays from context into TSMetaSportItem array.
@interface TSSportDataCombiner : NSObject

+ (NSArray<TSMetaSportItem *> *)combineFromContext:(TSSportParseContext *)context;

@end

NS_ASSUME_NONNULL_END
