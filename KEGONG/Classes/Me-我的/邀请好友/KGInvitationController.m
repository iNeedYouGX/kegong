//
//  KGInvitationController.m
//  KEGONG
//
//  Created by JasonBourne on 2019/5/14.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "KGInvitationController.h"
#import "CZNavigationView.h"
#import "GXNetTool.h"

#import <UMShare/UMShare.h>

@interface KGInvitationController ()
/** <#注释#> */
@property (nonatomic, strong) UIImageView *QRImageView;
/** 邀请码 */
@property (nonatomic, strong) UILabel *codeLabel;
@end

@implementation KGInvitationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CZGlobalWhiteBg;
    //导航条
    CZNavigationView *navigationView = [[CZNavigationView alloc] initWithFrame:CGRectMake(0, (IsiPhoneX ? 24 : 0), SCR_WIDTH, 67) title:@"邀请好友" rightBtnTitle:nil rightBtnAction:nil navigationViewType:CZNavigationViewTypeBlack];
    [self.view addSubview:navigationView];


    UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"head portrait"]];
    [self.view addSubview:iconImage];
    iconImage.center = CGPointMake(SCR_WIDTH / 2.0, 150);
    [self.view addSubview:iconImage];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.text = @"客工App";
    [nameLabel sizeToFit];
    nameLabel.y = CZGetY(iconImage) + 10;
    nameLabel.centerX = SCR_WIDTH / 2.0;
    [self.view addSubview:nameLabel];

    UIImageView *QRImageView = [[UIImageView alloc] init];
    self.QRImageView = QRImageView;
    [self.view addSubview:QRImageView];
    QRImageView.size = CGSizeMake(200, 180);
    QRImageView.y = CZGetY(nameLabel) + 20;
    QRImageView.centerX = SCR_WIDTH / 2.0;

    UILabel *codeLabel = [[UILabel alloc] init];
    self.codeLabel = codeLabel;
    codeLabel.y = CZGetY(QRImageView) + 10;;
    codeLabel.x = QRImageView.x;
    codeLabel.text = self.codeText;
    codeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    codeLabel.textColor = CZGlobalGray;
    [codeLabel sizeToFit];
    [self.view addSubview:codeLabel];

    UIButton *copyBtn = [[UIButton alloc] init];
    copyBtn.x = CZGetX(codeLabel) + 50;
    copyBtn.y = codeLabel.y - 5;
    copyBtn.size = CGSizeMake(60, 25);
    copyBtn.backgroundColor = UIColorFromRGB(0x0085DF);
    [copyBtn setTitle:@"复制" forState:UIControlStateNormal];
    copyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 13];
    [copyBtn addTarget:self action:@selector(generalPaste) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:copyBtn];


    //底部退出按钮
    UIButton *loginOut = [UIButton buttonWithType:UIButtonTypeCustom];
    loginOut.frame = CGRectMake(14, SCR_HEIGHT - ((IsiPhoneX ? 83 : 49) + 36 + 46), SCR_WIDTH - 28, 36);
    [self.view addSubview:loginOut];
    [loginOut setTitle:@"分享到微信" forState:UIControlStateNormal];
    loginOut.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginOut setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
    loginOut.layer.cornerRadius = 18;
    loginOut.layer.masksToBounds = YES;
    [loginOut addTarget:self action:@selector(shareButtonAction) forControlEvents:UIControlEventTouchUpInside];

    [self getQRCode];
}

// 获取客工邀请码和生成二维码的url
- (void)getQRCode
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    //获取详情数据
    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/app/my/sales/salescode.do"] body:nil header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqualToNumber:@(1)]) {
            [self getQRCode:result[@"url"]];
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSError *error) {
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    }];
}

- (void)getQRCode:(NSString *)QRStr
{
    // 1.创建过滤器 -- 苹果没有将这个字符封装成常量
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];

    // 2.过滤器恢复默认设置
    [filter setDefaults];

    // 3.给过滤器添加数据(正则表达式/帐号和密码) -- 通过KVC设置过滤器,只能设置NSData类型
    NSString *dataString = QRStr;
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];

    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];

    // 5.显示二维码
    //    UIImage *image = [UIImage imageWithCIImage:outputImage];
    self.QRImageView.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:120];
}

/**
 2  *  根据CIImage生成指定大小的UIImage
 3  *
 4  *  @param image CIImage
 5  *  @param size  图片宽度
 6  */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));

    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);

    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


// 分享
- (void)shareButtonAction
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
//    shareObject.thumbImage = [UIImage imageNamed:@"icon"];
    shareObject.shareImage = self.QRImageView.image;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;

    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:UMSocialPlatformType_WechatSession messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}

@end
