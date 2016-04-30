Pod::Spec.new do |s|
  s.name         = "JsonData"
  s.version      = "0.0.1"
  s.summary      = "Simple JSON parser and object mapping via JSON."
  s.homepage     = "https://github.com/wegie/JsonData"
  s.license      = "MIT"
  s.author       = "wegie"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/wegie/JsonData.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'JsonData/**/Commons.swift', 'JsonData/**/JsonData/*.swift'
  end

  s.subspec 'Objectable' do |o|
    o.source_files = 'JsonData/**/Objectable/*.swift'
    o.dependency 'JsonData/Core'
  end

end
