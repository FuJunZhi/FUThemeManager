# FUThemeManager
特点
- 可以对所有NSObject子类对象进行设置
- 灵活动态添加主题
- 当前主题记忆功能, 下一次启动自动布置
- 轻量级设计, 简化文件架构, 全部集合为两个文件中
- 支持主题字体设置（字体类型、字体大小...）
- 支持图片赋值类型设置（仅在wifi下显示图片、不显示图片、显示图片...）
- 支持UIView的主题背景颜色设置（代码设置、Interface Builder中设置）
- 支持UIImageView、UIButton的主题图片设置（代码设置、Interface Builder中设置）
- 支持UILabel、UItextView、UIButton的字体颜色设置（代码设置、Interface Builder中设置）
- 所有设置一行代码搞定
- UIImageView、UIButton根据状态进行图片赋值


### CocoaPods

  1. Add `pod 'FUThemeManager', '~> 1.0.2'` to your Podfile.

  2. Run `pod install` or `pod update`.

  3. '#import "FUThemeManager.h"'.


### 带动画的效果图
<img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUThemeManage.gif" width="40%" height="40%">


用法
==============
### 添加新主题
```
/*
* 添加主题
* 添加后的主题，会自动存储 无需每次都添加
*
* defaultJson 要添加的主题json全路径
* DefaultTheme 主题名称
*
*/
[FUThemeManager fu_AddThemeConfigJson:@"defaultJson" themeString:@"DefaultTheme"];
```
### JSON格式
```
{
   "自定义标签1": {
      "color1" : "#f5f5f5",
      "color2" : "255,255,255",
      "color3" : "255,255,255,0.5",
   },
   "color4" : "#38befa",

   "自定义标签2": {
      "image1" : "test1.png",
   },

   "image2" : "test2.png",
}
```
##### json数据，颜色值可以是rgb／rgba/16进制 格式
##### 可以自定义标签，多层级书写；赋值的时候层级关系之间只需用"."分割就行
```
例如：@"自定义标签1.color1"
```

### 默认主题设置
```
/*
* 默认主题
*
* DefaultTheme 主题名称
*
* 指定第一次启动APP时默认启用的主题
*/
[FUThemeManager fu_DefaultTheme:@"DefaultTheme"];
```

### 切换主题
```
/*
* 切换主题
*
* DefaultTheme 主题名称
*
* APP下一次开启会自动启用上一次的主题.
*/
[FUThemeManager fu_ChangeTheme:@"DefaultTheme"];
```

### 注
- 不要忘记设置默认主题, 应用中应该最少会有一个默认的主题
- 添加新主题、默认主题设置 一般在 `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`中添加


### 主题配置
```
self.fu_Theme.fu_ThemeChangeConfig(^(NSString *currentTheme, NSString *notiName) {
   /*
   * 所有NSObject子类都可以直接使用此方法
   *
   * 除了网络图片赋值，其他所有要根据主题改变的，都放在配置内部设置（颜色／字体／本地图片赋值）
   *
   * 根据notiName可知：
   *     FUFontTypeDidChangeNotification 字体改变
   *     FUThemeDidChangeNotification 主题改变
   */ 
});
```

### 颜色设置
```
*
* 颜色赋值，根据json数据的层级关系，层级关系之间用"."分割
*
* json数据里，色值可以是rgb／rgba/16进制 格式
*/
self.view.backgroundColor = [UIColor fu_ThemeColorName:@"自定义标签1.color1"];
```
- Interface Builder中设置主题字体颜色
  <img src="https://github.com/FuJunZhi/FUResources/blob/master/Images/FUThemeManage.png" width="80%" height="80%">

### 本地图片设置
```
*
* 图片赋值，根据json数据的层级关系，层级关系之间用"."分割
*
* fu_ThemeImageName
*/
self.testImageViewA.image = [UIImage fu_ThemeImageName:@"自定义标签2.image1"];
self.testImageViewB.image = [UIImage fu_ThemeImageName:@"image2"];
```

### 字体设置
```
*
* 根据设置的字体类型、字体大小返回当前字体
*
*/
self.testLabel.font = [UIFont fu_ThemeFont];
```

### 字体类型设置
```
/**
*  系统      FUFontTypeSystem,
*
*  华康娃娃体 FUFontTypeDFWaWaW5,
*／
[FUThemeManager fu_FontType:fontType];
```

### 字体大小设置
```
/**
*
*  超小 FUThemeFontSizeVerySmall = 6,
*
*  小   FUThemeFontSizeSmall = 9,
*
*  中   FUThemeFontSizeMiddle = 12,
*
*  大   FUThemeFontSizeLarge = 15,
*
*  超大 FUThemeFontSizeLargest = 18,
*/
[FUThemeManager fu_ThemeFontSize:fontSizeType];
```

### 网络图片赋值类型
```
/** 
*
*  显示图片 FUThemePhotoStyleShowPhotos
*
*  不显示图片 FUThemePhotoStyleShowPhotosNone,
*
*  仅在wifi下显示图片 FUThemePhotoStyleShowPhotoOnlyWifi,
*
*  未知情况 FUThemePhotoStyleShowPhotoUnKnow,
*／
[FUThemeManager fu_ThemePhotoStyle:showPhotoStyle];
```

==============
### 提供的分类方法
##### UIImage (FUThemeImage) 
```
//根据当前主题获取图片
+ (UIImage *)fu_ThemeImageName:(NSString *)imageName;
```

##### UIFont (FUThemeFont)
```
//根据当前主题返回Font
+ (UIFont *)fu_ThemeFont;
```

##### NSURL (FUThemeUrl)
```
//根据当前主题返回URL
+ (NSURL *)fu_ThemeUrl:(NSString *)url;
```

##### UIImageView (FUThemeImageView)
```
//根据网络图片赋值类型对UIImageView赋值
- (void)fu_setImageWithUrlStr:(NSString *)url placeholder:(UIImage *)place;
```

##### UIButton (FUThemeButton)
```
//根据网络图片赋值类型对UIButton赋值
- (void)fu_setImageWithUrlStr:(NSString *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;
```

### Interface Builder中可设置的属性
##### UIImageView
- Interface Builder中设置主题图片

##### UIButton
- Interface Builder中设置主题字体颜色
- Interface Builder中设置主题图片

#####  UIView
- Interface Builder中设置主题背景颜色

##### UILabel 
- Interface Builder中设置主题字体颜色

##### UITextView 
- Interface Builder中设置主题字体颜色

