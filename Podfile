source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target "fascia-ios" do
  pod 'Alamofire', '~> 4.9'
  pod 'RxSwift', '~> 5.0'
  pod 'RxCocoa', '~> 5.0'
  pod 'ObjectMapper', '~> 3.5'
  pod 'CSNotificationView'
  pod 'RxAlamofire', '~> 5.0'
  pod 'SVProgressHUD', '~> 2.2'
  # I'm waiting for https://github.com/viccalexander/Chameleon/pull/244
  # pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/wowansm/Chameleon.git', :commit => "96d52c36a45847fff60bcff7a58fec1e4bd7390b"
  pod 'SideMenu', '~> 6.0'
  pod 'Color-Picker-for-iOS', '~> 2.0'
  pod 'SESlideTableViewCell', '~> 0.7'
  pod 'Fabric', '~> 1.10.2'
  pod 'Crashlytics', '~> 3.13.4'
  pod 'Down', '~> 0.9.0'

  # post_install do | installer |
  #   installer.pods_project.targets.each do |target|
  #     target.build_configurations.each do |config|
  #       config.build_settings['SWIFT_VERSION'] = '3.0'
  #     end
  #   end
  # end
end

