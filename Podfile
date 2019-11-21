# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
#inhibit_all_warnings!
use_frameworks!

######################################## main project

workspace 'GleanerExample.xcworkspace'

target 'GleanerExample' do
      # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
      #use_frameworks!
    pod 'SnapKit', '~> 4.2.0'

    # RX
    pod 'RxSwift', '~> 5'
    pod 'RxDataSources'

    # NetWithRxSwift
    pod 'Moya', '~> 13.0.1'

    # JsonModel
    pod 'HandyJSON', '~> 5.0.0'
    pod 'SwiftyJSON'
    
    # 网络请求专属模型-存档
    pod 'YYCache', :modular_headers => true
    
    # Toast
    pod 'Toast-Swift', '~> 5.0.0'
    
end

# 指定target的swift版本
post_install do |installer|
  installer.pods_project.targets.each do |target|
    # 也可以不用 if，讓所有pod的版本都設為一樣的
#    if ['RxSwift', 'RxSwiftExt', 'RxCocoa', 'XCGLogger', 'HandyJSON'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.0'
#      end
    end
  end
end
