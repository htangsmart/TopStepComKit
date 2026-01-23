//
//  TSRequestTransferInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/1/20.
//

#import <Foundation/Foundation.h>
#import "TSRequestModel.h"
#import "TSRespondModel.h"
#import "TSKitBaseInterface.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Request listener callback block type
 * @chinese 请求监听回调块类型
 *
 * @param requestModel
 * EN: The received request model containing request information
 * CN: 收到的request模型，包含请求信息
 *
 * @param error
 * EN: Error information if failed, nil if successful
 * CN: 监听失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This callback is triggered when a request is received from the device.
 *     The callback provides the request model containing all request details.
 *     Use this block type to register a listener that will be notified whenever a new request arrives.
 * CN: 当从设备收到request时，此回调会被触发。
 *     回调提供包含所有请求详情的request模型。
 *     使用此块类型注册监听器，当有新请求到达时会被通知。
 */
typedef void(^TSRequestListenerBlock)(TSRequestModel * _Nullable requestModel, NSError * _Nullable error);

@protocol TSRequestTransferInterface <NSObject>

/**
 * @brief Register listener for receiving request
 * @chinese 注册收到request的监听
 *
 * @param completion
 * EN: Callback when a request is received
 *     - requestModel: The received request model containing request information
 *     - error: Error information if failed, nil if successful
 * CN: 收到request时的回调
 *     - requestModel: 收到的request模型，包含请求信息
 *     - error: 监听失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This callback will be triggered when a request is received from the device.
 *     The callback provides the request model containing all request details.
 *     Use this method to register a listener that will be notified whenever a new request arrives.
 * CN: 当从设备收到request时，此回调会被触发。
 *     回调提供包含所有请求详情的request模型。
 *     使用此方法注册监听器，当有新请求到达时会被通知。
 *
 * @note
 * EN: Multiple registrations will override previous ones.
 *     Remember to unregister the listener when done to avoid memory leaks.
 * CN: 多次注册会覆盖之前的注册。
 *     使用完毕后记得取消注册监听器以避免内存泄漏。
 */
- (void)registerRequestListener:(TSRequestListenerBlock)completion;

/**
 * @brief Respond to request
 * @chinese 请求响应
 *
 * @param respondModel
 * EN: Response model containing response information
 * CN: 包含响应信息的响应模型
 *
 * @param completion
 * EN: Completion callback
 *     - isSuccess: Whether the response was sent successfully
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - isSuccess: 响应是否发送成功
 *     - error: 发送失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This method sends a response to a previously received request.
 *     The respondModel contains all the response data that will be sent to the device.
 *     The completion callback will be triggered when the response operation completes,
 *     indicating whether the response was successfully sent or if an error occurred.
 * CN: 此方法用于响应之前收到的请求。
 *     响应模型包含将发送到设备的所有响应数据。
 *     完成回调在响应操作完成时触发，指示响应是否成功发送或是否发生错误。
 *
 * @note
 * EN: Make sure to call this method after receiving a request through registerRequestListener.
 *     The respondModel should correspond to the received request.
 * CN: 确保在通过registerRequestListener收到请求后调用此方法。
 *     响应模型应对应收到的请求。
 */
- (void)respondToRequest:(TSRespondModel *)respondModel completion:(TSCompletionBlock)completion;

/**
 * @brief Convert MP3 format to PCM format
 * @chinese 将MP3格式转换为PCM格式
 *
 * @param mp3FilePath
 * EN: Path to the source MP3 file
 * CN: 源MP3文件路径
 *
 * @param pcmFilePath
 * EN: Path to the output PCM file
 * CN: 输出PCM文件路径
 *
 * @param sampleRate
 * EN: Sample rate for PCM output (e.g., 44100, 48000 Hz)
 * CN: PCM输出的采样率（例如：44100、48000 Hz）
 *
 * @param bitDepth
 * EN: Bit depth for PCM output (e.g., 16, 24 bits)
 * CN: PCM输出的位深度（例如：16、24位）
 *
 * @param completion
 * EN: Completion callback
 *     - isSuccess: Whether the conversion was successful
 *     - error: Error information if failed, nil if successful
 * CN: 完成回调
 *     - isSuccess: 转换是否成功
 *     - error: 转换失败时的错误信息，成功时为nil
 *
 * @discussion
 * EN: This method converts an MP3 audio file to PCM format with specified sample rate and bit depth.
 *     The conversion process includes:
 *     1. Reading the MP3 file
 *    2. Decoding MP3 audio data
 *    3. Resampling to the specified sample rate (if needed)
 *    4. Converting to the specified bit depth
 *    5. Writing PCM data to the output file
 *     The output PCM file will be created at the specified path. If the file already exists, it will be overwritten.
 * CN: 此方法将MP3音频文件转换为指定采样率和位深度的PCM格式。
 *     转换过程包括：
 *     1. 读取MP3文件
 *     2. 解码MP3音频数据
 *     3. 重采样到指定采样率（如需要）
 *     4. 转换为指定位深度
 *     5. 将PCM数据写入输出文件
 *     输出PCM文件将在指定路径创建。如果文件已存在，将被覆盖。
 *
 * @note
 * EN: - Ensure the MP3 file exists and is readable
 *     - Ensure the output directory exists or can be created
 *     - Common sample rates: 8000, 16000, 22050, 44100, 48000 Hz
 *     - Common bit depths: 8, 16, 24, 32 bits
 *     - The conversion may take some time depending on file size
 * CN: - 确保MP3文件存在且可读
 *     - 确保输出目录存在或可以创建
 *     - 常用采样率：8000、16000、22050、44100、48000 Hz
 *     - 常用位深度：8、16、24、32位
 *     - 转换时间取决于文件大小
 */
- (void)convertMP3ToPCM:(NSString *)mp3FilePath
              pcmFilePath:(NSString *)pcmFilePath
               sampleRate:(NSInteger)sampleRate
                 bitDepth:(NSInteger)bitDepth
               completion:(TSCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
