//
//  TSScrollBannerView.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/3/11.
//

#import <UIKit/UIKit.h>

#import "TSBannerModel.h"


@class TSScrollBannerView;

@protocol TSScrollBannerViewDataSource <NSObject>



- (NSInteger)numberOfItemsInBannerView:(TSScrollBannerView *)bannerView;

-(NSString *)itemNameInBannerView:(TSScrollBannerView *)bannerView;

-(CGSize)bannerView:(TSScrollBannerView *)bannerView bannerSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

-(CGFloat)bannerView:(TSScrollBannerView *)bannerView spaceForItemAtIndexPath:(NSIndexPath *)indexPath;



@end

@protocol TSScrollBannerViewDelegate <NSObject>

- (void)bannerView:(TSScrollBannerView *)bannerView didSelectBannerAtIndex:(NSInteger)index;

@end


@interface TSScrollBannerView : UIView

@property (nonatomic,weak) id <TSScrollBannerViewDelegate>delegate;

@property (nonatomic,weak) id <TSScrollBannerViewDataSource>dataSource;


- (instancetype)initWithRegisterItemName:(NSString *)itemName;

- (void)reloadWithArray:(NSArray *)bannerArray;

@end

