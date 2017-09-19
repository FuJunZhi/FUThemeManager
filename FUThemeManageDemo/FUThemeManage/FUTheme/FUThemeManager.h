//
//  FUThemeManager.h
//  FUThemeManage
//
//  Created by fujunzhi on 16/7/11.
//  Copyright (c) 2016 FUTabBarController (https://github.com/FuJunZhi/FUThemeManager
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FUThemeNotiModel;
typedef void(^FUThemeConfigBlock)(NSString *currentTheme,NSString *notiName);
typedef FUThemeNotiModel *(^FUThemeNotiModelBlock)(FUThemeConfigBlock);
#define FUUserDefaults [NSUserDefaults standardUserDefaults]
#define FURGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define FUDispatchMain(block) dispatch_async(dispatch_get_main_queue(),block)
// block 防止循环引用的弱引用
#define WEAKSELF typeof(self) __weak weakSelf = self;
// block 强引用
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;
#define FUThemeDefault @"白天"
#define FUThemeNight @"夜间"

/**
 *  主题设置改变通知
 */
extern NSString *const FUThemeDidChangeNotification;

/**
 *  字体类型改变通知
 */
extern NSString *const FUFontTypeDidChangeNotification;

/*-------------------------------------------------------*/

//字体类型设置
typedef NS_ENUM(NSInteger, FUFontType) {
    /**
     *  系统
     */
    FUFontTypeSystem,
    /**
     *  华康娃娃体
     */
    FUFontTypeDFWaWaW5,
};

//图片赋值
typedef NS_ENUM(NSInteger, FUThemePhotoStyle) {
    /**
     *  显示图片
     */
    FUThemePhotoStyleShowPhotos = 0,
    /**
     *  不显示图片
     */
    FUThemePhotoStyleShowPhotosNone,
    /**
     *  仅在wifi下显示图片
     */
    FUThemePhotoStyleShowPhotoOnlyWifi,
    /**
     *  未知情况
     */
    FUThemePhotoStyleShowPhotoUnKnow,
};

//字体大小设置
typedef NS_ENUM(NSInteger, FUThemeFontSize) {
    /**
     *  超小  6
     */
    FUThemeFontSizeVerySmall = 6,
    /**
     *  小   9
     */
    FUThemeFontSizeSmall = 9,
    /**
     *  中   12
     */
    FUThemeFontSizeMiddle = 12,
    /**
     *  大   15
     */
    FUThemeFontSizeLarge = 15,
    /**
     *  超大 18
     */
    FUThemeFontSizeLargest = 18,
};

/*-------------------------------------------------------*/
@interface FUThemeManager : NSObject

#pragma mark - setting
/*
 * 添加主题
 *
 */
+ (void)fu_AddThemeConfigJson:(NSString *)json themeString:(NSString *)theme;
/*
 * 设置默认主题
 *
 */
+ (void)fu_DefaultTheme:(NSString *)theme;
/*
 * 改变主题
 *
 */
+ (void)fu_ChangeTheme:(NSString *)theme;
/**
 *  更改主题动画时长，默认1.0s
 */
+ (void)fu_ThemechangeAnimationDuration:(CGFloat)themechangeAnimationDuration;
/**
 *  设置字体类型
 *
 */
+ (void)fu_FontType:(FUFontType)fontType;
/**
 *  字体大小设置
 *
 */
+ (void)fu_ThemeFontSize:(FUThemeFontSize)fontSizeType;
/**
 *  网络图片赋值类型
 *
 */
+ (void)fu_ThemePhotoStyle:(FUThemePhotoStyle)showPhotoStyle;
/**
 *  夜间设置自动切换
 *
 */
+ (void)fu_ThemeAutoChange:(BOOL)themeAutoChange;

#pragma mark - getting
/*
 *  当前主题
 */
+ (NSString *)fu_CurrentTheme;
/**
 *  当前字体大小类型
 */
+ (FUThemeFontSize)fu_FontSizeType;
/**
 *  当前字体名
 */
+ (NSString *)fu_FontName;
/**
 *  当前图片赋值类型
 */
+ (FUThemePhotoStyle)fu_ShowPhotoStyle;
/**
 *  当前动画时长
 */
+ (CGFloat)fu_ThemeAnimationDuration;


////获取属性列表文件里面配置的皮肤颜色
//+ (UIColor *)colorNamed:(NSString *)name;
@end


@interface FUThemeNotiModel : NSObject
@property (nonatomic , copy , readonly ) FUThemeNotiModelBlock fu_ThemeChangeConfig;
@end

@interface NSObject (FUThemeManagerObject)
@property (nonatomic, strong) FUThemeNotiModel *fu_Theme;
@end

@interface UIColor (FUThemeColor)
//根据当前主题获取颜色
+ (UIColor *)fu_ThemeColorName:(NSString *)colorName;
//十六进制->RGB
+ (UIColor *)fu_ColorWithRGBHex:(UInt32)hex;
+ (UIColor *)fu_ColorWithHexString:(NSString *)stringToConvert;

@end

@interface UIImage (FUThemeImage)
//根据当前主题获取图片
+ (UIImage *)fu_ThemeImageName:(NSString *)imageName;

@end

@interface UIFont (FUThemeFont)
//根据当前主题返回Font
+ (UIFont *)fu_ThemeFont;
@end

@interface NSURL (FUThemeUrl)
//根据当前主题返回URL
+ (NSURL *)fu_ThemeUrl:(NSString *)url;

@end


IB_DESIGNABLE
@interface UIImageView (FUThemeImageView)
//根据对UIImageView赋值
- (void)fu_setImageWithUrlStr:(NSString *)url placeholder:(UIImage *)place;
//Interface Builder中设置主题图片
@property (nonatomic, copy) IBInspectable NSString *fu_ThemeImage;
@end

@interface UIButton (FUThemeButton)
//对UIButton赋值
- (void)fu_setImageWithUrlStr:(NSString *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;
//Interface Builder中设置主题字体颜色
@property (nonatomic, copy) IBInspectable NSString *fu_ThemeTextColor;
//Interface Builder中设置主题图片
@property (nonatomic, copy) IBInspectable NSString *fu_ThemeImage;
@end


@interface UIView (FUThemeView)
//Interface Builder中设置主题背景颜色
@property (nonatomic, copy) IBInspectable NSString *fu_ThemeBGColor;

@end

@interface UILabel (FUThemeLabel)
//Interface Builder中设置主题字体颜色
@property (nonatomic, copy) IBInspectable NSString *fu_ThemeTextColor;
@end

@interface UITextView (FUThemeTextView)
//Interface Builder中设置主题字体颜色
@property (nonatomic, copy) IBInspectable NSString *fu_ThemeTextColor;
@end




