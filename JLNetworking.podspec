Pod::Spec.new do |s|

  s.name         = "JLNetworking"
  s.version      = "1.0.0"
  s.summary      = "A short description of JLNetworking."

  s.description  = <<-DESC
                   A longer description of JLNetworking in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/JLNetworking"
  s.license      = "MIT"
  s.author             = { "JeremyLyu" => "734875137@qq.com" }
  s.source       = { :git => "https://github.com/JeremyLyu/JLNetworking.git" }
  s.requires_arc = true
  s.platform = :ios
  s.ios.deployment_target = "7.0"
  s.source_files  = "Classes", "Classes/*.{h,m}"
  s.dependency 'AFNetworking'

    s.subspec 'Support' do |ss|
    ss.source_files = "Classes/Support/*.{h,m}"
    end

    s.subspec 'Mapper' do |ss|
    ss.source_files = "Classes/Mapper/*.{h,m}"
    end

end
