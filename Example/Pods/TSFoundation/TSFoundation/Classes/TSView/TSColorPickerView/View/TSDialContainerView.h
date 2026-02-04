//
//  TSDialContainerView.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSColorCancelBlock)(void);
typedef void(^TSColorSureBlock)(UIColor *color);

@interface TSDialContainerView : UIView

+ (void)showContainOnView:(UIView *)superView cancelBlock:(TSColorCancelBlock)cancelBlock sureBlock:(TSColorSureBlock)sureBlock;

@end

NS_ASSUME_NONNULL_END
