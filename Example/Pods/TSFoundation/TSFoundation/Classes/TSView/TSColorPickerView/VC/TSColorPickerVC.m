//
//  TSColorPickerVC.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/6.
//

#import "TSColorPickerVC.h"
#import "MSColorWheelView.h"
#import "MSColorUtils.h"
#import "TSDialContainerView.h"

typedef void(^PickColorBlock)(UIColor *color);

@interface TSColorPickerVC ()


@property (nonatomic,strong) PickColorBlock  pickColorBlock ;

@property (nonatomic,weak) UIView * displayView;

@end

@implementation TSColorPickerVC


- (instancetype)initWithPickColorBlock:(void(^)(UIColor * pickColor))pickColorBlock displayView:(UIView *)displayView{
    self = [super init];
    if (self) {
        _pickColorBlock = pickColorBlock;
        _displayView = displayView;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initViews];
    [self layoutViews];

    
    // Do any additional setup after loading the view.
}

- (void)initData{
    self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.68];
    
}

- (void)initViews{
    if (self.displayView) {
        [self.view addSubview:self.displayView];
    }
    
}

- (void)layoutViews{
    
    if (self.displayView) {
        
        CGFloat imageWidth = 150;
        CGFloat imageHeight =150;
        self.displayView.frame = CGRectMake(([TSFrame screenWidth]-imageWidth)/2, [TSFrame safeAreaTop]+44+20, imageWidth,imageHeight);
        self.displayView.layer.borderColor = [TSColor colorwithHexString:@"#D4D5D6"].CGColor;
        self.displayView.layer.borderWidth = 4;
        self.displayView.layer.cornerRadius = imageWidth/2.0f;
        self.displayView.layer.masksToBounds = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    __weak typeof(self)weakSelf = self;
    [TSDialContainerView showContainOnView:self.view cancelBlock:^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf dismissWhenCancel:YES pickColor:nil];
    } sureBlock:^(UIColor * _Nonnull color) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf dismissWhenCancel:NO pickColor:color];
    }];
}

-(void)dismissWhenCancel:(BOOL)isCancel pickColor:(UIColor *)pickColor{
    [self dismissViewControllerAnimated:YES completion:^{
        if (!isCancel && pickColor) {
            if (self.pickColorBlock) {
                self.pickColorBlock(pickColor);
            }
        }
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
