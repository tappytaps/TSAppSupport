Pod::Spec.new do |s|
  s.name         = "TSAppSupport"
  s.version      = "0.0.1"
  s.summary      = "App support lib - messaging etc."

  s.description  = <<-DESC
                    App suport lib
                   DESC

  s.homepage     = "http://tappytaps.com"
  s.license      = 'GPL'
  s.author       = { "Jindrich Sarson" => "jindra@tappytaps.com" }
  s.platform     = :ios, '5.0'
  s.source       = { :git => "https://github.com/sarsonj/TSAppSupport.git", :tag => '0.0.1'}
  s.source_files  = 'TSAppSupport/Framework/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.framework  = 'SystemConfiguration'
  s.dependency 'AFNetworking', '< 1.9'
  s.dependency 'RMCategories'
  s.dependency 'MulticastDelegate', '= 0.0.2'

  s.requires_arc = true

end
