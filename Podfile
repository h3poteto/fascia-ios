source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target "fascia-ios" do
  pod 'Alamofire', '~> 4.2'
  pod 'RxSwift', '~> 3.0'
  pod 'RxCocoa', '~> 3.0'
  pod 'ObjectMapper', '~> 2.2'
  pod 'CSNotificationView'
  pod 'RxAlamofire', '~> 3.0'
  pod 'SVProgressHUD'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'SideMenu', '~> 2.0'
  pod 'Color-Picker-for-iOS', '~> 2.0'
  pod 'SESlideTableViewCell'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'MMMarkdown'

  post_install do | installer |
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end

