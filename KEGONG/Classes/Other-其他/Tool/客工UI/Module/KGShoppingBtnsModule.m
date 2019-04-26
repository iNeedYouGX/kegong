//
//  KGShoppingBtnsModule.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/24.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "KGShoppingBtnsModule.h"

@interface KGShoppingBtnsModule ()
/** 第二个 */
@property (nonatomic, strong) UILabel *priceLabel;
@end

@implementation KGShoppingBtnsModule

+ (instancetype)shoppingBtnsModule
{
    return [[KGShoppingBtnsModule alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"实付款：";
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
    [titleLabel sizeToFit];
    titleLabel.textColor = CZGlobalGray;
    titleLabel.x = 25;
    titleLabel.centerY = self.height / 2.0;
    [self addSubview:titleLabel];

    UILabel *priceLabel = [[UILabel alloc] init];
    priceLabel.text = @"¥0";
    priceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 12];
    [priceLabel sizeToFit];
    priceLabel.textColor = CZREDCOLOR;
    priceLabel.x = CZGetX(titleLabel);
    priceLabel.y = titleLabel.y;
    [self addSubview:priceLabel];
    self.priceLabel = priceLabel;

    UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [buyBtn setTitle:@"前往支付" forState:UIControlStateNormal];
    buyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
    [buyBtn setBackgroundColor:CZREDCOLOR];
    [buyBtn addTarget:self action:@selector(buyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    buyBtn.x = SCR_WIDTH - 14 - 100;
    buyBtn.y = 5.5;
    buyBtn.width = 100;
    buyBtn.height = 38;
    buyBtn.layer.cornerRadius = 19;
    [self addSubview:buyBtn];

    UIButton *shopping = [UIButton buttonWithType:UIButtonTypeCustom];
    [shopping setTitle:@"生成付款码" forState:UIControlStateNormal];
    shopping.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
    [shopping setBackgroundColor:UIColorFromRGB(0x4A90E2)];
    [shopping addTarget:self action:@selector(shoppingTrolleyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    shopping.x = SCR_WIDTH - 14 - 100 - 20 - 100;
    shopping.y = 5.5;
    shopping.width = 100;
    shopping.height = 38;
    shopping.layer.cornerRadius = 19;
    [self addSubview:shopping];
}

- (void)setPrice:(NSString *)price
{
    _price = price;
    self.priceLabel.text = price;
    [self.priceLabel sizeToFit];
}

- (void)shoppingTrolleyBtnAction:(UIButton *)sender
{
    !self.QRBlock ? : self.QRBlock();
}

- (void)buyBtnAction:(UIButton *)sender
{
    !self.buyBlock ? : self.buyBlock();
}

@end
