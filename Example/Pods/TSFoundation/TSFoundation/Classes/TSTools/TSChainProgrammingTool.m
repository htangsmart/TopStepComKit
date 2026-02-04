//
//  TSChainProgrammingTool.m
//  JieliJianKang
//
//  Created by luigi on 2024/3/29.
//

#import "TSChainProgrammingTool.h"
#import "ReactiveObjC.h"

@implementation UIButton (TSChainProgramming)

- (UIButton * _Nonnull (^)(NSString * _Nonnull, UIControlState))tsTitle {
    @weakify(self)
    return ^(NSString *title, UIControlState state) {
        @strongify(self)
        [self setTitle:title forState:state];
        return self;
    };
}

- (UIButton * _Nonnull (^)(UIColor * _Nonnull, UIControlState))tsTitleColor {
    @weakify(self)
    return ^(UIColor *titleColor, UIControlState state) {
        @strongify(self)
        [self setTitleColor:titleColor forState:state];
        return self;
    };
}

- (UIButton *(^)(NSAttributedString *, UIControlState))tsAttributedString {
    @weakify(self)
    return ^(NSAttributedString *attributedString, UIControlState state) {
        @strongify(self)
        [self setAttributedTitle:attributedString forState:state];
        return self;
    };
}

- (UIButton * _Nonnull (^)(UIFont * _Nonnull))tsTitleFont {
    @weakify(self)
    return ^(UIFont *font) {
        @strongify(self)
        self.titleLabel.font = font;
        return self;
    };
}

- (UIButton * _Nonnull (^)(UIImage * _Nonnull, UIControlState))tsImage {
    @weakify(self)
    return ^(UIImage *image, UIControlState state) {
        @strongify(self)
        [self setImage:image forState:state];
        return self;
    };
}

- (UIButton * _Nonnull (^)(UIImage * _Nonnull, UIControlState))tsBackgroundImage {
    @weakify(self)
    return ^(UIImage *backgroundImage, UIControlState state) {
        @strongify(self)
        [self setBackgroundImage:backgroundImage forState:state];
        return self;
    };
}

- (UIButton * _Nonnull (^)(id _Nonnull, SEL _Nonnull, UIControlEvents))tsAddTargetAction {
    @weakify(self)
    return ^(id target, SEL sel, UIControlEvents state) {
        @strongify(self)
        [self addTarget:target action:sel forControlEvents:state];
        return self;
    };
}

- (UIButton *(^)(NSInteger))tsCornerRadius {
    @weakify(self)
    return ^(NSInteger cornerRadius) {
        @strongify(self)
        self.layer.cornerRadius = cornerRadius;
        return self;
    };
}

- (UIButton *(^)(BOOL))tsMasksToBounds {
    @weakify(self)
    return ^(BOOL masksToBounds) {
        @strongify(self)
        self.layer.masksToBounds = masksToBounds;
        return self;
    };
}
- (UIButton *(^)(UIColor *))tsBorderColor {
    @weakify(self)
    return ^(UIColor *borderColor) {
        @strongify(self)
        self.layer.borderColor = [borderColor isKindOfClass:UIColor.class] ? borderColor.CGColor : nil;
        return self;
    };
}
- (UIButton *(^)(CGFloat))tsBorderWidth {
    @weakify(self)
    return ^(CGFloat borderWidth) {
        @strongify(self)
        self.layer.borderWidth = borderWidth;
        return self;
    };
}

@end

@implementation UILabel (TSChainProgramming)
- (UILabel *(^)(UIColor *))tsTextColor {
    @weakify(self)
    return ^(UIColor *textColor) {
        @strongify(self)
        self.textColor = textColor;
        return self;
    };
}
- (UILabel *(^)(UIFont *))tsFont {
    @weakify(self)
    return ^(UIFont *font) {
        @strongify(self)
        self.font = font;
        return self;
    };
}
- (UILabel *(^)(NSInteger))tsNumberOfLines {
    @weakify(self)
    return ^(NSInteger numberOfLines) {
        @strongify(self)
        self.numberOfLines = numberOfLines;
        return self;
    };
}
- (UILabel *(^)(NSString *))tsText {
    @weakify(self)
    return ^(NSString *text) {
        @strongify(self)
        self.text = text;
        return self;
    };
}
- (UILabel *(^)(UIColor *))tsBackgroundColor {
    @weakify(self)
    return ^(UIColor *backgroundColor) {
        @strongify(self)
        self.backgroundColor = backgroundColor;
        return self;
    };
}


- (UILabel *(^)(NSInteger))tsCornerRadius {
    @weakify(self)
    return ^(NSInteger cornerRadius) {
        @strongify(self)
        self.layer.cornerRadius = cornerRadius;
        return self;
    };
}

- (UILabel *(^)(BOOL))tsMasksToBounds {
    @weakify(self)
    return ^(BOOL masksToBounds) {
        @strongify(self)
        self.layer.masksToBounds = masksToBounds;
        return self;
    };
}
- (UILabel *(^)(UIColor *))tsBorderColor {
    @weakify(self)
    return ^(UIColor *borderColor) {
        @strongify(self)
        self.layer.borderColor = [borderColor isKindOfClass:UIColor.class] ? borderColor.CGColor : nil;
        return self;
    };
}
- (UILabel *(^)(CGFloat))tsBorderWidth {
    @weakify(self)
    return ^(CGFloat borderWidth) {
        @strongify(self)
        self.layer.borderWidth = borderWidth;
        return self;
    };
}
@end
