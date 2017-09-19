//
//  MineViewController.m
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

#import "MineViewController.h"
#import "FUThemeManager.h"
#import "MineUIService.h"
#import "MineViewModel.h"

@interface MineViewController ()
@property (nonatomic, strong) MineViewModel *mineViewModel;
@property (nonatomic, strong) MineUIService *mineUIService;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *testImageViewA;
@property (nonatomic, strong) UIImageView *testImageViewB;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //测试界面布局
    [self setUpSubTestViews];
    
#pragma mark - 主题配置
    /*
     * 所有NSObject子类都可以直接使用此方法
     *
     * 除了网络图片赋值，其他所有要根据主题改变的，都放在配置内部设置（颜色／字体／本地图片赋值）
     *
     * 根据notiName可知：
     *     FUFontTypeDidChangeNotification 字体改变
     *     FUThemeDidChangeNotification 主题改变
     */
    self.fu_Theme.fu_ThemeChangeConfig(^(NSString *currentTheme, NSString *notiName) {
        /*
         * 颜色赋值，根据json数据的层级关系，层级关系之间用"."分割
         *
         * json数据，色值可以是rgb／rgba/16进制 格式
         */
        self.view.backgroundColor = [UIColor fu_ThemeColorName:@"Mine.Mine_TableView_BGColor"];
        [self.navigationController.navigationBar setBarTintColor:[UIColor fu_ThemeColorName:@"Nav_Bar_BGColor"]];
        [self.navigationController.navigationBar setBackgroundColor:[UIColor fu_ThemeColorName:@"Nav_Bar_BGColor"]];
        
        /*
         * 图片赋值，根据json数据的层级关系，层级关系之间用"."分割
         *
         * fu_ThemeImageName
         */
        self.testImageViewA.image = [UIImage fu_ThemeImageName:@"image.Test1"];
        self.testImageViewB.image = [UIImage fu_ThemeImageName:@"Test2"];
        [self.tableView reloadData];
    });
    
}

#pragma mark - 主题改变
- (void)themeChange:(UISwitch *)sender
{
    if (sender.isOn)
    {
        /*
         * 切换主题
         *
         * DefaultTheme 主题名称
         *
         * APP下一次开启会自动启用上一次的主题.
         */
        [FUThemeManager fu_ChangeTheme:FUThemeNight];
    } else
    {
        [FUThemeManager fu_ChangeTheme:FUThemeDefault];
    }

}


#pragma mark - LazyLoading
- (MineUIService *)mineUIService
{
    if (!_mineUIService) {
        self.mineUIService = [MineUIService new];
        _mineUIService.viewModel = self.mineViewModel;
    }
    return _mineUIService;
}

- (MineViewModel *)mineViewModel
{
    if (!_mineViewModel) {
        self.mineViewModel = [MineViewModel new];
        _mineViewModel.mineVC = self;
        _mineViewModel.mineTableView = self.tableView;
    }
    return _mineViewModel;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.delegate = self.mineUIService;
        _tableView.dataSource = self.mineUIService;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.bounces = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (void)setUpSubTestViews
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //UIImageView
    CGFloat imageViewW = 50;
    self.testImageViewA = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, imageViewW, imageViewW)];
    self.testImageViewB = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - imageViewW, 64, imageViewW, imageViewW)];
    [self.view addSubview:_testImageViewA];
    [self.view addSubview:_testImageViewB];
    
    //tableView
    [self.view addSubview:self.tableView];
    CGFloat tableViewY = CGRectGetMaxY(self.testImageViewA.frame);
    self.tableView.frame = CGRectMake(0, tableViewY, screenWidth, screenHeight - tableViewY);
    
    //添加主题改变按钮
    UISwitch *themeSwith = [[UISwitch alloc] init];
    [themeSwith addTarget:self action:@selector(themeChange:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:themeSwith];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
