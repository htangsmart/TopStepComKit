//
//  TSNothingView.h
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/25.
//

#import <UIKit/UIKit.h>

@protocol TSNothingViewDelegate <NSObject>

- (void)beginRerefresh;

@end

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSNothingType) {
    eTSNothingNoData = 0,
    eTSNothingNetError,
};

@interface TSNothingView : UIView

@property (nonatomic,weak) id <TSNothingViewDelegate> delegate;

- (instancetype)init;

- (instancetype)initWithDesc:(NSString *)nothingDesc;

- (instancetype)initWithNothingImageName:(NSString *)imageName desc:(NSString *)nothingDesc;

- (instancetype)initWithNothingImageName:(NSString *)imageName desc:(NSString *)nothingDesc subDesc:(NSString *)subDesc;

- (void)reloadNothingViewWithImageName:(NSString *)imageName desc:(NSString *)nothingDesc subDesc:(NSAttributedString *)attributeSubDesc;

- (void)reloadWithNothingType:(TSNothingType)nothingType;

/*
 * @brief 切换 no data和net error 状态
 *
 * @param nothingType 类型；imageName 图片名称；nothingDesc 如果是无数据类型则为标题，如果是无网络则为刷新按钮字符
 */
- (void)reloadWithNothingType:(TSNothingType)nothingType imageName:(NSString *)imageName desc:(NSString *)nothingDesc subDesc:(NSAttributedString *)attributeSubDesc;


@end

NS_ASSUME_NONNULL_END
