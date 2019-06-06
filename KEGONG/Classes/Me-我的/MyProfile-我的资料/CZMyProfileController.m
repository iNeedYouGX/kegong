//
//  CZMyProfileController.m
//  BestCity
//
//  Created by JasonBourne on 2018/8/1.
//  Copyright © 2018年 JasonBourne. All rights reserved.
//

#import "CZMyProfileController.h"
#import "CZNavigationView.h"
#import "CZMyProfileCell.h"
#import "GXNetTool.h"


@interface CZMyProfileController () <UITableViewDelegate, UITableViewDataSource>
/** tableView */
@property (nonatomic, strong) UITableView *tableView;
/** 左侧标题的数组 */
@property (nonatomic, strong) NSArray *leftTitles;
/** 右侧的副标题 */
@property (nonatomic, strong) NSMutableArray *rightTitles;

@end

@implementation CZMyProfileController

- (NSArray *)leftTitles
{
    if (_leftTitles == nil) {
        _leftTitles = @[@"头像", @"昵称", @"联系方式", @"微信二维码"];
    }
    return _leftTitles;
}

- (NSMutableArray *)rightTitles
{
    if (_rightTitles == nil) {
        // 用户信息
        NSDictionary *userInfo = JPUSERINFO;
        _rightTitles = [NSMutableArray arrayWithArray:@[
                                                        @"",
                                                        userInfo[@"username"],
                                                        userInfo[@"mobile"],
                                                        userInfo[@"buscardpic"],
                                                        ]];
    }
    return _rightTitles;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUserInfo];
}

- (void)setUserInfo
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    //获取详情数据
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/my/user/getUserInfo.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqualToNumber:@(1)]) {
            [CZSaveTool setObject:result[@"salesInfo"] forKey:@"user"];
            self.rightTitles = nil;
            [self.tableView reloadData];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];

    } failure:^(NSError *error) {
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CZGlobalWhiteBg;
    //导航条
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"个人资料" rightBtnTitle:nil rightBtnAction:nil navigationViewType:CZNavigationViewTypeBlack];
    [self.view addSubview:navigationView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 68 + (IsiPhoneX ? 24 : 0), SCR_WIDTH, SCR_HEIGHT - 68 - (IsiPhoneX ? 24 : 0)) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}



#pragma  mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.leftTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // 头像
        CZMyProfileCell *cell = [CZMyProfileCell cellWithTableView:tableView cellType:0];
        cell.headerImage = self.rightTitles[indexPath.row];
        return cell;
    } else if (indexPath.row == 3) {
        CZMyProfileCell *cell = [CZMyProfileCell cellWithTableView:tableView cellType:2];
        cell.headerImage = JPUSERINFO[@"buscardpic"];
        return cell;
    } else {
        CZMyProfileCell *cell = [CZMyProfileCell cellWithTableView:tableView cellType:CZMyProfileCellTypeSubTitle];
        cell.title = self.leftTitles[indexPath.row];
        cell.subTitle = self.rightTitles[indexPath.row];
        return cell;
    }
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        [self openPhoto];
    }
}

#pragma mark - 调用相机
- (void)openPhoto
{
    // 创建弹窗
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        //判断是否可以打开照相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            // 创建相机类
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES; //可编辑
            //摄像头
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
        } else {
            NSLog(@"没有摄像头");
        }
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            // 创建相机类
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            NSLog(@"打开相册");
            [self presentViewController:picker animated:YES
                             completion:nil];
        } else {
            NSLog(@"不能打开相册");
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -<UIImagePickerControllerDelegate> 拍照完成回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<UIImagePickerControllerInfoKey, id> *)editingInfo
{
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera || picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        //上传图片
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"id"] = JPUSERINFO[@"salesid"];
        param[@"uploadFileType"] = @"5";
        [GXNetTool uploadNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"app/my/UploadFile.do"] body:param  fileSource:image success:^(id result) {
            if ([result[@"filepath"] length] > 10) {
                [CZProgressHUD showProgressHUDWithText:@"上传成功"];
                [self setUserInfo];
            } else {
                [CZProgressHUD showProgressHUDWithText:@"上传失败"];
            }
            [CZProgressHUD hideAfterDelay:1.5];
        } failure:^(NSError *error) {

        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
