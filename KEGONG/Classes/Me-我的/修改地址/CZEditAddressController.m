//
//  CZEditAddressController.m
//  BestCity
//
//  Created by JasonBourne on 2019/3/6.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "CZEditAddressController.h"
#import "CZNavigationView.h"
#import "GXNetTool.h"
#import "MOFSPickerManager.h"

@interface CZEditAddressController ()<UITextFieldDelegate>
/** 姓名 */
@property (nonatomic, weak) IBOutlet UITextField *nameLabel;
/** 电话号码 */
@property (nonatomic, weak) IBOutlet UITextField *numberLabel;
/** 选择地址 */
@property (nonatomic, weak) IBOutlet UITextField *addrLabel;
/** 详细地址 */
@property (nonatomic, weak) IBOutlet UITextField *contentAddressLabel;
/** 地区编码 */
@property (nonatomic, strong) NSString *regionCode;
@end

@implementation CZEditAddressController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CZGlobalWhiteBg;
    //导航条
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:self.currnetTitle rightBtnTitle:@"保存" rightBtnAction:^(CZNavigationView *nav){
        [self commit];
    } navigationViewType:CZNavigationViewTypeBlack];
    [self.view addSubview:navigationView];
    
    self.nameLabel.text = self.paramAddress[@"username"];
    self.numberLabel.text = self.paramAddress[@"mobile"];
//    self.addrLabel.text = self.paramAddress[@""];
//    self.contentAddressLabel.text = self.paramAddress[@""];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)commit
{
    if (![self textFieldControl]) {
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"userName"] = self.nameLabel.text; // 名字
    param[@"mobile"] = self.numberLabel.text; // 电话
    param[@"regionCode"] = self.regionCode; // 地区编码
    param[@"address"] = self.contentAddressLabel.text; // 收货地址
    param[@"isDefault"] = @"1"; // 是否是默认地址 1表示是，0表示否
    param[@"userId"] = self.paramAddress[@"userid"]; // 用户id

    [GXNetTool PostNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/my/member/AddAddress.do"] body:param bodySytle:GXRequsetStyleBodyHTTP header:nil response:GXResponseStyleJSON success:^(id result) {
        if (([result[@"success"] isEqual:@(1)])) {
            [CZProgressHUD showProgressHUDWithText:@"保存地址成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [CZProgressHUD showProgressHUDWithText:@"保存地址失败"];
        }
        [CZProgressHUD hideAfterDelay:1.5];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 非点击事件
- (BOOL)textFieldControl
{
    if (self.nameLabel.text.length == 0) {
        [CZProgressHUD showProgressHUDWithText:@"请输入收件人名称"];
        [CZProgressHUD hideAfterDelay:1.5];
        return NO;
    } else if (self.numberLabel.text.length != 11) {
        [CZProgressHUD showProgressHUDWithText:@"请正确输入收件人手机号"];
        [CZProgressHUD hideAfterDelay:1.5];
        return NO;
    } else if (self.contentAddressLabel.text.length == 0) {
        [CZProgressHUD showProgressHUDWithText:@"请输入详细地址"];
        [CZProgressHUD hideAfterDelay:1.5];
        return NO;
    } else if (self.addrLabel.text.length == 0) {
        [CZProgressHUD showProgressHUDWithText:@"请输入地区"];
        [CZProgressHUD hideAfterDelay:1.5];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -- end

#pragma mark -- 代理
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"---------%@", string);
    if ([string  isEqual: @" "]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.addrLabel) {
        [self.view endEditing:YES];
        [[MOFSPickerManager shareManger] showMOFSAddressPickerWithDefaultZipcode:@"450000-450900-450921" title:@"选择地址" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString * _Nullable address, NSString * _Nullable zipcode) {
            self.addrLabel.text = address;
            NSArray *arr = [zipcode componentsSeparatedByString:@"-"];
            self.regionCode = [arr lastObject];
            NSLog(@"%@", address);
        } cancelBlock:^{}];
        return NO;
    } else {
        return YES;
    }
}

@end
