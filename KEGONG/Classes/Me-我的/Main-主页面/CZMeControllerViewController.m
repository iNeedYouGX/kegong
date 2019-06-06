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
#import "GXNetTool.h"
#import "GXSqliteTool.h"
// 跳转
#import "KGMyClientController.h"
#import "CZMyProfileController.h"
#import "KGInvitationController.h"

@interface CZMeControllerViewController ()
/** 登录 */
@property (nonatomic, strong) UIButton *loginOut;
/** 用户名字 */
@property (nonatomic, strong) UILabel *nameLabel;
/** 邀请码 */
@property (nonatomic, strong) UILabel *codeLabel;
@end

@implementation CZMeControllerViewController
#pragma mark -- 周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUserInfo];
    [self getQRCode];
}

// 获取客工邀请码和生成二维码的url
- (void)getQRCode
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    //获取详情数据
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/my/sales/salescode.do"] body:nil header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqualToNumber:@(1)]) {
            self.codeLabel.text = [NSString stringWithFormat:@"邀请码: %@", result[@"salesCode"]];
            [self.codeLabel sizeToFit];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];

    } failure:^(NSError *error) {
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    }];
}

- (void)setUserInfo
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    //获取详情数据
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/my/user/getUserInfo.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqualToNumber:@(1)]) {
            [CZSaveTool setObject:result[@"salesInfo"] forKey:@"user"];
            self.nameLabel.text = JPUSERINFO[@"username"];
            [self.nameLabel sizeToFit];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];

    } failure:^(NSError *error) {
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    }];
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
    [loginOut setTitle:@"退出登录" forState:UIControlStateNormal];
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
    nameLabel.y = header.y;
    [topView addSubview:nameLabel];

    UILabel *codeLabel = [[UILabel alloc] init];
    self.codeLabel = codeLabel;
    codeLabel.x = nameLabel.x;
    codeLabel.y = CZGetY(header) - 20;
    codeLabel.text = @"邀请码: 1111111";
    codeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    codeLabel.textColor = CZGlobalGray;
    [codeLabel sizeToFit];
    [topView addSubview:codeLabel];

    UIButton *copyBtn = [[UIButton alloc] init];
    copyBtn.x = CZGetX(codeLabel) + 50;
    copyBtn.y = codeLabel.y - 5;
    copyBtn.size = CGSizeMake(60, 30);
    copyBtn.backgroundColor = UIColorFromRGB(0x0085DF);
    [copyBtn setTitle:@"复制" forState:UIControlStateNormal];
    copyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    [copyBtn addTarget:self action:@selector(generalPaste) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:copyBtn];


    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CZGetY(topView), SCR_WIDTH, 6)];
    line.backgroundColor = CZGlobalLightGray;
    [self.view addSubview:line];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushMyProfileController)];
    [topView addGestureRecognizer:tap];


    [self setupClientView:@"我的客户" action:@selector(pushSearchController)];
    [self setupClientView:@"邀请好友" action:@selector(pushInvitationController)];
}

// 我的客户
- (void)setupClientView:(NSString *)text action:(SEL)action
{
    UIView *topView = [[UIView alloc] init];
    topView.y = CZGetY([self.view.subviews lastObject]) + 1;
    topView.width = SCR_WIDTH;
    topView.height = 60;
    topView.backgroundColor = CZGlobalWhiteBg;
    [self.view addSubview:topView];

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
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

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [topView addGestureRecognizer:tap];
}
#pragma mark -- end

#pragma mark - 事件
- (void)generalPaste
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"哈哈哈哈";
    [CZProgressHUD showProgressHUDWithText:@"复制成功"];
    [CZProgressHUD hideAfterDelay:1.5];
}

// 退出事件
- (void)loginOutActionWithBtn:(UIButton *)sender
{
    [CZSaveTool setObject:@"" forKey:@"token"];
    GXSqliteTool *splite = [GXSqliteTool sqliteTool];
    [splite delete]; 
     if ([JPTOKEN length] <= 0) {
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

// 跳转邀请好友
- (void)pushInvitationController
{
    KGInvitationController *vc = [[KGInvitationController alloc] init];
    vc.codeText = self.codeLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}
 
// 跳转到我的信息
- (void)pushMyProfileController
{
    CZMyProfileController *vc = [[CZMyProfileController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -- end


@end
