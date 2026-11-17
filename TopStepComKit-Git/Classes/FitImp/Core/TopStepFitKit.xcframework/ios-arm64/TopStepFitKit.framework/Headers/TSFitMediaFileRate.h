#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <math.h>

typedef struct {
    uint32_t totalBytes;
    uint32_t lastBytes;
    uint32_t windowBytes;
    double lastGrowthTime;
    double windowTime;
    double bytesPerSecond;
    bool hasSample;
    bool windowActive;
} TSFitMediaFileRate;

static inline bool TSFitMediaFileRateExpire(TSFitMediaFileRate *rate, double now) {
    if (!rate->windowActive || now - rate->lastGrowthTime < 2.0) {
        return false;
    }
    bool wasVisible = rate->bytesPerSecond > 0;
    rate->bytesPerSecond = 0;
    rate->windowActive = false;
    return wasVisible;
}

static inline double TSFitMediaFileRateUpdate(TSFitMediaFileRate *rate, double progress, double now) {
    if (rate->totalBytes == 0 || !isfinite(now) ||
        (rate->hasSample && now < rate->lastGrowthTime)) {
        return 0;
    }
    if (!isfinite(progress) || progress < 0 || progress >= 1) {
        rate->bytesPerSecond = 0;
        rate->windowActive = false;
        return 0;
    }

    // 已核验的 FitCloudKit 以双精度回调已写入字节数除以握手文件大小。
    double scaledBytes = progress * rate->totalBytes;
    uint32_t bytes = (uint32_t)llround(scaledBytes);
    if (fabs(scaledBytes - bytes) > 1e-5) {
        // 清单大小与下载握手大小不一致时，不能依赖按比例还原的字节数。
        rate->totalBytes = 0;
        rate->bytesPerSecond = 0;
        rate->windowActive = false;
        return 0;
    }
    TSFitMediaFileRateExpire(rate, now);
    if (rate->hasSample && bytes == rate->lastBytes) {
        return rate->bytesPerSecond;
    }
    if (!rate->windowActive || bytes < rate->lastBytes) {
        rate->windowBytes = bytes;
        rate->windowTime = now;
        rate->bytesPerSecond = 0;
        rate->windowActive = true;
    } else if (now - rate->windowTime >= 0.5) {
        rate->bytesPerSecond = (bytes - rate->windowBytes) / (now - rate->windowTime);
        rate->windowBytes = bytes;
        rate->windowTime = now;
    }
    rate->lastBytes = bytes;
    rate->lastGrowthTime = now;
    rate->hasSample = true;
    return rate->bytesPerSecond;
}
