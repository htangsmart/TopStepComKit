#import "TSAIBudsIntegrationAvailability.h"
#if TS_BUDS_AI_INTEGRATION_AVAILABLE
#import "TSBaseVC.h"

/**
 * @brief Configure the host AI provider before connecting Buds
 * @chinese 在连接 Buds 前配置宿主 AI Provider
 */
@interface TSAIProviderSetupVC : TSBaseVC
@end
#endif
