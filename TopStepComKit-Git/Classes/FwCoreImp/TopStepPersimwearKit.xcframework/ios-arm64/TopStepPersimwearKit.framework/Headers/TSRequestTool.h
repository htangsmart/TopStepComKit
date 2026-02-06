//
//  TSRequestTool.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/1/21.
//

#import "TSFwKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Audio format conversion tool
 * @chinese 音频格式转换工具类
 *
 * @discussion
 * [EN]: Provides functionality to convert MP3 audio files to PCM format.
 *       This class uses AVFoundation framework to perform audio format conversion.
 * [CN]: 提供将MP3音频文件转换为PCM格式的功能。
 *       此类使用AVFoundation框架执行音频格式转换。
 */
@interface TSRequestTool : TSFwKitBase

/**
 * @brief Convert MP3 file to PCM format
 * @chinese 将MP3文件转换为PCM格式
 *
 * @param mp3FilePath
 * EN: The file path of the source MP3 file to be converted
 * CN: 要转换的源MP3文件路径
 *
 * @param pcmFilePath
 * EN: The file path where the converted PCM file will be saved
 * CN: 转换后的PCM文件保存路径
 *
 * @param sampleRate
 * EN: The sample rate for the output PCM file (e.g., 44100, 48000)
 * CN: 输出PCM文件的采样率（例如：44100、48000）
 *
 * @param bitDepth
 * EN: The bit depth for the output PCM file (e.g., 16, 24)
 * CN: 输出PCM文件的位深度（例如：16、24）
 *
 * @param completion
 * EN: Completion block called when conversion finishes. 
 *     isSuccess: YES if conversion succeeded, NO otherwise
 *     result: Additional result data (currently nil)
 * CN: 转换完成时调用的完成回调。
 *     isSuccess: 转换成功为YES，否则为NO
 *     result: 额外的结果数据（当前为nil）
 *
 * @discussion
 * [EN]: This method performs asynchronous audio format conversion from MP3 to PCM.
 *       The conversion process includes:
 *       1. Reading the MP3 file and extracting audio tracks
 *       2. Configuring audio output settings (sample rate, bit depth, mono channel)
 *       3. Converting audio data using AVAssetReader and AVAssetWriter
 *       4. Writing the converted PCM data to the output file
 *       
 *       The output PCM file will be in WAVE format with linear PCM encoding,
 *       mono channel, and the specified sample rate and bit depth.
 *       
 *       Note: This is an asynchronous operation. The completion block will be
 *       called on a background queue when the conversion completes.
 * [CN]: 此方法执行从MP3到PCM的异步音频格式转换。
 *       转换过程包括：
 *       1. 读取MP3文件并提取音频轨道
 *       2. 配置音频输出设置（采样率、位深度、单声道）
 *       3. 使用AVAssetReader和AVAssetWriter转换音频数据
 *       4. 将转换后的PCM数据写入输出文件
 *       
 *       输出的PCM文件将是WAVE格式，使用线性PCM编码，
 *       单声道，以及指定的采样率和位深度。
 *       
 *       注意：这是一个异步操作。转换完成时，完成回调将在后台队列上调用。
 *
 * @note
 * [EN]: The output file format is WAVE (.wav) with linear PCM encoding.
 *       The conversion is performed on a background queue and does not block the main thread.
 * [CN]: 输出文件格式为WAVE（.wav），使用线性PCM编码。
 *       转换在后台队列上执行，不会阻塞主线程。
 */
+ (void)convertMP3ToPCM:(nonnull NSString *)mp3FilePath 
            pcmFilePath:(nonnull NSString *)pcmFilePath 
             sampleRate:(NSInteger)sampleRate 
               bitDepth:(NSInteger)bitDepth 
             completion:(nonnull TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
