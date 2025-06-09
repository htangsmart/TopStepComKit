//
//  PyUrpc.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/12.
//

#import <Foundation/Foundation.h>

typedef int (^PyUrpcPortingCallback)(NSData *_Nonnull data);

@interface PyUrpc : NSObject

+(void)initUrpc;

+(void)portingInput:(NSData *_Nonnull)data;

+(int)startServer:(NSString * _Nonnull)bundleId;

+(void)connectServer:(NSString * _Nonnull)bundleId;

+(void)setPortingCallback:(PyUrpcPortingCallback _Nonnull)inputCallback;

+(NSArray<NSNumber *> *)convertDataToArray:(NSData *)data;

@end
