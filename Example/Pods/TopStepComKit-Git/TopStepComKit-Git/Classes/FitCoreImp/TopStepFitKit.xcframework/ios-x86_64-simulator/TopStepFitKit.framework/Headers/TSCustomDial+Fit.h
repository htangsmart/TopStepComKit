//
//  TSCustomDial+Fit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2026/1/12.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSCustomDial (Fit)

+(CGRect)fitPreviewTimeRectInBackgroundImageSize:(CGSize)originImageSize timeImageSize:(CGSize)timeImageSize position:(TSDialTimePosition)position ;

@end

NS_ASSUME_NONNULL_END
