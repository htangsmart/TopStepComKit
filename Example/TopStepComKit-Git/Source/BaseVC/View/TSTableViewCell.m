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
    
    self.cellNameLabe.frame = CGRectMake(16, 0, self.frame.size.width-32, CGFLOAT_MAX);
    [self.cellNameLabe sizeToFit];
    self.cellNameLabe.frame = CGRectMake(15, (55-CGRectGetHeight(self.cellNameLabe.frame))/2, self.frame.size.width-32, CGRectGetHeight(self.cellNameLabe.frame));
}

- (void)reloadCellWithModel:(TSValueModel *)cellModel{

    _cellModel = cellModel;
    self.cellNameLabe.text = cellModel.valueName;
    [self layoutViews];
}


- (void)reloadCellWithName:(NSString *)name{
    self.cellNameLabe.text = name;
    [self layoutViews];
}


- (UILabel *)cellNameLabe{
    if (!_cellNameLabe) {
        _cellNameLabe = [[UILabel alloc]init];
        _cellNameLabe.textColor = [UIColor blackColor];
        _cellNameLabe.textAlignment = NSTextAlignmentLeft;
        _cellNameLabe.numberOfLines = 0;
    }
    return _cellNameLabe;
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
