//
//  FUThemeManager.m
//  FUThemeManage
//
//  Created by fujunzhi on 16/7/11.
//  Copyright © 2016年 FJZ. All rights reserved.
//

#import "FUThemeManager.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"

#import <CoreText/CoreText.h>
//
#define userDefaults [NSUserDefaults standardUserDefaults]
#define myManager [FUThemeManager manager]

//颜色
#define RGB(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]
#define COLOR(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]
#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] > 7.0)

//Noti Name
NSString *const kThemeDidChangeNotification = @"ThemeDidChangeNotification";
NSString *const kFontTypeDidChangeNotification = @"FontTypeDidChangeNotification";

//KEY值
static NSString *const kTheme           = @"Theme";
static NSString *const kThemeAutoChange = @"ThemeAutoChange";
static NSString *const KFontType        = @"FontType";
static NSString *const KShowPhotoType   = @"ShowPhotoType";
static NSString *const KFontShowSizeType   = @"FontShowSizeType";

static NSBundle *bundleThemeDefault = nil;
static NSBundle *bundleThemeNight = nil;


@implementation FUThemeManager
- (instancetype)init {
    if (self = [super init]) {
        
        _theme = [[userDefaults objectForKey:kTheme] integerValue];
        
        _fontType = [[userDefaults objectForKey:KFontType] integerValue];
        
        _fontSizeType = [[userDefaults objectForKey:KFontShowSizeType] integerValue];
        
        _showPhotoStyle = [[userDefaults objectForKey:KShowPhotoType] integerValue];
        
        id themeAutoChange = [userDefaults objectForKey:kThemeAutoChange];
        if (themeAutoChange) {
            _themeAutoChange = [themeAutoChange boolValue];
        } else {
            _themeAutoChange = YES;
        }
        
        [self configureTheme:_theme];
        [self configFontTypeChange:_fontType];
        
    }
    return self;
}

+ (instancetype)manager {
    static FUThemeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FUThemeManager alloc] init];
    });
    return manager;
}


#pragma mark - save Photo Type
- (void)setShowPhotoStyle:(FUThemePhotoStyle)showPhotoStyle {
    _showPhotoStyle = showPhotoStyle;
    [userDefaults setObject:@(showPhotoStyle) forKey:KShowPhotoType];
    [userDefaults synchronize];
}

- (void)setFontSizeType:(FUThemeFontSize)fontSizeType {
    _fontSizeType = fontSizeType;
    [userDefaults setObject:@(fontSizeType) forKey:KFontShowSizeType];
    [userDefaults synchronize];
}
- (void)setFontType:(FUFontType)fontType {
    _fontType = fontType;
    [userDefaults setObject:@(fontType) forKey:KFontType];
    [userDefaults synchronize];
    [self configFontTypeChange:fontType];
    // 这里发通知;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFontTypeDidChangeNotification object:nil];
}

- (void)configFontTypeChange:(FUFontType)fontType {
    switch (fontType) {
        case FUFontTypeSystem:
            self.chageFontName = [UIFont systemFontOfSize:15].fontName;
            
            break;
        case FUFontTypeDFWaWaW5: {
            NSString *fontPath =  [[self filePath:@"regular"] stringByAppendingString:@"/dfgb_ww5/regular.ttf"];
            self.chageFontName = [self customFontWithPath:fontPath size:0];//@"DFWaWaW5-GB";
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)filePath:(NSString *)fileName {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
    NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
    return filePath;
}

-(NSString *)customFontWithPath:(NSString*)path size:(CGFloat)size
{
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    //    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    return fontName;
}


#pragma mark - Theme

//改变主题
- (void)setTheme:(FUTheme)theme {
    _theme = theme;
    [userDefaults setObject:@(theme) forKey:kTheme];
    [userDefaults synchronize];
    
    //更改设置
    [self configureTheme:theme];
    //发送通知，让其他界面更改主题
    [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDidChangeNotification object:nil];
    
}

//主题的设置
- (void)configureTheme:(FUTheme)theme {
    
    if (theme == FUThemeDefault) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        //这是屏幕的亮度
        //         [UIScreen mainScreen].brightness = 0.5;
    }
    
    if (theme == FUThemeNight) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        //        [UIScreen mainScreen].brightness = 0.3;
        
    }
    
}

- (void)setThemeAutoChange:(BOOL)themeAutoChange {
    _themeAutoChange = themeAutoChange;
    
    [userDefaults setObject:@(themeAutoChange) forKey:kThemeAutoChange];
    [userDefaults synchronize];
}

#pragma mark - Alpha

- (CGFloat)imageViewAlphaForCurrentTheme {
    if ([FUThemeManager manager].theme == FUThemeNight) {
        return 0.4;
    } else {
        return 1.0;
    }
}



#pragma mark - setting imageURL
+ (void)fu_setImageWithUrlStr:(NSString *)url placeholder:(UIImage *)place imageView:(UIImageView *)imageView
{
    [imageView sd_setImageWithURL:[self imageWithUrlStr:url] placeholderImage:place];
}

+ (void)fu_setImageWithUrlStr:(NSString *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder button:(UIButton *)btn
{
    [btn sd_setImageWithURL:[self imageWithUrlStr:url] forState:state placeholderImage:placeholder];
}

+ (NSURL *)imageWithUrlStr:(NSString *)url
{
    NSURL *imageUrl = [NSURL URLWithString:url];
    switch ([FUThemeManager manager].showPhotoStyle) {
        case FUThemePhotoStyleShowPhotos:
            imageUrl = [NSURL URLWithString:url];
            break;
        case FUThemePhotoStyleShowPhotosNone:
            imageUrl = nil;
            break;
        case FUThemePhotoStyleShowPhotoOnlyWifi: {
            
            if ([AFNetworkReachabilityManager sharedManager].isReachableViaWiFi) { // wifi 环境
                imageUrl = [NSURL URLWithString:url];
            }
        }
            break;
        default:
            break;
    }
    return imageUrl;
}

#pragma mark - getting imageName
+ (UIImage *)imageNamed:(NSString *)name
{
    NSString *strPath = [[NSBundle mainBundle] resourcePath];
    if (myManager.theme == FUThemeDefault)
    {
        
    }
    else if (myManager.theme == FUThemeNight)
    {
        strPath = [strPath stringByAppendingPathComponent:@"Night"];
    }
    
    if (iOS7)
    {
        strPath = [strPath stringByAppendingPathComponent:name];
    }
    else
    {
        //iOS7、iOS6不能自动追加后缀
        strPath = [strPath stringByAppendingPathComponent:name];
        strPath = [NSString stringWithFormat:@"%@@2x.png",strPath];
    }
    return [UIImage imageWithContentsOfFile:strPath];
}

//获取属性列表文件里面配置的皮肤颜色
+ (UIColor *)colorNamed:(NSString *)name
{
    UIColor *color = nil;
    NSBundle *bundleThemeConfig = nil;
    NSString *strPath = [[NSBundle mainBundle]resourcePath];
    if (myManager.theme == FUThemeDefault)
    {
        if (bundleThemeDefault == nil)
        {
            bundleThemeDefault = [NSBundle bundleWithPath:strPath];
        }
        bundleThemeConfig = bundleThemeDefault;
    }
    else if (myManager.theme == FUThemeNight)
    {
        if (bundleThemeNight == nil)
        {
            strPath = [strPath stringByAppendingPathComponent:@"Night/"];
            bundleThemeNight = [NSBundle bundleWithPath:strPath];
        }
        bundleThemeConfig = bundleThemeNight;
    }
    
    if (bundleThemeConfig != nil)
    {
        NSArray *aryColorElem = [[bundleThemeConfig localizedStringForKey:name value:name table:@"ThemeConfig"] componentsSeparatedByString:@","];
        if (aryColorElem != nil || aryColorElem.count == 4)
        {
            color = COLOR(((NSString*)aryColorElem[0]).integerValue, ((NSString*)aryColorElem[1]).integerValue, ((NSString*)aryColorElem[2]).integerValue, ((NSString*)aryColorElem[3]).doubleValue);;
        }
    }
    return color;
}


@end
