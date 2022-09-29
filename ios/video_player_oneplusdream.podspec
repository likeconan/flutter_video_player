#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint video_player_oneplusdream.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'video_player_oneplusdream'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
#  s.resources    = ['Assets/**.*']
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # third party platform
  s.dependency 'SnapKit'
  s.dependency 'ToastViewSwift'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.resource_bundles = {
       'OnePlusKitBundle' => ['Assets/*.xcassets']
  }
end
