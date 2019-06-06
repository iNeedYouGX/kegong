//
//  CZfeedbackController.m
//  BestCity
//
//  Created by JasonBourne on 2018/8/6.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import "CZfeedbackController.h"
#import "CZNavigationView.h"
#import "GXNetTool.h"
#import "DLIDEKeyboardView.h"

@interface CZfeedbackController () <UITextViewDelegate>
/** 反馈输入框 */
@property (nonatomic, weak) IBOutlet UITextView *textView;
/** 下方显示文字 */
@property (nonatomic, weak) IBOutlet UILabel *label;
/** 文字总数 */
@property (nonatomic, assign) NSInteger textCount;
@end

@implementation CZfeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textCount = 20;
    //导航条
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"添加备注" rightBtnTitle:nil rightBtnAction:nil navigationViewType:CZNavigationViewTypeBlack];
    [self.view addSubview:navigationView];
    
    // 添加回收键盘按钮
    [DLIDEKeyboardView attachToTextView:self.textView];
    
    // 文字个数
    NSInteger number = self.textCount - self.textView.text.length;
    NSString *therPrice = [NSString stringWithFormat:@"您还可以输入%ld个字", number];
    self.label.attributedText = [therPrice addAttributeColor:CZREDCOLOR Range:[therPrice rangeOfString:[NSString stringWithFormat:@"%ld", number]]];

    // 底部退出按钮
    UIButton *loginOut = [UIButton buttonWithType:UIButtonTypeCustom];
    loginOut.frame = CGRectMake(0, SCR_HEIGHT - 50, SCR_WIDTH, 50);
    [self.view addSubview:loginOut];
    [loginOut setTitle:@"提交" forState:UIControlStateNormal];
    loginOut.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginOut addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    loginOut.backgroundColor = CZREDCOLOR;
}

#pragma mark - 提交反馈
- (void)commit
{
    if (self.textView.text.length <= 0) {
        [CZProgressHUD showProgressHUDWithText:@"请输入文字"];
        [CZProgressHUD hideAfterDelay:1];
        return;
    }
    
    // 参数
    !self.delegate ? : [self.delegate feedbackController:self commitWithText:self.textView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length >= self.textCount) {
        NSString *text = [textView.text substringToIndex:self.textCount ];
        self.textView.text = text;
    }
    
    NSInteger number = self.textCount - textView.text.length;
    NSString *therPrice = [NSString stringWithFormat:@"您还可以输入%ld个字", number];
    self.label.attributedText = [therPrice addAttributeColor:CZREDCOLOR Range:[therPrice rangeOfString:[NSString stringWithFormat:@"%ld", number]]];
}



@end
