//
//  TSDialCapability+Internal.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/20.
//

#import "TSDialCapability.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSDialCapability ()

- (instancetype)initWithSupportsCustom:(BOOL)supportsCustom
                         supportsVideo:(BOOL)supportsVideo
                      maxVideoDuration:(NSInteger)maxVideoDuration
                     supportsSlideshow:(BOOL)supportsSlideshow
                    maxSlideshowImages:(NSInteger)maxSlideshowImages
                         colorTintable:(BOOL)colorTintable
                     supportsComponent:(BOOL)supportsComponent
                       maxInstallCount:(NSInteger)maxInstallCount
                          maxInnerCount:(NSInteger)maxInnerCount
                           screenWidth:(NSInteger)screenWidth
                          screenHeight:(NSInteger)screenHeight
                    deviceCornerRadius:(CGFloat)deviceCornerRadius
                          previewWidth:(NSInteger)previewWidth
                         previewHeight:(NSInteger)previewHeight
                   previewCornerRadius:(CGFloat)previewCornerRadius
                                 shape:(TSPeriphShape)shape NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
