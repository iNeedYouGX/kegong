//
//  CZUpdataView.m
//  BestCity
//
//  Created by JasonBourne on 2019/3/16.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "CZUpdataView.h"
#import <CoreImage/CoreImage.h>
#import <Photos/Photos.h>

@interface CZUpdataView ()
/** 删除按钮 */
@property (nonatomic, weak) IBOutlet UIButton *delectBtn;
/** 图片 */
@property (nonatomic, weak) IBOutlet UIImageView *QRImageView;
@end

@implementation CZUpdataView
+ (instancetype)updataView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil][0] ;
}

/** <#注释#> */
- (IBAction)gotoUpdata
{
    [self saveImage];
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

/** <#注释#> */
- (IBAction)deleteView
{
    if (self.isShoppingTrolley) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"支付未完成，关闭后无法清空购物车" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction * update = [UIAlertAction actionWithTitle:@"确定关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self removeFromSuperview];
        }];
        [alert addAction:ok];
        [alert addAction:update];
        UITabBarController *tabbar = (UITabBarController *)[[UIApplication sharedApplication].keyWindow rootViewController];
        UINavigationController *nav = tabbar.selectedViewController;
        [nav presentViewController:alert animated:YES completion:nil];
    } else {
        [self removeFromSuperview];
    }
}

- (void)saveImage {
    // 存储图片到"相机胶卷"
    UIImageWriteToSavedPhotosAlbum(self.QRImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// 成功保存图片到相册中, 必须调用此方法, 否则会报参数越界错误
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    [CZProgressHUD showProgressHUDWithText:msg];
    [CZProgressHUD hideAfterDelay:1.5];
}

@end
