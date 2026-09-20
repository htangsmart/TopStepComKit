//
//  WmGlassesMediaCount.h
//  UNIWatchMate
//
//  Created by abel on 2024/10/9.
//

#import <Foundation/Foundation.h>

//NS_ASSUM__NONNULL_BEGIN

@interface WmGlassesMediaCount : NSObject

@property (nonatomic, assign) NSInteger photo_num;
@property (nonatomic, assign) NSInteger video_num;
@property (nonatomic, assign) NSInteger record_num;
@property (nonatomic, assign) NSInteger music_num;

@end

//NS_ASSUME_NONNULL_END
