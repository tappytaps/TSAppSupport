Pod::Spec.new do |s|
  s.name         = "TSAppSupport"
  s.version      = "0.0.16"
  s.summary      = "App support lib - messaging etc."

  s.description  = <<-DESC
                    App suport lib
                   DESC

  s.homepage     = "http://tappytaps.com"
  s.license      = 'GPL'
  s.author       = { "Jindrich Sarson" => "jindra@tappytaps.com" }
  s.osx.deployment_target = '10.7'
  s.osx.frameworks = 'CoreServices', 'SystemConfiguration', 'Security'

  s.ios.deployment_target = '5.0'

  s.source       = { :git => "https://github.com/sarsonj/TSAppSupport.git", :tag => '0.0.16'}
  s.source_files  = 'TSAppSupport/Framework/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.osx.exclude_files = ['TSAppSupport/Framework/TSAppHTMLMessageController.*',
    'TSAppSupport/Framework/TSAppHTMLMessageWithBar.*']
  s.framework  = 'SystemConfiguration'
  s.dependency 'AFNetworking', '< 1.9'
  s.ios.dependency 'RMCategories'
  s.dependency 'MulticastDelegate', '~> 1.0'

  s.requires_arc = true
end
