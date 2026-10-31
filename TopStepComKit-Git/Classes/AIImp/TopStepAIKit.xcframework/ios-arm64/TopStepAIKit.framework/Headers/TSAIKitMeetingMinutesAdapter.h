#import "TSAIMeetingMinutesInterface.h"

@class TSAIContext;
@protocol TSAIMeetingMinutesProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Context-bound meeting minutes facade
 * @chinese 绑定 Context 的会议纪要门面
 */
@interface TSAIKitMeetingMinutesAdapter : NSObject <TSAIMeetingMinutesInterface>

/**
 * @brief Bind a meeting provider to its Context
 * @chinese 将会议 Provider 绑定到所属 Context
 * @param context
 * EN: Owning Context.
 * CN: 所属 Context。
 * @param provider
 * EN: Provider belonging to the same Context.
 * CN: 同一 Context 的 Provider。
 * @return
 * EN: A context-bound adapter.
 * CN: 绑定 Context 的适配器。
 */
- (instancetype)initWithContext:(TSAIContext *)context
                        provider:(id<TSAIMeetingMinutesProvider>)provider NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
