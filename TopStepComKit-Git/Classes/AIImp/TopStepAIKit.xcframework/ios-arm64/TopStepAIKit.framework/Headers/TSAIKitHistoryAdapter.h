#import <Foundation/Foundation.h>
#import "TSAIHistoryInterface.h"
@class TSAIContext;
@protocol TSAIHistoryProvider;
NS_ASSUME_NONNULL_BEGIN
/**
 * @brief Context-bound local history facade
 * @chinese 绑定 Context 的本地历史门面
 */
@interface TSAIKitHistoryAdapter : NSObject <TSAIHistoryInterface>
/**
 * @brief Bind history to its Context
 * @chinese 将历史能力绑定到 Context
 * @param context EN: Weakly held Context. CN: 弱引用的 Context。
 * @param provider EN: History capability. CN: 历史能力。
 * @return EN: A facade. CN: 门面实例。
 */
- (instancetype)initWithContext:(TSAIContext *)context provider:(id<TSAIHistoryProvider>)provider;
@end
NS_ASSUME_NONNULL_END
