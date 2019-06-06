//
//  CZHotSearchView.m
//  BestCity
//
//  Created by JasonBourne on 2018/11/3.
//  Copyright © 2018 JasonBourne. All rights reserved.
//

#import "CZHotSearchView.h"
#import "UIButton+CZExtension.h"

@interface CZHotSearchView ()<UITextFieldDelegate>
/** 右侧按钮 */
@property (nonatomic, strong) UIButton *rightBtn;
/** 文本框 */
@property (nonatomic, strong) CZTextField *textField;
/** 未读按钮 */
@property (nonatomic, strong) UILabel *unreadLabel;
@end

@implementation CZHotSearchView

- (instancetype)initWithFrame:(CGRect)frame msgAction:(void (^)(NSString *))block
{
    self = [super initWithFrame:frame];
    if (self) {
        self.msgBlock = block;
        [self setup];
    }
    return self;
}

//- (void)setFrame:(CGRect)frame
//{
//    CGRect rect = frame;
//    rect.size.width = SCR_WIDTH - 20;
//    rect.size.height = 34;
//    [super setFrame:rect];
//}

- (void)setTextFieldActive:(BOOL)textFieldActive
{
    _textFieldActive = textFieldActive;
    self.textField.enabled = textFieldActive;
}

- (void)setup
{
    CZTextField *textF = [[CZTextField alloc] init];
    textF.width = self.width;
    textF.height = self.height;
    self.textField = textF;
    self.textField.delegate = self;
    [textF addTarget:self action:@selector(textFieldAction:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:textF];
}

- (void)setUnreaderCount:(NSInteger)unreaderCount
{
    _unreaderCount = unreaderCount;
    if (unreaderCount <= 0) {
        self.unreadLabel.hidden = YES;
    } else {
        self.unreadLabel.hidden = NO;
        self.unreadLabel.text = [NSString stringWithFormat:@"%ld", unreaderCount];
    }
}

- (void)setMsgTitle:(NSString *)msgTitle
{
    _msgTitle = msgTitle;
    
    [self.rightBtn setTitle:msgTitle forState:UIControlStateNormal];
    self.rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.rightBtn setImage:nil forState:UIControlStateNormal];
}

- (void)msgAction
{
    !self.msgBlock ? : self.msgBlock(self.msgTitle);
}

- (void)textFieldAction:(CZTextField *)textField
{
    !self.delegate ? : [self.delegate hotView:self didTextFieldChange:textField];
    _searchText = textField.text;
}

- (void)setTextFieldBorderColor:(UIColor *)textFieldBorderColor
{
    _textFieldBorderColor = textFieldBorderColor;
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.layer.borderWidth = 0.3;
    self.textField.layer.borderColor = textFieldBorderColor.CGColor;
}

- (void)setSearchText:(NSString *)searchText
{
    _searchText = searchText;
    self.textField.text = searchText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    !self.msgBlock ? : self.msgBlock(self.msgTitle);
    return YES;
}

@end
