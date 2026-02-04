//
//  TSLoading.m
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/29.
//

#import "TSLoading.h"
#import "TSFont.h"
#import "TSToast.h"
#import "LOTAnimationView.h"
#import "JLPhoneUISetting.h"
#import "NSBundle+TSFoundation.h"
@interface TSLoadingAnimationView : UIView


@property (nonatomic,strong) LOTAnimationView *gifView ;
@end

@implementation TSLoadingAnimationView

- (void)dealloc
{
    [self.gifView stop];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
        [self initViews];
        [self layoutViews];
        [self loadValue];
    }
    return self;
}

- (void)initData{}

- (void)initViews{
    [self addSubview:self.gifView];
}

- (void)layoutViews{
    self.gifView.frame = CGRectMake(0, 0, 100, 100);
}

- (void)loadValue{
    [self.gifView play];
}

- (CGSize)intrinsicContentSize{
    return CGSizeMake(100, 100);
}

- (LOTAnimationView *)gifView{
    if (!_gifView) {
        _gifView = [LOTAnimationView animationWithFilePath:[self imageJson]];
        _gifView.loopAnimation = YES;
        _gifView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _gifView;
}

- (NSString *)imageJson{
    return [[NSBundle foundationBundle] pathForResource:@"image_loading_ani" ofType:@"json"];
}

@end


@implementation TSLoading



+ (void)showImageLoadingOnSuperView:(UIView *)superView {
        
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    hud.backgroundView.blurEffectStyle = UIBlurEffectStyleDark;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7];
    hud.bezelView.layer.cornerRadius = 16;
    hud.bezelView.frame = CGRectMake(hud.bezelView.frame.origin.x,hud.bezelView.frame.origin.y , 100, 100);
    hud.mode = MBProgressHUDModeCustomView;
        
    hud.customView = [[TSLoadingAnimationView alloc]init];
    hud.label.text = kJL_TXT("生成中，请稍后");
    hud.label.textColor = [UIColor whiteColor];
    hud.label.font = [TSFont TSFontPingFangSemiboldWithSize:12];
}


+ (void)showImageLoadingOnSuperView:(UIView *)superView  text:(nonnull NSString *)loadingText afterDelay:(CGFloat)delay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:superView animated:YES];
    hud.backgroundView.blurEffectStyle = UIBlurEffectStyleDark;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7];
    hud.bezelView.layer.cornerRadius = 16;
    hud.bezelView.frame = CGRectMake(hud.bezelView.frame.origin.x,hud.bezelView.frame.origin.y , 100, 100);
    hud.mode = MBProgressHUDModeCustomView;
        
    hud.customView = [[TSLoadingAnimationView alloc]init];
    hud.label.text = loadingText;//kJL_TXT("生成中，请稍后");
    hud.label.textColor = [UIColor whiteColor];
    hud.label.font = [TSFont TSFontPingFangSemiboldWithSize:12];
    
    [hud hideAnimated:YES afterDelay:delay];

}


+ (void)dismissImageLoadingOnSuperView:(UIView *)superView {
    [MBProgressHUD hideHUDForView:superView animated:YES];

}
+ (void)dismissImageLoadingOnSuperView:(UIView *)superView afterDelay:(CGFloat)delay{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:superView animated:YES];
    });
}
+ (void)dismissImageLoadingOnSuperView:(UIView *)superView afterDelay:(CGFloat)delay complete:(void(^)(void))complete{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:superView animated:YES];
        if (complete) {complete();}
    });
}










+ (void)showLoadingOnSuperView:(UIView *)superView {
    

    [TSToast showLoadingOnView:superView];
}

+ (void)showLoadingOnSuperView:(UIView *)superView  afterDelay:(CGFloat)delay {
    
    [TSToast showLoadingOnView:superView dismissAfterDelay:delay];
}


+ (void)showLoadingOnSuperView:(UIView *)superView text:(NSString *)loadingText{
    [TSToast showLoadingOnView:superView text:loadingText];

}

+ (void)showLoadingOnSuperView:(UIView *)superView text:(NSString *)loadingText afterDelay:(CGFloat)delay{
    
    [TSToast showLoadingOnView:superView text:loadingText dismissAfterDelay:delay];
}


+ (void)dismissLoadingOnSuperView:(UIView *)superView {
    [TSToast dismissLoadingOnView:superView];
}

+ (void)dismissLoadingOnSuperView:(UIView *)superView afterDelay:(CGFloat)delay{
    [TSToast dismissLoadingOnView:superView afterDelay:delay];
}

+ (void)dismissLoadingOnSuperView:(UIView *)superView afterDelay:(CGFloat)delay complete:(void (^)(void))complete{
    
    [TSToast dismissLoadingOnView:superView afterDelay:delay complete:^{
        complete();
    }];
}



@end
