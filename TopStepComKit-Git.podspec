#
# Be sure to run `pod lib lint TopStepComKit-Git.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TopStepComKit-Git'
  s.version          = '1.0.0'
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
  s.swift_version = '5.0'

  # 添加架构支持
  s.pod_target_xcconfig = {
    'VALID_ARCHS' => 'arm64 x86_64',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
    'IPHONEOS_DEPLOYMENT_TARGET' => '12.0',
    'HEADER_SEARCH_PATHS' => '$(inherited) ${PODS_ROOT}/TopStepComKit-Git/TopStepComKit-Git/Classes/**'
  }
  s.user_target_xcconfig = {
    'VALID_ARCHS' => 'arm64 x86_64',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'IPHONEOS_DEPLOYMENT_TARGET' => '12.0',
    'HEADER_SEARCH_PATHS' => '$(inherited) ${PODS_ROOT}/TopStepComKit-Git/TopStepComKit-Git/Classes/**'
  }

  # 添加静态库支持
  s.static_framework = true

  # Foundation subspec - contains InterfaceKit and ToolKit
  s.subspec 'Foundation' do |foundation|
    foundation.vendored_frameworks = [
      'TopStepComKit-Git/Classes/Foundation/TopStepInterfaceKit.xcframework',
      'TopStepComKit-Git/Classes/Foundation/TopStepToolKit.xcframework'
    ]
    foundation.preserve_paths = 'TopStepComKit-Git/Classes/Foundation/*.xcframework'
  end

  # ComKit subspec - contains the main interface
  s.subspec 'ComKit' do |comkit|
    comkit.vendored_frameworks = 'TopStepComKit-Git/Classes/ComKit/TopStepComKit.xcframework'
    comkit.dependency 'TopStepComKit-Git/Foundation'
    comkit.preserve_paths = 'TopStepComKit-Git/Classes/ComKit/*.xcframework'
  end

  # FitCoreImp subspec - contains FitKit implementation
  s.subspec 'FitCoreImp' do |fitcore|
    fitcore.vendored_frameworks = 'TopStepComKit-Git/Classes/FitCoreImp/TopStepFitKit.xcframework'
    fitcore.dependency 'TopStepComKit-Git/Foundation'
    fitcore.preserve_paths = 'TopStepComKit-Git/Classes/FitCoreImp/*.xcframework'
    
    # 添加FitCloud相关依赖
    fitcore.dependency 'FitCloudKit'
    fitcore.dependency 'FitCloudDFUKit'
    fitcore.dependency 'FitCloudWFKit'
    fitcore.dependency 'FitCloudNWFKit'
  end

  # 移除全局的 source_files，避免头文件重复
  # s.source_files = 'TopStepComKit-Git/Classes/**/*'
  
  
  # s.resource_bundles = {
  #   'TopStepComKit-Git' => ['TopStepComKit-Git/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
