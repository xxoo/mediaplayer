#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mediaplayer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mediaplayer'
  s.version          = '1.3.0'
  s.summary          = 'A lightweight media player for Flutter.'
  s.description      = <<-DESC
A lightweight media player with subtitle rendering and audio track switching support, leveraging system or app-level components for seamless playback.
                       DESC
  s.homepage         = 'http://github.com/xxoo/mediaplayer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'xxoo' => 'http://github.com/xxoo' }

  s.source           = { :path => '.' }
  s.source_files     = 'mediaplayer/Sources/mediaplayer/**/*.swift'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
