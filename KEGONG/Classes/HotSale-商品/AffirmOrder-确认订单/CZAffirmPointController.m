//
//  CZAffirmPointController.m
//  BestCity
//
//  Created by JasonBourne on 2019/3/15.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "CZAffirmPointController.h"
// 工具
#import "GXNetTool.h"
#import "UIImageView+WebCache.h"
#import "CZSubButton.h"
#import "KGServerTool.h"
//视图
#import "CZNavigationView.h"
#import "CZUpdataView.h"
//跳转
#import "KGMyClientController.h"




@interface CZAffirmPointController () <KGMyClientControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *moneyLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bgImage;

/** 显示个数 */
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet UILabel *topNumberLabel;

/** 头像 */
@property (nonatomic, weak) IBOutlet UIImageView *headerImage;
/** 姓名 */
@property (nonatomic, weak) IBOutlet UILabel *addressNameLabel;
/** 电话号码 */
@property (nonatomic, weak) IBOutlet UILabel *addressNumberLabel;
/** 地址 */
@property (nonatomic, weak)IBOutlet UILabel *addressLabel;
/** 地址数据全部 */
@property (nonatomic, strong) NSDictionary *addressData;
/** 添加地址的view */
@property (nonatomic, weak) IBOutlet UIView *addressView;
@property (nonatomic, weak) IBOutlet UIView *changeAddressView;

/** 底部View */
@property (nonatomic, strong) UIView *bottomView;
/** 实付款 */
@property (nonatomic, strong) UILabel *priceLabel;

// 辅助
/** 客户保存地址 */
@property (nonatomic, strong) NSDictionary *addressDic;

@end

static CGFloat const likeAndShareHeight = 49;
@implementation CZAffirmPointController
#pragma mark - 视图
- (UIView *)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.x = 0;
        _bottomView.y = SCR_HEIGHT - likeAndShareHeight - (IsiPhoneX ? 34 : 0);
        _bottomView.width = SCR_WIDTH;
        _bottomView.height = likeAndShareHeight;

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"实付款：";
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
        [titleLabel sizeToFit];
        titleLabel.textColor = CZGlobalGray;
        titleLabel.x = 25;
        titleLabel.centerY = likeAndShareHeight / 2.0;
        [_bottomView addSubview:titleLabel];
        // 点击事件
        //        [btn addTarget:self action:@selector(serviceBtnClickedBtn:) forControlEvents:UIControlEventTouchUpInside];

        UILabel *priceLabel = [[UILabel alloc] init];
        NSString *price = [NSString stringWithFormat:@"¥%ld", [self.dataSource[@"price"] integerValue] * [self.numberLabel.text integerValue]];
        priceLabel.text = price;
        priceLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 12];
        [priceLabel sizeToFit];
        priceLabel.textColor = CZREDCOLOR;
        priceLabel.x = CZGetX(titleLabel);
        priceLabel.y = titleLabel.y;
        [_bottomView addSubview:priceLabel];
        self.priceLabel = priceLabel;
        // 点击事件
        //        [btn addTarget:self action:@selector(serviceBtnClicked1Btn:) forControlEvents:UIControlEventTouchUpInside];


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
        [_bottomView addSubview:buyBtn];

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
        [_bottomView addSubview:shopping];
    }
    return _bottomView;
}
#pragma end -- end

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航条
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"确认订单" rightBtnTitle:nil rightBtnAction:nil navigationViewType:nil];
    navigationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navigationView];

    UITapGestureRecognizer *changeAddressViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSearchController)];
    [self.changeAddressView addGestureRecognizer:changeAddressViewTap];
    
    self.subTitleLabel.text = self.dataSource[@"gname"];
    self.subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 14];
    self.moneyLabel.text = [NSString stringWithFormat:@"¥%@", self.dataSource[@"price"]];
    if ([self.dataSource[@"goodsPhotos"] count] > 0) {
        [self.bgImage sd_setImageWithURL:[NSURL URLWithString:[KGSERVER_URL stringByAppendingPathComponent:self.dataSource[@"goodsPhotos"][0][@"photopath"]]]];
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSearchController)];
    [self.addressView addGestureRecognizer:tap];

    // 底部视图
    [self.view addSubview:self.bottomView];
}

#pragma mark - 事件
/** 创建订单 */
- (void)shoppingTrolleyBtnAction:(UIButton *)sender
{
    if (!self.addressDic) {
        [CZProgressHUD showProgressHUDWithText:@"请选择客户"];
        [CZProgressHUD hideAfterDelay:1.5];
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"addressID"] = self.addressDic[@"uaid"]; // 用户收货地址ID
    param[@"userID"] = self.addressDic[@"userid"]; // 用户id
    param[@"goodsInfo"] = @[@{@"goodsID" : self.dataSource[@"gid"], @"goodsCount" : self.numberLabel.text}]; // 商品信息
    [KGServerTool createOrderQRCode:param orderQRCodeBlock:^(NSString *QRImage) {
        CZUpdataView *backView = [CZUpdataView updataView];
        [backView getQRCode:QRImage];
        backView.frame = [UIScreen mainScreen].bounds;
        backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [[UIApplication sharedApplication].keyWindow addSubview: backView];
    }];
}

/** 加 */
- (IBAction)add
{
    NSInteger number = [self.numberLabel.text integerValue];
    if (number == [self.dataSource[@"stock"] integerValue]) return;
    number++;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", number];
    self.topNumberLabel.text = [NSString stringWithFormat:@"x%@", self.numberLabel.text];
    // 实付款
    NSString *price = [NSString stringWithFormat:@"¥%ld", [self.dataSource[@"price"] integerValue] * number];
    self.priceLabel.text = price;
    [self.priceLabel sizeToFit];
    self.moneyLabel.text = price;
    [self.moneyLabel sizeToFit];
}

/** 减 */
- (IBAction)move
{
    NSInteger number = [self.numberLabel.text integerValue];
    if (number == 1) return;
    number--;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", number];
    self.topNumberLabel.text = [NSString stringWithFormat:@"x%@", self.numberLabel.text];
    // 实付款
    NSString *price = [NSString stringWithFormat:@"¥%ld", [self.dataSource[@"price"] integerValue] * number];
    self.priceLabel.text = price;
    [self.priceLabel sizeToFit];
    self.moneyLabel.text = price;
    [self.moneyLabel sizeToFit];
}

// 跳转到地址界面
- (void)pushSearchController
{
    KGMyClientController *vc = [[KGMyClientController alloc] init];
    vc.type = KGMyClientControllerTypeOrder;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 代理
//KGMyClientControllerDelegate
- (void)myClientController:(KGMyClientController *)vc updataAddress:(NSDictionary *)address
{
    NSLog(@"%@", address);
    if (address) {
        self.addressDic = address;
        self.addressView.hidden = YES;
        /** 头像 */
        [self.headerImage sd_setImageWithURL:[NSURL URLWithString:address[@"userheadpath"]]];
        /** 姓名 */
        self.addressNameLabel.text = address[@"username"];
        /** 电话号码 */
        self.addressNumberLabel.text = address[@"mobile"];
        /** 地址 */
        self.addressLabel.text = address[@"address"];
    }
}
#pragma mark -- end



#pragma mark - 获取数据




@end
