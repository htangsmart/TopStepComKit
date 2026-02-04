//
//  TSChainProgrammingTool.h
//  JieliJianKang
//
//  Created by luigi on 2024/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (TSChainProgramming)
- (UIButton *(^)(NSString *, UIControlState))tsTitle;
- (UIButton *(^)(UIColor *, UIControlState))tsTitleColor;
- (UIButton *(^)(NSAttributedString *, UIControlState))tsAttributedString;
- (UIButton *(^)(UIFont *))tsTitleFont;
- (UIButton *(^)(UIImage *, UIControlState))tsImage;
- (UIButton *(^)(UIImage *, UIControlState))tsBackgroundImage;
- (UIButton *(^)(id, SEL, UIControlEvents))tsAddTargetAction;

- (UIButton *(^)(NSInteger))tsCornerRadius;
- (UIButton *(^)(BOOL))tsMasksToBounds;
- (UIButton *(^)(UIColor *))tsBorderColor;
- (UIButton *(^)(CGFloat))tsBorderWidth;

@end

@interface UILabel (TSChainProgramming)
- (UILabel *(^)(UIColor *))tsTextColor;
- (UILabel *(^)(UIFont *))tsFont;
- (UILabel *(^)(NSInteger))tsNumberOfLines;
- (UILabel *(^)(NSString *))tsText;
- (UILabel *(^)(UIColor *))tsBackgroundColor;

- (UILabel *(^)(NSInteger))tsCornerRadius;
- (UILabel *(^)(BOOL))tsMasksToBounds;
- (UILabel *(^)(UIColor *))tsBorderColor;
- (UILabel *(^)(CGFloat))tsBorderWidth;
@end

NS_ASSUME_NONNULL_END
