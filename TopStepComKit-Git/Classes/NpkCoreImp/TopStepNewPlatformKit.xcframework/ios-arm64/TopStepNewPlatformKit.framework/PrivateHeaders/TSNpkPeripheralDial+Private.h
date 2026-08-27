//
//  TSNpkPeripheralDial+Private.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import "TSNpkPeripheralDial.h"

@class TSDownloader;
@class TSManagedDownloadedFile;
@class TSNpkDialStyleCloudService;
@class TSNpkDialStyleConstraintMapper;

NS_ASSUME_NONNULL_BEGIN

@interface TSNpkPeripheralDial ()

@property (nonatomic, strong, nullable) TSNpkDialStyleCloudService *dialStyleCloudService;
@property (nonatomic, strong, nullable) TSNpkDialStyleConstraintMapper *dialStyleConstraintMapper;
@property (nonatomic, strong, nullable) TSDownloader *dialTemplateDownloader;
@property (nonatomic, strong, nullable) NSURL *dialStyleServiceURL;
@property (nonatomic, strong, nullable) NSURLSessionTask *dialMetadataTask;
@property (nonatomic, strong, nullable) NSURLSessionTask *dialTemplateDownloadTask;
@property (nonatomic, strong, nullable) TSManagedDownloadedFile *managedDialTemplateFile;
@property (nonatomic, assign) BOOL customDialInstalling;
@property (nonatomic, strong) dispatch_queue_t customDialWorkerQueue;

- (void)tsnpk_prepareDialStyleDependencies;
- (void)tsnpk_resolveTemplateForCustomDial:(TSCustomDial *)customDial
                                completion:(void (^)(BOOL success, NSError *_Nullable error))completion;
- (void)tsnpk_cleanupManagedDialTemplateForCustomDial:(nullable TSCustomDial *)customDial;

@end

NS_ASSUME_NONNULL_END
