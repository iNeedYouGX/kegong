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

@interface KGMyClientController () <UITableViewDelegate, UITableViewDataSource>
/** <#注释#> */
@property (nonatomic, strong) UITableView *tableView;
/** 数据 */
@property (nonatomic, strong) NSArray *listArr;
/** 选中的数据 */
@property (nonatomic, strong) NSDictionary *param;
@end

@implementation KGMyClientController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CZGlobalLightGray;
    // 获取数据
    if (self.type == KGMyClientControllerTypeOrder) {
        [self getOrderDataSource];
    } else {
        [self getDataSource];
    }

    //导航条
    typeof(self) weakSelf = self;
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"我的用户 " rightBtnTitle:@"保存" rightBtnAction:^(UIView *view){
        NSLog(@"点击了保存");
        if (self.param) {
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

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView = tableView;
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.frame = CGRectMake(0, CZGetY(navigationView) + 0.7, SCR_WIDTH, SCR_HEIGHT - CZGetY(navigationView) - 0.7);
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
- (void)getOrderDataSource
{
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"pageon"] = @(1);
    param[@"pageSize"] = @(1000);

    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/my/area/members.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqual:@(1)]) {
            self.listArr = result[@"areaMemberList"];
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
    KGMyClientCell *cell = [KGMyClientCell cellWithTableView:tableView];
    cell.model = self.listArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.param = self.listArr[indexPath.row];
//    NSLog(@"点击了---%ld--- %@", indexPath.row, self.param);

}

#pragma -- end

@end
