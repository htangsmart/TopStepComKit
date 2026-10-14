//
//  TSNpkDialBuildRouter.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Which dial building implementation runs @chinese 使用哪一套造包实现 */
typedef NS_ENUM(NSInteger, TSNpkDialBuildEngine) {
    /** @brief Original in-place res.bin editing (TSDialCreator) @chinese 原有的原地改写 res.bin 的实现（TSDialCreator） */
    TSNpkDialBuildEngineLegacy = 0,
    /** @brief Rebuild pipeline (TSNpkDialPackageBuilder) @chinese 重建 res.bin 的流水线实现（TSNpkDialPackageBuilder） */
    TSNpkDialBuildEngineV2 = 1,
};

/**
 * @brief Temporary switch between the legacy and the V2 dial building implementations
 * @chinese 在老实现与 V2 实现之间切换的临时路由
 *
 * @discussion
 * [EN]: Exists only for the transition: side-by-side comparison during development and a fallback for the first
 *       release. Once V2 is proven, delete this class together with the legacy creators and call
 *       TSNpkDialPackageBuilder directly. There is no automatic fallback on failure, on purpose.
 * [CN]: 只为过渡期存在：开发时用于新老对比，首个版本用于回退。V2 验证稳定后，连同老的 Creator 一起删除本类，
 *       改为直接调用 TSNpkDialPackageBuilder。刻意不做"失败后自动回退"。
 */
@interface TSNpkDialBuildRouter : NSObject

/** @brief Engine in use; defaults to legacy until V2 passes device verification @chinese 当前使用的实现；V2 真机验证通过前默认为老实现 */
@property (class, nonatomic, assign) TSNpkDialBuildEngine engine;

/**
 * @brief Build a custom dial package with the selected engine
 * @chinese 用选定的实现生成自定义表盘包
 */
+ (void)createCustomDial:(TSDialDraft *)draft
              completion:(void (^)(BOOL isSuccess,
                                   NSString *_Nullable resultFilePath,
                                   NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
