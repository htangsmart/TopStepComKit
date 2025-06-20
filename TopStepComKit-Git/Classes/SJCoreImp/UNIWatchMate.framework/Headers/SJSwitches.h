//
//  SJSwitches.h
//  UNIWatchMate
//
//  Created by t_t on 2024/7/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJSwitches : NSObject

@property (nonatomic, strong) NSMutableData *data;

- (instancetype)initWithSwitchStates:(NSArray<NSNumber *> *)switchStates;
- (void)setSwitchAtIndex:(int)index toState:(BOOL)state;
- (BOOL)getSwitchStateAtIndex:(int)index;

@end

NS_ASSUME_NONNULL_END
