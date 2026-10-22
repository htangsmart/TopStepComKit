//
//  TSDialGuiBinary.h
//  TopStepToolKit
//
//  Created by Codex on 2026/9/9.
//  Copyright © 2026 TopStep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdint.h>

/** @brief Internal wire-layout constants. @chinese 内部二进制布局常量。 */
static const NSUInteger kTSDialGuiHeaderSize = 64;
static const NSUInteger kTSDialGuiInfoOffset = 64;
static const NSUInteger kTSDialGuiControlOffset = 160;
static const NSUInteger kTSDialGuiControlSize = 32;
static const NSUInteger kTSDialGuiControlMaxCount = 100;
static const NSUInteger kTSDialGuiImageIndexOffset = 3360;
static const NSUInteger kTSDialGuiImageIndexSize = 12;
static const NSUInteger kTSDialGuiImageMaxCount = 2048;
static const NSUInteger kTSDialGuiFontIndexOffset = 27936;
static const NSUInteger kTSDialGuiFontIndexSize = 384;
static const NSUInteger kTSDialGuiFontMaxCount = 32;
static const NSUInteger kTSDialGuiGlyphMaxCount = 95;
static const NSUInteger kTSDialGuiImageDataOffset = 40224;
static const NSUInteger kTSDialGuiTailSize = 4;
static const NSUInteger kTSDialGuiOTAHeaderSize = 1024;

/**
 * @brief Read little-endian bytes from a caller-validated range.
 * @chinese 从调用方已验证的范围读取小端字节。
 * @param bytes EN: Source bytes. CN: 原始字节。
 * @param offset EN: Start offset. CN: 起始偏移。
 * @param count EN: Byte count up to four. CN: 最多四个字节。
 * @return EN: Unsigned value. CN: 无符号数值。
 */
NS_INLINE uint32_t TSDialGuiReadLE(const uint8_t *bytes, NSUInteger offset, NSUInteger count) {
    uint32_t value = 0;
    for (NSUInteger i = 0; i < count; i++) {
        value |= ((uint32_t)bytes[offset + i]) << (i * 8);
    }
    return value;
}

/**
 * @brief Write low-order little-endian bytes into a caller-validated range.
 * @chinese 将低位小端字节写入调用方已验证的范围。
 * @param bytes EN: Destination bytes. CN: 目标字节。
 * @param offset EN: Start offset. CN: 起始偏移。
 * @param value EN: Unsigned value. CN: 无符号数值。
 * @param count EN: Byte count up to four. CN: 最多四个字节。
 */
NS_INLINE void TSDialGuiWriteLE(uint8_t *bytes, NSUInteger offset, NSUInteger value, NSUInteger count) {
    for (NSUInteger i = 0; i < count; i++) {
        bytes[offset + i] = (uint8_t)(value >> (i * 8));
    }
}

/**
 * @brief CRC-16/BUYPASS: poly 8005, initial 0, no reflection or final XOR.
 * @chinese CRC-16/BUYPASS：多项式 8005，初始为零，不反射且无最终异或。
 * @param data EN: Bytes to checksum. CN: 待校验字节。
 * @return EN: Checksum; 123456789 produces FEE8. CN: 校验值，123456789 对应 FEE8。
 */
NS_INLINE uint16_t TSDialGuiCRC16Buypass(NSData *data) {
    const uint8_t *bytes = data.bytes;
    uint16_t checksum = 0;
    for (NSUInteger i = 0; i < data.length; i++) {
        checksum ^= (uint16_t)((uint16_t)bytes[i] << 8);
        for (NSUInteger j = 0; j < 8; j++) {
            checksum = (uint16_t)((checksum & 0x8000) != 0 ?
                                  ((uint32_t)checksum << 1) ^ 0x8005 : (uint32_t)checksum << 1);
        }
    }
    return checksum;
}
