//
//  TSTableViewCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/2.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSTableViewCell.h"

@interface TSTableViewCell ()

@property (nonatomic,strong) UILabel * cellNameLabe;

@property (nonatomic,strong) TSValueModel * cellModel;
@end

@implementation TSTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initData];
        [self initViews];
        [self fullValues];
        [self layoutViews];

    }
    return self;
}

- (void)initData{
    
}

- (void)initViews{
    
    [self.contentView addSubview:self.cellNameLabe];
}

- (void)fullValues{
}

- (void)layoutViews{
    [self setNeedsLayout];
}

- (void)reloadCellWithModel:(TSValueModel *)cellModel{

    _cellModel = cellModel;
    self.cellNameLabe.text = cellModel.valueName;
    [self setNeedsLayout];
}


- (void)reloadCellWithName:(NSString *)name{
    self.cellNameLabe.text = name;
    [self setNeedsLayout];
}


- (UILabel *)cellNameLabe{
    if (!_cellNameLabe) {
        _cellNameLabe = [[UILabel alloc]init];
        _cellNameLabe.textColor = [UIColor blackColor];
        _cellNameLabe.textAlignment = NSTextAlignmentLeft;
        _cellNameLabe.numberOfLines = 0;
        _cellNameLabe.font = [UIFont systemFontOfSize:17.0];

    }
    return _cellNameLabe;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat horizontalPadding = 32.0f; // 左右各16
    CGFloat x = 16.0f;
    CGFloat availableWidth = CGRectGetWidth(self.contentView.bounds) - horizontalPadding;
    if (availableWidth < 0) {
        availableWidth = 0;
    }
    CGSize fitSize = [self.cellNameLabe sizeThatFits:CGSizeMake(availableWidth, CGFLOAT_MAX)];
    CGFloat labelHeight = fitSize.height;
    CGFloat contentHeight = CGRectGetHeight(self.contentView.bounds);
    CGFloat y = (contentHeight - labelHeight) / 2.0f;
    if (y < 0) { y = 0; }
    self.cellNameLabe.frame = CGRectMake(x, y, availableWidth, labelHeight);
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
