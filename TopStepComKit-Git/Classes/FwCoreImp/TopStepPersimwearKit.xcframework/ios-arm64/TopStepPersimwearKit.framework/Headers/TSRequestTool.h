//
//  TSRequestTool.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/1/21.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSRequestTool : TSFwKitBase

+ (void)convertMP3ToPCM:(nonnull NSString *)mp3FilePath pcmFilePath:(nonnull NSString *)pcmFilePath sampleRate:(NSInteger)sampleRate bitDepth:(NSInteger)bitDepth completion:(nonnull TSCompletionBlock)completion ;

@end

NS_ASSUME_NONNULL_END
