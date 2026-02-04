//
//  TSAlert.h
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/28.
//

#import <Foundation/Foundation.h>
#import "TSAlertError.h"
#import "TSAlertConfiger.h"


@interface TSAlert : NSObject

+ (void)alertOnVC:(UIViewController *)presentVC 
        WithTitle:(NSString *)title content:(NSString *)content
     confirmTitle:(NSString *)confirmTitle
          confirm:(void(^)(void))confirmBlock
      cancelTitle:(NSString *)cancelTitle
           cancel:(void(^)(void))cancelBlock;


+ (void)alertAlbumSheetOnVC:(UIViewController *)presentVC
            tabkePhotoTitle:(NSString *)tabkePhotoTitle takePhotoBlock:(void(^)(void))takePhotoBlock
                 albumTitle:(NSString *)albumTitle
                 albumBlock:(void(^)(void))albumBlock
                cancelTitle:(NSString *)cancelTitle
                cancelBlock:(void(^)(void))cancelBlock ;

+(void)presentAlertOnVC:(UIViewController *)superVC
             alertTitle:(NSString *)alertTiltle
           alertContent:(NSString *)alertContent
                confirm:(NSString *)confirmString
           confirmBlock:(void(^)(id actionValue))confirmBlock;


+(void)presentAlertOnVC:(UIViewController *)superVC
             alertTitle:(NSString *)alertTiltle 
           alertContent:(NSString *)alertContent
                confirm:(NSString *)confirmString
           confirmBlock:(void(^)(id actionValue))confirmBlock
                 cancel:(NSString *)cancelString 
            cancelBlock:(void(^)(id actionValue))cancelBlock;


+(void)presentInputAlertOnVC:(UIViewController *)superVC
                  alertTitle:(NSString *)alertTiltle
                alertContent:(NSString *)alertContent
                     confirm:(NSString *)confirmString
                confirmBlock:(void(^)(id actionValue))confirmBlock
                      cancel:(NSString *)cancelString
                 cancelBlock:(void(^)(id actionValue))cancelBlock
            valueVerifyBlock:(TSAlertError*(^)(id actionValue))valueVerifyBlock;

+(void)presentMusicAlertOnVC:(UIViewController *)superVC
                  alertTitle:(NSString *)alertTiltle
                   itemArray:(NSArray *)itemArray
                     confirm:(NSString *)confirmString
                confirmBlock:(void (^)(id))confirmBlock
                      cancel:(NSString *)cancelString
                 cancelBlock:(void (^)(id))cancelBlock;

+ (void)presentInputAlertOnVC:(UIViewController *)superVC
                   alertTitle:(NSString *)alertTiltle
                 alertContent:(NSString *)alertContent
                      confirm:(NSString *)confirmString
                 confirmBlock:(void(^)(id actionValue))confirmBlock
                       cancel:(NSString *)cancelString
                  cancelBlock:(void(^)(id actionValue))cancelBlock
             valueVerifyBlock:(TSAlertError*(^)(id actionValue))valueVerifyBlock
                     alertSet:(nullable TSAlertConfiger * (^)(TSAlertConfiger *configer))alertSet;


@end

