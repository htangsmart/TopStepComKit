//
//  TSPickerViewController.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface TSPickerItem : NSObject<NSCopying>
@property (nonatomic,strong) NSString * value;
@property (nonatomic,strong) UIFont * itemFont;
@property (nonatomic,strong) UIColor * itemTextColor;
@property (nonatomic,strong) NSAttributedString * attributedValue;

+ (NSMutableArray *)pickItemsFormMinNum:(double)minNum toMaxNum:(double)maxNum interval:(double)interval fillZeroWhenLessTen:(BOOL)isFillZeroWhenLessTen;
//+ (NSMutableArray *)precisionPickItemsFormMinNum:(NSDecimalNumber *)minNum toMaxNum:(NSDecimalNumber *)maxNum interval:(NSDecimalNumber *)interval fillZeroWhenLessTen:(BOOL)isFillZeroWhenLessTen;

- (instancetype)initWithValue:(NSString *)value;

@end

@interface TSPickerComponent : NSObject
@property (nonatomic,strong) NSArray <TSPickerItem *>*items;
@property (nonatomic,strong) NSString * unit;
@property (nonatomic,strong) UIFont * unitFont;
@property (nonatomic,strong) UIColor * unitTextColor;
@property (nonatomic,assign) CGFloat actualWidth;
@property (nonatomic,assign) CGSize unitSize;

@property (nonatomic,assign) NSInteger selectedRow;

@property (nonatomic,assign) BOOL canLinkRefresh;

+(TSPickerComponent *)pickerComponentWithItems:(NSArray *)pickerItems unit:(NSString *)unit;
+(TSPickerComponent *)pickerComponentWithItems:(NSArray *)pickerItems unit:(NSString *)unit selectedRow:(NSInteger)selectedRow;

@end

@interface TSPickerValue : NSObject
@property (nonatomic,strong) TSPickerItem * valueItem;
@property (nonatomic,strong) NSString *unit;
- (instancetype)initWithValue:(TSPickerItem *)item unit:(NSString *)unit;
@end


typedef void(^TSPickerActionBlock)(NSArray * actionValue);
typedef NS_ENUM(NSUInteger, TSPickerActionDirection) {
    eTSPickerActionDirectionNone = 0,
    eTSPickerActionDirectionLeft,
    eTSPickerActionDirectionRight,
};
@interface TSPickerAction : NSObject

@property (nonatomic,assign) TSPickerActionDirection direction;

@property (nonatomic,strong) NSString * actionText;
@property (nonatomic,strong) UIFont * actionFont;
@property (nonatomic,strong) UIColor * actionTextCorlor;
@property (nonatomic,strong) UIColor * actionBackgroundCorlor;
@property (nonatomic,assign) CGFloat actionCornerRadius;

@property (nonatomic,strong) UIColor * actionBorderColor;
@property (nonatomic,assign) CGFloat actioBorderWidth;
@property (nonatomic,assign) CGSize actionSize;
@property (nonatomic,assign) CGFloat actionItemSpace;
// 执行
@property (nonatomic,copy) TSPickerActionBlock actionBlock;
@end


typedef NSArray *_Nullable(^TSPickerDataRefreshBlock)(NSArray * actionValue);

@interface TSPickerConfiger : NSObject

@property (nonatomic,copy) TSPickerDataRefreshBlock  dataRefreshBlock;
// 背景圆角
@property (nonatomic,assign) CGFloat pickerViewCornerRadius;
// 点击灰色区域是否取消
@property (nonatomic,assign) BOOL dismissWhenTapBackground;
// 所有按钮
@property (nonatomic,strong) NSArray <TSPickerAction *>* actions;

@property (nonatomic,strong) NSArray <TSPickerComponent*>* pickerDataArray;



@end


@interface TSPickerButton : UIButton

@property (nonatomic,strong) TSPickerAction * buttonAction;

+ (TSPickerButton *)pickerButtonWithAction:(TSPickerAction *)buttonAction ;


@end


@interface TSPickerRowView : UIView
- (void)reloadRowWithValue:(TSPickerItem *)rowItem;

@end


@interface TSPickerViewController : UIViewController

@property (nonatomic,strong) TSPickerConfiger * configer;

@end

NS_ASSUME_NONNULL_END
