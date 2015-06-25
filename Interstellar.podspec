Pod::Spec.new do |s|
  s.name = 'Interstellar'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'The simplest Signal<T> implementation for Functional Reactive Programming you will ever find.'
  s.homepage = 'https://github.com/JensRavens/Interstellar'
  s.social_media_url = 'http://twitter.com/JensRavens'
  s.authors = { 'Jens Ravens' => 'jens@nerdgeschoss.de' }
  s.source = { :git => 'https://github.com/JensRavens/Interstellar.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Interstellar/*.swift'

  s.requires_arc = true
end