# Uncomment the next line to define a global platform for your project

source 'https://github.com/CocoaPods/Specs.git'
install! 'cocoapods', :disable_input_output_paths => true

abstract_target 'ImageXExamples' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for ImageXExamples
  pod 'ImageX', :path => './'
  
  target 'ImageX (iOS)' do
    platform :ios, '12.0'
  end
  
  target 'ImageX (macOS)' do
    platform :macos, '11.0'
  end
  
end

# https://github.com/CocoaPods/CocoaPods/issues/11402
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
