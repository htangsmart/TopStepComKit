//
//  TSShare.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/23.
//

#import "TSShare.h"
#import "TSToast.h"
#import "TSScreenCapture.h"

@implementation TSShare


+(void)shareView:(UIView *)shareView onVC:(UIViewController *)superVC{
    [TSShare shareImage:[TSScreenCapture screenshotForView:shareView frame:shareView.bounds] onVC:superVC];
}

+ (void)shareView:(UIView *)shareView onVC:(UIViewController *)superVC complete:(void (^)(BOOL))complete{
    [TSShare shareImage:[TSScreenCapture screenshotForView:shareView frame:shareView.bounds] onVC:superVC complete:^(BOOL completed) {
        complete(completed);
    }];
}

+(void)shareImage:(UIImage *)shareImage onVC:(UIViewController *)superVC{
    [TSShare shareImage:shareImage onVC:superVC complete:^(BOOL completed) {
        [TSToast showText:completed ? kJL_TXT("分享成功") : kJL_TXT("分享失败") onView:superVC.view dismissAfterDelay:1.5];
    }];
}

+(void)shareImage:(UIImage *)shareImage onVC:(UIViewController *)superVC complete:(void(^)(BOOL completed))complete{
    
    //如果想分享图片 就把图片添加进去 文字什么的同上
    NSArray *activityItems = @[shareImage];
    // 创建分享vc
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    // 设置不出现在活动的项目
    activityVC.excludedActivityTypes = [TSShare shareTypes];
    [superVC presentViewController:activityVC animated:YES completion:nil];
    // 分享之后的回调
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        complete(completed);
    };
}

+(NSArray *)shareTypes{
    return @[UIActivityTypePrint,
            UIActivityTypeMessage,
            UIActivityTypePrint,
            UIActivityTypeAddToReadingList,
            UIActivityTypeOpenInIBooks,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll];

}
@end
