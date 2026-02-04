//
//  TSProgressButton.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSButtonProgressType) {
    eTSButtonUnknow = 0,
    eTSButtonBegin,
    eTSButtonProgress,
    eTSButtonSuccess,
    eTSButtonComplete,
    eTSButtonFaile,

};

@interface TSProgressButton : UIView

@property (nonatomic,assign) TSButtonProgressType proType;

/// 进度值，范围 0 ～ 1
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) NSString *title;

@property (nonatomic,assign) BOOL enable;

@property (nonatomic,assign) BOOL isShowProgress;

- (instancetype)initWithEvent:(void(^)(TSButtonProgressType proType))buttonEvent;
- (instancetype)initWithBeginColor:(UIColor *)beginColor endColor:(UIColor *)endColor uploadColor:(UIColor *)uploadColor event:(void(^)(TSButtonProgressType proType))buttonEvent;

- (void)beginAnimation;
- (void)endAnimation;

@end

NS_ASSUME_NONNULL_END
