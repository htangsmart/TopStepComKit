//
//  TSMetaFileUploadChecksum.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Incremental CRC-16/ARC: polynomial 0x8005, reflected, xor-out zero.
 * @chinese 增量 CRC-16/ARC：反射多项式 0xA001，初次传零，无最终异或。
 * @param data EN: Next bytes. CN: 下一段字节。
 * @param initialCRC EN: Zero initially, previous result afterwards. CN: 首段零，后续段传上次结果。
 * @return EN: Updated CRC state. CN: 更新后的 CRC 状态。
 */
FOUNDATION_EXPORT uint16_t TSMetaFileUploadCRC16ARC(NSData *data, uint16_t initialCRC);

/**
 * @brief Incremental CRC-16/BUYPASS: polynomial 0x8005, unreflected, xor-out zero.
 * @chinese 增量 CRC-16/BUYPASS：高位优先多项式 0x8005，初次传零，无最终异或。
 * @param data EN: Next bytes. CN: 下一段字节。
 * @param initialCRC EN: Zero initially, previous result afterwards. CN: 首段零，后续段传上次结果。
 * @return EN: Updated CRC state. CN: 更新后的 CRC 状态。
 */
FOUNDATION_EXPORT uint16_t TSMetaFileUploadCRC16BUYPASS(NSData *data, uint16_t initialCRC);

NS_ASSUME_NONNULL_END
