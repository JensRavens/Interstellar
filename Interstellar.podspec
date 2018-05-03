#!/usr/bin/ruby

Pod::Spec.new do |s|
  s.name = "Interstellar"
  s.version = "2.2.0"
  s.license = "MIT"
  s.summary = "The simplest Observable<T> implementation for Functional Reactive Programming you will ever find."
  s.homepage = "https://github.com/JensRavens/Interstellar"
  s.social_media_url = "http://twitter.com/JensRavens"
  s.authors = { "Jens Ravens" => "jens@nerdgeschoss.de" }
  s.source = { git: "https://github.com/JensRavens/Interstellar.git", tag: s.version }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.subspec "Core" do |cs|
    cs.source_files = [
      "Sources/Interstellar/Result.swift",
      "Sources/Interstellar/Signal.swift",
      "Sources/Interstellar/Observable.swift",
      "Sources/Interstellar/ObserverToken.swift",
      "Sources/Interstellar/Mutex.swift",
      "Sources/Interstellar/ResultType.swift",
      "Sources/Interstellar/Observable+Result.swift"]
  end

  s.subspec "Warpdrive" do |cs|
    cs.dependency "Interstellar/Core"
    cs.source_files = [
      "Sources/Interstellar/Warpdrive/Debounce.swift",
      "Sources/Interstellar/Warpdrive/Delay.swift",
      "Sources/Interstellar/Warpdrive/Threading.swift",
      "Sources/Interstellar/Warpdrive/Waiting.swift"
    ]
  end

  s.requires_arc = true
end
