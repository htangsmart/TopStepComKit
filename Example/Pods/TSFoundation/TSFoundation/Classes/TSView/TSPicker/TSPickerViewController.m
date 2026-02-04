//
//  TSPickerViewController.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/25.
//

#import "TSPickerViewController.h"
#import "TSFrame.h"
#import "TSFont.h"
#import "TSColor.h"
#import "TSShake.h"
#define kPickerAnimationTime 0.25

@interface TSPickerRowView ()
@property (nonatomic,strong) UILabel * rowValueLabel;
@end

@implementation TSPickerRowView

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
    [self addSubview:self.rowValueLabel];
}

- (void)layoutViews{}

- (void)reloadRowWithValue:(TSPickerItem *)rowItem{
    
    if (rowItem.value != self.rowValueLabel.text) {
        self.rowValueLabel.text = rowItem.value;
        self.rowValueLabel.font = rowItem.itemFont;
        self.rowValueLabel.textColor = rowItem.itemTextColor;
        [self.rowValueLabel sizeToFit];
        self.rowValueLabel.frame = CGRectMake((CGRectGetWidth(self.frame)-CGRectGetWidth(self.rowValueLabel.frame)-10)/2, (CGRectGetHeight(self.frame)-CGRectGetHeight(self.rowValueLabel.frame))/2, CGRectGetWidth(self.rowValueLabel.frame), CGRectGetHeight(self.rowValueLabel.frame));
    }
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}

- (UILabel *)rowValueLabel{
    if (!_rowValueLabel) {
        _rowValueLabel = [[UILabel alloc]init];
        _rowValueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rowValueLabel;
}
@end


@implementation TSPickerValue

- (instancetype)initWithValue:(TSPickerItem *)value unit:(NSString *)unit{
    self = [super init];
    if (self) {
        _valueItem = value;
        _unit = unit;
    }
    return self;
}
@end

@implementation TSPickerItem

- (instancetype)initWithValue:(NSString *)value
{
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone { 
    TSPickerItem *item = [[self class] allocWithZone:zone];
    item.value       = self.value;
    item.attributedValue = [self.attributedValue copy];
    item.itemFont = [self.itemFont copy];
    item.itemTextColor = [self.itemTextColor copy];
    return item;
}

+ (NSMutableArray *)pickItemsFormMinNum:(double)minNum toMaxNum:(double)maxNum interval:(double)interval fillZeroWhenLessTen:(BOOL)isFillZeroWhenLessTen{
    
    TSPickerItem *oriItem = [[TSPickerItem alloc]initWithValue:@""];
    oriItem.itemFont = [TSFont TSFontPingFangMediumWithSize:28];
    oriItem.itemTextColor = [TSColor colorwithHexString:@"#222222"];

    NSMutableArray *itemArray = [NSMutableArray new];
    
    @autoreleasepool {
        for (double i = minNum ; i <= maxNum ; i+=interval) {
            TSPickerItem *item = [oriItem copy];
            if (interval>=1) {
                if (isFillZeroWhenLessTen && i<10) {
                    // add 0
                    item.value = [NSString stringWithFormat:@"0%.0f",i];
                }else{
                    item.value = [NSString stringWithFormat:@"%.0f",i];
                }
            }else{
                item.value = [NSString stringWithFormat:@"%.1f",i];
            }
            [itemArray addObject:item];
        }
    }

    return itemArray;
}


@end

@implementation TSPickerComponent

+(TSPickerComponent *)pickerComponentWithItems:(NSArray *)pickerItems unit:(NSString *)unit selectedRow:(NSInteger)selectedRow{
    TSPickerComponent *component = [TSPickerComponent pickerComponentWithItems:pickerItems unit:unit];
    component.selectedRow = selectedRow;
    return component;
}

+(TSPickerComponent *)pickerComponentWithItems:(NSArray *)pickerItems unit:(NSString *)unit{
    TSPickerComponent *component = [[TSPickerComponent alloc]init];
    component.unitFont = [TSFont TSFontPingFangRegularWithSize:16];
    component.unitTextColor = [TSColor colorwithHexString:@"#222222"];
    component.items = pickerItems;
    component.unit = unit;
    
    TSPickerItem *lastItem = pickerItems.lastObject;
    CGFloat tolerance = 10;
    if (lastItem.value.length>0) {
        CGFloat itemWidth =  [lastItem.value boundingRectWithSize:CGSizeMake([TSFrame screenWidth], 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lastItem.itemFont} context:nil].size.width+tolerance;
        component.actualWidth = MAX(component.actualWidth, itemWidth);
    }else{
        component.actualWidth = [TSFrame screenWidth]/2;
    }
    return component;
}

- (UIFont *)unitFont{
    if (_unitFont) {
        return _unitFont;
    }
    return [TSFont TSFontPingFangRegularWithSize:16];
}

- (CGSize)unitSize{
    if (CGSizeEqualToSize(_unitSize, CGSizeZero)) {
        if (_unit && _unit.length>0 ) {
            return  [_unit boundingRectWithSize:CGSizeMake([TSFrame screenWidth], 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.unitFont} context:nil].size;
        }
        return CGSizeMake(30, 20);
    }
    return _unitSize;
}

- (NSInteger)selectedRow{
    if (_selectedRow>0) {
        return _selectedRow;
    }
    return 0;
}

@end

@implementation TSPickerAction

- (CGSize)actionSize{
    
    if ( CGSizeEqualToSize(_actionSize, CGSizeZero)) {
        if (_actionText.length>0) {
            UIFont *textFont = _actionFont?_actionFont:[TSFont TSFontPingFangRegularWithSize:16];
            CGRect rect = [_actionText boundingRectWithSize:CGSizeMake([TSFrame screenWidth]/2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil];
            return CGSizeMake(rect.size.width+16, rect.size.height+12);
        }
    }
    return _actionSize;
}

@end

@implementation TSPickerConfiger


@end

@implementation TSPickerButton

+ (TSPickerButton *)pickerButtonWithAction:(TSPickerAction *)buttonAction {

    TSPickerButton *pickerButton = [TSPickerButton buttonWithType:UIButtonTypeCustom];
    pickerButton.buttonAction = buttonAction;
    [pickerButton setTitle:buttonAction.actionText forState:UIControlStateNormal];
    pickerButton.titleLabel.font = buttonAction.actionFont;
    [pickerButton setTitleColor:buttonAction.actionTextCorlor forState:UIControlStateNormal];
    
    if (buttonAction.actionBackgroundCorlor) {
        [pickerButton setBackgroundColor:buttonAction.actionBackgroundCorlor];
    }
    if (buttonAction.actionCornerRadius>0) {
        pickerButton.layer.cornerRadius = buttonAction.actionCornerRadius;
        pickerButton.layer.masksToBounds = YES;
    }
    if (buttonAction.actioBorderWidth>0) {
        pickerButton.layer.borderColor = buttonAction.actionBorderColor.CGColor;
        pickerButton.layer.borderWidth = buttonAction.actioBorderWidth;
    }
    return pickerButton;
}
@end

@interface TSPickerViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) UIView * backView;
@property (nonatomic,strong) UIPickerView * pickerView;
@property (nonatomic,assign) CGFloat maxActionY;

@property (nonatomic,assign) CGFloat rowHeight;
@property (nonatomic,assign) CGFloat contentLeftMargin;
@property (nonatomic,assign) CGFloat maxComponentWidth;
@property (nonatomic,assign) CGFloat marginOfComponent;
@property (nonatomic,assign) CGFloat pickerLeftMargin;

@end

@implementation TSPickerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initViews];
    [self addTapGesture];
    [self layoutViews];
    [self setUpAllViews];
    [self addUnits];
    [self setSelectedRow];
    
}

- (void)initData{
    
    self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    self.backView.backgroundColor = [UIColor whiteColor];
    _rowHeight = 50;
    _contentLeftMargin = 0;
    _marginOfComponent = 5;
    _pickerLeftMargin = 7;
    _maxComponentWidth = CGRectGetWidth(self.view.frame)-2*_contentLeftMargin-(self.configer.pickerDataArray.count-1)*_marginOfComponent;
    if (self.configer && self.configer.pickerDataArray.count>0) {
        _maxComponentWidth = (CGRectGetWidth(self.view.frame)-2*_contentLeftMargin-2*_pickerLeftMargin-(self.configer.pickerDataArray.count-1)*_marginOfComponent)/self.configer.pickerDataArray.count;
    }
}

- (void)initViews{
    [self.view addSubview:self.backView];
    [self.backView addSubview:self.pickerView];
    [self addActions];
}

- (void)setUpAllViews{
    
    if (self.configer.pickerViewCornerRadius>0) {
        UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backView.bounds      byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(self.configer.pickerViewCornerRadius, self.configer.pickerViewCornerRadius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backView.layer.mask = maskLayer;
        self.backView.layer.masksToBounds = YES;
    }
}

- (void)layoutViews{
    
    CGFloat backViewHeight = CGRectGetHeight(self.view.frame)*(1-0.618);
    CGFloat marginY = 12;
    self.backView.frame = CGRectMake(0, self.view.frame.size.height, CGRectGetWidth(self.view.frame), backViewHeight);
    self.pickerView.frame = CGRectMake(_contentLeftMargin, _maxActionY+marginY, CGRectGetWidth(self.view.frame)-2*_contentLeftMargin, backViewHeight-(_maxActionY+marginY));
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self show];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
}

- (void)addActions{
    
    CGFloat leftOriX = 16;
    CGFloat rightOriX = [TSFrame screenWidth]-16;
    for (TSPickerAction *action in self.configer.actions) {
        TSPickerButton *actionButton = [TSPickerButton pickerButtonWithAction:action];
        [actionButton addTarget:self action:@selector(pickerActionButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.backView addSubview:actionButton];
        if (action.direction == eTSPickerActionDirectionRight) {
            actionButton.frame = CGRectMake(rightOriX-action.actionSize.width-action.actionItemSpace, 7, action.actionSize.width, action.actionSize.height);
            rightOriX-=(action.actionSize.width+action.actionItemSpace);
        }else{
            actionButton.frame = CGRectMake(leftOriX, 7, action.actionSize.width, action.actionSize.height);
            leftOriX+=(action.actionSize.width+action.actionItemSpace);
        }
        _maxActionY = CGRectGetMaxY(actionButton.frame);
    }
}

- (void)pickerActionButtonEvent:(TSPickerButton *)sender{
    [self dismissAfterDelay:0.0f complete:^{
        if (sender.buttonAction.actionBlock) {
            sender.buttonAction.actionBlock([self pickerValues]);
        }
    }];
}

- (void)addUnits{
        
    CGFloat unitMargin = 12;
    for (int i = 0;i<self.configer.pickerDataArray.count;i++) {
        TSPickerComponent *component = [self.configer.pickerDataArray objectAtIndex:i];
        if (component.unit) {
            UILabel *unitLabel = [[UILabel alloc]init];
            unitLabel.text = component.unit;
            unitLabel.textColor = component.unitTextColor;
            unitLabel.font = component.unitFont;
            unitLabel.textAlignment = NSTextAlignmentLeft;
//            unitLabel.backgroundColor = [UIColor blueColor];

            CGFloat valueLabeMargin = (_maxComponentWidth-component.actualWidth)/2;
            CGFloat componentMaxX = _contentLeftMargin+_pickerLeftMargin+_maxComponentWidth*(i+1)+_marginOfComponent*i;
            CGFloat oriX = componentMaxX-valueLabeMargin+unitMargin;
            CGFloat unitWidth = component.unitSize.width;
            CGFloat unitHeight = component.unitSize.height;
            if ((oriX+unitWidth) > componentMaxX) {// 容错
                oriX = componentMaxX - unitWidth;
            }
            CGFloat oriY = CGRectGetMinY(self.pickerView.frame)+CGRectGetHeight(self.pickerView.frame)/2-component.unitSize.height/2;
            
            unitLabel.frame = CGRectMake(oriX, oriY, unitWidth,unitHeight);
            [self.backView addSubview:unitLabel];
        }
    }

}

- (void)setSelectedRow{
    for (int i = 0;i<self.configer.pickerDataArray.count;i++) {
        TSPickerComponent *component = [self.configer.pickerDataArray objectAtIndex:i];
        if (component.selectedRow>0) {
            [self.pickerView selectRow:component.selectedRow inComponent:i animated:YES];
        }
    }
}

- (NSArray *)pickerValues{
    if (!self.configer || !self.configer.pickerDataArray) {return @[];}
    
    NSMutableArray *pickerValues = [NSMutableArray new];
    NSInteger components = [self.pickerView numberOfComponents];
    
    // 检查组件数量是否一致
    if (components != self.configer.pickerDataArray.count) {
        NSLog(@"Warning: Picker components count mismatch");
        return @[];
    }

    for (int i = 0;i<components;i++) {
        TSPickerComponent *component = [self.configer.pickerDataArray objectAtIndex:i];
        NSInteger selectedRow = component.selectedRow;
        if (component.items.count>selectedRow) {
            TSPickerItem *selectedItem = [component.items objectAtIndex:selectedRow];
            TSPickerValue *value = [[TSPickerValue alloc]initWithValue:selectedItem unit:component.unit];
            [pickerValues addObject:value];
        }
    }
    return pickerValues;
}

- (void)addTapGesture{
    if (_configer.dismissWhenTapBackground) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tap];
    }
}

- (void)tapGestureEvent:(UITapGestureRecognizer *)tapGesture{
    if (_configer.dismissWhenTapBackground) {
        [self dismissAfterDelay:0.0f complete:^{}];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.configer.pickerDataArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.configer && self.configer.pickerDataArray.count>component) {
        TSPickerComponent *currentCom = [self.configer.pickerDataArray objectAtIndex:component];
        return currentCom.items.count;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return _maxComponentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return _rowHeight;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    TSPickerRowView *pickerRowView = (TSPickerRowView *)view;
    if (!pickerRowView) {
        pickerRowView = [[TSPickerRowView alloc]init];
    }
    pickerRowView.frame =CGRectMake(0, 0, _maxComponentWidth, _rowHeight);
    if (self.configer && self.configer.pickerDataArray.count>0) {
        TSPickerComponent *currentCom = [self.configer.pickerDataArray objectAtIndex:component];
        if (currentCom.items.count > row) {
            TSPickerItem *item = [currentCom.items objectAtIndex:row];
            [pickerRowView reloadRowWithValue:item];
        }
    }
    return pickerRowView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [TSShake shake:UIImpactFeedbackStyleHeavy];
    // 越界处理
    if (component >= self.configer.pickerDataArray.count) {return;}
    //
    TSPickerComponent *componentModel = [self.configer.pickerDataArray objectAtIndex:component];
    componentModel.selectedRow = row;
    if (componentModel.canLinkRefresh && self.configer.dataRefreshBlock) {
        NSArray *reloadArray =  self.configer.dataRefreshBlock(self.configer.pickerDataArray);
        if (reloadArray && reloadArray.count>0) {
            for (NSNumber *index in reloadArray) {
                [self.pickerView reloadComponent:[index intValue]];
            }
        }
    }
}

- (void)show{
    [UIView animateWithDuration:kPickerAnimationTime delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5f];
        self.backView.frame = CGRectMake(0,CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.backView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.backView.frame));
    } completion:^(BOOL finished) {
    }];
}

- (void)dismissAfterDelay:(CGFloat)delay complete:(void(^)(void))complete{
    [UIView animateWithDuration:kPickerAnimationTime delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.0f];
        self.backView.frame = CGRectMake(0,CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.backView.frame));
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            complete();
        }];
    }];
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [UIView new];
    }
    return _backView;
}

- (UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]init];
        _pickerView.delegate =self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

@end
