//
//  TSToast.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/4.
//

#import "TSToast.h"
#import "TSFont.h"

#define kDefaultCornerRadius 5;


@implementation TSToastConfiger

- (UIFont *)textFont{
    
    return _textFont?_textFont:[TSFont TSFontPingFangSemiboldWithSize:14];
}

@end

@interface TSToast ()

@property (nonatomic,strong) TSToastConfiger * configer;

@property (nonatomic,strong) UIView * toastBackGroundView;

@property (nonatomic,strong) UILabel * toastLabel;

@property (nonatomic,strong) UIActivityIndicatorView * toastIndicatorView;


@end

@implementation TSToast

+ (void)showLoadingOnView:(UIView *)superView text:(NSString *)text{
    
    if (superView && text && text.length>0) {
        TSToastConfiger *configer = [[TSToastConfiger alloc]init];
        configer.toastType = eTSToastTextLoading;
        configer.superView = superView;
        configer.cornerRadius = kDefaultCornerRadius;
        configer.toastContent = text;

        TSToast *toast = [[TSToast alloc]initWithToastConfiger:configer];
        [superView addSubview:toast];
        [toast startAnimation];
    }
}

+ (void)showLoadingOnView:(UIView *)superView text:(NSString *)text dismissAfterDelay:(CGFloat)delay{
    
    [TSToast showLoadingOnView:superView text:text];
    [TSToast dismissLoadingOnView:superView afterDelay:delay];
}

+ (void)showLoadingOnView:(UIView *)superView{
    
    if (superView) {
        TSToastConfiger *configer = [[TSToastConfiger alloc]init];
        configer.toastType = eTSToastLoading;
        configer.superView = superView;
        configer.cornerRadius = kDefaultCornerRadius;
        
        TSToast *toast = [[TSToast alloc]initWithToastConfiger:configer];
        [superView addSubview:toast];
        [toast startAnimation];
    }
}

+ (void)showLoadingOnView:(UIView *)superView dismissAfterDelay:(CGFloat)delay{

    [TSToast showLoadingOnView:superView];
    [TSToast dismissLoadingOnView:superView afterDelay:delay];
}

+ (void)showLoadingOnView:(UIView *)superView dismissAfterDelay:(CGFloat)delay complete:(void(^)(void))complete{
    [TSToast showLoadingOnView:superView];
    [TSToast dismissLoadingOnView:superView afterDelay:delay complete:^{
        complete();
    }];
}


+ (void)showText:(NSString *)text onView:(UIView *)superView{
    
    if (superView) {
        TSToastConfiger *configer = [[TSToastConfiger alloc]init];
        configer.toastType = eTSToastText;
        configer.superView = superView;
        configer.toastContent = text;

        TSToast *toast = [[TSToast alloc]initWithToastConfiger:configer];
        [superView addSubview:toast];
    }
}

+ (void)showText:(NSString *)text onView:(UIView *)superView dismissAfterDelay:(CGFloat)delay{
    [TSToast showText:text onView:superView];
    [TSToast dismissLoadingOnView:superView afterDelay:delay];
}


+ (void)showText:(NSString *)text onView:(UIView *)superView dismissAfterDelay:(CGFloat)delay complete:(void(^)(void))complete{
    [TSToast showText:text onView:superView];
    [TSToast dismissLoadingOnView:superView afterDelay:delay complete:^{
        complete();
    }];
}


+ (void)showToastOnView:(UIView *)superView withConfiger:(TSToastConfiger *)configer{
    if (superView && configer) {
        configer.superView = superView;
        TSToast *toast = [[TSToast alloc]initWithToastConfiger:configer];
        [superView addSubview:toast];
    }
}


+ (void)dismissLoadingOnView:(UIView *)superView{
    if (superView) {
        [superView.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *subview = obj;
            if ([subview isKindOfClass:[TSToast class]]) {
                TSToast *toast = (TSToast *)subview;
                [toast stopAnimation];
                [subview removeFromSuperview];
            }
        }];
    }
}

+ (void)dismissLoadingOnView:(UIView *)superView afterDelay:(CGFloat)delay{
    if (superView) {
        [TSToast dismissLoadingOnView:superView afterDelay:delay complete:^{}];
    }
}

+ (void)dismissLoadingOnView:(UIView *)superView afterDelay:(CGFloat)delay complete:(void(^)(void))complete{
    if (superView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [TSToast dismissLoadingOnView:superView];
            complete();
        });
    }
}




- (instancetype)initWithToastConfiger:(TSToastConfiger *)configer{
    self = [super init];
    if (self) {
        _configer = configer;
        [self initData];
        [self initViews];
        [self fillinValues];
        [self layoutViews];
        [self showLoading];
    }
    return self;
}

- (void)initData{
    
}

- (void)initViews{
    if (_configer && _configer.superView) {
        [self addSubview:self.toastBackGroundView];
        if (_configer.toastType == eTSToastText) {
            [self.toastBackGroundView addSubview:self.toastLabel];
        }else if (_configer.toastType == eTSToastLoading){
            [self.toastBackGroundView addSubview:self.toastIndicatorView];
        }else if (_configer.toastType == eTSToastTextLoading){
            [self.toastBackGroundView addSubview:self.toastIndicatorView];
            [self.toastBackGroundView addSubview:self.toastLabel];
        } else{
        }
        [_configer.superView addSubview:self];
    }
}

- (void)fillinValues{
    if (_configer && _configer.superView) {
        if (_configer.toastType == eTSToastText||
            _configer.toastType == eTSToastTextLoading) {
            self.toastLabel.text = _configer.toastContent;
            self.toastLabel.font = _configer.textFont;
            self.toastLabel.textColor = _configer.textColor?_configer.textColor:[UIColor whiteColor];
        }
    }
}

- (void)layoutViews{
    
    if (_configer && _configer.superView) {
        self.frame = CGRectMake(0, 0, CGRectGetWidth(_configer.superView.frame), CGRectGetHeight(_configer.superView.frame));

        if (_configer.toastType == eTSToastText) {
            CGFloat backgroundHorMargin = 16;
            CGFloat textHorMargin = 28;
            CGFloat textVerMargin = 12;
            CGFloat maxWidth = self.frame.size.width-2*backgroundHorMargin-2*textHorMargin;
            
            CGSize textSize = [self.toastLabel.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_configer.textFont} context:nil].size;
            
            CGFloat backgroundWidth = textSize.width+2*textHorMargin;
            if (backgroundWidth<80) {
                backgroundWidth = 80;
            }

            CGFloat backgroundHeight = textSize.height+2*textVerMargin;
            
            if (_configer.toastPosition == eTSToastPositionMiddle) {
                self.toastBackGroundView.frame =CGRectMake((CGRectGetWidth(self.frame)-backgroundWidth)/2, (CGRectGetHeight(self.frame)-backgroundHeight)/2, backgroundWidth, backgroundHeight);
                self.toastLabel.frame = CGRectMake(textHorMargin,textVerMargin , textSize.width, textSize.height);
            }else if (_configer.toastPosition == eTSToastPositionTop){
                self.toastBackGroundView.frame =CGRectMake((CGRectGetWidth(self.frame)-backgroundWidth)/2, _configer.positionMargin, backgroundWidth, backgroundHeight);
                self.toastLabel.frame = CGRectMake(textHorMargin,textVerMargin , textSize.width, textSize.height);
            }else{
                self.toastBackGroundView.frame =CGRectMake((CGRectGetWidth(self.frame)-backgroundWidth)/2, (CGRectGetHeight(self.frame)-backgroundHeight-_configer.positionMargin), backgroundWidth, backgroundHeight);
                self.toastLabel.frame = CGRectMake(textHorMargin,textVerMargin , textSize.width, textSize.height);
            }
            
            self.toastBackGroundView.layer.cornerRadius = _configer.cornerRadius>0?_configer.cornerRadius:(backgroundHeight/2.0f);
         
        }else if (_configer.toastType == eTSToastTextLoading){
            
        
            CGFloat backgroundHorMargin = 16;
            CGFloat textHorMargin = 28;
            CGFloat textVerMargin = 12;
            CGFloat space = 8;
            CGFloat maxWidth = self.frame.size.width-2*backgroundHorMargin-2*textHorMargin;
            CGSize textSize = [self.toastLabel.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_configer.textFont} context:nil].size;
            

            CGFloat backgroundWidth = textSize.width+2*textHorMargin;
            if (backgroundWidth<80) {
                backgroundWidth = 80;
            }

            CGFloat backgroundWoH = 60;
            self.toastIndicatorView.frame = CGRectMake(0, textVerMargin, backgroundWoH, backgroundWoH);
            [self.toastIndicatorView sizeToFit];
            self.toastIndicatorView.frame = CGRectMake((backgroundWidth-CGRectGetWidth(self.toastIndicatorView.frame))/2, textVerMargin, CGRectGetWidth(self.toastIndicatorView.frame), CGRectGetHeight(self.toastIndicatorView.frame));

            self.toastLabel.frame = CGRectMake((backgroundWidth-textSize.width)/2,CGRectGetMaxY(self.toastIndicatorView.frame)+space , textSize.width, textSize.height);

            CGFloat backgroundHeight = textVerMargin + CGRectGetHeight(self.toastIndicatorView.frame)+space+ textSize.height+textVerMargin;


            self.toastBackGroundView.frame =CGRectMake((CGRectGetWidth(self.frame)-backgroundWidth)/2, (CGRectGetHeight(self.frame)-backgroundHeight)/2, backgroundWidth, backgroundHeight);
            self.toastBackGroundView.layer.cornerRadius = _configer.cornerRadius>0?_configer.cornerRadius:kDefaultCornerRadius;
            
        }else if (_configer.toastType == eTSToastLoading){
            CGFloat backgroundWoH = 60;
            
            self.toastBackGroundView.frame =CGRectMake((CGRectGetWidth(self.frame)-backgroundWoH)/2, (CGRectGetHeight(self.frame)-backgroundWoH)/2, backgroundWoH, backgroundWoH);
            self.toastIndicatorView.frame = CGRectMake(0, 0, backgroundWoH, backgroundWoH);
            self.toastBackGroundView.center = self.center;
            
            self.toastBackGroundView.layer.cornerRadius = _configer.cornerRadius>0?_configer.cornerRadius:kDefaultCornerRadius;

        }
    }
    
}

- (void)showLoading{
    if (_configer.toastType == eTSToastLoading||
        _configer.toastType == eTSToastTextLoading){
        [self startAnimation];
    }
}

- (void)startAnimation{
    if (self.toastIndicatorView) {
        [self.toastIndicatorView startAnimating];
    }
}

- (void)stopAnimation{
    if (_configer.toastType == eTSToastLoading||
        _configer.toastType == eTSToastTextLoading){
        if (_toastIndicatorView) {
            [self.toastIndicatorView stopAnimating];
        }
    }
}


- (UIView *)toastBackGroundView{
    if (!_toastBackGroundView) {
        _toastBackGroundView = [[UIView alloc]init];
        _toastBackGroundView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    }
    return _toastBackGroundView;
}

- (UILabel *)toastLabel{
    if (!_toastLabel) {
        _toastLabel = [[UILabel alloc]init];
        _toastLabel.textColor = [UIColor whiteColor];
        _toastLabel.font = _configer.textFont;
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.numberOfLines = 0;
    }
    return _toastLabel;
}


- (UIActivityIndicatorView *)toastIndicatorView{
    if (!_toastIndicatorView) {
        _toastIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _toastIndicatorView.hidesWhenStopped = YES;
        _toastIndicatorView.color = [UIColor whiteColor];
    }
    return _toastIndicatorView;
}

@end
