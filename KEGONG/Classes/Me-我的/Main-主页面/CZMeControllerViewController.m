//
//  CZMeControllerViewController.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/17.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "CZMeControllerViewController.h"
#import "CZNavigationView.h"
#import "CZLoginController.h"
#import "KGMyClientController.h"

@interface CZMeControllerViewController ()
/** 登录 */
@property (nonatomic, strong) UIButton *loginOut;
/** 用户名字 */
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation CZMeControllerViewController
#pragma mark -- 周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"]) {
        self.nameLabel.text = [CZSaveTool objectForKey:@"userName"];
        [self.nameLabel sizeToFit];
        [self.loginOut setTitle:@"退出账号" forState:UIControlStateNormal];
    } else {
        [self.loginOut setTitle:@"登录" forState:UIControlStateNormal];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CZGlobalLightGray;
    //导航条
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"我的" rightBtnTitle:nil rightBtnAction:nil navigationViewType:CZNavigationViewTypeBlack];
    navigationView.backgroundColor = CZGlobalWhiteBg;
//    navigationView.delegate = self;
    [self.view addSubview:navigationView];
    //导航条
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0) + 67, SCR_WIDTH, 0.7)];
    line.backgroundColor = CZGlobalLightGray;
    [self.view addSubview:line];

    // 创建上面视图
    [self setupTopView:CZGetY(line)];

    //底部退出按钮
    UIButton *loginOut = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginOut = loginOut;
    loginOut.frame = CGRectMake(14, SCR_HEIGHT - ((IsiPhoneX ? 83 : 49) + 36 + 46), SCR_WIDTH - 28, 36);
    [self.view addSubview:loginOut];
    [loginOut setTitle:@"登录" forState:UIControlStateNormal];
    loginOut.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginOut setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    loginOut.layer.cornerRadius = 18;
    loginOut.layer.masksToBounds = YES;
    [loginOut addTarget:self action:@selector(loginOutActionWithBtn:) forControlEvents:UIControlEventTouchUpInside];

}
#pragma mark -- end


#pragma mark -- 视图
// headerView
- (void)setupTopView:(CGFloat)Y
{
    UIView *topView = [[UIView alloc] init];
    [self.view addSubview:topView];
    topView.backgroundColor = CZGlobalWhiteBg;
    topView.y = Y;
    topView.width = SCR_WIDTH;
    topView.height = 90;

    UIImageView *header = [[UIImageView alloc] init];
    header.image = [UIImage imageNamed:@"head portrait"];
    header.x = 14;
    header.size = CGSizeMake(50, 50);
    header.centerY = topView.height / 2.0;
    [topView addSubview:header];

    UILabel *nameLabel = [[UILabel alloc] init];
    self.nameLabel = nameLabel;
    nameLabel.textColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    nameLabel.text = @"客工";
    [nameLabel sizeToFit];
    nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    nameLabel.x = CZGetX(header) + 14;
    nameLabel.centerY = topView.height / 2.0;
    [topView addSubview:nameLabel];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CZGetY(topView), SCR_WIDTH, 6)];
    line.backgroundColor = CZGlobalLightGray;
    [self.view addSubview:line];

    [self setupClientView];
}

// 我的客户
- (void)setupClientView
{
    UIView *topView = [[UIView alloc] init];
    topView.y = CZGetY([self.view.subviews lastObject]);
    topView.width = SCR_WIDTH;
    topView.height = 60;
    topView.backgroundColor = CZGlobalWhiteBg;
    [self.view addSubview:topView];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"我的客户";
    label.textColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    [label sizeToFit];
    label.x = 14;
    label.centerY = topView.height / 2.0;
    [topView addSubview:label];

    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right"]];
    arrow.x = SCR_WIDTH - 14 - arrow.width;
    arrow.centerY = topView.height / 2.0;
    [topView addSubview:arrow];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSearchController)];
    [topView addGestureRecognizer:tap];
}
#pragma mark -- end

#pragma mark - 事件
// 退出事件
- (void)loginOutActionWithBtn:(UIButton *)sender
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"]) {
        [CZSaveTool setObject:@"" forKey:@"userName"];
        self.nameLabel.text = [CZSaveTool objectForKey:@"userName"];
        [self.nameLabel sizeToFit];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
        [self.loginOut setTitle:@"登录" forState:UIControlStateNormal];
    } else {
        CZLoginController *vc = [CZLoginController shareLoginController];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

// 跳转到我的客户
- (void)pushSearchController
{
    KGMyClientController *vc = [[KGMyClientController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
