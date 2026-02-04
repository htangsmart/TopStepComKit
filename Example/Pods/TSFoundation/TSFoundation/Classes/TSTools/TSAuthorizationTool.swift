//
//  TSAuthorizationTool.swift
//  TSFoundation
//
//  Created by luigi on 2024/7/13.
//

import Foundation
import Photos

@objc public enum TSAuthorizationStatus: Int {
    /// 还未申请授权过
    case notDetermined
    /// 已授权
    case authorized
    /// 拒绝
    case denied
    /// 应用没有相关权限，且当前用户无法改变这个权限
    case restricted
    /// 硬件不支持
    case notSupport
}

@objcMembers public class TSAuthorizationTool: NSObject {
    
//MARK: - 相册权限
    
    /// 获取当相册授权状态
    public class func photoAuthorizationStatus() -> TSAuthorizationStatus {
        
        var status: TSAuthorizationStatus = .restricted
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            switch PHPhotoLibrary.authorizationStatus() {
                
                case .notDetermined: status = .notDetermined
                case .restricted: status = .restricted
                case .denied: status = .denied
                case .authorized: status = .authorized
                case .limited: status = .authorized
                @unknown default: status = .denied
            }
        }
        return status
    }
    
    /// 请求相册权限
    public class func requestPhotoAuthorization(result: @escaping(_ status: TSAuthorizationStatus) -> Void) {
        
        PHPhotoLibrary.requestAuthorization { photoStatus in
            
            var status:TSAuthorizationStatus = .notDetermined
            switch photoStatus {
                
                case .notDetermined: status = .notDetermined
                case .restricted: status = .restricted
                case .denied: status = .denied
                case .authorized: status = .authorized
                case .limited: status = .authorized
                @unknown default: status = .denied
            }
            DispatchQueue.main.async { result(status) }
        }
    }
    
    /// 获取当前相册授权状态，若还未申请授权过则申请授权并回调结果
    public class func photoAuthorizationStatusAndRequestIfNotDetermined(result: @escaping(_ status: TSAuthorizationStatus) -> Void) {
        
        let status = photoAuthorizationStatus()
        guard status == .notDetermined else {
            
            result(status)
            return
        }
        
        requestPhotoAuthorization { status in
            
            result(status)
        }
    }
    
    /// 获取当前相册授权状态，若还未申请授权过则申请授权并回调结果，如果授权被拒绝会创建并返回一个alert
    public class func photoAuthorizationStatusWithAlertAndRequestIfNotDetermined(result: @escaping(_ status: TSAuthorizationStatus, _ alert: UIAlertController?) -> Void) {
        
        let status = photoAuthorizationStatus()
        let alert = getAuthorizationDeniedAlert(alertTitle: LanguageCls.localizableTxt("相册权限被拒绝"), message: LanguageCls.localizableTxt("NSPhotoLibraryUsageDescription"))
        guard status == .notDetermined else {
        
            result(status, status == .authorized ? nil : alert)
            return
        }
        
        requestPhotoAuthorization { status in
            
            result(status, status == .authorized ? nil : alert)
        }
    }
    
//MARK: - 相机权限
    public class func cameraAuthorizationStatus() -> TSAuthorizationStatus {
        
        var status:TSAuthorizationStatus = .denied
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                
                case .notDetermined: status = .notDetermined
                case .restricted: status = .restricted
                case .denied: status = .denied
                case .authorized: status = .authorized
                @unknown default: status = .denied
            }
        }
        return status
    }
    
    public class func requestCameraAuthorization(result:@escaping(_ status: TSAuthorizationStatus) -> Void) {
     
        AVCaptureDevice.requestAccess(for: .video) { granted in
            
            DispatchQueue.main.async {
                
                result(self.cameraAuthorizationStatus())
            }
        }
    }

    /// 获取当前相机授权状态，若还未申请授权过则申请授权并回调结果
    public class func cameraAuthorizationStatusAndRequestIfNotDetermined(result: @escaping(_ status: TSAuthorizationStatus) -> Void) {
        
        let status = cameraAuthorizationStatus()
        guard status == .notDetermined else {
            
            result(status)
            return
        }
        
        requestCameraAuthorization { status in
            
            result(status)
        }
    }
    
    /// 获取当前相机授权状态，若还未申请授权过则申请授权并回调结果，如果授权被拒绝会创建并返回一个alert
    public class func cameraAuthorizationStatusWithAlertAndRequestIfNotDetermined(result: @escaping(_ status: TSAuthorizationStatus, _ alert: UIAlertController?) -> Void) {
        
        let status = cameraAuthorizationStatus()
        let alert = getAuthorizationDeniedAlert(alertTitle: LanguageCls.localizableTxt("相机权限被拒绝"), message: LanguageCls.localizableTxt("NSCameraUsageDescription"))
        guard status == .notDetermined else {
        
            result(status, status == .authorized ? nil : alert)
            return
        }
        
        requestCameraAuthorization { status in
            
            result(status, status == .authorized ? nil : alert)
        }
    }
//MARK: - 麦克风权限
    public class func microphoneAuthorizationStatus() -> TSAuthorizationStatus {
        
        var status: TSAuthorizationStatus = .denied
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .notDetermined: status = .notDetermined
            case .restricted: status = .restricted
            case .denied: status = .denied
            case .authorized: status = .authorized
            @unknown default: status = .denied
        }
        return status
    }
    
    public class func requestMicrophoneAuthorization(result:@escaping(_ status: TSAuthorizationStatus) -> Void) {
        
        if #available(iOS 17, *) {

            AVAudioApplication.requestRecordPermission { granted in
                
                DispatchQueue.main.async {
                    
                    result(self.microphoneAuthorizationStatus())
                }
            }
        } else {

            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                
                DispatchQueue.main.async {
                    
                    result(self.microphoneAuthorizationStatus())
                }
            }
        }
    }
    
    /// 获取当前麦克风授权状态，若还未申请授权过则申请授权并回调结果
    public class func microphoneAuthorizationStatusAndRequestIfNotDetermined(result: @escaping(_ status: TSAuthorizationStatus) -> Void) {
        
        let status = microphoneAuthorizationStatus()
        guard status == .notDetermined else {
            
            result(status)
            return
        }
        
        requestMicrophoneAuthorization { status in
            
            result(status)
        }
    }
    
    /// 获取当前麦克风授权状态，若还未申请授权过则申请授权并回调结果，如果授权被拒绝会创建并返回一个alert
    public class func microphoneAuthorizationStatusWithAlertAndRequestIfNotDetermined(result: @escaping(_ status: TSAuthorizationStatus, _ alert: UIAlertController?) -> Void) {
        
        let status = microphoneAuthorizationStatus()
        let alert = getAuthorizationDeniedAlert(alertTitle: LanguageCls.localizableTxt("麦克风权限被拒绝"), message: LanguageCls.localizableTxt("NSMicrophoneUsageDescription"))
        guard status == .notDetermined else {
        
            result(status, status == .authorized ? nil : alert)
            return
        }
        
        requestMicrophoneAuthorization { status in
            
            result(status, status == .authorized ? nil : alert)
        }
    }
}

func getAuthorizationDeniedAlert(alertTitle: String, message: String) -> UIAlertController {
    
    let alert = UIAlertController.init(title: alertTitle, message: "\(message)\n\(LanguageCls.localizableTxt("请前往设置应用授予权限"))", preferredStyle: .alert)
    alert.addAction(UIAlertAction.init(title: LanguageCls.localizableTxt("去设置"), style: .default, handler: { action in
        
//        let url = URL(string: UIApplication.openSettingsURLString)
#if swift(>=4.2)
    let url = URL(string: UIApplication.openSettingsURLString)
#else
    let url = URL(string: UIApplicationOpenSettingsURLString)
#endif

        if UIApplication.shared.canOpenURL(url!) {
            
            UIApplication.shared.open(url!)
        }
    }))
    alert.addAction(UIAlertAction.init(title: LanguageCls.localizableTxt("取消"), style: .default))
    return alert
}

