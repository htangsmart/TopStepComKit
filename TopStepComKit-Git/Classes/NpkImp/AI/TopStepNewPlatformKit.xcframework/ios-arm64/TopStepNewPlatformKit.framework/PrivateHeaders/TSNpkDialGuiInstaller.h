#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
@class TSNpkDialInspectedPackage, TSNpkFileTransferService;
NS_ASSUME_NONNULL_BEGIN

/** @brief GUI slot selection and upload adaptation, without public task ownership.
 * @chinese GUI 槽位选择与上传适配，不持有公开任务所有权。
 */
@interface TSNpkDialGuiInstaller : NSObject
/** @brief Bind inspected metadata to the previously captured upload operation.
 * @chinese 将检查结果绑定到此前已捕获的上传操作。
 * @param package EN: Inspected package. CN: 已校验包。
 * @param service EN: Captured upload operation. CN: 已捕获上传操作。
 * @return EN: Installer. CN: 安装器。
 */
- (instancetype)initWithPackage:(TSNpkDialInspectedPackage *)package service:(TSNpkFileTransferService *)service;
/** @brief Query slots and upload; Success is reported only after protocol END_ACK.
 * @chinese 查询槽位并上传，仅协议 END_ACK 后报告成功。
 * @param options EN: Optional strict target slot. CN: 可选严格目标槽位。
 * @param progress EN: Transfer progress. CN: 传输进度。
 * @param completion EN: Success, Failed or Canceled. CN: 成功、失败或取消结果。
 */
- (void)installWithOptions:(nullable TSDialInstallOptions *)options
                  progress:(nullable TSFileTransferProgressBlock)progress
                completion:(void (^)(TSFileTransferStatus status, NSError *_Nullable error))completion;
/** @brief Cancel the owned upload only. @chinese 仅取消本次持有的上传。
 * @param completion EN: Cancellation decision. CN: 取消裁决。
 */
- (void)cancelWithCompletion:(TSCompletionBlock)completion;
/** @brief Deterministic slot policy used by installation. @chinese 安装使用的确定性槽位策略。
 * @param slots EN: Current slots. CN: 当前槽位。
 * @param length EN: Full OTA length. CN: 完整 OTA 长度。
 * @param options EN: Optional strict target. CN: 可选严格目标。
 * @param error EN: No space or invalid slot. CN: 空间不足或槽位无效。
 * @return EN: Slot or nil. CN: 槽位或 nil。
 */
+ (nullable TSDialSlotModel *)targetSlotInSlots:(NSArray<TSDialSlotModel *> *)slots
                                packageLength:(unsigned long long)length
                                      options:(nullable TSDialInstallOptions *)options
                                        error:(NSError *_Nullable *_Nullable)error;
@end
NS_ASSUME_NONNULL_END
