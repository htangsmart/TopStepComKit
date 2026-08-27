#
# Be sure to run `pod lib lint TopStepComKit-Git.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'TopStepComKit-Git'
    s.version          = '1.0.0-beta9'
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
        'SWIFT_OPTIMIZATION_LEVEL' => '-Onone'
    }
    
    # 添加静态库支持
    s.static_framework = true

    # 默认安装全部当前可用能力。FitCoreImp 与 FitAIImp 包含同名的
    # TopStepFitKit.framework，必须互斥；默认选择支持 AI 的完整变体。
    s.default_subspecs = [
        'Foundation',
        'ComKit',
        'FitAIImp',
        'FwCoreImp',
        'NpkCoreImp'
    ]

    fit_base_frameworks = [
        'TopStepComKit-Git/Classes/FitBase/ABParTool.xcframework',
        'TopStepComKit-Git/Classes/FitBase/FitCloudDFUKit.xcframework',
        'TopStepComKit-Git/Classes/FitBase/FitCloudKit.xcframework',
        'TopStepComKit-Git/Classes/FitBase/FitCloudNWFKit.xcframework',
        'TopStepComKit-Git/Classes/FitBase/FitCloudWFKit.xcframework',
        'TopStepComKit-Git/Classes/FitBase/RTKLEFoundation.xcframework',
        'TopStepComKit-Git/Classes/FitBase/RTKLocalPlaybackSDK.xcframework',
        'TopStepComKit-Git/Classes/FitBase/RTKOTASDK.xcframework'
    ]
    fit_base_resources = [
        'TopStepComKit-Git/Classes/FitBase/FitCloudDFUKit.bundle',
        'TopStepComKit-Git/Classes/FitBase/FitCloudKit.bundle',
        'TopStepComKit-Git/Classes/FitBase/FitCloudNWFKit.bundle',
        'TopStepComKit-Git/Classes/FitBase/FitCloudWFKit.bundle'
    ]
    
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
        foundation.dependency 'SSZipArchive'
    end
    
    # ComKit subspec - contains the main interface
    s.subspec 'ComKit' do |comkit|
        comkit.vendored_frameworks = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
        comkit.dependency 'TopStepComKit-Git/Foundation'
        comkit.preserve_paths = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
    end
    
    # FitCoreImp subspec - contains the Core-only FitKit implementation
    s.subspec 'FitCoreImp' do |fitcore|
        fitcore.vendored_frameworks = fit_base_frameworks + [
            'TopStepComKit-Git/Classes/FitCoreImp/TopStepFitKit.xcframework'
        ]
        
        fitcore.dependency 'TopStepComKit-Git/Foundation'
        fitcore.dependency 'iOSDFULibrary', '~> 4.13.0'
        fitcore.dependency 'zipzap', '~> 8.1.1'
        
        fitcore.preserve_paths = fit_base_frameworks + fit_base_resources + [
            'TopStepComKit-Git/Classes/FitCoreImp/TopStepFitKit.xcframework'
        ]
        fitcore.resources = fit_base_resources
        fitcore.frameworks = ['UIKit', 'Foundation', 'CoreBluetooth', 'CoreGraphics','Accelerate']
    end

    # FitAIImp subspec - contains the complete FitKit AI variant.
    # Do not install it together with FitCoreImp because both provide TopStepFitKit.framework.
    s.subspec 'FitAIImp' do |fitai|
        fitai.ios.deployment_target = '13.0'
        fitai.vendored_frameworks = fit_base_frameworks + [
            'TopStepComKit-Git/Classes/FitAIImp/TopStepFitKit.xcframework'
        ]

        fitai.dependency 'TopStepComKit-Git/Foundation'
        fitai.dependency 'TopStepComKit-Git/AIImp'
        fitai.dependency 'iOSDFULibrary', '~> 4.13.0'
        fitai.dependency 'zipzap', '~> 8.1.1'

        fitai.preserve_paths = fit_base_frameworks + fit_base_resources + [
            'TopStepComKit-Git/Classes/FitAIImp/TopStepFitKit.xcframework'
        ]
        fitai.resources = fit_base_resources
        fitai.frameworks = ['UIKit', 'Foundation', 'CoreBluetooth', 'CoreGraphics','Accelerate']
    end

    # AIImp subspec - contains TopStepAIKit, AIBuds provider binaries and resources.
    s.subspec 'AIImp' do |ai|
        ai.ios.deployment_target = '13.0'
        ai.vendored_frameworks = [
            'TopStepComKit-Git/Classes/AIImp/TopStepAIKit.xcframework',
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/Base/*.xcframework',
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/AI/*.xcframework',
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/Extensions/*.xcframework',
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/Audio/*.{framework,xcframework}',
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/AI/*.{framework,xcframework}',
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/Security/*.framework'
        ]
        ai.vendored_libraries = [
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/AI/libQPlayAutoSDK.a'
        ]
        ai.resources = [
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/AI/AIBudsAudio.bundle',
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/Extensions/AIBudsAIDashboard.bundle',
            'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/AI/MGBundle.bundle'
        ]

        ai.dependency 'TopStepComKit-Git/Foundation'
        ai.dependency 'zipzap'
        ai.dependency 'iOSLogBrowserSDK'
        ai.dependency 'SocketRocket'
        ai.dependency 'AFNetworking', '~> 4.0'
        ai.dependency 'onnxruntime-objc', '1.18.0'
        ai.dependency 'WCDB.swift', '2.1.16'
        ai.dependency 'libogg', '1.3.5'
        ai.dependency 'libopus', '1.1'
        ai.dependency 'GCDWebServer'
        ai.dependency 'YYWebImage'
        ai.frameworks = [
            'Foundation', 'CoreBluetooth', 'CoreGraphics', 'CoreAudio', 'CoreMedia',
            'AVFoundation', 'UIKit', 'QuartzCore', 'Metal', 'CoreVideo', 'CoreMotion',
            'Accelerate', 'VideoToolbox'
        ]
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
    
    
#    s.subspec 'SJCoreImp' do |sjcore|
#        
#        sjcore.vendored_frameworks = [
#        'TopStepComKit-Git/Classes/SJCoreImp/TopStepSJWatchKit.xcframework',
#        'TopStepComKit-Git/Classes/SJCoreImp/h264encoder.framework',
#        'TopStepComKit-Git/Classes/SJCoreImp/opus-ios.framework',
#        'TopStepComKit-Git/Classes/SJCoreImp/SJWatchLib.framework',
#        'TopStepComKit-Git/Classes/SJCoreImp/TLOCP.framework',
#        'TopStepComKit-Git/Classes/SJCoreImp/UNIWatchMate.framework',
#        ]
#        sjcore.dependency 'TopStepComKit-Git/Foundation'
#        sjcore.preserve_paths = [
#        'TopStepComKit-Git/Classes/SJCoreImp/TopStepSJWatchKit.xcframework',
#        'TopStepComKit-Git/Classes/SJCoreImp/h264encoder.framework',
#        'TopStepComKit-Git/Classes/SJCoreImp/opus-ios.framework',
#        'TopStepComKit-Git/Classes/SJCoreImp/SJWatchLib.framework',
#        'TopStepComKit-Git/Classes/SJCoreImp/TLOCP.framework',
#        'TopStepComKit-Git/Classes/SJCoreImp/UNIWatchMate.framework',
#        ]
#        
#        
#        sjcore.dependency 'YYCategories','= 1.0.4'
#        sjcore.dependency "ReactiveObjC",'= 3.1.1'
#        sjcore.dependency 'SWCompression/TAR'
#        
#        sjcore.dependency 'RxSwift' , '= 6.8.0'
#        sjcore.dependency 'RxCocoa' , '= 6.8.0'
#        sjcore.dependency 'PromiseKit','= 8.1.1'
#        sjcore.dependency 'HandyJSON', '= 5.0.0'
#        sjcore.dependency 'SwiftyJSON','= 5.0.1'
#        
#        
#    end
    
    # NpkCoreImp subspec
    s.subspec 'NpkCoreImp' do |npkcore|
        npkcore.vendored_frameworks = [
        'TopStepComKit-Git/Classes/NpkCoreImp/TopStepBleMetaKit.xcframework',
        'TopStepComKit-Git/Classes/NpkCoreImp/TopStepNewPlatformKit.xcframework',
        'TopStepComKit-Git/Classes/NpkCoreImp/h264encoder.framework',
        ]
        npkcore.vendored_libraries = [
        'TopStepComKit-Git/Classes/NpkCoreImp/libTscCompressor.a',
        ]
        npkcore.dependency 'TopStepComKit-Git/Foundation'
        npkcore.dependency 'Protobuf'
        npkcore.preserve_paths = [
        'TopStepComKit-Git/Classes/NpkCoreImp/TopStepBleMetaKit.xcframework',
        'TopStepComKit-Git/Classes/NpkCoreImp/TopStepNewPlatformKit.xcframework',
        'TopStepComKit-Git/Classes/NpkCoreImp/h264encoder.framework',
        'TopStepComKit-Git/Classes/NpkCoreImp/libTscCompressor.a',
        ]
        
        npkcore.frameworks = ['Foundation', 'UIKit']
    end
    
end
