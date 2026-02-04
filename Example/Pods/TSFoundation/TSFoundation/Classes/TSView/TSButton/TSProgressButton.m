//
//  TSProgressButton.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/5.
//

#import "TSProgressButton.h"
#import "TSFont.h"
#import "TSColor.h"
#import "TSFrame.h"
typedef void(^ButtonEvent)(TSButtonProgressType proType);

@interface TSProgressButton ()

@property (nonatomic,strong) UIView * gradualView;

@property (nonatomic,strong) CAGradientLayer *gradientLayer  ;

@property (nonatomic,strong) UILabel * titleLabe;

@property (nonatomic,strong) UIControl * buttonControl;

@property (nonatomic,copy) ButtonEvent buttonEvent;

@property (nonatomic,strong) UIColor * beginColor;
@property (nonatomic,strong) UIColor * endColor;
@property (nonatomic,strong) UIColor * uploadColor;

@end

@implementation TSProgressButton



- (instancetype)initWithEvent:(void(^)(TSButtonProgressType proType))buttonEvent
{
    self = [super init];
    if (self) {
        _buttonEvent = buttonEvent;
        [self initData];
        [self initViews];
        [self layoutViews];
        [self.gradualView.layer addSublayer: self.gradientLayer];

    }
    return self;
}

- (instancetype)initWithBeginColor:(UIColor *)beginColor endColor:(UIColor *)endColor uploadColor:(nonnull UIColor *)uploadColor event:(nonnull void (^)(TSButtonProgressType))buttonEvent{
    _beginColor = beginColor;
    _endColor = endColor;
    _uploadColor = uploadColor;
    return [self initWithEvent:buttonEvent];
}

- (void)initData{
    
    self.layer.cornerRadius = 24;
    self.gradualView.layer.cornerRadius = 24;
    
}

- (void)initViews{
    [self addSubview:self.gradualView];
    [self addSubview:self.titleLabe];
    [self addSubview:self.buttonControl];
}

- (void)layoutViews{
 
    self.gradualView.frame  =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.gradientLayer.frame =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.titleLabe.frame  =CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.buttonControl.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self layoutViews];
}

- (void)setEnable:(BOOL)enable{
    _enable = enable;
    if (_enable == NO) {
        self.buttonControl.enabled = NO;
        self.gradualView.alpha = 0.5;
    }else{
        self.buttonControl.enabled = YES;
        self.gradualView.alpha = 1.0;
    }
}

- (void)beginAnimation{
    self.gradualView.frame = CGRectMake(0, 0, 48, self.frame.size.height);
    self.gradientLayer.frame = CGRectMake(0, 0, 48, self.frame.size.height);
    self.backgroundColor = self.endColor;

    self.backgroundColor = self.uploadColor;
    self.gradualView.hidden = NO;

}

- (void)endAnimation{
    self.gradualView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}


/// 设置进度值
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (_isShowProgress) {
        _titleLabe.text = [NSString stringWithFormat:@"%.1f%%",progress*100];
    }
    CGFloat maxWidth =(self.frame.size.width-48)*progress;
    CGFloat width = 48+maxWidth;
    [UIView animateWithDuration:0.2 animations:^{
        self.gradualView.frame = CGRectMake(0, 0, width, self.frame.size.height);
        self.gradientLayer.frame = CGRectMake(0, 0, width, self.frame.size.height);
    }];
}


- (CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors     = @[(__bridge id)self.beginColor.CGColor, (__bridge id)self.endColor.CGColor];
        _gradientLayer.locations  = @[@0.0, @1.0];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint   = CGPointMake(1.0, 0);
        _gradientLayer.frame      = CGRectMake(0, 0,  [TSFrame screenWidth]-32, 48);
        _gradientLayer.cornerRadius = 24;
    }
    return _gradientLayer;
}


- (void)setTitle:(NSString *)title{
    _titleLabe.text = title;
}

- (void)buttonControlEvent{
    if (_buttonEvent) {
        _buttonEvent(_proType);
    }
}

- (UIColor *)beginColor{
    if (!_beginColor) {
        _beginColor =[TSColor colorwithHexString:@"#24FFBD"];
    }
    return _beginColor;
}

- (UIColor *)endColor{
    if (!_endColor) {
        _endColor = [TSColor colorwithHexString:@"#46BAFF"];
    }
    return _endColor;
}
- (UIColor *)uploadColor{
    if (!_uploadColor) {
        _uploadColor = [UIColor colorWithRed:222/255.0f green:243/255.0f blue:251/255.0f alpha:1.0f];
    }
    return _uploadColor;
}

- (UIView *)gradualView{
    if (!_gradualView) {
        _gradualView = [[UIView alloc]init];
        _gradualView.clipsToBounds = YES;
//        _gradualView.hidden = YES;
    }
    return _gradualView;
}

- (UILabel *)titleLabe{
    if (!_titleLabe) {
        _titleLabe = [[UILabel alloc]init];
        _titleLabe.textColor = [UIColor whiteColor];
        _titleLabe.font = [TSFont TSFontPingFangMediumWithSize:14];
        _titleLabe.textAlignment = NSTextAlignmentCenter;
        _titleLabe.backgroundColor = [UIColor clearColor];
    }
    return _titleLabe;

}

- (UIControl *)buttonControl{
    if (!_buttonControl) {
        _buttonControl  = [[UIControl alloc]init];
        [_buttonControl addTarget:self action:@selector(buttonControlEvent) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _buttonControl;
}

@end


