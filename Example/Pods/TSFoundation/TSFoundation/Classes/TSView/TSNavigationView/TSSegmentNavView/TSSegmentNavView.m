//
//  TSDialHomeNavView.m
//  TSDial
//
//  Created by 磐石 on 2024/8/1.
//

#import "TSSegmentNavView.h"

#import "TSFont.h"
#import "TSFrame.h"
#import "TSShake.h"
#import "TSLoading.h"
#import "TSChecker.h"
#import "TSAttributedString.h"
#import "TSGradientLayerButton.h"
#import "UIImage+Bundle.h"
#import "NSBundle+TSFoundation.h"

@implementation TSSegmentAction
- (instancetype)initWithActionName:(NSString *)actionName actionBlock:(TSActionBlock)actionBlock
{
    if(self = [super init]){
        _actionName = actionName;
        _actionBlock = actionBlock;
    }
    return self;
}

- (instancetype)initWithActionName:(NSString *)actionName actionEvent:(SEL)actionEvent{
    if(self = [super init]){
        _actionName = actionName;
        _actionEvent = actionEvent;
    }
    return self;

}

@end



@interface TSSegmentNavView ()

@property (nonatomic,strong) UIButton * backButton;

@property (nonatomic,strong) UIScrollView * backView;

@property (nonatomic,strong) NSMutableArray * allActions;

@property (nonatomic,strong) NSMutableArray * allButtons;

@property (nonatomic,strong) UIView * selectedColorView;


@end

@implementation TSSegmentNavView

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
    
}

- (void)initViews{
    
    [self addSubview:self.backButton];
    [self addSubview:self.backView];
}

- (void)layoutViews{
    
    self.backButton.frame = CGRectMake(6, [TSFrame safeAreaTop], 44, 44);
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self reLayoutAllSubViews];
}

- (void)selectedSegmentAtIndex:(NSInteger)index{
    if (self.allButtons && self.allButtons.count>index) {
        [self selectedButton:[self.allButtons objectAtIndex:index]];
    }
}

- (void)addActions:(NSArray *)actions{
    if (actions && actions.count>0) {
        [self.allActions addObjectsFromArray:actions];
    }
    [self reLayoutViews];
}

- (void)addAction:(NSString *)actionName actionEvent:(SEL)actionEvent{
    
    TSSegmentAction *action  =  [[TSSegmentAction alloc] initWithActionName:actionName actionEvent:actionEvent];
    if (action) {[self.allActions addObject:action];}
    [self reLayoutViews];
}


- (void)addAction:(NSString *)actionName action:(void(^)(void))actionBlock{

    TSSegmentAction *action  =  [[TSSegmentAction alloc] initWithActionName:actionName actionBlock:actionBlock];
    if (action) {[self.allActions addObject:action];}
    [self reLayoutViews];
}

- (void)reLayoutViews{
    [self.backView removeSubviews];
    [self.allButtons removeAllObjects];
    [self addAllSubViews];
    [self reLayoutAllSubViews];
}

- (void)addAllSubViews{
    
    for (TSSegmentAction *action in self.allActions) {
        TSGradientLayerButton *button = [TSGradientLayerButton defaultGradientLayerButton];
        [button setTitle:action.actionName forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[TSColor colorwithHexString:@"#555555"] forState:UIControlStateNormal];
        [button setTitleColor:[TSColor colorwithHexString:@"#FFFFFF"] forState:UIControlStateSelected];
        button.titleLabel.font = [TSFont TSFontPingFangMediumWithSize:12];
        [button showGradientLayer:NO];
        [self.allButtons addObject:button];
        [self.backView addSubview:button];
    }
}

- (void)reLayoutAllSubViews{
    CGFloat maxX = 4;
    CGFloat maxY = 4;
    CGFloat height = 0;
    for (TSGradientLayerButton *button in self.allButtons) {
        CGSize buttonSize = [button.currentTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[TSFont TSFontPingFangMediumWithSize:12]} context:nil].size;
        button.frame = CGRectMake(maxX, maxY, buttonSize.width+24, buttonSize.height+14);
        maxX+=button.width;
        height = button.height;
    }
    maxX+=4;
    CGFloat maxBackViewWidth = self.width-88;
    CGFloat maxBackViewHeight = height+8;
    if (maxX>(maxBackViewWidth)) {
        self.backView.frame = CGRectMake(44, self.height-maxBackViewHeight-5, maxBackViewWidth, maxBackViewHeight);
        self.backView.contentSize = CGSizeMake(maxX, maxBackViewHeight);
    }else{
        self.backView.frame = CGRectMake((self.width-maxX)/2, self.height-maxBackViewHeight-5, maxX, maxBackViewHeight);
        self.backView.contentSize = CGSizeMake(maxX, maxBackViewHeight);
    }
    self.backView.layer.cornerRadius = self.backView.height/2.0f;
}

- (void)actionButtonEvent:(UIButton *)sender{
    
    [self selectedButton:sender];
    [self postSegmentNavDelegate:sender];
}

- (void)selectedButton:(UIButton *)targetButton{
    if (targetButton) {
        for (TSGradientLayerButton *button in self.allButtons) {
            BOOL isCurrent = button==targetButton;
            button.selected = isCurrent;
            [button showGradientLayer:isCurrent];
        }
    }
}

- (void)postSegmentNavDelegate:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tsSegment:didSelectedAtIndex:)]) {
        [self.delegate tsSegment:self didSelectedAtIndex:[self.allButtons indexOfObject:sender]];
    }
}

- (void)backButtonEvent:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(returnBack)]) {
        [self.delegate returnBack];
    }
}

- (UIButton *)backButton{
    
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"icon_return_nol_black" inBundle:[NSBundle foundationBundle]] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIScrollView *)backView{
    if (!_backView) {
        _backView = [UIScrollView new];
        _backView.backgroundColor = [TSColor colorwithHexString:@"#F2F2F2"];
    }
    return _backView;
}

- (NSMutableArray *)allActions{
    if (!_allActions) {
        _allActions = [NSMutableArray new];
    }
    return _allActions;
}

- (NSMutableArray *)allButtons{
    if (!_allButtons) {
        _allButtons = [NSMutableArray new];
    }
    return _allButtons;
}


@end
