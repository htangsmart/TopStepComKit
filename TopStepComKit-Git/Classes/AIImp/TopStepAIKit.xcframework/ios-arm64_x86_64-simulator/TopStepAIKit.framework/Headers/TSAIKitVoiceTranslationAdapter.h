#import <Foundation/Foundation.h>
#import "TSAIVoiceTranslationInterface.h"
@class TSAIContext;
@protocol TSAIVoiceTranslationProvider;
NS_ASSUME_NONNULL_BEGIN
/**
 * @brief Context-bound phone translation facade
 * @chinese 绑定 Context 的手机翻译门面
 */
@interface TSAIKitVoiceTranslationAdapter : NSObject <TSAIVoiceTranslationInterface>
/**
 * @brief Bind an existing capability to its Context
 * @chinese 将现有能力绑定到所属 Context
 * @param context
 * EN: Owning Context, weakly referenced.
 * CN: 所属 Context，使用弱引用。
 * @param provider
 * EN: Translation capability.
 * CN: 翻译能力。
 * @return
 * EN: A facade instance.
 * CN: 门面实例。
 */
- (instancetype)initWithContext:(TSAIContext *)context provider:(id<TSAIVoiceTranslationProvider>)provider;
@end
NS_ASSUME_NONNULL_END
