Pod::Spec.new do |s|
  s.name = "Interstellar"
  s.version = "1.3.0"
  s.license = "MIT"
  s.summary = "The simplest Signal<T> implementation for Functional Reactive Programming you will ever find."
  s.homepage = "https://github.com/JensRavens/Interstellar"
  s.social_media_url = "http://twitter.com/JensRavens"
  s.authors = { "Jens Ravens" => "jens@nerdgeschoss.de" }
  s.source = { git: "https://github.com/JensRavens/Interstellar.git", tag: s.version }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.subspec "Core" do |cs|
    cs.source_files = "Interstellar/*.swift"
  end

  s.subspec "Warpdrive" do |cs|
    cs.dependency "Interstellar/Core"
    cs.source_files = "Warpdrive/*.swift"
  end

  s.requires_arc = true
end
