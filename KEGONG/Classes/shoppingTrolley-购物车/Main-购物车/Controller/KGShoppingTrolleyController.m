//
//  KGShoppingTrolleyController.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/22.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "KGShoppingTrolleyController.h"
// 视图
#import "CZNavigationView.h"
#import "KGShoppingTrolleyCell.h"
#import "CZUpdataView.h"
// 工具
#import "GXNetTool.h"
#import "GXSqliteTool.h"
#import "UIImageView+WebCache.h"
#import "KGServerTool.h"
//跳转
#import "KGMyClientController.h"
#import "CZfeedbackController.h"

@interface KGShoppingTrolleyController () <UITableViewDelegate, UITableViewDataSource, KGMyClientControllerDelegate, CZfeedbackControllerDelegate>
/** 表单 */
@property (nonatomic, strong) UITableView *tableView;
/** 数据 */
@property (nonatomic, strong) NSMutableArray *array;
/** 底部View */
@property (nonatomic, strong) UIView *bottomView;
/** 实付款 */
@property (nonatomic, strong) UILabel *priceLabel;

// 地址
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *labelName;
@property (nonatomic, strong) UILabel *addressLabel;
@property (nonatomic, strong) UIView *topView; // 盖子

/** 合计 */
@property (nonatomic, strong) UILabel *titleLabel;
/** 购买按钮 */
@property (nonatomic, strong) UIButton *buyBtn;
/** 生成二维码 */
@property (nonatomic, strong) UIButton *shopping;
/** 全选按钮 */
@property (nonatomic, strong) UIButton *allSelectedBtn;

// 辅助
/** 客户保存地址 */
@property (nonatomic, strong) NSDictionary *addressDic;
/** 购物车信息 */
@property (nonatomic, strong) NSMutableArray *goodsParam;
/** 记录订单 */
@property (nonatomic, strong) NSString *orderID;
/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 弹出的二维码 */
@property (nonatomic, strong) CZUpdataView *backView;

/** 备注 */
@property (nonatomic, strong) UILabel *remarkLabel;

@end

static CGFloat const likeAndShareHeight = 49;
@implementation KGShoppingTrolleyController
#pragma mark - 数据的初始化
- (NSMutableArray *)goodsParam
{
    if (_goodsParam == nil) {
        _goodsParam = [NSMutableArray array];
    }
    return _goodsParam;
}

- (NSMutableArray *)array
{
    if (_array == nil) {
        _array = [NSMutableArray array];
    }
    return _array;
}
#pragma mark -- end


#pragma mark - 获取数据
- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadNewTrailDataSorce)];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTrailDataSorce)];
}
#pragma mark -- end

#pragma mark - 视图
- (UITableView *)tableView
{
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0) + 67.7, SCR_WIDTH, SCR_HEIGHT - likeAndShareHeight - ((IsiPhoneX ? 24 : 0) + 67.7) - (IsiPhoneX ? 83 : 49)) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableFooterView = [self setupFooterView];
    }
    return _tableView;
}

// 尾部视图
- (UIView *)setupFooterView
{
    UIView *backView = [[UIView alloc] init];
    backView.y = 0;
    backView.width = SCR_WIDTH;
    backView.height = 90 + 12 + 90 + 6;
    backView.backgroundColor = CZGlobalLightGray;

    UIView *view1 = [self setupClientView];
    [backView addSubview:view1];

     UIView *view2 = [self setuprRmarkView];
    view2.y = 90 + 6;
    [backView addSubview:view2];

    return backView;
}

// 我的客户
- (UIView *)setupClientView
{
    UIView *backView = [[UIView alloc] init];
    backView.y = 0;
    backView.width = SCR_WIDTH;
    backView.height = 90 + 12;
    backView.backgroundColor = CZGlobalLightGray;

    // 下面的背景
    UIView *addressView = [[UIView alloc] init];
    addressView.y = 6;
    addressView.width = SCR_WIDTH;
    addressView.height = backView.height - 12;
    addressView.backgroundColor = CZGlobalWhiteBg;
    [backView addSubview:addressView];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSearchController)];
    [addressView addGestureRecognizer:tap1];

    // 下面
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    imageView.size = CGSizeMake(34, 34);
    imageView.layer.cornerRadius = 17;
    imageView.layer.masksToBounds = YES;
    imageView.x = 14;
    imageView.centerY = backView.height / 2.0;
    [addressView addSubview:imageView];
    self.imageView = imageView;

    UILabel *labelName = [[UILabel alloc] init];
    labelName.text = @"15388249384";
    labelName.textColor = UIColorFromRGB(0x1A1A1A);
    labelName.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    [labelName sizeToFit];
    labelName.x = CZGetX(imageView) + 10;
    labelName.y = imageView.y - 5;
    [addressView addSubview:labelName];
    self.labelName = labelName;

    UIImageView *addressImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"address"]];
    addressImage.size = CGSizeMake(16, 20);
    addressImage.x = CZGetX(imageView) + 10;
    addressImage.y = CZGetY(imageView) - 15;
    [addressView addSubview:addressImage];

    UILabel *addressLabel = [[UILabel alloc] init];
    addressLabel.text = @"浙江省杭州市滨江区海威大厦712畅卓电商浙江省杭州市滨江区海威大厦712畅卓电商";
    addressLabel.textColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    addressLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    addressLabel.x = CZGetX(addressImage) + 10;
    addressLabel.y = addressImage.y;
    addressLabel.width = SCR_WIDTH - addressLabel.x - 30;
    self.addressLabel = addressLabel;

    CGRect rect = [addressLabel.text boundingRectWithSize:CGSizeMake(SCR_WIDTH - addressLabel.x - 30, 200.0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:addressLabel.font} context:nil];
    addressLabel.height = rect.size.height;
    addressLabel.numberOfLines = 2;
    [addressView addSubview:addressLabel];

    UIImageView *arrow1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right"]];
    arrow1.x = SCR_WIDTH - 14 - arrow1.width;
    arrow1.centerY = backView.height / 2.0;
    [addressView addSubview:arrow1];

    // 盖子
    UIView *topView = [[UIView alloc] init];
    topView.y = 6;
    topView.width = SCR_WIDTH;
    topView.height = backView.height - 12;
    topView.backgroundColor = CZGlobalWhiteBg;
    [backView addSubview:topView];
    self.topView = topView;

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
    return backView;
}

- (UIView *)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.x = 0;
        _bottomView.y = SCR_HEIGHT - likeAndShareHeight - (IsiPhoneX ? 83 : 49);
        _bottomView.width = SCR_WIDTH;
        _bottomView.height = likeAndShareHeight;

        UIButton *allSelectedBtn = [[UIButton alloc] init];
        [allSelectedBtn setImage:[UIImage imageNamed:@"square-nor"] forState:UIControlStateNormal];
        [allSelectedBtn setImage:[UIImage imageNamed:@"square-sel"] forState:UIControlStateSelected];
        [allSelectedBtn setTitle:@"全选" forState:UIControlStateNormal];
        [allSelectedBtn setTitleColor:UIColorFromRGB(0x090909) forState:UIControlStateNormal];
        allSelectedBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
        allSelectedBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [allSelectedBtn sizeToFit];
        allSelectedBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [allSelectedBtn addTarget:self action:@selector(allSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        allSelectedBtn.x = 10;
        allSelectedBtn.width = allSelectedBtn.width + 5;
        allSelectedBtn.centerY = _bottomView.height / 2.0;
        [_bottomView addSubview:allSelectedBtn];
        self.allSelectedBtn = allSelectedBtn;

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"合计：";
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
        [titleLabel sizeToFit];
        titleLabel.textColor = UIColorFromRGB(0x090909);
        titleLabel.x = CZGetX(allSelectedBtn) + 5;
        titleLabel.centerY = likeAndShareHeight / 2.0;
        [_bottomView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        // 点击事件
        //        [btn addTarget:self action:@selector(serviceBtnClickedBtn:) forControlEvents:UIControlEventTouchUpInside];

        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.text = @"0";
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
        buyBtn.y = 5.5;
        buyBtn.width = 100;
        buyBtn.height = 38;
        buyBtn.x = SCR_WIDTH - 10 - buyBtn.width;
        buyBtn.layer.cornerRadius = 19;
        [_bottomView addSubview:buyBtn];
        self.buyBtn = buyBtn;

        UIButton *shopping = [UIButton buttonWithType:UIButtonTypeCustom];
        [shopping setTitle:@"生成付款码" forState:UIControlStateNormal];
        shopping.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
        [shopping setBackgroundColor:UIColorFromRGB(0x4A90E2)];
        [shopping addTarget:self action:@selector(shoppingTrolleyBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        shopping.y = 5.5;
        shopping.width = 100;
        shopping.height = 38;
        shopping.x = SCR_WIDTH - 10 - buyBtn.width - 10 - shopping.width;
        shopping.layer.cornerRadius = 19;
        [_bottomView addSubview:shopping];
        self.shopping = shopping;
    }
    return _bottomView;
}

// 添加备注
- (UIView *)setuprRmarkView
{
    UIView *backView = [[UIView alloc] init];
    backView.y = 0;
    backView.width = SCR_WIDTH;
    backView.height = 90 + 12;
    backView.backgroundColor = CZGlobalLightGray;

    // 盖子
    UIView *topView = [[UIView alloc] init];
    topView.y = 6;
    topView.width = SCR_WIDTH;
    topView.height = backView.height - 12;
    topView.backgroundColor = CZGlobalWhiteBg;
    [backView addSubview:topView];

    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.text = @"添加备注";
    label.textColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 15];
    [label sizeToFit];
    label.x = 14;
    label.height = 90;
    label.width = SCR_WIDTH - 30 - 14;
    label.centerY = topView.height / 2.0;
    [topView addSubview:label];
    self.remarkLabel = label;

    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right"]];
    arrow.x = SCR_WIDTH - 14 - arrow.width;
    arrow.centerY = topView.height / 2.0;
    [topView addSubview:arrow];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushAddRemarkController)];
    [topView addGestureRecognizer:tap];
    return backView;
}
#pragma mark -- end

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.tableView reloadData];
    //导航条 @"完成"
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"购物车" rightBtnTitle:@"编辑" rightBtnAction:^(CZNavigationView *view) {
        if ([view.rightRecordBtn.titleLabel.text isEqualToString:@"编辑"]) {
            view.rightText = @"完成";
            [self.buyBtn setTitle:@"删除" forState:UIControlStateNormal];
            self.titleLabel.hidden = YES;
            self.priceLabel.hidden = YES;
            self.shopping.hidden = YES;
        } else {
            view.rightText = @"编辑";
            [self.buyBtn setTitle:@"前往支付" forState:UIControlStateNormal];
            self.titleLabel.hidden = NO;
            self.priceLabel.hidden = NO;
            self.shopping.hidden = NO;
        }
    } navigationViewType:nil];

    navigationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navigationView];
    //导航条
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0) + 67, SCR_WIDTH, 0.7)];
    line.backgroundColor = CZGlobalLightGray;
    [self.view addSubview:line];
    // 表
    [self.view addSubview:self.tableView];
    // 购买
    [self.view addSubview:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 获取数据
    GXSqliteTool *tool = [GXSqliteTool sqliteTool];
    self.array = [NSMutableArray arrayWithArray:[tool select]];
    self.priceLabel.text = @"0";
    self.allSelectedBtn.selected = NO;
    [self.goodsParam removeAllObjects]; // 记录选中的数组
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
}
#pragma mark -- end

#pragma mark - 代理
// CZfeedbackController
- (void)feedbackController:(CZfeedbackController *)vc commitWithText:(NSString *)text
{
    self.remarkLabel.text = [NSString stringWithFormat:@"备注: %@", text];
    [self.remarkLabel sizeToFit];
    self.remarkLabel.x = 14;
    self.remarkLabel.centerY = 90 / 2.0;
}

//KGMyClientControllerDelegate
- (void)myClientController:(KGMyClientController *)vc updataAddress:(NSDictionary *)address
{
    NSLog(@"%@", address);
    if (address) {
        self.addressDic = address;
        self.topView.hidden = YES;
        /** 头像 */
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:address[@"userheadpath"]]];
        /** 电话号码 */
        self.labelName.text = address[@"mobile"];
        /** 地址 */
        self.addressLabel.text = address[@"address"];
        CGRect rect = [self.addressLabel.text boundingRectWithSize:CGSizeMake(SCR_WIDTH - self.addressLabel.x - 30, 200.0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.addressLabel.font} context:nil];
        self.addressLabel.height = rect.size.height;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 118;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KGShoppingTrolleyCell *cell = [KGShoppingTrolleyCell cellWithTableView:tableView];
    cell.model = self.array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KGShoppingTrolleyModel *model = self.array[indexPath.row];
    if (model.isSelected) {
         model.isSelected = NO;
        CGFloat allPrice = [self.priceLabel.text floatValue];
        CGFloat price = allPrice - [model.price floatValue] * [model.amount floatValue];
        self.priceLabel.text = [NSString stringWithFormat:@"%.2lf", price];
        [self.priceLabel sizeToFit];
        NSDictionary *goods = @{@"goodsID" : model.goodsId, @"goodsCount" : model.amount};
        if ([self.goodsParam containsObject:goods]) {
            [self.goodsParam removeObject:goods];
        }
        //全选按钮
        self.allSelectedBtn.selected = NO;
    } else {
         model.isSelected = YES;
        CGFloat allPrice = [self.priceLabel.text floatValue];
        CGFloat price = allPrice + [model.price floatValue] * [model.amount floatValue];
        self.priceLabel.text = [NSString stringWithFormat:@"%.2lf", price];
        [self.priceLabel sizeToFit];

        NSDictionary *goods = @{@"goodsID" : model.goodsId, @"goodsCount" : model.amount};
        if (![self.goodsParam containsObject:goods]) {
            [self.goodsParam addObject:goods];
        }
        if (self.goodsParam.count == self.array.count) {
            //全选按钮
            self.allSelectedBtn.selected = YES;
        }
    }
    [self.tableView reloadData];
}
#pragma mark -- end

#pragma mark - 事件
// 跳转到地址界面
- (void)pushSearchController
{
    KGMyClientController *vc = [[KGMyClientController alloc] init];
    vc.type = KGMyClientControllerTypeOrder;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

// 全选
- (void)allSelectedAction:(UIButton *)sender
{
    if (sender.isSelected) {
        for (KGShoppingTrolleyModel *model in self.array) {
            model.isSelected = NO;
        }
        self.priceLabel.text = @"0";
        [self.goodsParam removeAllObjects];
    } else {
        self.priceLabel.text = @"0";
        for (KGShoppingTrolleyModel *model in self.array) {
            model.isSelected = YES;
            CGFloat allPrice = [self.priceLabel.text floatValue];
            CGFloat price = allPrice + [model.price floatValue] * [model.amount floatValue];
            self.priceLabel.text = [NSString stringWithFormat:@"%.2lf", price];
            [self.priceLabel sizeToFit];
            NSDictionary *goods = @{@"goodsID" : model.goodsId, @"goodsCount" : model.amount};
            if (![self.goodsParam containsObject:goods]) {
                [self.goodsParam addObject:goods];
            }
        }
    }
    sender.selected = !sender.selected;
    [self.tableView reloadData];
}

// 创建订单
- (void)shoppingTrolleyBtnAction:(UIButton *)sender
{
    if (!self.addressDic) {
        [CZProgressHUD showProgressHUDWithText:@"请选择客户"];
        [CZProgressHUD hideAfterDelay:1.5];
        return;
    }
    if (self.goodsParam.count == 0) {
        [CZProgressHUD showProgressHUDWithText:@"请选择商品"];
        [CZProgressHUD hideAfterDelay:1.5];
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"goodsInfo"] = self.goodsParam; // 商品信息
    param[@"remark"] = self.remarkLabel.text;
    param[@"addressID"] = self.addressDic[@"uaid"]; // 用户收货地址ID
    param[@"userID"] = self.addressDic[@"userid"]; // 用户id

    typeof(self) weakSelf = self;
    [KGServerTool createOrderQRCode:param orderQRCodeBlock:^(NSString *QRImage, NSString *orderID) {
        self.orderID = orderID;
        CZUpdataView *backView = [CZUpdataView updataView];
        backView.isShoppingTrolley = YES;
        self.backView = backView;
        [backView getQRCode:QRImage];
        backView.frame = [UIScreen mainScreen].bounds;
        backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [weakSelf.view addSubview:backView];
         self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getOrderInfo) userInfo:nil repeats:YES];
    }];
}

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
                [self deleteWithSelectedGoods:nil];
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

// 前往支付
- (void)buyBtnAction:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"删除"]) {
        [self deleteWithSelectedGoods:self.goodsParam];
    } else {
        // 支付
    }
}

// 删除数据
- (void)deleteWithSelectedGoods:(NSMutableArray *)goodsParam
{
    GXSqliteTool *tool = [GXSqliteTool sqliteTool];

    if (goodsParam.count > 0) {
        for (int i = 0; i < goodsParam.count; i++) {
            NSDictionary *dic = goodsParam[i];
            [tool deleteWithText:dic[@"goodsID"]];
        }
        [goodsParam removeAllObjects];
    } else {
        [tool delete];
        [self.goodsParam removeAllObjects];
    }
    self.array = [NSMutableArray arrayWithArray:[tool select]];
    self.priceLabel.text = @"0";
    [self.tableView reloadData];
}

// 跳转到添加备注
- (void)pushAddRemarkController
{
    CZfeedbackController *vc = [[CZfeedbackController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -- end

@end
