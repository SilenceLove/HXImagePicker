Pod::Spec.new do |s|
  s.name         = "HXImagePicker"
  s.version      = "0.0.1"
  s.summary      = "An easy image picker"
  s.homepage     = "https://github.com/LoveZYForever/HXImagePicker"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "LoveZYForever" => "294005139@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/LoveZYForever/HXImagePicker.git", :commit => "fcc978f1ae4dede8e5dd16cf66ec645120c854b3" }
  s.source_files = "HXImagePicker/*.{h,m}"
  s.resources    = "HXImagePicker/images/*.png"
  s.requires_arc = true

end
