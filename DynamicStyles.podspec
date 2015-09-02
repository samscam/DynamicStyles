Pod::Spec.new do |s|
  s.name = 'DynamicStyles'
  s.version = '0.2.0-beta'
  s.license = 'MIT'
  s.summary = 'Stylesheets for iOS apps! With dynamic type scaling!'
  s.homepage = 'https://github.com/samscam/DynamicStyles'
  s.social_media_url = 'http://twitter.com/samscam'
  s.authors = { 'Sam Easterby-Smith' => 'me@samscam.co.uk' }
  s.source = { :git => 'https://github.com/samscam/DynamicStyles.git', :tag => s.version, :branch => 'Swift-2.0' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'DynamicStyles/*.swift'

  s.requires_arc = true
end
