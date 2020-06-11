Pod::Spec.new do |s|
  s.name             = "TVADataBinder"
  s.version           = '0.4.1'
  s.summary          = "TVADataBinder"
  s.description      = <<-DESC
                        TVADataBinder container.
                       DESC
  s.homepage         = "https://github.com/applicaster-plugins/TVADataBinder-iOS.git"
  s.license          = ''
  s.author           = { "cmps" => "a=roei.carmel@msapps.mobi" }
  s.source           = { :git => "git@github.com:applicaster-plugins/TVADataBinder-iOS.git", :tag => s.version.to_s }

  s.platform                = :ios, '10.0'
  s.ios.deployment_target   = "10.0"
  s.requires_arc            = true
  s.static_framework        = true
  s.swift_version           = '5.0'

  s.source_files = 'PluginClasses/**/*.{swift}'

  s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                  'ENABLE_BITCODE' => 'YES',
                  'SWIFT_VERSION' => '5.0'
              }

  s.dependency 'ApplicasterSDK'
  s.dependency 'ZappSDK'
  s.dependency 'ZappGeneralPluginsSDK'
  s.dependency 'ZappPlugins'

end
