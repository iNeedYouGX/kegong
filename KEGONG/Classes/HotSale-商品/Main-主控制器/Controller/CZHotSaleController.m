//
//  CZHotSaleController.m
//  BestCity
//
//  Created by JasonBourne on 2018/7/24.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import "CZHotSaleController.h"
#import "GXNetTool.h"
#import "CZHotSearchView.h"

#import "GXCategoryController.h" // 标题
#import "GXSubCategoryController.h" // 详情
#import "CZHotTitleModel.h" // 模型


@interface CZHotSaleController ()
//** 主标题数组 */
@property (nonatomic, strong) NSArray *mainTitles;
//** 主标题数组 */
@property (nonatomic, strong) NSArray *detailData;
/** 搜索框 */
@property (nonatomic, strong) CZHotSearchView *search;


@end

@implementation CZHotSaleController
#pragma mark - 数据
// 获取url
- (void)getImageUrl
{
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/variables.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqual:@(1)]) {
            KGIMAGEURL = result[@"variableMap"][@"imageserver_path"];
            // 获取类目数据
            [self obtainTtitles];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSError *error) {}];
}

// 获取标题数据
- (void)obtainTtitles
{
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/goods/types.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"msg"] isEqualToString:@"成功"]) {
            //标题的数据
            self.mainTitles = [CZHotTitleModel objectArrayWithKeyValuesArray:result[@"parentTypes"]];
            self.detailData = result[@"childTypes"];
            [self setupCategoryView];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSError *error) {}];
}

#pragma mark -- end

#pragma mark - 视图
- (void)setupTopSearchView
{
    self.search = [[CZHotSearchView alloc] initWithFrame:CGRectMake(10, IsiPhoneX ? 54 : 30, SCR_WIDTH - 20, 34) msgAction:^(NSString *title){}];
    self.search.textFieldActive = NO;
    [self.view addSubview:self.search];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSearchController)];
//    [self.search addGestureRecognizer:tap];
}

// 创建类目
- (void)setupCategoryView
{
    GXCategoryController *categoryVc = [[GXCategoryController alloc] init];
    categoryVc.view.frame = CGRectMake(0, CZGetY(self.search) + 12, 100, SCR_HEIGHT - CZGetY(self.search) - (IsiPhoneX ? 83 : 49) - 12);
    [self.view addSubview:categoryVc.view];
    [self addChildViewController:categoryVc];
    categoryVc.categories = self.mainTitles;


    GXSubCategoryController *subCategoryVc = [[GXSubCategoryController alloc] init];
    subCategoryVc.view.frame = CGRectMake(100, CZGetY(self.search) + 12, SCR_WIDTH - 90, SCR_HEIGHT - CZGetY(self.search) - (IsiPhoneX ? 83 : 49) - 12);
    [self.view addSubview:subCategoryVc.view];
    [self addChildViewController:subCategoryVc];
    subCategoryVc.dataArr = self.detailData;

    // 签代理
    categoryVc.delegate = subCategoryVc;
}

#pragma mark -- end

#pragma mark - 控制器的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTopSearchView];

    // 获取url
    [self getImageUrl];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self isLogin];
}

- (void)isLogin
{
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/user/IsLogin.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"isLogin"] isEqual:@(0)]) {
            CZLoginController *vc = [CZLoginController shareLoginController];
            UITabBarController *tabbar = (UITabBarController *)[[UIApplication sharedApplication].keyWindow rootViewController];
            UINavigationController *nav = tabbar.selectedViewController;
            UIViewController *currentVc = nav.topViewController;
            [currentVc.navigationController popViewControllerAnimated:YES];
            [nav presentViewController:vc animated:YES completion:^{
                [CZProgressHUD showProgressHUDWithText:@"请重新登录"];
                [CZProgressHUD hideAfterDelay:2];
            }];
        } else {
            if (self.mainTitles.count == 0) {
                for (UIView *v in self.view.subviews) {
                    [v removeFromSuperview];
                }
                [self setupTopSearchView];
                // 获取url
                [self getImageUrl];
            }

        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSError *error) {}];
}
#pragma mark -- end

@end
