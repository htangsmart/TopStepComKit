//
//  TSNothingView.m
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/25.
//

#import "TSNothingView.h"
#import "TSFont.h"
#import "TSColor.h"
#import "TSChecker.h"
#import "TSFrame.h"
#import "UIView+CBFrameHelpers.h"
#import "UIImage+Bundle.h"
#import "NSBundle+TSFoundation.h"
#import "TSGradientLayerButton.h"

@interface TSNothingView ()

@property (nonatomic,strong) UIImageView * nothingImageView;

@property (nonatomic,strong) UILabel * nothingDescLabel;

@property (nonatomic,strong) UILabel * nothingMoreDescLabel;

@property (nonatomic,strong) TSGradientLayerButton * refreshButton;

@property (nonatomic,strong)  NSString *nothingImageName ;

@property (nonatomic,strong)  NSString *nothingDesc ;

@property (nonatomic,strong)  NSString *nothingSubDesc ;

@property (nonatomic,strong)  NSAttributedString *nothingAttributeSubDesc ;

@property (nonatomic,assign) TSNothingType nothingType;

@end

@implementation TSNothingView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initUI];
        [self fillInValues];
        [self layoutViews];
    }
    return self;
}

- (instancetype)initWithDesc:(NSString *)nothingDesc
{
    self = [super init];
    if (self) {
        _nothingDesc = nothingDesc;
        [self initUI];
        [self fillInValues];
        [self layoutViews];
    }
    return self;
}

- (instancetype)initWithNothingImageName:(NSString *)imageName desc:(NSString *)nothingDesc
{
    self = [super init];
    if (self) {
        
        _nothingDesc = nothingDesc;
        _nothingImageName = imageName;
        [self initUI];
        [self fillInValues];
        [self layoutViews];
    }
    return self;
}

- (instancetype)initWithNothingImageName:(NSString *)imageName desc:(NSString *)nothingDesc subDesc:(NSString *)subDesc{
    self = [super init];
    if (self) {
        
        _nothingDesc = nothingDesc;
        _nothingImageName = imageName;
        _nothingSubDesc = subDesc;
        
        [self initUI];
        [self fillInValues];
        [self layoutViews];
    }
    return self;

}

- (void)reloadNothingViewWithImageName:(NSString *)imageName desc:(NSString *)nothingDesc subDesc:(NSAttributedString *)attributeSubDesc{
    _nothingDesc = nothingDesc;
    _nothingImageName = imageName;
    _nothingAttributeSubDesc = attributeSubDesc;
    [self fillInValues];
    [self layoutViews];
}

- (void)reloadWithNothingType:(TSNothingType)nothingType{
    _nothingType = nothingType;
    [self fillInValues];
    [self layoutViews];
}

- (void)reloadWithNothingType:(TSNothingType)nothingType imageName:(NSString *)imageName desc:(NSString *)nothingDesc subDesc:(NSAttributedString *)attributeSubDesc{
    _nothingType = nothingType;
    _nothingDesc = nothingDesc;
    _nothingImageName = imageName;
    _nothingAttributeSubDesc = attributeSubDesc;
    [self fillInValues];
    [self layoutViews];
}


- (void)initUI{
    
    [self addSubview:self.nothingImageView];
    [self addSubview:self.nothingDescLabel];
    [self addSubview:self.nothingMoreDescLabel];

}

- (void)fillInValues{
    
    if (![TSChecker isEmptyString:self.nothingImageName]) {
        [_nothingImageView setImage:[UIImage imageNamed:self.nothingImageName inBundle:[NSBundle foundationBundle]]];
    }else{
        [_nothingImageView setImage:[UIImage imageNamed:@"contact_nothing_data" inBundle:[NSBundle foundationBundle]]];
    }
    
    if (_nothingType == eTSNothingNoData) {
        
        self.nothingDescLabel.hidden = NO;
        self.nothingDescLabel.text = [TSChecker isEmptyString:self.nothingDesc]?kJL_TXT("暂无数据"):self.nothingDesc;
        
        if (self.nothingAttributeSubDesc) {
            self.nothingMoreDescLabel.hidden = NO;
            self.nothingMoreDescLabel.attributedText = self.nothingAttributeSubDesc;
        }else{
            if (![TSChecker isEmptyString:self.nothingSubDesc]) {
                self.nothingMoreDescLabel.hidden = NO;
                self.nothingMoreDescLabel.text = self.nothingSubDesc;
            }else{
                self.nothingMoreDescLabel.hidden = YES;
                self.nothingMoreDescLabel.text = @"";
            }
        }
    }else{
        
        
    }
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self layoutViews];
}

- (void)layoutViews{
    if (_nothingType == eTSNothingNoData) {
        if ([self showMoreLabel]) {
            [self layoutWithMoreLabel];
        }else{
            [self layoutWithoutMoreLabel];
        }
    }else{
        [self layoutWithNetError];
    }
}

- (BOOL)showMoreLabel{
    if (![TSChecker isEmptyString:self.nothingSubDesc] && self.nothingMoreDescLabel.hidden == NO) {
        return YES;
    }
    return NO;
}

- (void)layoutWithMoreLabel{
    CGFloat itemSpace = 12;
    
    self.nothingDescLabel.frame = CGRectMake(20, 0, self.frame.size.width-40,[TSFrame screenHeight]);
    [self.nothingDescLabel sizeToFit];
    
    self.nothingMoreDescLabel.frame = CGRectMake(20, 0, self.frame.size.width-40,[TSFrame screenHeight]);
    [self.nothingMoreDescLabel sizeToFit];
    
    CGFloat totalHeight = CGRectGetHeight(self.nothingImageView.frame)+itemSpace+CGRectGetHeight(self.nothingDescLabel.frame)+itemSpace+CGRectGetHeight(self.nothingMoreDescLabel.frame);
    CGFloat oriY = (self.frame.size.height-totalHeight)/2.0f;
    self.nothingImageView.frame = CGRectMake((self.frame.size.width-264)/2.0f, oriY, 264, 181);
   
    self.nothingDescLabel.frame = CGRectMake(20, self.nothingImageView.maxY+24, self.frame.size.width-40, self.nothingDescLabel.frame.size.height);
    
    self.nothingMoreDescLabel.frame = CGRectMake(20, self.nothingDescLabel.maxY+16, self.frame.size.width-40, self.nothingMoreDescLabel.frame.size.height);
}

- (void)layoutWithoutMoreLabel{
    CGFloat itemSpace = 12;
    self.nothingDescLabel.frame = CGRectMake(20, 0, self.frame.size.width-40,[TSFrame screenHeight]);
    [self.nothingDescLabel sizeToFit];
    CGFloat totalHeight = CGRectGetHeight(self.nothingImageView.frame)+itemSpace+CGRectGetHeight(self.nothingDescLabel.frame);
    CGFloat oriY = (self.frame.size.height-totalHeight)/2.0f;
    self.nothingImageView.frame = CGRectMake((self.frame.size.width-264)/2.0f, oriY, 264, 181);
    self.nothingDescLabel.frame = CGRectMake(20, self.nothingImageView.maxY+itemSpace, self.frame.size.width-40, self.nothingDescLabel.frame.size.height);
}

- (void)layoutWithNetError{
    
    CGFloat itemSpace = 12;
    NSString *refreshTitle = [TSChecker isEmptyString:self.nothingDesc]?kJL_TXT("刷新"):self.nothingDesc;
    
    CGSize buttonSize =  [refreshTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[TSFont TSFontPingFangSemiboldWithSize:14]}  context:nil].size;
    
    CGFloat totalHeight = 120+itemSpace+buttonSize.height;

    CGFloat oriY = (self.frame.size.height-totalHeight)/2.0f;
    self.nothingImageView.frame = CGRectMake((self.frame.size.width-120)/2.0f, oriY, 120, 120);
    
    
    self.refreshButton.frame = CGRectMake((self.frame.size.width-buttonSize.width-112)/2.0f, self.nothingImageView.maxY+itemSpace, self.frame.size.width-40, self.nothingDescLabel.frame.size.height);

}


- (void)refreshButtonEvent:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginRefreshing)]) {
        [self.delegate beginRerefresh];
    }
}

- (UIImageView *)nothingImageView{
    if (!_nothingImageView) {
        _nothingImageView = [[UIImageView alloc]init];
    }
    return _nothingImageView;
}

- (UILabel *)nothingDescLabel{
    
    if (!_nothingDescLabel) {
        _nothingDescLabel = [[UILabel alloc]init];
        _nothingDescLabel.font = [TSFont TSFontPingFangRegularWithSize:18];
        _nothingDescLabel.textColor = [TSColor colorwithHexString:@"#999999"];
        _nothingDescLabel.numberOfLines = 0;
        _nothingDescLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nothingDescLabel;
}

- (UILabel *)nothingMoreDescLabel{
    
    if (!_nothingMoreDescLabel) {
        _nothingMoreDescLabel = [[UILabel alloc]init];
        _nothingMoreDescLabel.font = [TSFont TSFontPingFangRegularWithSize:13];
        _nothingMoreDescLabel.textColor = [TSColor colorwithHexString:@"#525252"];
        _nothingMoreDescLabel.numberOfLines = 0;
        _nothingMoreDescLabel.textAlignment = NSTextAlignmentLeft;
        _nothingMoreDescLabel.hidden = YES;
    }
    return _nothingMoreDescLabel;
}


- (TSGradientLayerButton *)refreshButton{
    if (!_refreshButton) {
        _refreshButton = [TSGradientLayerButton defaultGradientLayerButton];
        [_refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _refreshButton.titleLabel.font = [TSFont TSFontPingFangSemiboldWithSize:14];
        [_refreshButton addTarget:self action:@selector(refreshButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshButton;
}

@end
