//
//  GXCategoryListController.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/18.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "GXCategoryListController.h"
#import "CZNavigationView.h"
#import "CZMutContentButton.h"
#import "GXNetTool.h"
#import "GXCategoryListCell.h"
#import "GXCategoryListDetailController.h" // 详情

@interface GXCategoryListController () <UITableViewDelegate, UITableViewDataSource>
/** <#注释#> */
@property (nonatomic, strong) CZNavigationView *navigationView;
/** 记录 */
@property (nonatomic, strong) CZMutContentButton *recordBtn;
/** 列表数据 */
@property (nonatomic, strong) NSArray *listArr;
/** 列表 */
@property (nonatomic, strong) UITableView *tableView;
/** 页数 */
@property (nonatomic, assign) NSInteger page;

@end

@implementation GXCategoryListController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CZGlobalLightGray;
    // 获取列表数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"gtid"] = self.param[@"gtid"];
    [self getDataSource:param];

    //导航条
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"分类" rightBtnTitle:nil rightBtnAction:nil navigationViewType:CZNavigationViewTypeBlack];
    self.navigationView = navigationView;
    navigationView.backgroundColor = CZGlobalWhiteBg;
    //    navigationView.delegate = self;
    [self.view addSubview:navigationView];
    //导航条
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0) + 67, SCR_WIDTH, 0.7)];
    line.backgroundColor = CZGlobalLightGray;
    [self.view addSubview:line];

    // 创建标题
    [self contentViewTitles];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView = tableView;
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.frame = CGRectMake(0, CZGetY(navigationView) + 40.7, SCR_WIDTH, SCR_HEIGHT - CZGetY(navigationView) - 40.7);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];

}

#pragma mark - 视图
- (void)contentViewTitles
{
    UIView *topTitleView = [[UIView alloc] init];
    topTitleView.y = CZGetY(self.navigationView);
    topTitleView.width = SCR_WIDTH;
    topTitleView.height = 40;
    topTitleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topTitleView];

    //导航条
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CZGetY(topTitleView), SCR_WIDTH, 0.7)];
    line.backgroundColor = CZGlobalLightGray;
    [self.view addSubview:line];
    NSArray *titles = @[@"综合", @"销量", @"上新", @"价格"];
    for (int i = 0; i < titles.count; i++) {
        UIView *backView = [[UIView alloc] init];
        backView.width = SCR_WIDTH / titles.count;
        backView.height = topTitleView.height;
        backView.x = backView.width * i;
        [topTitleView addSubview:backView];

        CZMutContentButton *rightBtn = [CZMutContentButton buttonWithType:UIButtonTypeCustom];
        rightBtn.adjustsImageWhenHighlighted = NO;
        rightBtn.tag = i;
        [rightBtn setTitle:titles[i] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(moreTrialReport:) forControlEvents:UIControlEventTouchUpInside];
        rightBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 15];
        [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (i == 0) {
            [rightBtn setTitleColor:CZREDCOLOR forState:UIControlStateNormal];
            //        商品排序 1 默认排序 2 销量排序 3 价格排序
            self.recordBtn = rightBtn;
        }
        if (i == 3) {
            [rightBtn setImage:[UIImage imageNamed:@"WX20190418-140041"] forState:UIControlStateNormal];
        }
        [backView addSubview:rightBtn];
        [rightBtn sizeToFit];
        rightBtn.center = CGPointMake(backView.width / 2.0, backView.height / 2.0);
    }


}
#pragma mark -- end

#pragma mark - 事件
- (void)moreTrialReport:(CZMutContentButton *)sender
{
    sender.selected = YES;
    switch (sender.tag) {
        case 3:
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"gtid"] = self.param[@"gtid"];
            param[@"search"] = self.param[@"gtname"];
            param[@"orderby"] = @"price";

            // 点击数
            NSInteger falg = sender.flag % 2;
            switch (falg) {
                case 0:
                    /** 默认降序 */
                    [sender setImage:[UIImage imageNamed:@"WX20190418-140115"] forState:UIControlStateSelected];
                    param[@"sequence"] = @"desc";
                    break;
                case 1:
                    /** 升序 */
                    [sender setImage:[UIImage imageNamed:@"WX20190418-140058"] forState:UIControlStateSelected];
                    param[@"sequence"] = @"asc";
                    break;

                default:
                    break;
            }
            sender.flag ++;
            [self.recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if (self.recordBtn != sender) {
                self.recordBtn.selected = NO;
                self.recordBtn.flag = 0;
            }
            [sender setTitleColor:CZREDCOLOR forState:UIControlStateNormal];
            [self getDataSource:param];
            break;
        }
        case 0:
        {
            [self.recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.recordBtn.selected = NO;
            [sender setTitleColor:CZREDCOLOR forState:UIControlStateNormal];
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"gtid"] = self.param[@"gtid"];
            [self getDataSource:param];
            break;
        }
        case 1:
        {
            [self.recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.recordBtn.selected = NO;
            [sender setTitleColor:CZREDCOLOR forState:UIControlStateNormal];
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"gtid"] = self.param[@"gtid"];
            param[@"search"] = self.param[@"gtname"];
            param[@"orderby"] = @"salesvolumes";
            param[@"sequence"] = @"asc";
            [self getDataSource:param];
            break;
        }
        case 2:
        {
            [self.recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.recordBtn.selected = NO;
            [sender setTitleColor:CZREDCOLOR forState:UIControlStateNormal];
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"gtid"] = self.param[@"gtid"];
            param[@"search"] = self.param[@"gtname"];
            param[@"orderby"] = @"putondate";
            param[@"sequence"] = @"asc";
            [self getDataSource:param];
            break;
        }
        default:
        {
            [self.recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.recordBtn.selected = NO;
            [sender setTitleColor:CZREDCOLOR forState:UIControlStateNormal];
            break;
        }
    }

    self.recordBtn = sender;
}
#pragma mark -- end

#pragma mark - 数据
- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadNewTrailDataSorce)];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTrailDataSorce)];
}
// 获取列表数据
- (void)getDataSource:(NSDictionary *)subParam
{
    self.page = 1;
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:subParam];
    param[@"row"] = @(10);
    param[@"pageon"] = @(self.page);
    [CZProgressHUD showProgressHUDWithText:nil];
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/goods/list.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqual:@(1)]) {
//            // 获取类目数据
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"hotSaleDataList.json" ofType:nil];
//            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//            NSDictionary *sourceData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.listArr = [result[@"goodsList"] isKindOfClass:[NSArray class]] ? result[@"goodsList"] : @[];
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
    return 168;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXCategoryListCell *cell = [GXCategoryListCell cellWithTableView:tableView];
    cell.model = self.listArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //push到详情
    GXCategoryListDetailController *vc = [[GXCategoryListDetailController alloc] init];
    NSDictionary *param = self.listArr[indexPath.row];
    vc.pointId = param[@"gid"];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma -- end

@end
