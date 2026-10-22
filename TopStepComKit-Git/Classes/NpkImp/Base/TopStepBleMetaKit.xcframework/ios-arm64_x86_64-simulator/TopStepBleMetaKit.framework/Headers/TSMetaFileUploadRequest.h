//
//  TSMetaFileUploadRequest.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Explicit input format. @chinese 明确指定输入格式，不按扩展名判断。 */
typedef NS_ENUM(NSUInteger, TSMetaFileUploadFormat) {
    TSMetaFileUploadFormatRaw,
    TSMetaFileUploadFormatContainer,
};

/**
 * @brief Immutable upload intent bound to the original connection.
 * @chinese 绑定原始连接的不可变上传请求；文件验证在后台准备数据源时完成。
 */
@interface TSMetaFileUploadRequest : NSObject <NSCopying>

/**
 * @brief Local source file URL
 * @chinese 本地源文件地址
 *
 * @discussion
 * [EN]: Copied by the factory without opening the file. Source preparation requires a
 *       readable, nonempty regular file at a file URL and creates a private snapshot;
 *       the caller's file is neither modified nor deleted by the upload source.
 * [CN]: 工厂仅复制地址，不打开文件。准备阶段要求 file URL 指向可读、非空的普通文件，
 *       并创建私有快照；上传数据源不会修改或删除调用方文件。
 */
@property (nonatomic, copy, readonly) NSURL *fileURL;

/**
 * @brief Explicit source format
 * @chinese 明确指定的源文件格式
 *
 * @discussion
 * [EN]: Set by the selected factory. Raw creates a virtual TOPSTEP header; Container
 *       validates an existing TOPSTEP container. The filename extension is not used.
 * [CN]: 由所选工厂设置。Raw 生成虚拟 TOPSTEP 头，Container 校验已有 TOPSTEP 容器；
 *       不根据文件扩展名推断格式。
 */
@property (nonatomic, assign, readonly) TSMetaFileUploadFormat format;

/**
 * @brief Raw file protocol type
 * @chinese 原始文件的协议类型
 *
 * @discussion
 * [EN]: Raw requests accept 17 (EPO), 23 (music), or 25 (offline map), validated during
 *       source preparation. Container requests leave this value at zero and derive
 *       their effective type from the validated item headers instead.
 * [CN]: Raw 请求仅支持 17（星历）、23（音乐）、25（离线地图），在准备数据源时校验。
 *       Container 请求中此值保持零，实际类型由校验后的条目头推导。
 */
@property (nonatomic, assign, readonly) uint8_t fileType;

/**
 * @brief Raw file target basename
 * @chinese 原始文件在设备端的名称
 *
 * @discussion
 * [EN]: Copied for Raw requests and nil for Container requests. The UTF-8 name must
 *       occupy 1...64 bytes, contain no path separators or NUL, and not equal "." or
 *       "..". No PB directory is included and invalid names are not truncated.
 * [CN]: Raw 请求复制此名称，Container 请求为 nil。UTF-8 长度必须为 1...64 字节，
 *       不含路径分隔符或 NUL，且不能为 "." 或 ".."；不包含 PB 目录，不截断非法名称。
 */
@property (nonatomic, copy, readonly, nullable) NSString *fileName;

/**
 * @brief Optional raw file item index
 * @chinese 原始文件的可选条目索引
 *
 * @discussion
 * [EN]: Copied for Raw requests. Nil writes zero into the virtual item header;
 *       otherwise source preparation requires a finite integer in 0...255.
 *       Container requests do not use this property.
 * [CN]: Raw 请求复制此值。nil 在虚拟条目头中写入零；非空时准备阶段要求为
 *       0...255 的有限整数。Container 请求不使用此属性。
 */
@property (nonatomic, copy, readonly, nullable) NSNumber *index;

/**
 * @brief Optional WATCHFACE container item index override
 * @chinese WATCHFACE 容器条目索引的可选覆盖值
 *
 * @discussion
 * [EN]: Container-only copied value; nil preserves the original header. A non-nil
 *       value must be a finite integer in 0...255 and requires a fully validated
 *       container with exactly one WATCHFACE item (type 5). Only that item's index
 *       byte in the in-memory transfer header changes; the source file, TBUI id,
 *       body checksum and other header bytes remain unchanged.
 * [CN]: 仅用于 Container 请求并复制保存；nil 保留原头。非空值须为 0...255 的有限整数，
 *       且容器完整校验后必须恰含一个 WATCHFACE（类型 5）条目。仅覆盖内存传输头中
 *       该条目的索引字节，不改源文件、TBUI 编号、正文 CRC 或其他头字节。
 */
@property (nonatomic, copy, readonly, nullable) NSNumber *containerItemIndexOverride;

/**
 * @brief Whether this request requires a single game container
 * @chinese 是否要求单条目游戏容器
 *
 * @discussion
 * [EN]: Set only by the game container factory. After full container validation,
 *       the source requires one item with file type 7, 8 or 12 and pack type 2.
 * [CN]: 仅由游戏容器工厂设置。数据源完成完整容器校验后，要求恰含一个
 *       文件类型为 7、8 或 12、打包类型为 2 的条目。
 *
 * @note
 * [EN]: Defaults to NO for existing factories. File type is OTA metadata, not
 *       the public game type or skin number; this flag does not validate those values.
 * [CN]: 既有工厂默认为 NO。文件类型属于 OTA 元数据，不是公版游戏类型或皮肤编号；
 *       此标记不负责校验游戏类型与皮肤编号。
 */
@property (nonatomic, assign, readonly) BOOL gameContainer;

/**
 * @brief Optional game item index override
 * @chinese 游戏条目索引的可选覆盖值
 *
 * @discussion
 * [EN]: Copied by the game container factory. After full validation, only the
 *       item's in-memory index byte changes; the source file and body remain unchanged.
 * [CN]: 由游戏容器工厂复制保存。完整校验后只修改条目在内存中的索引字节，
 *       不改源文件及正文。
 *
 * @note
 * [EN]: Nil preserves the existing index. A supplied value must be a finite
 *       integer NSNumber in 0...255 and requires storage_addr == 0; a nonzero
 *       physical address cannot be combined with a slot override. Invalid values are not truncated.
 * [CN]: nil 保留原索引；非空值必须是 0...255 的有限整数 NSNumber，
 *       且条目 storage_addr 必须为 0；非零物理地址不能与槽位覆盖同时使用。
 *       数据源拒绝非法值，不进行截断。
 */
@property (nonatomic, copy, readonly, nullable) NSNumber *gameItemIndexOverride;

/**
 * @brief Captured peripheral identity
 * @chinese 捕获的原始外设标识
 *
 * @discussion
 * [EN]: Required copied UUID captured before asynchronous business preparation.
 *       The uploader compares it with the connected peripheral together with
 *       connectionGeneration; it does not retarget the request after reconnecting.
 * [CN]: 必填 UUID，在业务异步准备前捕获并复制。上传器结合 connectionGeneration
 *       核对当前连接，不会在重连后将旧请求重新指向设备。
 */
@property (nonatomic, copy, readonly) NSUUID *deviceIdentifier;

/**
 * @brief Captured connection generation
 * @chinese 捕获的原始连接代次
 *
 * @discussion
 * [EN]: Connection-session counter captured with deviceIdentifier; it is not a
 *       timestamp. Zero is rejected during source preparation. Uploading requires
 *       an exact match with the current generation, including same-device reconnects.
 * [CN]: 与 deviceIdentifier 一起捕获的连接会话计数，不是时间戳。准备数据源时拒绝零值；
 *       上传时必须与当前代次完全一致，同一设备重连也不能复用旧代次。
 */
@property (nonatomic, assign, readonly) NSUInteger connectionGeneration;

/**
 * @brief Create an immutable raw file request.
 * @chinese 构建不可变原始文件请求，不执行文件读写。
 * @param fileURL EN: Local file URL. CN: 本地文件地址。
 * @param fileType EN: 17 (EPO), 23 (music), or 25 (map). CN: 17 星历、23 音乐或 25 地图。
 * @param fileName EN: UTF-8 basename, at most 64 bytes. CN: UTF-8 名称，最多 64 字节。
 * @param index EN: Optional integer in 0...255. CN: 可选的 0...255 整数索引。
 * @param deviceIdentifier EN: Captured peripheral identity. CN: 已捕获的设备标识。
 * @param connectionGeneration EN: Captured connection generation. CN: 已捕获的连接代次。
 * @return EN: Request whose values are copied. CN: 已复制参数的请求。
 */
+ (instancetype)rawRequestWithFileURL:(NSURL *)fileURL
                           fileType:(uint8_t)fileType
                           fileName:(NSString *)fileName
                              index:(nullable NSNumber *)index
                   deviceIdentifier:(NSUUID *)deviceIdentifier
               connectionGeneration:(NSUInteger)connectionGeneration;

/**
 * @brief Preserve an existing TOPSTEP container without metadata rewriting.
 * @chinese 使用已有 TOPSTEP 容器，不改写名称、索引及未知头字段。
 * @param fileURL EN: Local container URL. CN: 本地容器文件地址。
 * @param deviceIdentifier EN: Captured peripheral identity. CN: 已捕获的设备标识。
 * @param connectionGeneration EN: Captured connection generation. CN: 已捕获的连接代次。
 * @return EN: Immutable container request. CN: 不可变容器请求。
 */
+ (instancetype)containerRequestWithFileURL:(NSURL *)fileURL
                         deviceIdentifier:(NSUUID *)deviceIdentifier
                     connectionGeneration:(NSUInteger)connectionGeneration;

/** @brief Override the single validated WATCHFACE item in the in-memory header.
 * @chinese 仅覆盖已完整验证的单个 WATCHFACE 条目的内存头索引。
 * @param fileURL EN: Container URL. CN: 容器地址。
 * @param index EN: Optional integer 0...255. CN: 可选的 0...255 整数。
 * @param deviceIdentifier EN: Captured device. CN: 捕获的设备。
 * @param connectionGeneration EN: Captured connection. CN: 捕获的连接代次。
 * @return EN: Immutable request. CN: 不可变请求。
 */
+ (instancetype)containerRequestWithFileURL:(NSURL *)fileURL
                containerItemIndexOverride:(nullable NSNumber *)index
                          deviceIdentifier:(NSUUID *)deviceIdentifier
                      connectionGeneration:(NSUInteger)connectionGeneration;

/**
 * @brief Create a request restricted to a single TOPSTEP-packed game item
 * @chinese 创建限定单个 TOPSTEP 打包游戏条目的请求
 *
 * @param fileURL
 * EN: Complete TOPSTEP container URL; source preparation validates its content.
 * CN: 完整 TOPSTEP 容器地址，由数据源准备阶段校验内容。
 *
 * @param index
 * EN: Optional integer in 0...255; nil preserves the original item index.
 *     A supplied index requires a zero item storage address.
 * CN: 可选的 0...255 整数；nil 保留原条目索引。
 *     指定索引时，条目物理存储地址必须为 0。
 *
 * @param deviceIdentifier
 * EN: Captured original device identity.
 * CN: 已捕获的原始设备标识。
 *
 * @param connectionGeneration
 * EN: Captured original connection generation.
 * CN: 已捕获的原始连接代次。
 *
 * @return
 * EN: Immutable request; constructing it does not read or modify the source file.
 * CN: 不可变请求；构建时不读取或修改源文件。
 */
+ (instancetype)gameContainerRequestWithFileURL:(NSURL *)fileURL
                              targetSlotIndex:(nullable NSNumber *)index
                             deviceIdentifier:(NSUUID *)deviceIdentifier
                         connectionGeneration:(NSUInteger)connectionGeneration;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
