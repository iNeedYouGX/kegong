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
#import "KGShoppingBtnsModule.h"
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
@property (nonatomic, strong) KGShoppingBtnsModule *bottomView;

// 辅助
/** 客户保存地址 */
@property (nonatomic, strong) NSDictionary *addressDic;
/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 记录订单 */
@property (nonatomic, strong) NSString *orderID;
/** 弹出的二维码 */
@property (nonatomic, strong) CZUpdataView *backView;
@end

static CGFloat const likeAndShareHeight = 49;
@implementation CZAffirmPointController
#pragma mark - 视图
- (KGShoppingBtnsModule *)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[KGShoppingBtnsModule alloc] initWithFrame:CGRectMake(0, SCR_HEIGHT - likeAndShareHeight - (IsiPhoneX ? 34 : 0), SCR_WIDTH, likeAndShareHeight)];
        NSString *price = [NSString stringWithFormat:@"¥%ld", [self.dataSource[@"price"] integerValue] * [self.numberLabel.text integerValue]];
        self.bottomView.price = price;
        typeof(self) weakSelf = self;
        _bottomView.QRBlock = ^{
            if (!weakSelf.addressDic) {
                [CZProgressHUD showProgressHUDWithText:@"请选择客户"];
                [CZProgressHUD hideAfterDelay:1.5];
                return;
            }
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"addressID"] = weakSelf.addressDic[@"uaid"]; // 用户收货地址ID
            param[@"userID"] = weakSelf.addressDic[@"userid"]; // 用户id
            param[@"goodsInfo"] = @[@{
                                        @"goodsID" : weakSelf.dataSource[@"gid"],
                                        @"goodsCount" : weakSelf.numberLabel.text
                                      }];
            // 商品信息
            [KGServerTool createOrderQRCode:param orderQRCodeBlock:^(NSString *QRImage, NSString *orderID) {
                weakSelf.orderID = orderID;
                CZUpdataView *backView = [CZUpdataView updataView];
                weakSelf.backView = backView;
                [backView getQRCode:QRImage];
                backView.frame = [UIScreen mainScreen].bounds;
                backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
                [weakSelf.view addSubview:backView];
                 weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(getOrderInfo) userInfo:nil repeats:YES];
            }];
        };
        _bottomView.buyBlock = ^{
            NSLog(@"前往支付");
        };
    }
    return _bottomView;
}

#pragma mark -- end

#pragma mark - 周期
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
#pragma mark -- end

#pragma mark - 事件
// 开启轮训订单情况
- (void)getOrderInfo
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"orderID"] = self.orderID;
    param[@"userID"] = self.addressDic[@"userid"];
    NSString *url = [KGSERVER_URL stringByAppendingPathComponent:@"app/my/order/orderInfo.do"];
    [GXNetTool PostNetWithUrl:url body:param bodySytle:GXRequsetStyleBodyHTTP header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqualToNumber:@(1)])
        {
            if ([result[@"orderInfo"][@"paymentstatus"] isEqualToNumber:@(12)]) {

                [self.timer invalidate];
                [CZProgressHUD showProgressHUDWithText:@"支付成功"];
                [CZProgressHUD hideAfterDelay:1.5];
                [self.backView removeFromSuperview ];
            } else if ([result[@"orderInfo"][@"paymentstatus"] isEqualToNumber:@(8)]) {
                [CZProgressHUD showProgressHUDWithText:@"支付失败"];
                [CZProgressHUD hideAfterDelay:1.5];
                [self.timer invalidate];
            }
        }
    } failure:^(NSError *error) {}];
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
    self.bottomView.price = price;
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
    self.bottomView.price = price;
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
#pragma mark -- end

#pragma mark - 代理
// KGMyClientControllerDelegate
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
#pragma mark -- end



@end
