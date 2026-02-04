//
//  TSScrollBannerItem.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/11.
//

#import <UIKit/UIKit.h>
#import "TSBannerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSScrollBannerItem : UICollectionViewCell

- (void)reloadBannerCellWithModel:(TSBannerModel *)bannerModel;

@end

NS_ASSUME_NONNULL_END
