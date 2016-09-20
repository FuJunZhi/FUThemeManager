Pod::Spec.new do |s|
    s.name         = "FUThemeManager"
    s.version      = "1.0.0"
    s.summary      = "ThemeManager"
    s.homepage     = "https://github.com/FuJunZhi/FUThemeManager"
    s.license      = "MIT"
    s.authors      = {"fujunzhi" => "185476975@qq.com"}
    s.platform     = :ios, "7.0"
    s.source       = {:git => "https://github.com/FuJunZhi/FUThemeManager.git", :tag => s.version}
    s.source_files = "FUThemeManager/*.{h,m}"
    s.resources = "FUThemeManager/FUThemeManager.bundle"
    s.requires_arc = true
end