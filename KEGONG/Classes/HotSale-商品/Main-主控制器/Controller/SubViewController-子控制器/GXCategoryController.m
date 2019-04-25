//
//  GXCategoryController.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/16.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "GXCategoryController.h"
#import "GXCategoryCell.h"


@interface GXCategoryController ()
/** 记录选中的indexPath */
@property (nonatomic, strong) NSIndexPath *recordPath;
@end

@implementation GXCategoryController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *ID = @"GXCategoryController";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
}

- (void)setCategories:(NSArray<CZHotTitleModel *> *)categories
{
    _categories = categories;
    [self.tableView reloadData];
    NSIndexPath *selIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:selIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:selIndex];
    self.recordPath = selIndex;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.recordPath != nil) {
        [self.tableView selectRowAtIndexPath:self.recordPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:self.recordPath];
    }
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CZHotTitleModel *model = self.categories[indexPath.row];
    GXCategoryCell *cell = [GXCategoryCell cellwithTableView:tableView];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"----didSelectRowAtIndexPath---");
    // 记录点中项
     self.recordPath = indexPath;
    CZHotTitleModel *param = self.categories[indexPath.row];


    if ([self.delegate respondsToSelector:@selector(categoryController:didSelectedSubCategory:)]) {
        CZHotTitleModel *param = self.categories[indexPath.row];
        [self.delegate categoryController:self didSelectedSubCategory:param];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"取消选中%ld", indexPath.row);
}


@end
