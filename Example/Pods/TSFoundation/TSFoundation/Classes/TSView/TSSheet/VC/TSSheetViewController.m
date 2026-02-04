//
//  TSSheetViewController.m
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import "TSSheetViewController.h"

#import "TSSheetContainerView.h"

@interface TSSheetViewController ()<TSSheetContainerViewDelegate>

@property (nonatomic,strong) TSSheetContainerView * sheetView;

@end

@implementation TSSheetViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initViews];
    [self layoutViews];
    [self requestValues];
}
- (void)initData{
    
    self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
}

- (void)initViews{
    
    [self.view addSubview:self.sheetView];
}

- (void)layoutViews{
    
}

- (void)requestValues{
    [self.sheetView reloadContainerWithActions:self.actions cancelAction:self.cancelAction];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.sheetView show];
}

- (void)containerDismiss:(TSSheetContainerView *)container{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}




- (TSSheetContainerView *)sheetView{
    if (!_sheetView) {
        _sheetView = [[TSSheetContainerView alloc]init];
        _sheetView.delegate = self;
    }
    return _sheetView;
}

@end
