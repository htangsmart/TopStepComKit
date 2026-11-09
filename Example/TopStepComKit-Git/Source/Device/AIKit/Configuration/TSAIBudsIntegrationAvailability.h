// 旧发布版配置继续编译原 Demo；新联调入口要求本地中立契约和两个 Provider 均已安装。
#ifndef TSAIBudsIntegrationAvailability_h
#define TSAIBudsIntegrationAvailability_h

#if __has_include(<TopStepAIKit/TSAIDeviceAuthenticationBridge.h>) && \
    __has_include(<TopStepAIKit/TSAIBudsManager.h>) && \
    __has_include(<TopStepAIKit/TSAIWoQiConfiguration.h>) && \
    __has_include(<TopStepBudsKit/TSBudsAIDeviceBridge.h>)
#define TS_BUDS_AI_INTEGRATION_AVAILABLE 1
#else
#define TS_BUDS_AI_INTEGRATION_AVAILABLE 0
#endif

#endif
