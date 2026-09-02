//
//  TSEpoDefines.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/9.
//

#import <Foundation/Foundation.h>

/**
 * @brief EPO file constellation type
 * @chinese EPO 星历文件星座类型
 *
 * @discussion
 * [EN]: Only meaningful for multi-constellation(GNSS) devices, where each constellation needs its
 *       own EPO file. Used when providing custom EPO files via [TSEpoSource fileURLs:types:].
 *       WARNING: the raw values(0..5) MUST match the device protocol's constellation numbering.
 *       Do NOT reorder or reassign them, otherwise custom files would be bound to the wrong
 *       constellation.
 * [CN]: 仅对多星座(GNSS)设备有意义，每个星座需要独立的星历文件。
 *       在通过 [TSEpoSource fileURLs:types:] 自备星历文件时使用。
 *       警告：原始值(0..5)必须与设备协议的星座编号一致，切勿重排或重新赋值，
 *       否则自备文件会被绑定到错误的星座。
 */
typedef NS_ENUM(NSUInteger, TSEpoType) {
    /** GPS / 美国 */
    eTSEpoTypeGPS     = 0,
    /** GLONASS / 俄罗斯 */
    eTSEpoTypeGLO     = 1,
    /** Galileo / 欧盟 */
    eTSEpoTypeGALILEO = 2,
    /** BeiDou / 中国北斗 */
    eTSEpoTypeBEIDOU  = 3,
    /** NavIC(IRNSS) / 印度 */
    eTSEpoTypeIRN     = 4,
    /** QZSS / 日本 */
    eTSEpoTypeQZSS    = 5,
};

/**
 * @brief EPO update source type
 * @chinese EPO 更新星历来源类型
 *
 * @discussion
 * [EN]: Identifies where the EPO ephemeris data comes from. The four sources are mutually
 *       exclusive; a TSEpoSource is created by a dedicated factory method and locked to one type.
 * [CN]: 标识 EPO 星历数据的来源。四种来源互斥；TSEpoSource 通过专用工厂方法创建，
 *       创建后即锁定为某一种类型，不会出现非法组合。
 */
typedef NS_ENUM(NSUInteger, TSEpoSourceType) {
    /** Builtin server / SDK 内置服务器 */
    eTSEpoSourceBuiltinServer = 0,
    /** Custom server / 自定义服务器地址(响应格式需与内置一致) */
    eTSEpoSourceCustomServer  = 1,
    /** Self-provided per-constellation files / 自备各星座星历文件(SDK 负责合并+推送) */
    eTSEpoSourceFileURLs      = 2,
    /** Self-provided merged bin / 自备已合并的最终 bin 文件(SDK 仅推送) */
    eTSEpoSourceBinFile       = 3,
};
