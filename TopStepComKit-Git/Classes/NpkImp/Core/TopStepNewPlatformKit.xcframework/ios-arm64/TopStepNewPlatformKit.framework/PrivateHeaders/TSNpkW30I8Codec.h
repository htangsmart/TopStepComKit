#ifndef TSNPK_W30_I8_CODEC_H
#define TSNPK_W30_I8_CODEC_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

enum {
    W30_I8_OK = 0,
    W30_I8_INVALID_ARGUMENT = 1,
    W30_I8_INVALID_DIMENSIONS = 2,
    W30_I8_INVALID_LENGTH = 3,
    W30_I8_OVERFLOW = 4,
    W30_I8_OUT_OF_MEMORY = 5,
};

/** @brief Compute palette plus index bytes. @chinese 计算调色板加索引的字节数。
 * @param width EN: Pixel width. CN: 像素宽度。
 * @param height EN: Pixel height. CN: 像素高度。
 * @param payload_size EN: Output byte count. CN: 输出字节数。
 * @return EN: W30_I8 status. CN: W30_I8 状态码。
 */
int TSNpkW30I8PayloadSize(uint32_t width, uint32_t height, size_t *payload_size);

/** @brief Encode straight RGBA into W30 I8. @chinese 将直通 RGBA 编码为 W30 I8。
 * @param rgba EN: Straight RGBA bytes. CN: 直通 RGBA 字节。
 * @param rgba_length EN: Exact input length. CN: 精确输入长度。
 * @param width EN: Pixel width. CN: 像素宽度。
 * @param height EN: Pixel height. CN: 像素高度。
 * @param payload EN: Caller-owned output buffer. CN: 调用方提供的输出缓冲。
 * @param payload_length EN: Exact output size. CN: 精确输出大小。
 * @return EN: W30_I8 status. CN: W30_I8 状态码。
 */
int TSNpkW30I8EncodeRGBA(const uint8_t *rgba,
                       size_t rgba_length,
                       uint32_t width,
                       uint32_t height,
                       uint8_t *payload,
                       size_t payload_length);

#ifdef __cplusplus
}
#endif

#endif
