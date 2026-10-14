//
//  TSNpkEpo.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2026/7/9.
//

#import "TSNpkKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief NPK EPO(GNSS ephemeris) implementation
 * @chinese NPK 端 EPO(GNSS 星历) 实现
 *
 * @discussion
 * [EN]: Implements TSEpoInterface on the New Platform. Update pipeline for server sources:
 *       necessity check -> request ephemeris URLs -> download per-constellation files -> merge into
 *       one device bin -> push. fileURLs source: local files are used directly, remote ones are
 *       downloaded, then merged and pushed the same way. binFile source is pushed as-is.
 *       Ephemeris files/merge format follow the Android implementation.
 * [CN]: 在新平台上实现 TSEpoInterface。服务器来源的更新流程：
 *       必要性检查 -> 请求星历 URL -> 下载各星座文件 -> 合并成单个设备 bin -> 推送。
 *       fileURLs 来源：本地文件直接使用、远程文件先下载，再同样合并推送；binFile 来源原样推送。
 *       星历文件与合并格式对齐安卓实现。
 */
@interface TSNpkEpo : TSNpkKitBase<TSEpoInterface>

@end

NS_ASSUME_NONNULL_END
