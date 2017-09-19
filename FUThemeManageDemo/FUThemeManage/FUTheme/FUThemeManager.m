//
//  FUThemeManager.m
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
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY FUIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "FUThemeManager.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#define FUMyManager [FUThemeManager manager]

//Noti Name
NSString *const FUThemeDidChangeNotification          = @"fu_ThemeDidChangeNotification";
NSString *const FUFontTypeDidChangeNotification       = @"fu_FontTypeDidChangeNotification";

//KEY值
static NSString *const FUTheme                        = @"fu_Theme";
static NSString *const FUThemeAutoChange              = @"fu_ThemeAutoChange";
static NSString *const FUFontTypeKey                  = @"fu_FontType";
static NSString *const FUShowPhotoType                = @"fu_ShowPhotoType";
static NSString *const FUFontShowSizeType             = @"fu_FontShowSizeType";
static NSString *const FUThemechangeAnimationDuration = @"fu_ThemechangeAnimationDuration";
static NSString *const FUThemeNotificationName        = @"fu_ThemeNotificationName";


@interface FUThemeManager()
@property (nonatomic , strong) NSMutableDictionary *fu_JsonConfigInfo;
/*
 * 当前主题
 */
@property (nonatomic , copy) NSString *fu_CurrentTheme;
/*
 * 所有的主题
 */
@property (nonatomic , strong) NSMutableSet *fu_AllThemes;
/**
 *  字体类型
 */
@property (nonatomic, assign) FUFontType fu_FontType;
/**
 *  图片赋值类型
 */
@property (nonatomic, assign) FUThemePhotoStyle fu_ShowPhotoStyle;
/**
 *  字体大小设置
 */
@property (nonatomic, assign) FUThemeFontSize fu_FontSizeType;
/**
 *  夜间设置自动切换
 */
@property (nonatomic, assign) BOOL fu_ThemeAutoChange;
/**
 *  更改主题动画时长
 */
@property (nonatomic, assign) CGFloat fu_ThemechangeAnimationDuration;
/**
 *  返回：字体名
 */
@property (nonatomic, copy) NSString *fu_ThemeFontName;
@end


@implementation FUThemeManager
- (instancetype)init {
    if (self = [super init]) {
        _fu_CurrentTheme = [FUUserDefaults objectForKey:FUTheme];
        
        _fu_FontType = [[FUUserDefaults objectForKey:FUFontTypeKey] integerValue];
        
        _fu_FontSizeType = [[FUUserDefaults objectForKey:FUFontShowSizeType] integerValue];
        
        _fu_ShowPhotoStyle = [[FUUserDefaults objectForKey:FUShowPhotoType] integerValue];
        
        id themeAutoChange = [FUUserDefaults objectForKey:FUThemeAutoChange];
        _fu_ThemeAutoChange = themeAutoChange ? [themeAutoChange boolValue] : NO;
        
        id themechangeAnimationDuration = [FUUserDefaults objectForKey:FUThemechangeAnimationDuration];
        _fu_ThemechangeAnimationDuration = themechangeAnimationDuration ? [themechangeAnimationDuration doubleValue] : 1;
        [self configFontTypeChange:_fu_FontType];
        
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

- (NSMutableDictionary *)fu_JsonConfigInfo
{
    if (!_fu_JsonConfigInfo) self.fu_JsonConfigInfo = [@{} mutableCopy];
    return _fu_JsonConfigInfo;
}

- (NSMutableSet *)fu_AllThemes
{
    if (!_fu_AllThemes) self.fu_AllThemes = [NSMutableSet set];
    return _fu_AllThemes;
}

#pragma mark - Theme
+ (void)fu_AddThemeConfigJson:(NSString *)json themeString:(NSString *)theme;
{
    if (json) {
        NSError *jsonError = nil;
        NSDictionary *jsonConfigInfo = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
        NSAssert(!jsonError, @"添加的主题json配置数据解析错误 - 错误描述");
        NSAssert(jsonConfigInfo, @"添加的主题json配置数据解析为空 - 请检查");
        NSAssert(theme, @"添加的主题json标签不能为空");
        
        if (!jsonError && jsonConfigInfo)
            [FUMyManager.fu_JsonConfigInfo setValue:@{@"json":jsonConfigInfo} forKey:theme];
        [FUMyManager.fu_AllThemes addObject:theme];
    }
}

+ (void)fu_ChangeTheme:(NSString *)theme
{
    NSAssert([FUMyManager.fu_AllThemes containsObject:theme], @"所启用的主题不存在 - 请检查是否添加了该%@主题的设置" , theme);
    FUMyManager.fu_CurrentTheme = theme;
    //发送通知，让其他界面更改主题
    [[NSNotificationCenter defaultCenter] postNotificationName:FUThemeDidChangeNotification object:nil userInfo:@{FUThemeNotificationName:FUThemeDidChangeNotification}];
}

+ (void)fu_DefaultTheme:(NSString *)theme
{
    if (!FUMyManager.fu_CurrentTheme && ![FUUserDefaults objectForKey:FUTheme]) FUMyManager.fu_CurrentTheme = theme;
}

+ (void)fu_FontType:(FUFontType)fontType
{
    FUMyManager.fu_FontType = fontType;
}

+ (void)fu_ThemePhotoStyle:(FUThemePhotoStyle)showPhotoStyle
{
    FUMyManager.fu_ShowPhotoStyle = showPhotoStyle;
}

+ (void)fu_ThemeFontSize:(FUThemeFontSize)fontSizeType
{
    FUMyManager.fu_FontSizeType = fontSizeType;
}

+ (void)fu_ThemeAutoChange:(BOOL)themeAutoChange
{
    FUMyManager.fu_ThemeAutoChange = themeAutoChange;
}

+ (void)fu_ThemechangeAnimationDuration:(CGFloat)themechangeAnimationDuration
{
    FUMyManager.fu_ThemechangeAnimationDuration = themechangeAnimationDuration;
}

+ (NSString *)fu_ChageFontName
{
    return FUMyManager.fu_ThemeFontName;
}

#pragma mark - setting Type
- (void)setFu_ShowPhotoStyle:(FUThemePhotoStyle)fu_ShowPhotoStyle
{
    _fu_ShowPhotoStyle = fu_ShowPhotoStyle;
    [FUUserDefaults setObject:@(fu_ShowPhotoStyle) forKey:FUShowPhotoType];
    [FUUserDefaults synchronize];
}

- (void)setFu_FontSizeType:(FUThemeFontSize)fu_FontSizeType
{
    _fu_FontSizeType = fu_FontSizeType;
    [FUUserDefaults setObject:@(fu_FontSizeType) forKey:FUFontShowSizeType];
    [FUUserDefaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:FUFontTypeDidChangeNotification object:nil userInfo:@{FUThemeNotificationName:FUFontTypeDidChangeNotification}];
}

- (void)setFu_FontType:(FUFontType)fu_FontType
{
    _fu_FontType = fu_FontType;
    [FUUserDefaults setObject:@(fu_FontType) forKey:FUFontTypeKey];
    [FUUserDefaults synchronize];
    [self configFontTypeChange:fu_FontType];
    [[NSNotificationCenter defaultCenter] postNotificationName:FUFontTypeDidChangeNotification object:nil userInfo:@{FUThemeNotificationName:FUFontTypeDidChangeNotification}];
}

- (void)setFu_CurrentTheme:(NSString *)fu_CurrentTheme
{
    _fu_CurrentTheme = fu_CurrentTheme;
    [FUUserDefaults setObject:fu_CurrentTheme forKey:FUTheme];
    [FUUserDefaults synchronize];
}

//待完善
- (void)setFu_ThemeAutoChange:(BOOL)fu_ThemeAutoChange
{
    _fu_ThemeAutoChange = fu_ThemeAutoChange;
    [FUUserDefaults setObject:@(fu_ThemeAutoChange) forKey:FUThemeAutoChange];
    [FUUserDefaults synchronize];
}

- (void)setFu_ThemechangeAnimationDuration:(CGFloat)fu_ThemechangeAnimationDuration
{
    NSAssert(fu_ThemechangeAnimationDuration >= 0, @"默认的更改主题动画时长不能小于0秒");
    _fu_ThemechangeAnimationDuration = fu_ThemechangeAnimationDuration;
    [FUUserDefaults setObject:@(fu_ThemechangeAnimationDuration) forKey:FUThemechangeAnimationDuration];
    [FUUserDefaults synchronize];
}

#pragma mark - getting

+ (NSString *)fu_CurrentTheme
{
    return FUMyManager.fu_CurrentTheme;
}

+ (FUFontType)fu_FontType
{
    return FUMyManager.fu_FontType;
}

+ (FUThemePhotoStyle)fu_ShowPhotoStyle
{
    return FUMyManager.fu_ShowPhotoStyle;
}

+ (CGFloat)fu_ThemeAnimationDuration
{
    return FUMyManager.fu_ThemechangeAnimationDuration;
}

+ (FUThemeFontSize)fu_FontSizeType
{
    return FUMyManager.fu_FontSizeType;
}

+ (NSString *)fu_FontName
{
    return FUMyManager.fu_ThemeFontName;
}

- (void)configFontTypeChange:(FUFontType)fontType {
    switch (fontType) {
        case FUFontTypeSystem:
            self.fu_ThemeFontName = [UIFont systemFontOfSize:15].fontName;
            break;
        case FUFontTypeDFWaWaW5: {
            NSString *fontPath =  [[self filePath:@"regular"] stringByAppendingString:@"/dfgb_ww5/regular.ttf"];
            self.fu_ThemeFontName = [self customFontWithPath:fontPath size:0];//@"DFWaWaW5-GB";
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



////获取属性列表文件里面配置的皮肤颜色
//+ (UIColor *)colorNamed:(NSString *)name
//{
//    UIColor *color = nil;
//    NSBundle *bundleThemeConfig = nil;
//    NSString *strPath = [[NSBundle mainBundle]resourcePath];
//    if (FUMyManager.theme == FUThemeDefault)
//    {
//        if (bundleThemeDefault == nil)
//        {
//            bundleThemeDefault = [NSBundle bundleWithPath:strPath];
//        }
//        bundleThemeConfig = bundleThemeDefault;
//    }
//    else if (FUMyManager.theme == FUThemeNight)
//    {
//        if (bundleThemeNight == nil)
//        {
//            strPath = [strPath stringByAppendingPathComponent:@"Night/"];
//            bundleThemeNight = [NSBundle bundleWithPath:strPath];
//        }
//        bundleThemeConfig = bundleThemeNight;
//    }
//    
//    if (bundleThemeConfig != nil)
//    {
//        NSArray *aryColorElem = [[bundleThemeConfig localizedStringForKey:name value:name table:@"ThemeConfig"] componentsSeparatedByString:@","];
//        if (aryColorElem != nil || aryColorElem.count == 4)
//        {
//            color = COLOR(((NSString*)aryColorElem[0]).integerValue, ((NSString*)aryColorElem[1]).integerValue, ((NSString*)aryColorElem[2]).integerValue, ((NSString*)aryColorElem[3]).doubleValue);;
//        }
//    }
//    return color;
//}

//主题的设置
//- (void)configureTheme:(FUTheme)theme {
//
//    if (theme == FUThemeDefault) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//        //这是屏幕的亮度
//        //         [UIScreen mainScreen].brightness = 0.5;
//    }
//
//    if (theme == FUThemeNight) {
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//        //        [UIScreen mainScreen].brightness = 0.3;
//
//    }
//
//}

@end

@interface FUThemeNotiModel()
@property (nonatomic, copy) FUThemeConfigBlock fu_ThemeChangeConfigBlock;

@end

@implementation FUThemeNotiModel
- (FUThemeNotiModelBlock)fu_ThemeChangeConfig
{
    WEAKSELF
    return ^(FUThemeConfigBlock configBlock) {
        STRONGSELF
        strongSelf.fu_ThemeChangeConfigBlock = configBlock;
        FUDispatchMain(^{
          if(configBlock) configBlock(FUMyManager.fu_CurrentTheme,nil);
        });
        return strongSelf;
    };
}
@end


@interface NSObject()
@property (nonatomic, assign, getter=isFu_ThemeExist) BOOL fu_ThemeExist;

@end


@implementation NSObject (FUThemeManagerObject)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSArray *selStringsArray = @[@"dealloc"];
        
        [selStringsArray enumerateObjectsUsingBlock:^(NSString *selString, NSUInteger idx, BOOL *stop) {
            
            NSString *fuSelString = [@"fu_" stringByAppendingString:selString];
            Method fuMethod = class_getInstanceMethod(self, NSSelectorFromString(fuSelString));
            Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(selString));
            if (!class_addMethod([self class], NSSelectorFromString(fuSelString), method_getImplementation(fuMethod), method_getTypeEncoding(fuMethod))) {
                method_exchangeImplementations(originalMethod, fuMethod);
            }
            
        }];
        
    });
}


- (void)fu_dealloc
{
    //NSString *str = [NSString stringWithFormat:@"%@", self.class];
    if (self.isFu_ThemeExist) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:FUThemeDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:FUFontTypeDidChangeNotification object:nil];
        objc_removeAssociatedObjects(self);
    }
    [self fu_dealloc];
}

- (void)fu_ThemeDidChangeThemeNotify:(NSNotification *)noti
{
    WEAKSELF
    FUDispatchMain(^{
        STRONGSELF
        if (strongSelf.fu_Theme.fu_ThemeChangeConfigBlock) strongSelf.fu_Theme.fu_ThemeChangeConfigBlock(FUMyManager.fu_CurrentTheme,noti.userInfo[FUThemeNotificationName]);
        //动画
        UIView *coverView = [[UIApplication sharedApplication].delegate.window snapshotViewAfterScreenUpdates:NO];
        [[UIApplication sharedApplication].delegate.window addSubview:coverView];
        [UIView animateWithDuration:FUMyManager.fu_ThemechangeAnimationDuration animations:^{
            coverView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [coverView removeFromSuperview];
        }];
        /*[UIView beginAnimations:@"ThemeDidChange" context:nil];
        [UIView setAnimationDuration:FUMyManager.fu_ThemechangeAnimationDuration];
        if (strongSelf.fu_Theme.fu_ThemeChangeConfigBlock) strongSelf.fu_Theme.fu_ThemeChangeConfigBlock(FUMyManager.fu_CurrentTheme,noti.userInfo[FUThemeNotificationName]);
        [UIView commitAnimations];*/
    });
}

- (void)setFu_Theme:(FUThemeNotiModel *)fu_Theme
{
    if(self && fu_Theme) objc_setAssociatedObject(self, @selector(fu_Theme), fu_Theme , OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (FUThemeNotiModel *)fu_Theme
{
    FUThemeNotiModel *model = objc_getAssociatedObject(self, _cmd);
    if (!model) {
        model = [FUThemeNotiModel new];
        objc_setAssociatedObject(self, _cmd, model , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fu_ThemeDidChangeThemeNotify:) name:FUThemeDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fu_ThemeDidChangeThemeNotify:) name:FUFontTypeDidChangeNotification object:nil];
        self.fu_ThemeExist = YES;
    }
    return model;
}

- (void)setFu_ThemeExist:(BOOL)fu_ThemeExist
{
    if(self && fu_ThemeExist) objc_setAssociatedObject(self, @selector(isFu_ThemeExist), @(fu_ThemeExist) , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isFu_ThemeExist
{
    return self ? [objc_getAssociatedObject(self, _cmd) boolValue] : NO;
}


@end

@implementation UIColor (FUThemeColor)

+ (UIColor *)fu_ColorWithRGBHex:(UInt32)hex
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)fu_ColorWithHexString:(NSString *)stringToConvert
{
    
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    //是否是@"R,G,B,A"格式
    NSArray *array = [stringToConvert componentsSeparatedByString:@","];
    if (array.count >= 3)
    {
        CGFloat red = [array[0] floatValue];
        CGFloat green = [array[1] floatValue];
        CGFloat blue = [array[2] floatValue];
        CGFloat alpha = array.count > 3 ? [array[3] floatValue] : 1.0;
        return FURGBA(red,green,blue,alpha);
    }
    
    //16 String should be 6 or 8 characters
    if ([cString length] < 6)
        return [UIColor clearColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    NSScanner *scanner = [NSScanner scannerWithString:cString];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [UIColor fu_ColorWithRGBHex:hexNum];
}

+ (UIColor *)fu_ThemeColorName:(NSString *)colorName
{
    __block id config = FUMyManager.fu_JsonConfigInfo[FUMyManager.fu_CurrentTheme][@"json"];
    [[colorName componentsSeparatedByString:@"."] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([config isKindOfClass:[NSDictionary class]])
            config = config[obj];
    }];
    return config ? [UIColor fu_ColorWithHexString:config] : nil;
}
@end


@implementation UIImage (FUThemeImage)

+ (UIImage *)fu_ThemeImageName:(NSString *)imageName
{
    __block id config = FUMyManager.fu_JsonConfigInfo[FUMyManager.fu_CurrentTheme][@"json"];
    [[imageName componentsSeparatedByString:@"."] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([config isKindOfClass:[NSDictionary class]])
            config = config[obj];
    }];
    
    UIImage *image = [UIImage imageNamed:config];
    if (!image) image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:config]];
    
    return image;
}

@end

@implementation UIFont (FUThemeFont)
+ (UIFont *)fu_ThemeFont
{
    return [UIFont fontWithName:FUMyManager.fu_ThemeFontName size:FUMyManager.fu_FontSizeType];
}
@end

@implementation NSURL (FUThemeUrl)
+ (NSURL *)fu_ThemeUrl:(NSString *)url
{
    NSURL *imageUrl = [NSURL URLWithString:url];
    switch (FUMyManager.fu_ShowPhotoStyle) {
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
@end

@implementation UIImageView (FUThemeImageView)
- (void)fu_setImageWithUrlStr:(NSString *)url placeholder:(UIImage *)place
{
    [self sd_setImageWithURL:[NSURL fu_ThemeUrl:url] placeholderImage:place];
}

- (void)setFu_ThemeImage:(NSString *)fu_ThemeImage
{
    self.image = [UIImage fu_ThemeImageName:fu_ThemeImage];
    if(self && fu_ThemeImage) objc_setAssociatedObject(self, @selector(fu_ThemeImage), fu_ThemeImage , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)fu_ThemeImage
{
    return self ? objc_getAssociatedObject(self, _cmd) :  @"";
}
@end


@implementation UIButton (FUThemeButton)
- (void)fu_setImageWithUrlStr:(NSString *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder
{
    [self sd_setImageWithURL:[NSURL fu_ThemeUrl:url] forState:state placeholderImage:placeholder];
}

- (void)setFu_ThemeTextColor:(NSString *)fu_ThemeTextColor
{
    self.titleLabel.textColor = [UIColor fu_ThemeColorName:fu_ThemeTextColor];
    if(self && fu_ThemeTextColor) objc_setAssociatedObject(self, @selector(fu_ThemeTextColor), fu_ThemeTextColor , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)fu_ThemeTextColor
{
    return self ? objc_getAssociatedObject(self, _cmd) :  @"";
}


- (void)setFu_ThemeImage:(NSString *)fu_ThemeImage
{
    [self setImage:[UIImage fu_ThemeImageName:fu_ThemeImage] forState:UIControlStateNormal];
    if(self && fu_ThemeImage) objc_setAssociatedObject(self, @selector(fu_ThemeImage), fu_ThemeImage , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)fu_ThemeImage
{
    return self ? objc_getAssociatedObject(self, _cmd) :  @"";
}
@end


@implementation UIView (FUThemeView)
- (void)setFu_ThemeBGColor:(NSString *)fu_ThemeBGColor
{
    self.backgroundColor = [UIColor fu_ThemeColorName:fu_ThemeBGColor];
    if(self && fu_ThemeBGColor) objc_setAssociatedObject(self, @selector(fu_ThemeBGColor), fu_ThemeBGColor , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)fu_ThemeBGColor
{
    return self ? objc_getAssociatedObject(self, _cmd) :  @"";
}
@end

@implementation UILabel (FUThemeLabel)
- (void)setFu_ThemeTextColor:(NSString *)fu_ThemeTextColor
{
    self.textColor = [UIColor fu_ThemeColorName:fu_ThemeTextColor];
    if(self && fu_ThemeTextColor) objc_setAssociatedObject(self, @selector(fu_ThemeTextColor), fu_ThemeTextColor , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)fu_ThemeTextColor
{
    return self ? objc_getAssociatedObject(self, _cmd) :  @"";
}
@end

@implementation UITextView (FUThemeTextView)
- (void)setFu_ThemeTextColor:(NSString *)fu_ThemeTextColor
{
    self.textColor = [UIColor fu_ThemeColorName:fu_ThemeTextColor];
    if(self && fu_ThemeTextColor) objc_setAssociatedObject(self, @selector(fu_ThemeTextColor), fu_ThemeTextColor , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)fu_ThemeTextColor
{
    return self ? objc_getAssociatedObject(self, _cmd) :  @"";
}
@end




