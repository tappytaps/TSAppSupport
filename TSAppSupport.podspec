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
  s.osx.deployment_target = '10.8'
  s.osx.frameworks = 'CoreServices', 'SystemConfiguration', 'Security'

  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'

  s.source       = { :git => "https://github.com/sarsonj/TSAppSupport.git", :tag => '0.0.16'}
  s.source_files  = 'TSAppSupport/Framework/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.osx.exclude_files = ['TSAppSupport/Framework/TSAppHTMLMessageController.*',
    'TSAppSupport/Framework/TSAppHTMLMessageWithBar.*']
  s.tvos.exclude_files = ['TSAppSupport/Framework/TSAppHTMLMessageController.*',
    'TSAppSupport/Framework/TSAppHTMLMessageWithBar.*']

  s.framework  = 'SystemConfiguration'
  s.dependency 'AFNetworking', '3.0.0-beta.1'
  s.ios.dependency 'RMCategories'
  s.dependency 'MulticastDelegate', '~> 1.0'

  s.requires_arc = true
end
