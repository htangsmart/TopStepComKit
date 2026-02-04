//
//  TSSheetContainerView.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import "TSSheetContainerView.h"
#import "TSSheetContainerCell.h"

#define kActionHeight 56
#define kMarginBottom 12

@interface TSSheetContainerView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * sheetTableView;

@property (nonatomic,strong) UIButton * cancelButton;

@property (nonatomic,strong) NSArray * actions;

@property (nonatomic,strong) TSSheetAction * cancelAction;
@end

@implementation TSSheetContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
        [self initViews];
        [self layoutViews];
    }
    return self;
}

- (void)initData{
    self.backgroundColor = [UIColor clearColor];
}

- (void)initViews{
    [self addSubview:self.sheetTableView];
    [self addSubview:self.cancelButton];
}

- (void)layoutViews{
    CGFloat maxSheetHeight = [self sheetViewHeight];
    self.frame = CGRectMake(0, [TSFrame screenHeight], [TSFrame screenWidth], maxSheetHeight);
    self.sheetTableView.frame = CGRectMake(12, 12, self.width-24, self.actions.count*kActionHeight);
    self.cancelButton.frame = CGRectMake(12, self.sheetTableView.maxY+8, self.width-24, 56);
}

- (void)reloadContainerWithActions:(NSArray *)actions cancelAction:(TSSheetAction *)cancelAction{
    
    _actions = actions;
    _cancelAction = cancelAction;
    [self.sheetTableView reloadData];
    
    [self.cancelButton setTitle:self.cancelAction.actionName forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [TSFont TSFontPingFangMediumWithSize:15];
    [self layoutViews];
}

- (void)show{
    self.y = [TSFrame screenHeight];
    [UIView animateWithDuration:0.35 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = [TSFrame screenHeight]-[self sheetViewHeight];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissComplete:(void(^)(void))complete{
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = [TSFrame screenHeight];
    } completion:^(BOOL finished) {
        complete();
    }];
}

- (void)postDelegateDismiss{
    if (self.delegate && [self.delegate respondsToSelector:@selector(containerDismiss:)]) {
        [self.delegate containerDismiss:self];
    }
}

- (CGFloat)sheetViewHeight{
    CGFloat maxHeight = 12;
    if (self.actions.count>0) {
        maxHeight += (self.actions.count*kActionHeight);
    }
    if (self.cancelAction) {
        maxHeight+=8;
        maxHeight += kActionHeight;
    }
    maxHeight+= [TSFrame safeAreaBottom];
    maxHeight+= kMarginBottom;
    return maxHeight;
}


- (void)cancelButtonEvent:(UIButton *)sender{
    __weak typeof(self)weakSelf = self;
    [self dismissComplete:^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf postDelegateDismiss];
        [strongSelf perforActionBlock:strongSelf.cancelAction];
    }];
}
- (void)perforActionBlock:(TSAlertAction *)action{
    if (action && action.actionBlock) {
        action.actionBlock(nil);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.actions.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kActionHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndefier = @"kTSSheetContainerCell";
    TSSheetContainerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndefier];
    if (cell == nil) {
        cell = [[TSSheetContainerCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndefier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0) {
        [cell reloadContainerCellWithAction:[self.actions objectAtIndex:indexPath.row]];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0 ) {
        __weak typeof(self)weakSelf = self;
        [self dismissComplete:^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf postDelegateDismiss];
            if (strongSelf.actions.count>indexPath.row) {
                [strongSelf perforActionBlock:[strongSelf.actions objectAtIndex:indexPath.row]];
            }
        }];
    }
}

- (UITableView *)sheetTableView{
    if (!_sheetTableView) {
        _sheetTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) style:UITableViewStylePlain];
        _sheetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _sheetTableView.delegate = self;
        _sheetTableView.dataSource = self;
        _sheetTableView.layer.cornerRadius = 12.0f;
        _sheetTableView.layer.masksToBounds = YES;
        _sheetTableView.bounces = NO;
    }
    return _sheetTableView;;
}


- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton addTarget:self action:@selector(cancelButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.layer.cornerRadius = 12.0f;
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.backgroundColor = [UIColor whiteColor];
    }
    return _cancelButton;
}


@end
