//
//  TSPhotoPreviewCell.h
//  JieliJianKang
//
//  Created by luigi on 2024/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TSPhotoPreviewView;
@interface TSPhotoPreviewCell : UICollectionViewCell
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, strong) id photo;
@property (nonatomic, strong) TSPhotoPreviewView *previewView;
- (void)recoverSubviews;

@end

@interface TSPhotoPreviewView : UIView
@property (nonatomic, strong) id photo;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
- (void)recoverSubviews;
@end

NS_ASSUME_NONNULL_END
