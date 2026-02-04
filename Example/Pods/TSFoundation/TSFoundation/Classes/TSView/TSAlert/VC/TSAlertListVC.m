//
//  TSAlertListVC.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/4.
//

#import "TSAlertListVC.h"
#import "TSAlertListMusicCell.h"
#import "UIView+CBFrameHelpers.h"

@interface TSAlertListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * alertTableView;

@end

@implementation TSAlertListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)initViews{
    [super initViews];
    [self.backView addSubview:self.alertTableView];

}

- (void)setUpAllViews{
    
    [super setUpAllViews];
    
    self.alertTitleLabel.text = self.configer.title;
    self.alertTitleLabel.textColor = self.configer.titleColor;
    self.alertTitleLabel.font =self.configer.titleFont;
    self.alertTitleLabel.textAlignment = self.configer.titleTextAlignment;

    self.alertTableView.backgroundColor = self.configer.contentBackgroundColor;
    self.alertTableView.layer.cornerRadius = self.configer.contentCornerRadius;
    self.alertTableView.layer.masksToBounds = YES;

}

- (void)layoutViews{
    [super layoutViews];
    
    self.alertTitleLabel.frame = CGRectMake(10, 24, (CGRectGetWidth(self.backView.frame)-20), 44);
    [self.alertTitleLabel sizeToFit];
    self.alertTitleLabel.frame = CGRectMake(10, 24, (CGRectGetWidth(self.backView.frame)-20), self.alertTitleLabel.frame.size.height);

    CGFloat maxHeight = self.configer.cellHeight*(self.configer.alertItemArray.count>3?3:self.configer.alertItemArray.count);
   
    self.alertTableView.frame = CGRectMake(10, self.alertTitleLabel.maxY+ CGRectGetHeight(self.alertTitleLabel.frame)>0?(self.alertTitleLabel.maxY+15):self.alertTitleLabel.frame.origin.y, (CGRectGetWidth(self.backView.frame)-20), maxHeight);
}

- (CGFloat)maxY{
    return CGRectGetMaxY(self.alertTableView.frame);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.configer.alertItemArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.configer.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndefier = @"kTSAlertListMusicCell";
    TSAlertListMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndefier];
    if (cell == nil) {
        cell = [[TSAlertListMusicCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndefier];
    }
    if (self.configer.alertItemArray.count>indexPath.row) {
        [cell reloadItemCellWith:[self.configer.alertItemArray objectAtIndex:indexPath.row]];
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (UITableView *)alertTableView{
    if (!_alertTableView) {
        _alertTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        _alertTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _alertTableView.delegate = self;
        _alertTableView.dataSource = self;
    }
    return _alertTableView;;
}




@end
