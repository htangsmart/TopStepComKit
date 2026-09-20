//
//  AIBudsHandlers.h
//  AIBuds
//
//  Created by pcjbird on 2026-02-12.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#ifndef AIBudsHandlers_h
#define AIBudsHandlers_h

#import <Foundation/Foundation.h>

@protocol AIBudsFoundDeviceConvertible;
@class AIBudsMediaFileInfoModel;
@class AIBudsImportedMediaFileModel;

typedef NS_ENUM(NSInteger, AIBudsCameraOtaProgressPhase);

NS_ASSUME_NONNULL_BEGIN

/// Handler invoked when a device is discovered during scanning.
/// - Parameters:
///   - device: The discovered device that conforms to `AIBudsFoundDeviceConvertible`.
///   - isExistingDevice: Indicates whether the device is already in the discovered devices list. A value of true means reporting an updated advertisement data and RSSI for that device.
typedef void (^AIBudsScanningOnDeviceFoundHandler)(id<AIBudsFoundDeviceConvertible> _Nonnull device, BOOL isExistingDevice);

/// Handler invoked when the scanning process stops.
typedef void (^AIBudsOnScanStopHandler)(void);

/// A common completion handler used throughout the SDK.
///
/// - Parameters:
///   - success: Indicates whether the operation completed successfully.
///   - error: An optional error object that provides details if the operation failed; `nil` if the operation succeeded.
typedef void (^AIBudsCompletionHandler)(BOOL success,
                                        NSError *_Nullable error);

/// Device response completion handler, which will also return a status code.
/// - Parameters:
///   - success: Indicates whether the operation completed successfully.
///   - statusCode: The status code returned by the device. `nil` if the operation failed.
///   - error: An optional error object that provides details if the operation failed; `nil` if the operation succeeded.
typedef void (^AIBudsStatusCodeCompletionHandler)(BOOL success,
                                                  NSNumber *_Nullable statusCode,
                                                  NSError *_Nullable error);

/// Callback block for OTA upgrade start completion
/// - Parameters:
///   - success: whether the OTA start succeeded
///   - error: error information if failed
typedef void (^AIBudsOtaStartCompletionHandler)(BOOL success,
                                                NSError *_Nullable error);

/// OTA upgrade progress callback
/// - Parameters:
///   - progress: progress value, range 0.0–1.0
typedef void (^AIBudsOtaProgressHandler)(CGFloat progress);

/// The OTA upgrade completion callback
/// - Parameters:
///   - success: whether upgrade success
///   - avgSpeed: the avg transfer speed, kB/s
///   - error: error information if failed
typedef void (^AIBudsOtaCompletionHandler)(BOOL success,
                                           CGFloat avgSpeed,
                                           NSError *_Nullable error);

/// Callback block for camera OTA upgrade configure hotspot starting
typedef void (^AIBudsCameraOtaConfigureHotspotStartingHandler)(void);

/// Callback block for camera OTA upgrade configure hotspot completion
/// - Parameters:
///   - success: whether the configuration succeeded
///   - error: error information if failed
typedef void (^AIBudsCameraOtaHotspotConfigureCompletionHandler)(BOOL success,
                                                                 NSError *_Nullable error);

/// Callback block for entering camera OTA mode starting
typedef void (^AIBudsEnterCameraOtaModeStartingHandler)(void);

/// Callback block for entering camera OTA mode completion
/// - Parameters:
///   - success: whether entering OTA mode succeeded
///   - error: error information if failed
typedef void (^AIBudsEnterCameraOtaModeCompletionHandler)(BOOL success,
                                                          NSError *_Nullable error);

/// Callback block for waiting for device hotspot open during camera OTA upgrade.
typedef void (^AIBudsCameraOtaStartingToWaitForHotspotOpenHandler)(void);

/// Callback block for camera OTA upgrade connecting device hotspot starting
/// - Parameters:
///   - ssid: the SSID of the device hotspot
typedef void (^AIBudsCameraOtaConnectDeviceHotspotStartingHandler)(NSString *ssid);

/// Callback block for camera OTA upgrade connecting device hotspot completion
/// - Parameters:
///   - success: whether the connection succeeded
///   - error: error information if failed
typedef void (^AIBudsCameraOtaDeviceHotspotConnectCompletionHandler)(BOOL success,
                                                                     NSError *_Nullable error);

/// Callback block for camera OTA upgrade http server starting
typedef void (^AIBudsCameraOtaHttpServerStartingHandler)(void);

/// Callback block for camera OTA upgrade http server start completion
/// - Parameters:
///   - success: whether the HTTP server start succeeded
///   - error: error information if failed
typedef void (^AIBudsCameraOtaHttpServerStartCompletionHandler)(BOOL success,
                                                                NSError *_Nullable error);

/// Callback block for camera OTA upgrade sending firmware url
/// - Parameters:
///   - firmwareUrl: the firmware URL to be sent
typedef void (^AIBudsCameraOtaSendingFirmwareUrlHandler)(NSString *firmwareUrl);

/// Callback block for camera OTA upgrade sending firmware url completion
/// - Parameters:
///   - success: whether sending firmware URL succeeded
///   - error: error information if failed
typedef void (^AIBudsCameraOtaFirmwareUrlSendCompletionHandler)(BOOL success,
                                                                NSError *_Nullable error);

/// Callback block for camera OTA upgrade start completion
/// - Parameters:
///   - success: whether the camera OTA start succeeded
///   - error: error information if failed
typedef void (^AIBudsCameraOtaStartCompletionHandler)(BOOL success,
                                                      NSError *_Nullable error);

/// Callback block for camera OTA upgrade file transfer started
typedef void (^AIBudsCameraOtaFileTransferStartedHandler)(void);

/// Callback block for camera OTA upgrade file transfer completed
typedef void (^AIBudsCameraOtaFileTransferCompletedHandler)(void);

/// Callback block for waiting for device flashing during camera OTA upgrade.
typedef void (^AIBudsCameraOtaWaitingForFlashingHandler)(void);

/// Callback block for camera OTA upgrade flashing started
typedef void (^AIBudsCameraOtaFlashingStartedHandler)(void);

/// Callback block for camera OTA upgrade flashing completed
typedef void (^AIBudsCameraOtaFlashingCompletedHandler)(void);

/// Camera OTA upgrade progress callback
/// - Parameters:
///   - phase: the current progress phase
///   - progress: progress value, range 0–100
typedef void (^AIBudsCameraOtaPhaseProgressHandler)(AIBudsCameraOtaProgressPhase phase,
                                                    NSInteger progress);

/// The camera OTA upgrade completion callback
/// - Parameters:
///   - success: whether upgrade success
///   - error: error information if failed
typedef void (^AIBudsCameraOtaCompletionHandler)(BOOL success,
                                                 NSError *_Nullable error);

/// Callback block for file import configure hotspot starting
typedef void (^AIBudsMediaFileImportConfigureHotspotStartingHandler)(void);

/// Callback block for file import configure hotspot completion
/// - Parameters:
///   - success: whether the configuration succeeded
///   - error: error information if failed
typedef void (^AIBudsMediaFileImportHotspotConfigureCompletionHandler)(BOOL success,
                                                                       NSError *_Nullable error);

/// Callback block for entering file transfer mode starting
typedef void (^AIBudsEnterMediaFileTransferModeStartingHandler)(void);

/// Callback block for entering file transfer mode completion
/// - Parameters:
///   - success: whether entering file transfer mode succeeded
///   - error: error information if failed
typedef void (^AIBudsEnterMediaFileTransferModeCompletionHandler)(BOOL success,
                                                                  NSError *_Nullable error);

/// Callback block for waiting for device hotspot open during file import.
typedef void (^AIBudsMediaFileImportStartingToWaitForHotspotOpenHandler)(void);

/// Callback block for file import connecting device hotspot starting
/// - Parameters:
///   - ssid: the SSID of the device hotspot
typedef void (^AIBudsMediaFileImportConnectDeviceHotspotStartingHandler)(NSString *ssid);

/// Callback block for file import connecting device hotspot completion
/// - Parameters:
///   - success: whether the connection succeeded
///   - error: error information if failed
typedef void (^AIBudsMediaFileImportDeviceHotspotConnectCompletionHandler)(BOOL success,
                                                                           NSError *_Nullable error);

/// Callback block for file import prepare completion
/// - Parameters:
///   - success: whether file import prepare succeeded
///   - mediaFiles: the media file info models to be imported
///   - error: error information if failed
typedef void (^AIBudsMediaFileImportFetchMediaFilesInfoCompletionHandler)(BOOL success,
                                                                          NSArray<AIBudsMediaFileInfoModel *> *mediaFiles,
                                                                          NSError *_Nullable error);

/// Handler invoked when a data chunk is received during file import.
/// - Parameters:
///   - dataChunk: The received data chunk; `nil` if an error occurred.
///   - taskId: The unique identifier for the current file import task.
///   - fileUrl: The URL of the file being imported.
///   - fileSize: The total size of the file in bytes.
///   - transferredSize: The number of bytes that have been transferred so far.
///   - error: An optional error object that provides details if the operation failed; `nil` if the operation succeeded.
typedef void (^AIBudsMediaFileImportDataChunkHandler)(NSData *_Nullable dataChunk,
                                                      NSString *taskId,
                                                      NSString *fileUrl,
                                                      uint64_t fileSize,
                                                      uint64_t transferredSize,
                                                      NSError *_Nullable error);

/// Callback block for single file import transfer starting
/// - Parameters:
///   - mediaFile: metadata model of the file that is starting to be imported.
typedef void (^AIBudsMediaFileImportSingleTransferStartingHandler)(AIBudsMediaFileInfoModel *mediaFile);

/// Callback block for single file import transfer completion
/// - Parameters:
///   - success: whether the file transfer succeeded
///   - transferResult: local result model for this transfer, including metadata,
///     downloaded local URL, optional playable stabilized URL, and possible error.
///   - error: error information if failed
typedef void (^AIBudsMediaFileImportSingleTransferCompletionHandler)(BOOL success,
                                                                     AIBudsImportedMediaFileModel * transferResult,
                                                                     NSError *_Nullable error);

/// Callback block for file import speed change
/// - Parameters:
///   - speed: the current speed in bytes per second
typedef void (^AIBudsMediaFileImportTransferSpeedHandler)(uint64_t speed);

/// Handler invoked when the file import transfer batch progress changes.
/// - Parameters:
///   - fileIndex: The index of the current file in the batch.
///   - totalFileCount: The total number of files in the batch.
typedef void (^AIBudsMediaFileImportTransferBatchProgressHandler)(NSInteger fileIndex,
                                                                  NSInteger totalFileCount);



/// Handler invoked when the video stabilization process begins.
typedef void (^AIBudsVideoStabilizationPhaseBeginHandler)(void);

/// Handler invoked to report progress during the stabilization of an individual video file.
/// - Parameters:
///   - mediaFile: The imported media file model representing the video being stabilized.
///   - progress: The current stabilization progress, in the range 0.0 to 1.0.
typedef void (^AIBudsVideoStabilizationProgressHandler)(AIBudsImportedMediaFileModel * mediaFile,
                                                        double progress);

/// Handler invoked to report batch progress when stabilizing multiple video files.
/// - Parameters:
///   - fileIndex: The zero-based index of the current file being processed in the batch.
///   - totalFileCount: The total number of files in the stabilization batch.
typedef void (^AIBudsVideoStabilizationBatchProgressHandler)(NSInteger fileIndex,
                                                             NSInteger totalFileCount);
              
/// Handler invoked when the entire video stabilization process finishes.
typedef void (^AIBudsVideoStabilizationPhaseFinishHandler)(void);

/// Handler invoked when a single video file finishes stabilization (success or failure).
/// - Parameters:
///   - mediaFile: The imported media file model with updated stabilization status.
///   - success: Whether the stabilization succeeded for this file.
typedef void (^AIBudsVideoStabilizationSingleFileCompletionHandler)(AIBudsImportedMediaFileModel * mediaFile,
                                                                   BOOL success);



/// Completion handler for high-level media file import.
/// - Parameters:
///   - success: Whether all requested files were downloaded successfully.
///   - mediaFiles: Successfully imported files. A post-processing failure falls back to
///     the original file and is reported by the corresponding result model.
///   - error: The download or local-file error when `success` is `NO`.
typedef void (^AIBudsMediaFileImportCompletionHandler)(BOOL success,
                                                       NSArray<AIBudsImportedMediaFileModel *> *mediaFiles,
                                                       NSError *_Nullable error);

/// Callback block for rtsp live streaming configure hotspot starting
typedef void (^AIBudsLiveStreamingConfigureHotspotStartingHandler)(void);

/// Callback block for rtsp live streaming configure hotspot completion
/// - Parameters:
///   - success: whether the configuration succeeded
///   - error: error information if failed
typedef void (^AIBudsLiveStreamingHotspotConfigureCompletionHandler)(BOOL success,
                                                                     NSError *_Nullable error);

/// Callback block for entering live streaming mode starting
typedef void (^AIBudsEnterLiveStreamingModeStartingHandler)(void);

/// Callback block for entering live streaming mode completion
/// - Parameters:
///   - success: whether entering live streaming mode succeeded
///   - error: error information if failed
typedef void (^AIBudsEnterLiveStreamingModeCompletionHandler)(BOOL success,
                                                              NSError *_Nullable error);

/// Callback block for waiting for device hotspot open during live streaming session.
typedef void (^AIBudsLiveStreamingStartingToWaitForHotspotOpenHandler)(void);

/// Callback block for live streaming connecting device hotspot starting
/// - Parameters:
///   - ssid: the SSID of the device hotspot
typedef void (^AIBudsLiveStreamingConnectDeviceHotspotStartingHandler)(NSString *ssid);

/// Callback block for live streaming connecting device hotspot completion
/// - Parameters:
///   - success: whether the connection succeeded
///   - error: error information if failed
typedef void (^AIBudsLiveStreamingDeviceHotspotConnectCompletionHandler)(BOOL success,
                                                                         NSError *_Nullable error);

/// Callback when rtsp live streaming address is received
/// - Parameters:
///   - rtspAddress: the RTSP live streaming address, for example: "rtsp://192.168.8.123:80/media/stream"
typedef void (^AIBudsLiveStreamingRtspAddressReceivedHandler)(NSString *rtspAddress);

/// Callback block for live streaming session start completion
/// - Parameters:
///   - success: whether the live streaming session start succeeded
///   - error: error information if failed
typedef void (^AIBudsLiveStreamingSessionStartCompletionHandler)(BOOL success,
                                                                 NSError *_Nullable error);

/// Callback when jpeg live streaming data is received
/// - Parameters:
///   - data: the jpeg live streaming data
typedef void (^AIBudsLiveStreamingJpegDataReceivedHandler)(NSData *jpegData);

/// The live streaming session finish completion callback
/// - Parameters:
///   - isUserInitiatedStop: whether the live streaming session is stopped by user or not
///   - error: error information if stopped with an interrupt
typedef void (^AIBudsLiveStreamingSessionFinishHandler)(BOOL isUserInitiatedStop,
                                                        NSError *_Nullable error);

NS_ASSUME_NONNULL_END

#endif /* AIBudsHandlers_h */
