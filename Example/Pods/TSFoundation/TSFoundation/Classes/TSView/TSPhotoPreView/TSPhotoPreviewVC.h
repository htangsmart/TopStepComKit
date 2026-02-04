//
//  TSPhotoPreviewVC.h
//  JieliJianKang
//
//  Created by luigi on 2024/4/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPhotoPreviewVC : UIViewController
@property (nonatomic, copy) NSArray *photos;
/// 当前显示图片索引
@property (nonatomic, assign) NSInteger currentIndex;
/// 是否可下载至相册
@property (nonatomic, assign) BOOL canSaveToPhotoAlbum;
/// 是否显示删除按钮
@property (nonatomic, assign) BOOL showDeleteBtn;
/// 删除按钮点击事件，调用方可根据preViewVC.currentIndex确定需要删除的图片
@property (nonatomic, copy) void(^deleteBtnClickBlock)(TSPhotoPreviewVC *preViewVC, void(^ _Nullable resultBlock)(BOOL deleteResult));
@end

NS_ASSUME_NONNULL_END
