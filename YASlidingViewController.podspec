Pod::Spec.new do |s|

  s.name         = "YASlidingViewController"
  s.version      = "1.0.0"
  s.summary      = "A sliding UIViewController for iOS."

  s.description  = <<-DESC
                   YASlidingViewController allows you to set one (or two) view controllers to be full height on iOS7 so that the color behind the statusbar can be controlled, while the top view sits below the status bar as per iOS6. See the screenshot for an example of how it would appear.
                   DESC

  s.homepage     = "https://github.com/ThomasConner/YASlidingViewController"
  s.screenshots  = "http://dribbble.s3.amazonaws.com/users/14827/screenshots/1193991/8.png"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Thomas Conner" => "thomas.conner@me.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/ThomasConner/YASlidingViewController.git", :tag => "1.0.0" }
  s.source_files  = 'YASlidingViewController', 'YASlidingViewController/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'

end
