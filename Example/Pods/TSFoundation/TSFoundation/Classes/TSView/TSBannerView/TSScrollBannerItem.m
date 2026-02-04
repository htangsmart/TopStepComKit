//
//  TSScrollBannerItem.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/11.
//

#import "TSScrollBannerItem.h"
#import "TSColor.h"
#import "TSFont.h"
#import "TSFrame.h"
#import "TSShake.h"
#import "TSLoading.h"
#import "TSChecker.h"
#import "TSAttributedString.h"
//#import<SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImage.h>

@interface TSScrollBannerItem ()

@property (nonatomic,strong) UIView * backView;

@property (nonatomic,strong) UIImageView * bannerImageView;

@property (nonatomic,strong) UILabel * bannerTitleLabel;

@property (nonatomic,strong) UILabel * bannerDescLabel;

@end

@implementation TSScrollBannerItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initViews];
        [self layoutViews];
    }
    return self;
}

- (void)initData{
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backView.backgroundColor = [UIColor whiteColor];

    self.contentView.layer.cornerRadius = 12;
    self.contentView.layer.masksToBounds = YES;
}

- (void)initViews{
    [self.contentView addSubview:self.backView];
    
    [self.backView addSubview:self.bannerImageView];
    [self.backView addSubview:self.bannerTitleLabel];
    [self.backView addSubview:self.bannerDescLabel];
}

- (void)layoutViews{

    self.backView.frame = CGRectMake(0, 0, [TSFrame screenWidth], 156);
    self.bannerImageView.frame = CGRectMake(16, 0, [TSFrame screenWidth]-32, 156);
    self.bannerImageView.layer.cornerRadius = 12;
    self.bannerImageView.layer.masksToBounds = YES;
    
    self.bannerDescLabel.frame = CGRectMake(32, CGRectGetHeight(self.backView.frame)-CGRectGetHeight(self.bannerDescLabel.frame)-16, CGRectGetWidth(self.backView.frame)-64,CGFLOAT_MAX);
    [self.bannerDescLabel sizeToFit];
    self.bannerDescLabel.frame = CGRectMake(32, CGRectGetHeight(self.backView.frame)-CGRectGetHeight(self.bannerDescLabel.frame)-16, CGRectGetWidth(self.backView.frame)-64, CGRectGetHeight(self.bannerDescLabel.frame));

    self.bannerTitleLabel.frame = CGRectMake(32, CGRectGetMinY(self.backView.frame)-CGRectGetHeight(self.bannerTitleLabel.frame)-16, CGRectGetWidth(self.backView.frame)-64,CGFLOAT_MAX);
    [self.bannerTitleLabel sizeToFit];
    self.bannerTitleLabel.frame = CGRectMake(32, CGRectGetMinY(self.bannerDescLabel.frame)-CGRectGetHeight(self.bannerTitleLabel.frame)-16, CGRectGetWidth(self.backView.frame)-64, CGRectGetHeight(self.bannerTitleLabel.frame));
}

- (void)reloadBannerCellWithModel:(TSBannerModel *)bannerModel{

    if (![TSChecker isEmptyString:bannerModel.bannerImageUrl]) {
        [self.bannerImageView sd_setImageWithURL:[NSURL URLWithString:bannerModel.bannerImageUrl]];
    }
    
    [self.bannerTitleLabel setText:bannerModel.bannerTitle];
    [self.bannerDescLabel setText:bannerModel.bannerDesc];
    [self layoutViews];
}


- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]init];
    }
    return _backView;
}

- (UIImageView *)bannerImageView{
    
    if (!_bannerImageView) {
        _bannerImageView = [[UIImageView alloc]init];
        _bannerImageView.backgroundColor = [TSColor colorwithHexString:@"#F2F2F2"];
        _bannerImageView.layer.cornerRadius = 12;
        _bannerImageView.layer.masksToBounds = YES;
    }
    return _bannerImageView;
}

- (UILabel *)bannerTitleLabel{
    if (!_bannerTitleLabel) {
        _bannerTitleLabel = [[UILabel alloc]init];
        _bannerTitleLabel.textColor = [TSColor colorwithHexString:@"#FFFFFF"];
        _bannerTitleLabel.font = [TSFont TSFontPingFangSemiboldWithSize:16];
        _bannerTitleLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _bannerTitleLabel;
}

- (UILabel *)bannerDescLabel{
    if (!_bannerDescLabel) {
        _bannerDescLabel = [[UILabel alloc]init];
        _bannerDescLabel.textColor = [TSColor colorwithHexString:@"#FFFFFF"];
        _bannerDescLabel.font = [TSFont TSFontPingFangRegularWithSize:12];
        _bannerDescLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _bannerDescLabel;
}



@end
