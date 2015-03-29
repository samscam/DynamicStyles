Pod::Spec.new do |s|
  s.name = 'DynamicStyles'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'Stylesheets for iOS apps! With dynamic type scaling!'
  s.homepage = 'https://github.com/samscam/DynamicStyles'
  s.social_media_url = 'http://twitter.com/samscam'
  s.authors = { 'Sam Easterby-Smith' => 'me@samscam.co.uk' }
  s.source = { :git => 'https://github.com/samscam/DynamicStyles.git', :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files = 'DynamicStyles/*.swift'

  s.requires_arc = true
end
