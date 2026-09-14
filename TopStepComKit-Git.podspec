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
    'Interface',
    'ToolsAll',
    'ComKit',
    'FitAIImp',
    'FwCoreImp',
    'NpkCoreImp'
    ]
    
    # Interface subspec - contains the public SDK protocols and models.
    s.subspec 'Interface' do |interface|
        interface.vendored_frameworks =
        'TopStepComKit-Git/Classes/Foundation/TopStepInterfaceKit.xcframework'
        interface.preserve_paths =
        'TopStepComKit-Git/Classes/Foundation/TopStepInterfaceKit.xcframework'
    end
    
    # ToolsCore subspec - common utilities without FFmpeg.
    s.subspec 'ToolsCore' do |tools|
        tools.vendored_frameworks =
        'TopStepComKit-Git/Classes/Foundation/TopStepToolKit.xcframework'
        tools.preserve_paths =
        'TopStepComKit-Git/Classes/Foundation/TopStepToolKit.xcframework'
        tools.dependency 'SSZipArchive'
    end
    
    # ToolsAll subspec - common utilities plus the local FFmpeg binaries.
    s.subspec 'ToolsAll' do |tools|
        tools.dependency 'TopStepComKit-Git/ToolsCore'
        tools.vendored_frameworks =
        'TopStepComKit-Git/Classes/Foundation/FFmpeg/*.xcframework'
        tools.preserve_paths =
        'TopStepComKit-Git/Classes/Foundation/FFmpeg/*.xcframework'
    end
    
    # ComKit subspec - contains the main interface
    s.subspec 'ComKit' do |comkit|
        comkit.vendored_frameworks = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
        comkit.dependency 'TopStepComKit-Git/Interface'
        comkit.dependency 'TopStepComKit-Git/ToolsCore'
        comkit.preserve_paths = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
    end
    
    # FitCoreImp subspec - local Core variant and the three shared local binaries.
    s.subspec 'FitCoreImp' do |fitcore|
        fitcore.vendored_frameworks = [
        'TopStepComKit-Git/Classes/FitImp/Core/TopStepFitKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudGPSAccelerate.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudOTAGenKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/LogMate.xcframework'
        ]
        
        fitcore.preserve_paths = [
        'TopStepComKit-Git/Classes/FitImp/Core/TopStepFitKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudGPSAccelerate.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudOTAGenKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/LogMate.xcframework'
        ]
        fitcore.frameworks = ['UIKit', 'Foundation', 'CoreBluetooth', 'CoreGraphics','Accelerate']

        fitcore.dependency 'TopStepComKit-Git/Interface'
        fitcore.dependency 'TopStepComKit-Git/ToolsAll'
        
        # FitCloudKit family remains managed by CocoaPods; only the three
        # shared binaries above are shipped locally.
        fitcore.dependency 'FitCloudKit'
        fitcore.dependency 'FitCloudDFUKit'
        fitcore.dependency 'FitCloudWFKit'
        fitcore.dependency 'FitCloudNWFKit'
        fitcore.dependency 'ReactiveObjC'
        fitcore.dependency 'MJExtension'
        
    end
    
    # FitAIImp subspec - contains the complete FitKit AI variant.
    # Do not install it together with FitCoreImp because both provide TopStepFitKit.framework.
    s.subspec 'FitAIImp' do |fitai|
        fitai.ios.deployment_target = '13.0'
        fitai.vendored_frameworks = [
        'TopStepComKit-Git/Classes/FitImp/AI/TopStepFitKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudGPSAccelerate.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudOTAGenKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/LogMate.xcframework'
        ]
        
        fitai.preserve_paths = [
        'TopStepComKit-Git/Classes/FitImp/AI/TopStepFitKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudGPSAccelerate.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudOTAGenKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/LogMate.xcframework'
        ]
        fitai.frameworks = ['UIKit', 'Foundation', 'CoreBluetooth', 'CoreGraphics','Accelerate']

        fitai.dependency 'TopStepComKit-Git/Interface'
        fitai.dependency 'TopStepComKit-Git/ToolsAll'
        fitai.dependency 'TopStepComKit-Git/AIImp'
        
        fitai.dependency 'FitCloudKit'
        fitai.dependency 'FitCloudDFUKit'
        fitai.dependency 'FitCloudWFKit'
        fitai.dependency 'FitCloudNWFKit'
        fitai.dependency 'ReactiveObjC'
        fitai.dependency 'MJExtension'
        
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
        
        ai.frameworks = [
        'Foundation', 'CoreBluetooth', 'CoreGraphics', 'CoreAudio', 'CoreMedia',
        'AVFoundation', 'UIKit', 'QuartzCore', 'Metal', 'CoreVideo', 'CoreMotion',
        'Accelerate', 'VideoToolbox'
        ]

        ai.resources = [
        'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/AI/AIBudsAudio.bundle',
        'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/Extensions/AIBudsAIDashboard.bundle',
        'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/AI/MGBundle.bundle'
        ]
        
        ai.dependency 'TopStepComKit-Git/Interface'
        ai.dependency 'TopStepComKit-Git/ToolsCore'
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
    end
    
    # FwCoreImp subspec
    #
    # @note
    # EN: FwCoreImp only supports arm64 (real device), does NOT support simulator (x86_64/arm64-simulator).
    # CN: FwCoreImp仅支持arm64真机，不支持模拟器（x86_64/arm64-simulator）。
    s.subspec 'FwCoreImp' do |fwcore|
        fwcore.vendored_frameworks = [
        'TopStepComKit-Git/Classes/FwImp/TopStepPersimwearKit.xcframework',
        'TopStepComKit-Git/Classes/FwImp/persimwearSDK.framework'
        ]
        fwcore.preserve_paths = [
        'TopStepComKit-Git/Classes/FwImp/TopStepPersimwearKit.xcframework',
        'TopStepComKit-Git/Classes/FwImp/persimwearSDK.framework',
        'TopStepComKit-Git/Classes/FwImp/WearApi.bundle'
        ]
        fwcore.resources = [
        'TopStepComKit-Git/Classes/FwImp/WearApi.bundle'
        ]
        fwcore.frameworks = ['Foundation', 'UIKit']
        fwcore.libraries = ['z', 'bz2', 'sqlite3']
        
        fwcore.dependency 'TopStepComKit-Git/Interface'
        fwcore.dependency 'TopStepComKit-Git/ToolsCore'

    end
    
    
    # NpkCoreImp subspec
    s.subspec 'NpkCoreImp' do |npkcore|
        npkcore.vendored_frameworks = [
        'TopStepComKit-Git/Classes/NpkImp/TopStepBleMetaKit.xcframework',
        'TopStepComKit-Git/Classes/NpkImp/TopStepNewPlatformKit.xcframework',
        'TopStepComKit-Git/Classes/NpkImp/h264encoder.framework',
        ]
        npkcore.vendored_libraries = [
        'TopStepComKit-Git/Classes/NpkImp/libTscCompressor.a',
        ]
        npkcore.dependency 'TopStepComKit-Git/Interface'
        npkcore.dependency 'TopStepComKit-Git/ToolsCore'
        npkcore.dependency 'Protobuf'
        npkcore.preserve_paths = [
        'TopStepComKit-Git/Classes/NpkImp/TopStepBleMetaKit.xcframework',
        'TopStepComKit-Git/Classes/NpkImp/TopStepNewPlatformKit.xcframework',
        'TopStepComKit-Git/Classes/NpkImp/h264encoder.framework',
        'TopStepComKit-Git/Classes/NpkImp/libTscCompressor.a',
        ]
        
        npkcore.frameworks = ['Foundation', 'UIKit']
    end
    
end
