//
//  TSNpkOpusDecoder.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/10/27.
//

#import <Foundation/Foundation.h>

@class TSMetaOpusHead;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK Opus decoder error domain
 * @chinese NPK Opus 解码错误域
 */
FOUNDATION_EXPORT NSErrorDomain const TSNpkOpusErrorDomain;

/**
 * @brief Explicitly verified firmware packet-boundary contract
 * @chinese 经显式核验的固件分帧契约
 */
typedef NS_ENUM(NSUInteger, TSNpkOpusFramingMode) {
    /**
     * @brief No confirmed boundaries
     * @chinese 尚未确认边界
     */
    TSNpkOpusFramingModeUnknown = 0,
    /**
     * @brief One complete codec packet per payload
     * @chinese 每份载荷是一个完整编解码包
     */
    TSNpkOpusFramingModeCompletePacket,
    /**
     * @brief Confirmed fixed-size CBR packet stream
     * @chinese 已确认固定包长的 CBR 字节流
     */
    TSNpkOpusFramingModeFixedCBRStream
};

/**
 * @brief Decoder failures with separate format, framing and capacity causes
 * @chinese 区分格式、分帧及容量原因的解码错误
 */
typedef NS_ERROR_ENUM(TSNpkOpusErrorDomain, TSNpkOpusErrorCode) {
    /**
     * @brief Unsupported header format
     * @chinese 不支持的头部格式
     */
    TSNpkOpusErrorUnsupportedFormat = 1000,
    /**
     * @brief Unconfirmed packet boundaries
     * @chinese 未确认包边界
     */
    TSNpkOpusErrorFramingUnconfirmed = 1001,
    /**
     * @brief Input is not configured or already closed
     * @chinese 输入未配置或已经关闭
     */
    TSNpkOpusErrorNotConfigured = 1002,
    /**
     * @brief Invalid packet format or duration
     * @chinese 包格式或时长无效
     */
    TSNpkOpusErrorInvalidPacket = 1003,
    /**
     * @brief Local input or output capacity exceeded
     * @chinese 超出本地输入或输出容量
     */
    TSNpkOpusErrorCapacityExceeded = 1004,
    /**
     * @brief Incomplete trailing packet
     * @chinese 尾部包不完整
     */
    TSNpkOpusErrorIncompleteFrame = 1005,
    /**
     * @brief Codec creation or decoding failure
     * @chinese 编解码创建或解码失败
     */
    TSNpkOpusErrorDecoderFailure = 1006
};

/**
 * @brief Stateful NPK Opus-to-PCM decoder with bounded frame reassembly
 * @chinese 带有界分帧重组的 NPK Opus 转 PCM 状态解码器
 *
 * @discussion
 * [EN]: Call all methods, including reset and property reads, on the same codec serial queue.
 *       Returns 16000 Hz mono signed Int16 little-endian PCM. It owns no queues or callbacks.
 * [CN]: 全部方法、reset 及属性读取应在同一编解码串行队列调用。
 *       输出 16000 Hz、单声道、有符号 Int16 小端 PCM；本类不持有队列或回调。
 */
@interface TSNpkOpusDecoder : NSObject

/**
 * @brief Whether a configured decoder still accepts input
 * @chinese 已配置的解码器是否仍接纳输入
 *
 * @discussion
 * [EN]: Configuration creates a fresh codec state; finish, reset or a failure closes input.
 * [CN]: 配置创建全新的编解码状态；finish、reset 或失败会封闭输入。
 *
 * @note
 * [EN]: Initially NO. A failure requires a new explicit configuration before more data is accepted.
 * [CN]: 初始为 NO；失败后必须重新显式配置才接纳数据。
 */
@property (nonatomic, assign, readonly) BOOL isConfigured;

/**
 * @brief Cumulative samples returned successfully in this configuration
 * @chinese 本次配置中已成功返回的累计样本数
 *
 * @discussion
 * [EN]: Counts actual decoded mono samples at 16000 Hz, independent of BLE notification count.
 * [CN]: 按 16000 Hz 单声道的真实解码样本计数，与 BLE 通知数量无关。
 *
 * @note
 * [EN]: Initially zero; reset or a new configuration clears it. Finish preserves the final count.
 * [CN]: 初始为零，reset 或新配置会清零；finish 保留最终计数。
 */
@property (nonatomic, assign, readonly) NSUInteger decodedSampleCount;

/**
 * @brief Encoded bytes waiting for a complete fixed-size packet
 * @chinese 等待组成完整定长包的编码字节数
 *
 * @discussion
 * [EN]: Only the confirmed fixed-CBR mode retains an incomplete packet across payloads.
 * [CN]: 仅已确认的固定 CBR 模式会跨载荷保留不完整包。
 *
 * @note
 * [EN]: Initially zero; always smaller than the configured packet size, at most 1274 bytes.
 * [CN]: 初始为零，始终小于配置包长，最多 1274 字节。
 */
@property (nonatomic, assign, readonly) NSUInteger pendingEncodedBytes;

/**
 * @brief Configure a fresh decoder using a verified framing mode
 * @chinese 按已核验分帧模式配置全新的解码器
 *
 * @param header
 * EN: Header with sampling=16000, channel=0 and frameMs of 10, 20, 40 or 60.
 * CN: sampling=16000、channel=0，frameMs 为 10、20、40 或 60 的音频头。
 *
 * @param framingMode
 * EN: Explicit firmware contract; bitrate never selects this mode automatically.
 * CN: 显式固件契约；不会根据 bitrate 自动选择模式。
 *
 * @param error
 * EN: Receives a format, framing or codec initialization failure.
 * CN: 返回格式、分帧或编解码初始化错误。
 *
 * @return
 * EN: YES when configured; NO leaves input closed. Old state is discarded in either case.
 * CN: 配置成功返回 YES；NO 时封闭输入，无论成功与否均丢弃原状态。
 *
 * @discussion
 * [EN]: Bitrate is 500-512000 bits/s, or zero when absent in complete-packet mode. Fixed CBR additionally
 *       requires an integral bitrate * frameMs / 8000 packet size of 1-1275 bytes. This is a local
 *       supported packet limit, not the general maximum size of all possible Opus packets.
 * [CN]: 码率须为 500-512000 比特/秒，完整包模式允许零表示缺失。固定 CBR 还要求
 *       bitrate * frameMs / 8000 为 1-1275 字节的整数包长；这是本地支持限制，不代表所有 Opus 包的理论上限。
 */
- (BOOL)configureWithHeader:(TSMetaOpusHead *)header
              framingMode:(TSNpkOpusFramingMode)framingMode
                    error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Decode a bounded payload without concealing missing packets
 * @chinese 解码有界载荷，不隐藏丢包或补零
 *
 * @param payload
 * EN: Nonempty encoded data; complete-packet mode accepts at most 1275 bytes.
 * CN: 非空编码数据；完整包模式最多接纳 1275 字节。
 *
 * @param error
 * EN: Receives a terminal decode failure; the caller must abort the current capture.
 * CN: 返回终止性的解码错误，调用方须结束当前采集。
 *
 * @return
 * EN: Independent Int16LE PCM, empty data while waiting for a partial fixed packet, or nil on error.
 *       One call produces at most 64000 PCM bytes; the caller bounds downstream pending output.
 * CN: 返回独立的 Int16LE PCM；等待定长残帧时返回空数据，失败返回 nil。
 *     单次最多输出 64000 字节 PCM，下游等待交付的数据预算由调用方管理。
 */
- (nullable NSData *)decodePayload:(NSData *)payload error:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Finish natural input after its final complete PCM has been delivered
 * @chinese 在最后完整 PCM 已交付后正常结束输入
 *
 * @param error
 * EN: Receives an incomplete trailing packet error; no padding or PLC is performed.
 * CN: 返回尾部残包错误，不补零也不进行丢包隐藏。
 *
 * @return
 * EN: YES for a configured stream with no trailing bytes; NO otherwise. Input closes in both cases.
 * CN: 已配置且无尾部残字节时返回 YES，否则为 NO；两种结果均封闭输入。
 */
- (BOOL)finishWithError:(NSError * _Nullable * _Nullable)error;

/**
 * @brief Destroy codec state and discard residual bytes and counters
 * @chinese 销毁编解码状态，丢弃残留字节并清空计数
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
