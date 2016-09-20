//
//  FUThemeManager.h
//  FUThemeManage
//
//  Created by fujunzhi on 16/7/11.
//  Copyright © 2016年 FJZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  夜间设置改变通知
 */
extern NSString *const kThemeDidChangeNotification;

/**
 *  字体类型改变通知
 */
extern NSString *const KFontTypeDidChangeNotification;

/*-------------------------------------------------------*/

//夜间设置
typedef NS_ENUM(NSInteger, FUTheme) {
    /**
     *  白天
     */
    FUThemeDefault,
    /**
     *  夜晚
     */
    FUThemeNight,
};

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
     *  超小
     */
    FUThemeFontSizeVerySmall = 0,
    /**
     *  小
     */
    FUThemeFontSizeSmall,
    /**
     *  中
     */
    FUThemeFontSizeMiddle,
    /**
     *  大
     */
    FUThemeFontSizeLarge,
    /**
     *  超大
     */
    FUThemeFontSizeLargest,
};

/*-------------------------------------------------------*/
@interface FUThemeManager : NSObject
/**
 *  单例
 */
+ (instancetype)manager;


/*--------------------------属性---------------------------*/

/**
 *  字体类型
 */
@property (nonatomic, assign) FUFontType fontType;
/**
 *  主题
 */
@property (nonatomic, assign) FUTheme theme;
/**
 *  图片赋值类型
 */
@property (nonatomic, assign) FUThemePhotoStyle showPhotoStyle;
/**
 *  字体大小设置
 */
@property (nonatomic, assign) FUThemeFontSize fontSizeType;
/**
 *  夜间设置自动切换
 */
@property (nonatomic, assign) BOOL themeAutoChange;



/**
 *  返回：根据主题改变Alpha
 */
@property (nonatomic, assign) CGFloat imageViewAlphaForCurrentTheme;

/**
 *  返回：字体名
 */
@property (nonatomic, copy) NSString *chageFontName;



/*--------------------------方法---------------------------*/

//UIImageView、UIButton网络赋值
+ (void)fu_setImageWithUrlStr:(NSString *)url placeholder:(UIImage *)place imageView:(UIImageView *)imageView;
+ (void)fu_setImageWithUrlStr:(NSString *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder button:(UIButton *)btn;

//根据主题返回图片名
+ (UIImage *)imageNamed:(NSString *)name;
//获取属性列表文件里面配置的皮肤颜色
+ (UIColor *)colorNamed:(NSString *)name;
@end
