//
//  DialThumbnailAdapter.h
//  Biu2us
//
//  Created by t_t on 2023/3/30.
//
#import <Foundation/Foundation.h>

@interface DialThumbnailAdapter : NSObject

+ (int)peekJpgData:(NSString *)dialFilePath withCompletionHandler:(void (^)(NSData *jpegData, NSError *error))completionHandler;

@end
