//
//  StarburstStreamModel.h
//  StarburstSdk
//
//  Created by liangshi on 2024/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarburstStreamModel : NSObject
@property (nonatomic, assign) NSInteger code;//1: processing, 10: complete -1：fail
@property (nonatomic, strong, nullable) NSString *msg;//提示文字
@property (nonatomic, strong, nullable) NSString *failReason;//失败原因
@property (nonatomic, strong, nullable) NSString *llmResponse;// 增量返回的⽂本内容
@property (nonatomic, assign) BOOL complete;// ⽂本内容是否完成
@end

NS_ASSUME_NONNULL_END
