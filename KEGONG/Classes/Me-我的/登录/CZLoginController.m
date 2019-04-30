//
//  CZLoginController.m
//  BestCity
//
//  Created by JasonBourne on 2018/8/7.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import "CZLoginController.h"
#import "GXNetTool.h"
#import "CZProgressHUD.h"
#import "TSLWebViewController.h"
#import "KCUtilMd5.h"



@interface CZLoginController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
/** 登录按钮 */
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end


static id instancet_;
@implementation CZLoginController

+ (instancetype)shareLoginController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instancet_ = [[CZLoginController alloc] init];
    });
    return instancet_;
}

#pragma mark - POP到前一页
- (IBAction)popAction:(id)sender {
//    UITabBarController *vc = (UITabBarController *)self.nextResponder;
//    if (!_isLogin) {
//        vc.selectedIndex = 0;
//    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 登录
- (IBAction)loginAction:(id)sender {
//    13922222222
//    1234
    // 短信登录接口
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"mobile"] = self.userTextField.text;
    param[@"password"] = [KCUtilMd5 stringToMD5:self.passwordTextField.text];;
    
    NSString *url = [KGSERVER_URL stringByAppendingPathComponent:@"/app/user/SalesLogin.do"];
    [GXNetTool PostNetWithUrl:url body:param bodySytle:GXRequsetStyleBodyHTTP header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqualToNumber:@(1)])
        {
            [CZProgressHUD showProgressHUDWithText:@"登录成功"];
            //cookies获取
                NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                NSArray *cookieArr = [cookieJar cookies];
                for(NSHTTPCookie *cookie in cookieArr) {
            // 获取cookie
                    NSString *cook = [NSString stringWithFormat:@"%@=%@",  cookie.name,  cookie.value];
                    [CZSaveTool setObject:cook forKey:@"token"];
                    NSLog(@"cookie －> %@", cookie);
                    NSLog(@"cookie.name －> %@", cookie.name);
                    NSLog(@"cookie.value －> %@", cookie.value);
                }
            // 是否登录
            self.isLogin = YES;
            // 删除账号密码
            self.userTextField.text = nil;
            self.passwordTextField.text = nil;
            
            // 登录成功发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:loginChangeUserInfo object:nil];
        } else {
            [CZProgressHUD showProgressHUDWithText:result[@"msg"]];
        }
        [CZProgressHUD hideAfterDelay:2];
        
    } failure:^(NSError *error) {}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    15900000000 1234
    self.userTextField.text = @"15900000000";
    //代理方法监听时候都会慢一步
    [self.userTextField addTarget:self action:@selector(textFieldAction:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldAction:) forControlEvents:UIControlEventEditingChanged];
    
    // 接收登录时候的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissViewController) name:loginChangeUserInfo object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.userTextField.text = @"15900000000";
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** 跳转用户协议 */
- (void)userAgreement
{
    TSLWebViewController *webVc = [[TSLWebViewController alloc] initWithURL:[NSURL URLWithString:UserAgreement_url]];
    webVc.titleName = @"用户协议";
    [self presentViewController:webVc animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)textFieldAction:(UITextField *)textField
{
    if (self.userTextField.text.length != 0 && self.passwordTextField.text.length != 0 ) {
        [self enabledAndRedColor:self.loginBtn];
    } else {
        [self disabledAndGrayColor:self.loginBtn];
    }
    
    if (self.userTextField == textField) {
        if (self.userTextField.text.length > 11) {
            self.userTextField.text = [self.userTextField.text substringToIndex:11];
        }
    }
}

//键盘Return事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

/** 激活红色 */
- (void)enabledAndRedColor:(UIButton *)btn
{
    btn.backgroundColor = CZREDCOLOR;
    btn.enabled = YES;
}

/** 残疾灰色 */
- (void)disabledAndGrayColor:(UIButton *)btn
{
    btn.backgroundColor = CZBTNGRAY;
    btn.enabled = NO;
}

@end
