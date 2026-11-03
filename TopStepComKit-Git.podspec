#
# Be sure to run `pod lib lint TopStepComKit-Git.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'TopStepComKit-Git'
    s.version          = '1.0.0-beta18'
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
    
    # 本 Pod 只分发预编译二进制，没有源码，此设置不影响 SDK 产物本身的链接方式。
    #
    # 链接方式说明：
    # TopStepComKit / TopStepNewPlatformKit / TopStepFitKit / TopStepPersimwearKit / TopStepAIKit
    # 均以动态 xcframework 交付，App 无论在多少个 target 里引入本 Pod，运行时都只有一份实现。
    # 它们依赖的第三方 Pod（Protobuf、ReactiveObjC、MJExtension、AFNetworking 等）通过 @rpath 动态链接，
    # 不会被打进 SDK，因此接入方需使用 use_frameworks!（动态）；若使用静态链接，需把这些依赖单独改为动态 framework。
    # 被吸收进动态库的第三方静态 SDK（FitCloud、persimwearSDK、AIBuds 等）只随 Pod 发布无二进制的头文件框架。
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
    
    # ToolKit 二进制包含 Core、DialFormat、DialVideo，运行时仍需要动态 PAR 与 FFmpeg。
    # ToolsCore 只分发 ToolKit；宿主选择下面的子包或提供兼容的现有动态库。
    s.subspec 'ToolsCore' do |tools|
        tools.vendored_frameworks = 'TopStepComKit-Git/Classes/Foundation/TopStepToolKit.xcframework'
        tools.preserve_paths = 'TopStepComKit-Git/Classes/Foundation/TopStepToolKit.xcframework'
        tools.dependency 'SSZipArchive'
    end

    # FFmpeg 的配套框架作为一组选择，避免混用不同版本的 libav/libsw。
    s.subspec 'FFmpeg' do |ffmpeg|
        ffmpeg.vendored_frameworks = [
            'TopStepComKit-Git/Classes/Foundation/FFmpeg/libavcodec.xcframework',
            'TopStepComKit-Git/Classes/Foundation/FFmpeg/libavdevice.xcframework',
            'TopStepComKit-Git/Classes/Foundation/FFmpeg/libavfilter.xcframework',
            'TopStepComKit-Git/Classes/Foundation/FFmpeg/libavformat.xcframework',
            'TopStepComKit-Git/Classes/Foundation/FFmpeg/libavutil.xcframework',
            'TopStepComKit-Git/Classes/Foundation/FFmpeg/libswresample.xcframework',
            'TopStepComKit-Git/Classes/Foundation/FFmpeg/libswscale.xcframework'
        ]
    end

    s.subspec 'PAR' do |par|
        par.vendored_frameworks = 'TopStepComKit-Git/Classes/Foundation/PAR/ABParTool.xcframework'
    end

    # 完整工具依赖入口；复用已有 FFmpeg、PAR 或 MagicHelper 时按需选择独立子包。
    s.subspec 'ToolsAll' do |tools|
        tools.dependency 'TopStepComKit-Git/ToolsCore'
        tools.dependency 'TopStepComKit-Git/FFmpeg'
        tools.dependency 'TopStepComKit-Git/PAR'
        tools.dependency 'TopStepComKit-Git/MagicHelper'
    end

    # 可选共享运行库。AIImp 不强制引入，已有兼容动态 MagicHelper 的宿主无需选择。
    s.subspec 'MagicHelper' do |magic_helper|
        magic_helper.vendored_frameworks = [
            'TopStepComKit-Git/Classes/Foundation/MagicHelper/MagicHelper.xcframework',
            'TopStepComKit-Git/Classes/Foundation/MagicHelper/MicrosoftCognitiveServicesSpeech.xcframework'
        ]
        magic_helper.resources = 'TopStepComKit-Git/Classes/Foundation/MagicHelper/MGBundle.bundle'
        # 头文件模块与 vendored xcframework 同目录，复用 CocoaPods 自动生成的搜索路径。
        magic_helper.preserve_paths = 'TopStepComKit-Git/Classes/Foundation/MagicHelper/*.framework'
        magic_helper.dependency 'SocketRocket', '~> 0.7.1'
    end
    
    # ComKit subspec - contains the main interface
    s.subspec 'ComKit' do |comkit|
        comkit.vendored_frameworks = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
        comkit.dependency 'TopStepComKit-Git/Interface'
        comkit.dependency 'TopStepComKit-Git/ToolsCore'
        comkit.preserve_paths = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
    end
    
    # FitImp/Base 共用本地二进制。
    # FitCloud 系列与 RTK 系列全部以 xcframework 交付，不再通过 CocoaPods 引入同名 Pod。
    # ABParTool 由可选 PAR 子包或宿主现有兼容动态库提供。
    # FitCloud 系列与 LogMate 为静态库，已吸收进 TopStepFitKit 动态库；这里只保留需单独嵌入的 RTK 动态库。
    fit_base_frameworks = [
        'TopStepComKit-Git/Classes/FitImp/Base/RTKLEFoundation.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/RTKLocalPlaybackSDK.xcframework',
        'TopStepComKit-Git/Classes/FitImp/Base/RTKOTASDK.xcframework'
    ]
    # 被吸收的 FitCloud 静态库只提供无二进制的头文件框架，供编译 TopStepFitKit 公开头文件，不参与链接。
    fit_header_stubs = 'TopStepComKit-Git/Classes/FitImp/Base/*.framework'
    fit_base_resources = [
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudDFUKit.bundle',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudKit.bundle',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudNWFKit.bundle',
        'TopStepComKit-Git/Classes/FitImp/Base/FitCloudWFKit.bundle'
    ]

    # FitCoreImp subspec - Core 变体 + FitImp/Base 共用二进制。
    s.subspec 'FitCoreImp' do |fitcore|
        fitcore.vendored_frameworks = fit_base_frameworks + [
            'TopStepComKit-Git/Classes/FitImp/Core/TopStepFitKit.xcframework'
        ]
        fitcore.preserve_paths = fit_base_frameworks + fit_base_resources + [fit_header_stubs] + [
            'TopStepComKit-Git/Classes/FitImp/Core/TopStepFitKit.xcframework'
        ]
        fitcore.resources = fit_base_resources
        fitcore.frameworks = ['UIKit', 'Foundation', 'CoreBluetooth', 'CoreGraphics','Accelerate']

        fitcore.dependency 'TopStepComKit-Git/Interface'
        fitcore.dependency 'TopStepComKit-Git/ToolsCore'
        # 原先由 FitCloudDFUKit / FitCloudNWFKit 这两个 Pod 间接带入，
        # 改为本地 xcframework 后必须显式声明。
        fitcore.dependency 'iOSDFULibrary', '~> 4.13.0'
        fitcore.dependency 'zipzap', '~> 8.1.1'
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
        fitai.preserve_paths = fit_base_frameworks + fit_base_resources + [fit_header_stubs] + [
            'TopStepComKit-Git/Classes/FitImp/AI/TopStepFitKit.xcframework'
        ]
        fitai.resources = fit_base_resources
        fitai.frameworks = ['UIKit', 'Foundation', 'CoreBluetooth', 'CoreGraphics','Accelerate']

        fitai.dependency 'TopStepComKit-Git/Interface'
        fitai.dependency 'TopStepComKit-Git/ToolsCore'
        fitai.dependency 'TopStepComKit-Git/AIImp'
        fitai.dependency 'iOSDFULibrary', '~> 4.13.0'
        fitai.dependency 'zipzap', '~> 8.1.1'
        fitai.dependency 'ReactiveObjC'
        fitai.dependency 'MJExtension'
    end
    
    # AIImp subspec - contains TopStepAIKit, AIBuds provider binaries and resources.
    s.subspec 'AIImp' do |ai|
        ai.ios.deployment_target = '15.0'
        # MagicHelper 由宿主的兼容动态库或可选 MagicHelper 子包提供，不吸收进 AIKit。
        # AIBuds 适配层仍由 AIKit 实现；ONNX、DscrowSdk、QPlay 随 MagicHelper 管理。
        ai.vendored_frameworks = [
        'TopStepComKit-Git/Classes/AIImp/TopStepAIKit.xcframework',
        'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/Audio/ten_vad.framework',
        'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/Audio/LAME.xcframework',
        'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Dependencies/AI/StarburstSdk.framework'
        ]
        # 被吸收的 AIBuds 等静态 SDK 只提供无二进制的头文件框架，供编译 TopStepAIKit 公开头文件，不参与链接。
        ai.preserve_paths = 'TopStepComKit-Git/Classes/AIImp/*.framework'
        
        ai.frameworks = [
        'Foundation', 'CoreBluetooth', 'CoreGraphics', 'CoreAudio', 'CoreMedia',
        'AVFoundation', 'UIKit', 'QuartzCore', 'Metal', 'CoreVideo', 'CoreMotion',
        'Accelerate', 'VideoToolbox'
        ]

        ai.resources = [
        'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/AI/AIBudsAudio.bundle',
        'TopStepComKit-Git/Classes/AIImp/Providers/AIBuds/Frameworks/Extensions/AIBudsAIDashboard.bundle'
        ]
        
        ai.dependency 'TopStepComKit-Git/Interface'
        ai.dependency 'TopStepComKit-Git/ToolsCore'
        ai.dependency 'zipzap'
        # iOSLogBrowserSDK 已吸收进 AIKit；MagicHelper 的实现及依赖由独立动态库提供。
        ai.dependency 'SocketRocket'
        ai.dependency 'AFNetworking', '~> 4.0'
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
        # persimwearSDK 静态库已吸收进 TopStepPersimwearKit 动态库，只发布其头文件框架（无二进制）。
        fwimp.vendored_frameworks = [
        'TopStepComKit-Git/Classes/FwImp/TopStepPersimwearKit.xcframework'
        ]
        fwimp.preserve_paths = [
        'TopStepComKit-Git/Classes/FwImp/TopStepPersimwearKit.xcframework',
        'TopStepComKit-Git/Classes/FwImp/*.framework',
        'TopStepComKit-Git/Classes/FwImp/WearApi.bundle'
        ]
        fwimp.resources = [
        'TopStepComKit-Git/Classes/FwImp/WearApi.bundle'
        ]
        fwimp.frameworks = ['Foundation', 'UIKit']
        fwimp.libraries = ['z', 'bz2', 'sqlite3']
        
        fwimp.dependency 'TopStepComKit-Git/Interface'
        fwimp.dependency 'TopStepComKit-Git/ToolsCore'
        # 动态 TopStepPersimwearKit 运行时链接 ReactiveObjC，需由接入方提供。
        fwimp.dependency 'ReactiveObjC'

    end
    
    
    # NpkImp/Base 共用本地二进制：BleMeta 协议底座 + 表盘视频编码库（动态）。
    # 表盘压缩库 libTscCompressor 为静态库，已吸收进 TopStepNewPlatformKit 动态库，不再单独发布。
    # TopStepNewPlatformKit.xcframework 按 Core / AI 两个变体分别位于 NpkImp/Core 与 NpkImp/AI。
    npk_base_frameworks = [
        'TopStepComKit-Git/Classes/NpkImp/Base/TopStepBleMetaKit.xcframework',
        'TopStepComKit-Git/Classes/NpkImp/Base/h264encoder.framework'
    ]

    # NpkCoreImp subspec - Core 变体 + NpkImp/Base 共用二进制。
    # 不可与 NpkAIImp 同时安装：两者都提供 TopStepNewPlatformKit.framework。
    s.subspec 'NpkCoreImp' do |npkcore|
        npkcore.vendored_frameworks = npk_base_frameworks + [
            'TopStepComKit-Git/Classes/NpkImp/Core/TopStepNewPlatformKit.xcframework'
        ]
        npkcore.preserve_paths = npk_base_frameworks + [
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
        npkai.preserve_paths = npk_base_frameworks + [
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
