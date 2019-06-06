//
//  KGMyClientController.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/19.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "KGMyClientController.h"
#import "GXNetTool.h"
#import "CZNavigationView.h"
#import "KGMyClientCell.h"
#import "CZEditAddressController.h"
#import "CZHotSearchView.h"

@interface KGMyClientController () <UITableViewDelegate, UITableViewDataSource, CZHotSearchViewDelegate>
/** <#注释#> */
@property (nonatomic, strong) UITableView *tableView;
/** 数据 */
@property (nonatomic, strong) NSArray *listArr;
/** 选中的数据 */
@property (nonatomic, strong) NSDictionary *param;
/** 搜索框 */
@property (nonatomic, strong) CZHotSearchView *search;
@end

@implementation KGMyClientController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 获取数据
    if (self.type == KGMyClientControllerTypeOrder) {
        [self getOrderDataSource:@""];
    } else {
        [self getDataSource];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CZGlobalWhiteBg;
    NSString *rightText;
    if (self.type == KGMyClientControllerTypeOrder) {
        rightText = @"保存";
    } else {
        rightText = @"";
    }
    //导航条
    typeof(self) weakSelf = self;
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"我的用户" rightBtnTitle:rightText rightBtnAction:^(UIView *view){
        NSLog(@"点击了保存");
        if (self.param && rightText.length > 0) {
            !self.delegate ? : [self.delegate myClientController:weakSelf updataAddress:self.param];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [CZProgressHUD showProgressHUDWithText:@"请选择用户"];
            [CZProgressHUD hideAfterDelay:1.5];
        }
    } navigationViewType:CZNavigationViewTypeBlack];
    navigationView.backgroundColor = CZGlobalWhiteBg;
    //    navigationView.delegate = self;
    [self.view addSubview:navigationView];
    //导航条
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0) + 67, SCR_WIDTH, 0.7)];
    line.backgroundColor = CZGlobalLightGray;
    [self.view addSubview:line];

    // 搜索框
    self.search = [[CZHotSearchView alloc] initWithFrame:CGRectMake(10, CZGetY(line), SCR_WIDTH -  20 - 40, 34) msgAction:^(NSString *title) {

    }];
    self.search.delegate = self;
    [self.view addSubview:self.search];

    UIButton *searchBtn = [[UIButton alloc] init];
    [searchBtn setTitle:@"确定" forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchBtn sizeToFit];
    searchBtn.x = CZGetX(self.search) + 10;
    searchBtn.centerY = self.search.centerY;
    [self.view addSubview:searchBtn];
    [searchBtn addTarget:self
                  action:@selector(searchBtnAction) forControlEvents:UIControlEventTouchUpInside];

    if (self.type == KGMyClientControllerTypeMe) {
        searchBtn.hidden = YES;
        self.search.height = 0;
    }

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    self.tableView = tableView;
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.frame = CGRectMake(0, CZGetY(self.search), SCR_WIDTH, SCR_HEIGHT - CZGetY(self.search));
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - 数据
// 获取我的列表数据
- (void)getDataSource
{
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"pageon"] = @(1);
    param[@"pageSize"] = @(1000);

    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/my/sales/members.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqual:@(1)]) {
            self.listArr = result[@"salesMemberList"];
            [self.tableView reloadData];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSError *error) {}];
}

// 获取代客下单时列表数据
- (void)getOrderDataSource:(NSString *)name
{
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"pageon"] = @(1);
    param[@"pageSize"] = @(1000);
    param[@"searchVal"] = name;

    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/my/area/members.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqual:@(1)]) {
            self.listArr = result[@"areaMemberList"];
            NSMutableArray *mutArr = [self.listArr mutableCopy];
            [mutArr removeAllObjects];



            [self.tableView reloadData];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSError *error) {}];
}
#pragma -- end

#pragma mark - 代理
// UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == KGMyClientControllerTypeMe) {
        KGMyClientCell *cell = [KGMyClientCell cellWithTableView:tableView type:KGMyClientCellTypeNoSelect];
        cell.model = self.listArr[indexPath.row];
        return cell;
    } else {
        KGMyClientCell *cell = [KGMyClientCell cellWithTableView:tableView type:KGMyClientCellTypeDefault];
        cell.model = self.listArr[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == KGMyClientControllerTypeMe) {
        self.param = self.listArr[indexPath.row];
        NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.param[@"mobile"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

    } else {
        self.param = self.listArr[indexPath.row];
        if ([self.param[@"address"] length] == 0) {
            CZEditAddressController *vc = [[CZEditAddressController alloc] init];
            vc.paramAddress = self.param;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

// <CZHotSearchViewDelegate>
- (void)hotView:(CZHotSearchView *)hotView didTextFieldChange:(CZTextField *)textField
{
    NSLog(@"%@", textField.text);
    if (textField.text.length == 0) {
        hotView.msgTitle = @"取消";
    } else {
        hotView.msgTitle = @"搜索";
    }
}

#pragma -- end

#pragma mark -- 事件
- (void)searchBtnAction
{
    [self getOrderDataSource:self.search.searchText];
}
#pragma end

@end
