//
//  TSBaseVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/10.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBaseVC.h"

@interface TSBaseVC ()

@end

@implementation TSBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
        
    [self initData];
    [self setupViews];
    [self layoutViews];
}

- (void)initData{
    
    self.view.backgroundColor = [UIColor colorWithRed:246/255.0f green:246/255.0f blue:246/255.0f alpha:1.0f];
}


- (void)setupViews{
    [self.view addSubview:self.sourceTableview];
}

- (void)layoutViews{
    self.sourceTableview.frame = CGRectMake(0, 64, self.view.frame.size.width, CGRectGetHeight(self.view.frame)-64);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndefier = @"kTSTableViewCell";
    TSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndefier];
    if (cell == nil) {
        cell = [[TSTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndefier];
    }
    if (self.sourceArray.count>indexPath.row) {
        [cell reloadCellWithName:[self cellNameAtIndexPath:indexPath]];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (NSString *)cellNameAtIndexPath:(NSIndexPath *)cellIndexPath{
    TSValueModel *model = [self.sourceArray objectAtIndex:cellIndexPath.row];
    if (model && [model isKindOfClass:[TSValueModel class]]) {
        return model.valueName;
    }
    return @"";
}


- (UITableView *)sourceTableview{
    if (!_sourceTableview) {
        _sourceTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        _sourceTableview.delegate = self;
        _sourceTableview.dataSource = self;
        _sourceTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _sourceTableview.backgroundColor = [UIColor colorWithRed:246/255.0f green:246/255.0f blue:246/255.0f alpha:1.0f];
    }
    return _sourceTableview;;
}

// 显示蓝牙未授权提示
- (void)showAlertWithMsg:(NSString *)errorMsg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                 message:errorMsg
                                                          preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
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
