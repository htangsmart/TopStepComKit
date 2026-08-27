//
//  TSFitPeripheralDial+Private.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import "TSFitPeripheralDial.h"

#import <FitCloudDFUKit/FitCloudDFUKit.h>

@class TSFitCustomDialInstallOperation;
@class TSFitCustomDialTemplateResolver;
@class TSFitCustomDialTimeImageResolver;
@class TSFitDialStyleConstraintMapper;
@class TSFitDialTemplateDownloader;
@class TSFitDialTemplateRepository;
@class TSFitDialTemplateRequestContextLoader;

NS_ASSUME_NONNULL_BEGIN

/** @brief Watch-face switch callback @chinese 表盘切换回调 */
typedef void (^TSDialDidChangedBlock)(NSArray<TSDialModel *> *dials);
/** @brief Watch-face deletion callback @chinese 表盘删除回调 */
typedef void (^TSDialBeenDeletedBlock)(TSDialModel *dial);

@interface TSFitPeripheralDial () <FitCloudDFUDelegate>

/** @brief Slot index used for switching @chinese 用于切换表盘的位置索引 */
@property (nonatomic, assign) NSInteger switchDialIndex;
/** @brief Binary push index @chinese 表盘二进制推送索引 */
@property (nonatomic, assign) NSInteger enablePushDialIndex;
/** @brief Current dial completion @chinese 当前表盘操作完成回调 */
@property (nonatomic, copy, nullable) TSDialCompletionBlock dialCompletionBlock;
/** @brief Current dial progress callback @chinese 当前表盘推送进度回调 */
@property (nonatomic, copy, nullable) TSDialProgressBlock dialProgressBlock;
/** @brief Current custom dial @chinese 当前操作的自定义表盘模型 */
@property (nonatomic, strong, nullable) TSCustomDial *currentCustomDial;
/** @brief Current dial @chinese 当前操作的表盘模型 */
@property (nonatomic, strong, nullable) TSDialModel *currentDial;
/** @brief Current custom-dial installation @chinese 当前自定义表盘安装操作 */
@property (nonatomic, strong, nullable) TSFitCustomDialInstallOperation *customDialInstallOperation;
/** @brief Shared custom-dial template resolver @chinese 共享自定义表盘模板解析器 */
@property (nonatomic, strong, nullable) TSFitCustomDialTemplateResolver *customDialTemplateResolver;
/** @brief Shared custom-dial time-image resolver @chinese 共享自定义表盘时间图片解析器 */
@property (nonatomic, strong, nullable) TSFitCustomDialTimeImageResolver *customDialTimeImageResolver;
/** @brief Shared custom-dial resource downloader @chinese 共享自定义表盘资源下载器 */
@property (nonatomic, strong, nullable) TSFitDialTemplateDownloader *customDialResourceDownloader;
/** @brief Whether custom-dial resources are being prepared @chinese 是否正在准备自定义表盘资源 */
@property (nonatomic, assign) BOOL isPreparingCustomDial;
/** @brief Shared template request context loader @chinese 共享模板请求上下文加载器 */
@property (nonatomic, strong, nullable) TSFitDialTemplateRequestContextLoader *customDialTemplateContextLoader;
/** @brief Shared template catalog repository @chinese 共享模板目录仓库 */
@property (nonatomic, strong, nullable) TSFitDialTemplateRepository *customDialTemplateRepository;
/** @brief Shared custom-dial style mapper @chinese 共享自定义表盘样式转换器 */
@property (nonatomic, strong, nullable) TSFitDialStyleConstraintMapper *customDialStyleConstraintMapper;
/** @brief Registered switch callback @chinese 已注册的表盘切换回调 */
@property (nonatomic, copy, nullable) TSDialDidChangedBlock dialDidChangedBlock;
/** @brief Registered deletion callback @chinese 已注册的表盘删除回调 */
@property (nonatomic, copy, nullable) TSDialBeenDeletedBlock dialBeenDeletedBlock;

/**
 * @brief Push a dial without entering DFU mode
 * @chinese 不进入 DFU 模式推送表盘
 * @param dial EN: Dial to push. CN: 待推送表盘。
 * @param progressBlock EN: Progress callback. CN: 进度回调。
 * @param completion EN: Completion callback. CN: 完成回调。
 */
- (void)pushDialWithoutDFUModel:(TSDialModel *)dial
                 progressBlock:(nullable TSDialProgressBlock)progressBlock
                    completion:(TSDialCompletionBlock)completion;
/**
 * @brief Push a dial after entering DFU mode
 * @chinese 进入 DFU 模式后推送表盘
 * @param dial EN: Dial to push. CN: 待推送表盘。
 * @param progressBlock EN: Progress callback. CN: 进度回调。
 * @param completion EN: Completion callback. CN: 完成回调。
 */
- (void)pushDialInDFUModel:(TSDialModel *)dial
             progressBlock:(nullable TSDialProgressBlock)progressBlock
                completion:(TSDialCompletionBlock)completion;
/**
 * @brief Whether the dial can be pushed without entering DFU mode
 * @chinese 表盘是否可在不进入 DFU 模式时推送
 * @return EN: YES when direct transfer is supported. CN: 支持直接传输时返回 YES。
 */
- (BOOL)canPushDialWithoutEnteringDFUMode;

/**
 * @brief Prepare shared template dependencies for constraint queries and installation
 * @chinese 为约束查询和安装准备共享模板依赖
 */
- (void)tsfit_prepareCustomDialTemplateDependencies;

@end

/**
 * @brief Internal custom watch-face implementation
 * @chinese 自定义表盘内部实现
 */
@interface TSFitPeripheralDial (CustomDial)

/** @brief Create and install a custom dial @chinese 制作并安装自定义表盘 */
- (void)tsfit_installCustomDial:(TSCustomDial *)customDial
                  progressBlock:(nullable TSDialProgressBlock)progressBlock
                     completion:(nullable TSDialCompletionBlock)completion;

/** @brief Install a downloaded cloud dial @chinese 安装已下载的云表盘 */
- (void)tsfit_installDownloadedCloudDial:(TSDialModel *)dial
                           progressBlock:(nullable TSDialProgressBlock)progressBlock
                              completion:(nullable TSDialCompletionBlock)completion;

/** @brief Generate a dial preview @chinese 生成表盘预览图 */
- (void)tsfit_previewImageWith:(UIImage *)originImage
                     timeImage:(UIImage *)timeImage
                  timePosition:(TSDialTimePosition)timePosition
                     maxKBSize:(CGFloat)maxKBSize
                    completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion;

/** @brief Generate a dial preview with alpha option @chinese 按透明背景选项生成表盘预览图 */
- (void)tsfit_previewImageWith:(UIImage *)originImage
                     timeImage:(nullable UIImage *)timeImage
                  timePosition:(TSDialTimePosition)timePosition
                     maxKBSize:(CGFloat)maxKBSize
     keepTransparentBackground:(BOOL)keepTransparentBackground
                    completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion;

/** @brief Generate a preview from a custom dial item @chinese 根据自定义表盘项生成预览图 */
- (void)tsfit_previewImageWithDialItem:(TSCustomDialItem *)dialItem
                             maxKBSize:(CGFloat)maxKBSize
                            completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion;

/** @brief Generate an item preview with alpha option @chinese 按透明背景选项生成表盘项预览图 */
- (void)tsfit_previewImageWithDialItem:(TSCustomDialItem *)dialItem
                             maxKBSize:(CGFloat)maxKBSize
             keepTransparentBackground:(BOOL)keepTransparentBackground
                            completion:(void (^)(UIImage * _Nullable, NSError * _Nullable))completion;

/** @brief Validate and push a dial @chinese 校验并推送表盘 */
- (void)pushDial:(TSDialModel *)dial
   progressBlock:(nullable TSDialProgressBlock)progressBlock
      completion:(TSDialCompletionBlock)completion;

/** @brief Push a dial through the new OTA channel @chinese 使用新 OTA 通道推送表盘 */
- (void)pushDialInNewWay:(TSDialModel *)dial
           progressBlock:(nullable TSDialProgressBlock)progressBlock
              completion:(TSDialCompletionBlock)completion;

/** @brief Get module styles for the current dial @chinese 获取当前表盘的模块样式 */
- (NSArray<NSNumber *> *)modulesStyleArray;

@end

NS_ASSUME_NONNULL_END
