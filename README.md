# FUThemeManager
*设置主题（夜间模式/字体类型设置/图片赋值/字体大小设置）
*UIImageView、UIButton根据状态进行图片赋值


### CocoaPods

  1. Add `pod 'FUThemeManager', '~> 1.0.0'` to your Podfile.

  2. Run `pod install` or `pod update`.

  3. #import "FUThemeManager.h".


###initialize

1.单例
+ (instancetype)manager;

/*--------------------------属性---------------------------*/

2.字体类型
@property (nonatomic, assign) FUFontType fontType;

3.主题
@property (nonatomic, assign) FUTheme theme;

4.图片赋值类型
@property (nonatomic, assign) FUThemePhotoStyle showPhotoStyle;

5.字体大小设置
@property (nonatomic, assign) FUThemeFontSize fontSizeType;

6.夜间设置自动切换
@property (nonatomic, assign) BOOL themeAutoChange;

7.返回：根据主题改变Alpha
@property (nonatomic, assign) CGFloat imageViewAlphaForCurrentTheme;

8.返回：字体名
@property (nonatomic, copy) NSString *chageFontName;



/*--------------------------方法---------------------------*/

//UIImageView、UIButton网络赋值
+ (void)fu_setImageWithUrlStr:(NSString *)url placeholder:(UIImage *)place imageView:(UIImageView *)imageView;
+ (void)fu_setImageWithUrlStr:(NSString *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder button:(UIButton *)btn;

//根据主题返回图片名
+ (UIImage *)imageNamed:(NSString *)name;
//获取属性列表文件里面配置的皮肤颜色
+ (UIColor *)colorNamed:(NSString *)name;
