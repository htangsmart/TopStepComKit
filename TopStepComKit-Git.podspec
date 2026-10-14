#
# Be sure to run `pod lib lint TopStepComKit-Git.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'TopStepComKit-Git'
    s.version          = '1.0.0-beta11'
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
    
    s.ios.deployment_target = '15.0'
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
    # TopStepFitKit.framework、NpkCoreImp 与 NpkAIImp 包含同名的
    # TopStepNewPlatformKit.framework，各自必须互斥；默认选择支持 AI 的完整变体。
    s.default_subspecs = [
    'Interface',
    'ToolsAll',
    'ComKit',
    'FitAIImp',
    'FwImp',
    'NpkAIImp'
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
    
    # FitImp/Base 共用本地二进制。
    # develop_fitcloudkit_pod 分支：FitCloud 系列（FitCloudKit / FitCloudDFUKit / FitCloudWFKit /
    # FitCloudNWFKit）通过 CocoaPods 依赖引入，宿主 App 可与 SDK 共用同一份。
    # RTK 系列随 FitCloudDFUKit Pod、ABParTool 随 FitCloudWFKit Pod 带入，此处不再内置；
    # FitImp/Base 下的 FitCloud* / RTK* / ABParTool 二进制及 bundle 在本分支不被引用。
    fit_base_frameworks = [
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudGPSAccelerate.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudOTAGenKit.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/LogMate.xcframework'
    ]

    # FitCoreImp subspec - Core 变体 + FitImp/Base 共用二进制。
    s.subspec 'FitCoreImp' do |fitcore|
        fitcore.vendored_frameworks = fit_base_frameworks + [
            'TopStepComKit-Git/Classes/FitImp/Core/TopStepFitKit.xcframework'
        ]
        fitcore.preserve_paths = fit_base_frameworks + [
            'TopStepComKit-Git/Classes/FitImp/Core/TopStepFitKit.xcframework'
        ]
        fitcore.frameworks = ['UIKit', 'Foundation', 'CoreBluetooth', 'CoreGraphics','Accelerate']

        fitcore.dependency 'TopStepComKit-Git/Interface'
        fitcore.dependency 'TopStepComKit-Git/ToolsAll'
        # FitCloud 系列由 CocoaPods 管理。iOSDFULibrary、zipzap 分别由 FitCloudDFUKit、
        # FitCloudNWFKit 间接带入，不再显式声明，避免与其版本约束（如 iOSDFULibrary ~> 4.11.0）冲突。
        fitcore.dependency 'FitCloudKit'
        fitcore.dependency 'FitCloudDFUKit'
        fitcore.dependency 'FitCloudWFKit'
        fitcore.dependency 'FitCloudNWFKit'
        fitcore.dependency 'ReactiveObjC'
        fitcore.dependency 'MJExtension'
    end

    # FitAIImp subspec - AI 变体 + FitImp/Base 共用二进制。
    # 不可与 FitCoreImp 同时安装：两者都提供 TopStepFitKit.framework。
    s.subspec 'FitAIImp' do |fitai|
        fitai.ios.deployment_target = '15.0'
        fitai.vendored_frameworks = fit_base_frameworks + [
            'TopStepComKit-Git/Classes/FitImp/AI/TopStepFitKit.xcframework'
        ]
        fitai.preserve_paths = fit_base_frameworks + [
            'TopStepComKit-Git/Classes/FitImp/AI/TopStepFitKit.xcframework'
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
        ai.ios.deployment_target = '15.0'
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
    
    # FwImp subspec
    #
    # @note
    # EN: FwImp only supports arm64 (real device), does NOT support simulator (x86_64/arm64-simulator).
    # CN: FwImp仅支持arm64真机，不支持模拟器（x86_64/arm64-simulator）。
    s.subspec 'FwImp' do |fwimp|
        fwimp.vendored_frameworks = [
        'TopStepComKit-Git/Classes/FwImp/TopStepPersimwearKit.xcframework',
        'TopStepComKit-Git/Classes/FwImp/persimwearSDK.framework'
        ]
        fwimp.preserve_paths = [
        'TopStepComKit-Git/Classes/FwImp/TopStepPersimwearKit.xcframework',
        'TopStepComKit-Git/Classes/FwImp/persimwearSDK.framework',
        'TopStepComKit-Git/Classes/FwImp/WearApi.bundle'
        ]
        fwimp.resources = [
        'TopStepComKit-Git/Classes/FwImp/WearApi.bundle'
        ]
        fwimp.frameworks = ['Foundation', 'UIKit']
        fwimp.libraries = ['z', 'bz2', 'sqlite3']
        
        fwimp.dependency 'TopStepComKit-Git/Interface'
        fwimp.dependency 'TopStepComKit-Git/ToolsCore'

    end
    
    
    # NpkImp/Base 共用本地二进制：BleMeta 协议底座 + 表盘视频编码/压缩库（与 FitImp/Base 同构）。
    # TopStepNewPlatformKit.xcframework 按 Core / AI 两个变体分别位于 NpkImp/Core 与 NpkImp/AI。
    npk_base_frameworks = [
        'TopStepComKit-Git/Classes/NpkImp/Base/TopStepBleMetaKit.xcframework',
        'TopStepComKit-Git/Classes/NpkImp/Base/h264encoder.framework'
    ]
    npk_base_libraries = [
        'TopStepComKit-Git/Classes/NpkImp/Base/libTscCompressor.a'
    ]

    # NpkCoreImp subspec - Core 变体 + NpkImp/Base 共用二进制。
    # 不可与 NpkAIImp 同时安装：两者都提供 TopStepNewPlatformKit.framework。
    s.subspec 'NpkCoreImp' do |npkcore|
        npkcore.vendored_frameworks = npk_base_frameworks + [
            'TopStepComKit-Git/Classes/NpkImp/Core/TopStepNewPlatformKit.xcframework'
        ]
        npkcore.vendored_libraries = npk_base_libraries
        npkcore.preserve_paths = npk_base_frameworks + npk_base_libraries + [
            'TopStepComKit-Git/Classes/NpkImp/Core/TopStepNewPlatformKit.xcframework'
        ]
        npkcore.frameworks = ['Foundation', 'UIKit']

        npkcore.dependency 'TopStepComKit-Git/Interface'
        npkcore.dependency 'TopStepComKit-Git/ToolsCore'
        npkcore.dependency 'Protobuf'
    end

    # NpkAIImp subspec - AI 变体（Core + NPK AI DeviceBridge）+ NpkImp/Base 共用二进制，依赖 AIImp。
    # 不可与 NpkCoreImp 同时安装：两者都提供 TopStepNewPlatformKit.framework。
    s.subspec 'NpkAIImp' do |npkai|
        npkai.ios.deployment_target = '15.0'
        npkai.vendored_frameworks = npk_base_frameworks + [
            'TopStepComKit-Git/Classes/NpkImp/AI/TopStepNewPlatformKit.xcframework'
        ]
        npkai.vendored_libraries = npk_base_libraries
        npkai.preserve_paths = npk_base_frameworks + npk_base_libraries + [
            'TopStepComKit-Git/Classes/NpkImp/AI/TopStepNewPlatformKit.xcframework'
        ]
        npkai.frameworks = ['Foundation', 'UIKit']

        npkai.dependency 'TopStepComKit-Git/Interface'
        npkai.dependency 'TopStepComKit-Git/ToolsCore'
        npkai.dependency 'TopStepComKit-Git/AIImp'
        npkai.dependency 'Protobuf'
    end

    # NpkImp subspec - 向后兼容别名（已弃用）。
    # 历史上 NpkImp 只发布 Core 实现，这里映射到 NpkCoreImp；需要 AI 请显式改用 NpkAIImp。
    s.subspec 'NpkImp' do |npkimp|
        npkimp.dependency 'TopStepComKit-Git/NpkCoreImp'
    end
    
end
