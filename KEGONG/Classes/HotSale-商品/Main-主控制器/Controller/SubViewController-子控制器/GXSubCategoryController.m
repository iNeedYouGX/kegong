//
//  GXSubCategoryController.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/16.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "GXSubCategoryController.h"
#import "CZScollerImageTool.h"
#import "CZMyPointsCell.h"
#import "GXNetTool.h"
#import "GXCategoryController.h"
#import "GXCategoryListController.h"

@interface GXSubCategoryController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GXCategoryControllerDelegate>
/** 表单 */
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation GXSubCategoryController

#pragma mark - 数据
// 获取标题数据
- (void)obtainTtitlesWithParentgid:(NSString *)parentgid
{
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"parentgid"] = parentgid;
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/goods/types.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"msg"] isEqualToString:@"成功"]) {
            _dataArr = result[@"childTypes"];
            [self.collectionView reloadData];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSError *error) {}];
}

#pragma mark -- end

#pragma mark - 周期
static NSString * const ID = @"GXSubCategoryController";
- (void)viewDidLoad {
    [super viewDidLoad];


    //    [collectionView reloadData];
}
#pragma mark -- end

- (void)setDataArr:(NSArray *)dataArr
{
    _dataArr = dataArr;
    // 创建轮播图
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    imageView.frame = CGRectMake(14, 0, self.view.width - 28, 90);
    imageView.image = [UIImage imageNamed:@"banner"];
    [self.view addSubview:imageView];

    // 创建厨房电器标题
    UIView *lineView = [[UIView alloc] init];
    lineView.width = imageView.width;
    lineView.y = CZGetY(imageView);
    lineView.x = 14;
    lineView.height = 70;
    //    lineView.backgroundColor = RANDOMCOLOR;
    [self.view addSubview:lineView];

    // 创建中尖的标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"家用厨房电器";
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 14];
    titleLabel.textColor = [UIColor blackColor];
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake(lineView.width / 2.0, lineView.height / 2.0);
    [lineView addSubview:titleLabel];

    // 左边线
    UIView *leftLine = [[UIView alloc] init];
    leftLine.height = 1;
    leftLine.width = 40;
    leftLine.backgroundColor = CZGlobalGray;
    leftLine.x = CGRectGetMinX(titleLabel.frame) - 10 - leftLine.width;
    leftLine.centerY = titleLabel.centerY;
    [lineView addSubview:leftLine];
    // 右边线
    UIView *rightLine = [[UIView alloc] init];
    rightLine.height = 1;
    rightLine.width = 40;
    rightLine.backgroundColor = CZGlobalGray;
    rightLine.x = CGRectGetMaxX(titleLabel.frame) + 10;
    rightLine.centerY = titleLabel.centerY;
    [lineView addSubview:rightLine];



    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((self.view.width - 28) / 3, (self.view.width - 28) / 3 + 30);
    layout.minimumInteritemSpacing = 0;
    //    layout.minimumLineSpacing = 0;
    //    layout.sectionInset = UIEdgeInsetsMake(18, 14, 10, 14);
    //
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(14, CZGetY(lineView), self.view.width - 28, self.view.height - CZGetY(lineView)) collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    self.collectionView = collectionView;

    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CZMyPointsCell class]) bundle:nil] forCellWithReuseIdentifier:ID];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CZMyPointsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
//    cell.backgroundColor = RANDOMCOLOR;
    cell.dicData = self.dataArr[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *param = self.dataArr[indexPath.row];
    GXCategoryListController *vc = [[GXCategoryListController alloc] init];
    vc.param = param;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 代理
- (void)categoryController:(GXCategoryController *)categoryViewController didSelectedSubCategory:(CZHotTitleModel *)subCategory
{
    [self obtainTtitlesWithParentgid:subCategory.gtid];
}

@end
