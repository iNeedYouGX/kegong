//
//  GXCategoryListDetailController.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/18.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "GXCategoryListDetailController.h"
#import "UIButton+CZExtension.h" // 按钮扩展
#import "GXNetTool.h"
#import "CZScollerImageTool.h"
#import "CZNavigationView.h"
#import "CZSubButton.h"
#import "CZAffirmPointController.h" //确认订单

#import "GXSqliteTool.h"

@interface GXCategoryListDetailController () <UIScrollViewDelegate, UIWebViewDelegate>
/** 数据 */
@property (nonatomic, strong) NSDictionary *dataSource;
/** 滚动视图 */
@property (nonatomic, strong) UIScrollView *scrollerView;
/** 返回键 */
@property (nonatomic, strong) UIButton *popButton;
/** webView */
@property (nonatomic, strong) UIWebView *webView;
/** 底部View */
@property (nonatomic, strong) UIView *bottomView;
/** 记录偏移量 */
@property (nonatomic, assign) CGFloat recordOffsetY;
/** <#注释#> */
@property (nonatomic, strong) UIView *navigationView;
@end

@implementation GXCategoryListDetailController
static CGFloat const likeAndShareHeight = 49;

- (UIScrollView *)scrollerView
{
    if (_scrollerView == nil) {
        _scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? -44 : -20), SCR_WIDTH, SCR_HEIGHT - likeAndShareHeight - (IsiPhoneX ? -44 : -20) - (IsiPhoneX ? 34 : 0))];
        self.scrollerView.delegate = self;
        _scrollerView.backgroundColor = CZGlobalWhiteBg;
    }
    return _scrollerView;
}

- (UIButton *)popButton
{
    if (_popButton == nil) {
        _popButton = [UIButton buttonWithFrame:CGRectMake(14, (IsiPhoneX ? 54 : 30), 30, 30) backImage:@"nav-back-1" target:self action:@selector(popAction)];
        _popButton.backgroundColor = [UIColor colorWithRed:21/255.0 green:21/255.0 blue:21/255.0 alpha:0.3];
        _popButton.layer.cornerRadius = 15;
        _popButton.layer.masksToBounds = YES;
    }
    return _popButton;
}

- (void)popAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.x = 0;
        _bottomView.y = SCR_HEIGHT - likeAndShareHeight - (IsiPhoneX ? 34 : 0);
        _bottomView.width = SCR_WIDTH;
        _bottomView.height = likeAndShareHeight;

        CZSubButton *btn = [CZSubButton buttonWithType:UIButtonTypeCustom];
        btn.width = 20;
        btn.height = 25;
        [btn setImage:[UIImage imageNamed:@"tab-service"] forState:UIControlStateNormal];
        [btn setTitle:@"客服" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.x = 25;
        btn.y = 5;
        [_bottomView addSubview:btn];
        // 点击事件
//        [btn addTarget:self action:@selector(serviceBtnClickedBtn:) forControlEvents:UIControlEventTouchUpInside];

        CZSubButton *btn1 = [CZSubButton buttonWithType:UIButtonTypeCustom];
        btn1.width = 20;
        btn1.height = 25;
        [btn1 setImage:[UIImage imageNamed:@"tab-cart"] forState:UIControlStateNormal];
        [btn1 setTitle:@"购物车" forState:UIControlStateNormal];
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn1.x = CZGetX(btn) + 40;
        btn1.y = 5;
        [_bottomView addSubview:btn1];
        // 点击事件
        [btn1 addTarget:self action:@selector(gotoShoppingCar:) forControlEvents:UIControlEventTouchUpInside];


        UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [buyBtn setTitle:@"立即购买" forState:UIControlStateNormal];
        buyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
        [buyBtn setBackgroundColor:CZREDCOLOR];
        [buyBtn addTarget:self action:@selector(buyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        buyBtn.x = SCR_WIDTH - 14 - 100;
        buyBtn.y = 5.5;
        buyBtn.width = 100;
        buyBtn.height = 38;
        buyBtn.layer.cornerRadius = 19;
        [_bottomView addSubview:buyBtn];

        UIButton *shopping = [UIButton buttonWithType:UIButtonTypeCustom];
        [shopping setTitle:@"加入购物车" forState:UIControlStateNormal];
        shopping.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
        [shopping setBackgroundColor:[UIColor orangeColor]];
        [shopping addTarget:self action:@selector(shoppingTrolleyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        shopping.x = SCR_WIDTH - 14 - 100 - 20 - 100;
        shopping.y = 5.5;
        shopping.width = 100;
        shopping.height = 38;
        shopping.layer.cornerRadius = 19;
        [_bottomView addSubview:shopping];
    }
    return _bottomView;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // 获取数据
    [self getDataSource];
    // 创建滚动视图
    [self.view addSubview:self.scrollerView];
    // 加载pop按钮
    [self.view addSubview:self.popButton];

    [self.view addSubview:self.bottomView];

    //导航条
    UIView *navigationBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, 67 + (IsiPhoneX ? 24 : 0))];
    navigationBackView.backgroundColor = [UIColor whiteColor];
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"商品详情" rightBtnTitle:nil rightBtnAction:nil navigationViewType:nil];
    navigationView.backgroundColor = [UIColor whiteColor];
    [navigationBackView addSubview:navigationView];
    [self.view addSubview:navigationBackView];
    self.navigationView = navigationBackView;
    self.navigationView.hidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > 0 && offsetY < scrollView.contentSize.height - scrollView.height) {
        if (offsetY >= 120) {
            self.navigationView.hidden = NO;

        } else {
            self.navigationView.hidden = YES;
        }
    }
    self.recordOffsetY = offsetY;
}

- (void)setupSubViews
{
    // 创建轮播图
    CZScollerImageTool *imageView = [[CZScollerImageTool alloc] initWithFrame:CGRectMake(0, 0, SCR_WIDTH, SCR_WIDTH)];
    [self.scrollerView addSubview:imageView];
    NSMutableArray *images = [NSMutableArray array];
    for (NSDictionary *image in self.dataSource[@"goodsPhotos"]) {
        [images addObject:[KGSERVER_URL stringByAppendingPathComponent:image[@"photopath"]]];
    }
    imageView.imgList = images;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, CZGetY(imageView) + 16, SCR_WIDTH - 28, 100)];
    titleLabel.text = self.dataSource[@"gname"];
    titleLabel.textColor = CZBLACKCOLOR;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 16];
    // label自动算高
    CGRect rect = [titleLabel.text boundingRectWithSize:CGSizeMake(titleLabel.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : titleLabel.font} context:nil];
    titleLabel.height = rect.size.height;
    [self.scrollerView addSubview:titleLabel];

    // 钱数
    UILabel *moneyLabel = [[UILabel alloc] init];
    moneyLabel.x = 14;
    moneyLabel.y = CZGetY(titleLabel) + 16;
    moneyLabel.width = titleLabel.width / 2.0;
    moneyLabel.height = 20;
    moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
    moneyLabel.text = [NSString stringWithFormat:@"¥%@", self.dataSource[@"price"]];
    moneyLabel.textColor = CZREDCOLOR;
    [self.scrollerView addSubview:moneyLabel];

    UILabel *salesvolumes = [[UILabel alloc] init];
    salesvolumes.y = moneyLabel.y;
    salesvolumes.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 13];
    salesvolumes.text = [NSString stringWithFormat:@"月售%@件", self.dataSource[@"salesvolumes"]];
    [salesvolumes sizeToFit];
    salesvolumes.x = SCR_WIDTH - 14 - salesvolumes.width;
    salesvolumes.textColor = CZGlobalGray;
    [self.scrollerView addSubview:salesvolumes];

    // 时间
    UIImageView *timeLabel = [[UIImageView alloc] init];
    timeLabel.x = 14;
    timeLabel.y = CZGetY(moneyLabel) + 16;
    timeLabel.width = SCR_WIDTH - 28;
    timeLabel.height = 44;
    timeLabel.image = [UIImage imageNamed:@"WX20190418-165758"];

    [self.scrollerView addSubview:timeLabel];

    // 创建分隔线
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, CZGetY(timeLabel), SCR_WIDTH, 7)];
    lineView2.backgroundColor = CZGlobalLightGray;
    [self.scrollerView addSubview:lineView2];

    //标题
    UILabel *webTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, CZGetY(lineView2) + 38, 150, 20)];
    webTitleLabel.text = @"商品详情";
    webTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 18];
    [self.scrollerView addSubview:webTitleLabel];


    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, CZGetY(webTitleLabel) + 20, SCR_WIDTH, 200)];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.scrollerView addSubview:self.webView];
    self.webView.delegate = self;
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.opaque = NO;

    NSString *head =@"<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\"><style>img{max-width: 100%; width:auto; height:auto!important;}</style></head>";
    NSString *html = [NSString stringWithFormat:@"<html>%@<body>%@</body></html>", head, self.dataSource[@"shopdescribe"]];

    [self.webView loadHTMLString:html baseURL:nil];
    self.scrollerView.contentSize = CGSizeMake(0, CZGetY(self.webView));

}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [CZProgressHUD showProgressHUDWithText:nil];
    [CZProgressHUD hideAfterDelay:2];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [CZProgressHUD hideAfterDelay:0];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [CZProgressHUD hideAfterDelay:0];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    CGSize size =  [change[@"new"] CGSizeValue];
    self.webView.height = size.height;
    // 更新滚动视图
    self.scrollerView.contentSize = CGSizeMake(0, CZGetY(self.webView));
}

#pragma mark - 获取数据
- (void)getDataSource
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"gid"] = self.pointId;
    [CZProgressHUD showProgressHUDWithText:nil];
    //获取详情数据
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/goods/detail.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
//        if ([result[@"msg"] isEqualToString:@"success"]) {
            self.dataSource = result[@"defaultgoods"];

            [self setupSubViews];
//        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];

    } failure:^(NSError *error) {
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    }];
}

#pragma mark - 事件
// 跳转购物车
- (void)gotoShoppingCar:(UIButton *)sender
{
    UITabBarController *tabbar = (UITabBarController *)[[UIApplication sharedApplication].keyWindow rootViewController];
    tabbar.selectedIndex = 2;
}

// 购买按钮事件
- (void)buyBtnAction:(UIButton *)sender
{
    CZAffirmPointController *vc = [[CZAffirmPointController alloc] init];
    vc.dataSource = self.dataSource;
    [self.navigationController pushViewController:vc animated:YES];
}

// 加入购物车
- (void)shoppingTrolleyBtnAction:(UIButton *)sender
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"gid"] = self.dataSource[@"gid"]; // 商品id
    param[ @"amount"] = @(1); // 数量
    param[@"shopid"] = self.dataSource[@"shopid"]; // 店铺编号
    param[@"shopname"] = self.dataSource[@"shopname"]; // 店铺名称
    param[@"userid"] = @""; // 用户id
    param[@"aguideid"] = @""; // 主导购员id
    
    KGShoppingTrolleyModel *model = [[KGShoppingTrolleyModel alloc] init];
    model.shopImage = [KGSERVER_URL stringByAppendingPathComponent:self.dataSource[@"thumbnail"]];
    model.shopName = self.dataSource[@"gname"];
    model.price = self.dataSource[@"price"];
    model.amount = @"1";
    model.shopCount = self.dataSource[@"stock"];
    model.goodsId = self.dataSource[@"gid"];

    GXSqliteTool *tool = [GXSqliteTool sqliteTool];

    if ([tool insert:model]) {
        [CZProgressHUD showProgressHUDWithText:@"加入购物车成功"];
    } else {
        [CZProgressHUD showProgressHUDWithText:@"已经加入购物车"];
    }
    [CZProgressHUD hideAfterDelay:1.5];
}

@end
