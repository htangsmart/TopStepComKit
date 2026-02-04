//
//  TSCustomTableViewCell.h
//  JieliJianKang
//
//  Created by luigi on 2024/3/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TSCustomTableViewCellStyle) {
    /// 只有title、content、detail
    TSCustomTableViewCellStyle_default,
    
    /// 右侧添加一个next图标
    TSCustomTableViewCellStyle_next,
    
    /// 右侧添加一个UISwitch
    TSCustomTableViewCellStyle_switch,
    
    /// 右侧添加一个选择按钮
    TSCustomTableViewCellStyle_select,
};

@protocol TSCustomTableViewCellProtocol <NSObject>
@required
@property (nonatomic, copy) NSString *cellTag;//单元格标识
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, strong) UIImage * titleImage;
@property (nonatomic, assign) BOOL isOn;//UIswitch isOn
@property (nonatomic, assign) BOOL isSelected;//选择按钮isSelected
- (void)switchChange:(BOOL)isOn;
@end

@interface TSCustomTableViewCell : UITableViewCell
@property (weak, nonatomic) id<TSCustomTableViewCellProtocol> cellModel;
@property (nonatomic, strong) UIView * cellBGView;
@property (nonatomic, strong) UIImageView * titleImgV;
@property (nonatomic, strong) UILabel * titleLab;
@property (nonatomic, strong) UILabel * contentLab;
@property (nonatomic, strong) UILabel * detailLab;
@property (nonatomic, strong) UIImageView * nextIcon;
@property (nonatomic, strong) UISwitch * aSwitch;
@property (nonatomic, strong) UIButton * selectBtn;
/**
 * 初始化单元格
 *
 * @param cellStyle 单元格类型
 * @param reuseIdentifier 重用标识符
 * @param cellEdgeInset cellBGView内缩量
 * 默认titlePriority = UILayoutPriorityDefaultLow，contentPriority = UILayoutPriorityRequired
 */
- (instancetype)initWithCellStyle:(TSCustomTableViewCellStyle)cellStyle reuseIdentifier:(NSString *)reuseIdentifier cellEdgeInset:(UIEdgeInsets)cellEdgeInset;

- (instancetype)initWithCellStyle:(TSCustomTableViewCellStyle)cellStyle reuseIdentifier:(NSString *)reuseIdentifier cellEdgeInset:(UIEdgeInsets)cellEdgeInset titlePriority:(UILayoutPriority)titlePriority contentPriority:(UILayoutPriority)contentPriority;
@end

NS_ASSUME_NONNULL_END
