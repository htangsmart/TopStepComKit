//
//  TSDialTimePositionView.m
//  TopStepComKit_Example
//

#import "TSDialTimePositionView.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSDialEditorAppearance.h"
#import "TSDialEditorState.h"

@interface TSDialTimePositionView ()
// 按显示顺序排列的实际接口选项。
@property (nonatomic, copy) NSArray<TSCustomDialPositionOption *> *options;
// 当前设备形状。
@property (nonatomic, assign) BOOL roundScreen;
// 选项按钮。
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
// 标题。
@property (nonatomic, strong) UIView *heading;
// 提示。
@property (nonatomic, strong) UILabel *hint;
@end

@implementation TSDialTimePositionView

#pragma mark - 生命周期

// 根据设备形状绘制小表，选项保持四列宽度。
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.heading.frame = CGRectMake(0, 17, width, 20);
    self.hint.frame = CGRectMake(width - 80, 17, 80, 20);
    CGFloat cardWidth = (width - 24) / 4;
    for (NSUInteger index = 0; index < self.buttons.count; index++) {
        UIButton *button = self.buttons[index];
        button.frame = CGRectMake(index % 4 * (cardWidth + 8), 50 + index / 4 * 76, cardWidth, 68);
        UIView *face = [button viewWithTag:100];
        CGSize faceSize = self.roundScreen ? CGSizeMake(28, 28) : CGSizeMake(24, 29);
        face.frame = CGRectMake((cardWidth - faceSize.width) / 2, 9, faceSize.width, faceSize.height);
        face.layer.cornerRadius = self.roundScreen ? 14 : 6;
        UIView *marker = [face viewWithTag:101];
        CGPoint origin = CGPointMake((faceSize.width - 11) / 2, 5);
        switch (self.options[index].position) {
            case eTSDialTimePositionLeft: origin = CGPointMake(3, 12); break;
            case eTSDialTimePositionRight: origin = CGPointMake(faceSize.width - 14, 12); break;
            case eTSDialTimePositionBottom: origin.y = faceSize.height - 10; break;
            case eTSDialTimePositionTopLeft: origin.x = 3; break;
            case eTSDialTimePositionTopRight: origin.x = faceSize.width - 14; break;
            case eTSDialTimePositionBottomLeft: origin = CGPointMake(3, faceSize.height - 10); break;
            case eTSDialTimePositionBottomRight: origin = CGPointMake(faceSize.width - 14, faceSize.height - 10); break;
            case eTSDialTimePositionCenter: origin.y = (faceSize.height - 5) / 2; break;
            default: break;
        }
        marker.frame = (CGRect){origin, CGSizeMake(11, 5)};
        UILabel *caption = (UILabel *)[button viewWithTag:102];
        caption.frame = CGRectMake(0, 43, cardWidth, 17);
    }
}

#pragma mark - 公开方法

// 只展示接口允许的位置，按钮顺序遵循 HTML。
- (void)configureWithState:(TSDialEditorState *)state constraint:(TSCustomDialStyleConstraint *)constraint {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    self.roundScreen = constraint.screenShape == eTSPeriphShapeCircle;
    self.heading = [TSDialEditorAppearance heading:state.draftType == TSDialDraftTypeDanMu ? 4 : 3
                                           title:@"时间位置"];
    [self addSubview:self.heading];
    self.hint = [TSDialEditorAppearance label:@"轻点切换" size:10 color:0x93958E];
    self.hint.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.hint];
    NSArray *order = @[@(eTSDialTimePositionTop), @(eTSDialTimePositionLeft),
                       @(eTSDialTimePositionRight), @(eTSDialTimePositionBottom),
                       @(eTSDialTimePositionTopLeft), @(eTSDialTimePositionTopRight),
                       @(eTSDialTimePositionBottomLeft), @(eTSDialTimePositionBottomRight), @(eTSDialTimePositionCenter)];
    NSMutableArray *options = [NSMutableArray array];
    for (NSNumber *position in order) {
        for (TSCustomDialPositionOption *option in constraint.positions) {
            if (option.position == position.integerValue) {
                [options addObject:option];
                break;
            }
        }
    }
    self.options = options;
    self.buttons = [NSMutableArray array];
    for (TSCustomDialPositionOption *option in options) {
        BOOL selected = option.position == state.timePosition;
        UIButton *button = [TSDialEditorAppearance button:@"" primary:NO];
        button.tag = option.position;
        button.backgroundColor = selected ? [TSDialEditorAppearance color:0xFFF6F1] : UIColor.whiteColor;
        button.layer.borderWidth = selected ? 1.5 : 1;
        button.layer.borderColor = [TSDialEditorAppearance color:selected ? 0xF16D43 : 0xE7E9E2].CGColor;
        UIView *face = [[UIView alloc] init];
        face.tag = 100;
        face.userInteractionEnabled = NO;
        face.layer.borderWidth = 1;
        face.layer.borderColor = [TSDialEditorAppearance color:selected ? 0xD5A085 : 0xB7BEAC].CGColor;
        UIView *marker = [[UIView alloc] init];
        marker.tag = 101;
        marker.backgroundColor = [TSDialEditorAppearance color:selected ? 0xD78359 : 0x8A977A];
        marker.layer.cornerRadius = 2;
        [face addSubview:marker];
        NSArray *titles = @[@"上方", @"左侧", @"右侧", @"下方", @"左上", @"右上", @"左下", @"右下", @"居中"];
        NSString *title = titles[[order indexOfObject:@(option.position)]];
        UILabel *caption = [TSDialEditorAppearance label:title size:11 color:selected ? 0xB97350 : 0x9DA294];
        caption.tag = 102;
        caption.textAlignment = NSTextAlignmentCenter;
        button.accessibilityLabel = title;
        button.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0);
        [button addSubview:face];
        [button addSubview:caption];
        [button addTarget:self action:@selector(selectPosition:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.buttons addObject:button];
    }
    [self setNeedsLayout];
}

// 正常四个位置仍保持原型高度，更多位置沿用同一网格。
- (CGFloat)preferredHeight {
    return 61 + MAX(1, (self.options.count + 3) / 4) * 76;
}

#pragma mark - 私有方法

// 回传真实位置枚举，不回传 UI 排序索引。
- (void)selectPosition:(UIButton *)sender {
    if (self.onPositionSelected) {
        self.onPositionSelected(sender.tag);
    }
}

@end
