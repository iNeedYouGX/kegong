//
//  CZTabBarController.m
//  BestCity
//
//  Created by JasonBourne on 2018/7/24.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import "CZTabBarController.h"
#import "CZNavigationController.h"
#import "CZHotSaleController.h" // 商品
#import "KGShoppingTrolleyController.h" // 购物车
#import "CZMeControllerViewController.h" // 我的


@interface CZTabBarController ()<UITabBarControllerDelegate>

@end

@implementation CZTabBarController

+(void)initialize
{
    NSMutableDictionary *normalAttr = [NSMutableDictionary dictionary];
    normalAttr[NSForegroundColorAttributeName] = CZRGBColor(40, 40, 40);
    normalAttr[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    
    NSMutableDictionary *selectedAttr = [NSMutableDictionary dictionary];
    selectedAttr[NSForegroundColorAttributeName] = CZRGBColor(277, 20, 54);
    selectedAttr[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    
    [[UITabBarItem appearance] setTitleTextAttributes:normalAttr forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:selectedAttr forState:UIControlStateSelected];
    
    [[UITabBar appearance] setBarTintColor: CZRGBColor(254, 254, 254)];
    // 设配iOS12, tabbar抖动问题
    [[UITabBar appearance] setTranslucent:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self setupWithController:[[UIViewController alloc] init] title:@"接单" image:@"tab-form-nor" selectedImage:@"tab-form-sel"];
    [self setupWithController:[[CZHotSaleController alloc] init] title:@"商品" image:@"tab-good-nor" selectedImage:@"tab-good-sel"];
    [self setupWithController:[[KGShoppingTrolleyController alloc] init] title:@"购物车" image:@"tab-cart-nor" selectedImage:@"tab-cart-sel"];
    [self setupWithController:[[CZMeControllerViewController alloc] init] title:@"我的" image:@"tab-people-nor" selectedImage:@"tab-people-sel"];
    
    self.selectedIndex = 2;
    self.tabBar.clipsToBounds = YES;
}


- (void)setupWithController:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
//    if (![vc isKindOfClass:[CZMeController class]] && ![vc isKindOfClass:[CZTrialMainController class]]) {
//        WMPageController *hotVc = (WMPageController *)vc;
//        hotVc.selectIndex = 0;
//        hotVc.menuViewStyle = WMMenuViewStyleLine;
////        hotVc.progressWidth = 30;
//        hotVc.itemMargin = 10;
//        hotVc.progressHeight = 3;
//        hotVc.automaticallyCalculatesItemWidths = YES;
//        hotVc.titleFontName = @"PingFangSC-Medium";
//        hotVc.titleColorNormal = CZGlobalGray;
//        hotVc.titleColorSelected = [UIColor blackColor];
//        hotVc.titleSizeNormal = 15.0f;
//        hotVc.titleSizeSelected = 16;
//
//        hotVc.progressColor = [UIColor redColor];
//    }
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    CZNavigationController *nav = [[CZNavigationController alloc] initWithRootViewController:vc];
//    [vc.navigationController setNavigationBarHidden:YES];
    [self addChildViewController:nav];
}

@end
