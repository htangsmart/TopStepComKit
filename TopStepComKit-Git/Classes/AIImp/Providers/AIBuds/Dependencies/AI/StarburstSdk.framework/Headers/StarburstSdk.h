//
//  Starburst.h
//  Starburst
//
//  Created by cookies on 2023/6/12.
//

#import <Foundation/Foundation.h>

//! Project version number for Starburst.
//FOUNDATION_EXPORT double StarburstSdkVersionNumber;

//! Project version string for Starburst.
//FOUNDATION_EXPORT const unsigned char StarburstSdkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <StarburstSdk/PublicHeader.h>

#import <StarburstSdk/StarburstSdkManager.h>
#import <StarburstSdk/StarburstConfig.h>
#import <StarburstSdk/StarburstPhoneSdk.h>
#import <StarburstSdk/StartburstMixSdk.h>
#import <StarburstSdk/StartburstGlassesSdk.h>
#import <StarburstSdk/StartburstGlassChat.h>
#import <StarburstSdk/StarburstVadManager.h>
#import <StarburstSdk/StarburstAsrConfig.h>
#import <StarburstSdk/StarburstAsrModel.h>
#import <StarburstSdk/StarburstFileAsrModel.h>
#import <StarburstSdk/StarbaustVoiceChatModel.h>
#import <StarburstSdk/StarbusrtSpeaker.h>
#import <StarburstSdk/StarburstStreamModel.h>
#import <StarburstSdk/StarburstOffLineFile.h>
#import <StarburstSdk/StartburstDecoderConfig.h>
#import <StarburstSdk/TextToImageManager.h>
#import <StarburstSdk/TextToImageCallback.h>
#import <StarburstSdk/AIGCErrorCode.h>
#import <StarburstSdk/TextToSpeechManager.h>
#import <StarburstSdk/TextToSpeechCallback.h>
#import <StarburstSdk/FileProcessingManager.h>
#import <StarburstSdk/FileResultTaskPoller.h>
#import <StarburstSdk/FileTaskResult.h>
#import <StarburstSdk/StarburstVoiceChatRecorder.h>
#import <StarburstSdk/StarburstAudioStreamConfig.h>
#import <StarburstSdk/TcFeatureIds.h>
#import <StarburstSdk/TcFeatureConfig.h>
#import <StarburstSdk/TcFeatureResponse.h>
#import <StarburstSdk/TcFeatureDecision.h>
#import <StarburstSdk/TcFeatureManager.h>
//#import <StarburstSdk/CustomChatWebSocketClient.h>
//#import <StarburstSdk/CustomVoiceChatConfig.h>

// Expose Swift-based JSBridge APIs to Objective-C consumers.
#if __has_include(<StarburstSdk/StarburstSdk-Swift.h>)
#import <StarburstSdk/StarburstSdk-Swift.h>
#endif
