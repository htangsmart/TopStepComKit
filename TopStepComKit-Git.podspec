#
# Be sure to run `pod lib lint TopStepComKit-Git.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'TopStepComKit-Git'
    s.version          = '1.0.0-beta8'
    s.summary          = 'TopStepComKit SDK for iOS development'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    TopStep SDK provides a comprehensive set of tools and interfaces for iOS development.
    It includes multiple modules that can be used independently based on your needs.
    DESC
    
    s.homepage         = 'https://github.com/htangsmart/TopStepComKit'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'rd@hetangsmart.com' => 'tengzhang@topstep-tech.com' }
    s.source           = { :git => 'https://github.com/htangsmart/TopStepComKit.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '12.0'
    s.swift_versions = ['5.0']
    
    # 基础配置
    s.pod_target_xcconfig = {
        'VALID_ARCHS' => 'arm64',
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 x86_64',
        'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
        'HEADER_SEARCH_PATHS' => '$(inherited) ${PODS_ROOT}/TopStepComKit-Git/TopStepComKit-Git/Classes/**',
        'OTHER_LDFLAGS' => '$(inherited) -ObjC',
        'ONLY_ACTIVE_ARCH' => 'NO',
        'SWIFT_OPTIMIZATION_LEVEL' => '-Onone',
        'IPHONEOS_DEPLOYMENT_TARGET' => '12.0'
    }
    
    # 添加静态库支持
    s.static_framework = true
    
    # Foundation subspec - contains InterfaceKit and ToolKit
    s.subspec 'Foundation' do |foundation|
        foundation.vendored_frameworks = [
        'TopStepComKit-Git/Classes/Foundation/TopStepInterfaceKit.xcframework',
        'TopStepComKit-Git/Classes/Foundation/TopStepToolKit.xcframework'
        ]
        foundation.preserve_paths = [
        'TopStepComKit-Git/Classes/Foundation/TopStepInterfaceKit.xcframework',
        'TopStepComKit-Git/Classes/Foundation/TopStepToolKit.xcframework'
        ]
    end
    
    # ComKit subspec - contains the main interface
    s.subspec 'ComKit' do |comkit|
        comkit.vendored_frameworks = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
        comkit.dependency 'TopStepComKit-Git/Foundation'
        comkit.preserve_paths = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
    end
    
    # FitCoreImp subspec - contains FitKit implementation
    s.subspec 'FitCoreImp' do |fitcore|
        fitcore.vendored_frameworks = 'TopStepComKit-Git/Classes/FitCoreImp/*.xcframework'
        
        fitcore.dependency 'TopStepComKit-Git/Foundation'
        fitcore.dependency 'iOSDFULibrary', '~> 4.11.0'
        fitcore.dependency 'zipzap', '~> 8.1.1'
        
        fitcore.preserve_paths = [
        'TopStepComKit-Git/Classes/FitCoreImp/*.xcframework',
        'TopStepComKit-Git/Classes/FitCoreImp/*.bundle'
        ]
        
        fitcore.resources = [
        'TopStepComKit-Git/Classes/FitCoreImp/*.bundle'
        ]
        fitcore.frameworks = ['UIKit', 'Foundation', 'CoreBluetooth', 'CoreGraphics','Accelerate']
    end
    
    # FwCoreImp subspec
    #
    # @note
    # EN: FwCoreImp only supports arm64 (real device), does NOT support simulator (x86_64/arm64-simulator).
    # CN: FwCoreImp仅支持arm64真机，不支持模拟器（x86_64/arm64-simulator）。
    s.subspec 'FwCoreImp' do |fwcore|
        fwcore.vendored_frameworks = [
        'TopStepComKit-Git/Classes/FwCoreImp/TopStepPersimwearKit.xcframework',
        'TopStepComKit-Git/Classes/FwCoreImp/persimwearSDK.framework'
        ]
        fwcore.dependency 'TopStepComKit-Git/Foundation'
        fwcore.preserve_paths = [
        'TopStepComKit-Git/Classes/FwCoreImp/TopStepPersimwearKit.xcframework',
        'TopStepComKit-Git/Classes/FwCoreImp/persimwearSDK.framework',
        'TopStepComKit-Git/Classes/FwCoreImp/WearApi.bundle'
        ]
        fwcore.resources = [
        'TopStepComKit-Git/Classes/FwCoreImp/WearApi.bundle'
        ]
        fwcore.frameworks = ['Foundation', 'UIKit']
        fwcore.libraries = ['z', 'bz2', 'sqlite3']
    end
    
    
    s.subspec 'SJCoreImp' do |sjcore|
        
        sjcore.vendored_frameworks = [
        'TopStepComKit-Git/Classes/SJCoreImp/TopStepSJWatchKit.xcframework',
        'TopStepComKit-Git/Classes/SJCoreImp/h264encoder.framework',
        'TopStepComKit-Git/Classes/SJCoreImp/opus-ios.framework',
        'TopStepComKit-Git/Classes/SJCoreImp/SJWatchLib.framework',
        'TopStepComKit-Git/Classes/SJCoreImp/TLOCP.framework',
        'TopStepComKit-Git/Classes/SJCoreImp/UNIWatchMate.framework',
        ]
        sjcore.dependency 'TopStepComKit-Git/Foundation'
        sjcore.preserve_paths = [
        'TopStepComKit-Git/Classes/SJCoreImp/TopStepSJWatchKit.xcframework',
        'TopStepComKit-Git/Classes/SJCoreImp/h264encoder.framework',
        'TopStepComKit-Git/Classes/SJCoreImp/opus-ios.framework',
        'TopStepComKit-Git/Classes/SJCoreImp/SJWatchLib.framework',
        'TopStepComKit-Git/Classes/SJCoreImp/TLOCP.framework',
        'TopStepComKit-Git/Classes/SJCoreImp/UNIWatchMate.framework',
        ]
        
        
        sjcore.dependency 'YYCategories','= 1.0.4'
        sjcore.dependency "ReactiveObjC",'= 3.1.1'
        sjcore.dependency 'SWCompression/TAR'
        
        sjcore.dependency 'RxSwift' , '= 6.8.0'
        sjcore.dependency 'RxCocoa' , '= 6.8.0'
        sjcore.dependency 'PromiseKit','= 8.1.1'
        sjcore.dependency 'HandyJSON', '= 5.0.0'
        sjcore.dependency 'SwiftyJSON','= 5.0.1'
        
        
    end
    
    # NpkCoreImp subspec
    s.subspec 'NpkCoreImp' do |npkcore|
        npkcore.vendored_frameworks = [
        'TopStepComKit-Git/Classes/NpkCoreImp/TopStepBleMetaKit.xcframework',
        'TopStepComKit-Git/Classes/NpkCoreImp/TopStepNewPlatformKit.xcframework'
        ]
        npkcore.dependency 'TopStepComKit-Git/Foundation'
        npkcore.dependency 'Protobuf', '= 3.25.0'
        npkcore.preserve_paths = [
        'TopStepComKit-Git/Classes/NpkCoreImp/TopStepBleMetaKit.xcframework',
        'TopStepComKit-Git/Classes/NpkCoreImp/TopStepNewPlatformKit.xcframework',
        'TopStepComKit-Git/Classes/NpkCoreImp/*.bundle'
        ]
        npkcore.resources = [
        'TopStepComKit-Git/Classes/NpkCoreImp/*.bundle'
        ]
        npkcore.frameworks = ['Foundation', 'UIKit']
    end
    
end
