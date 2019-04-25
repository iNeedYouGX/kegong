//
//  KGServerTool.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/24.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "KGServerTool.h"
#import "GXNetTool.h"

@implementation KGServerTool

+ (void)createOrderQRCode:(NSDictionary *)param orderQRCodeBlock:(orderQRCodeBlock) QRCodeblock
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"%@", jsonStr);


    NSString *url = [KGSERVER_URL stringByAppendingPathComponent:@"/app/my/order/OrderSave.do"];
    [CZProgressHUD showProgressHUDWithText:nil];
    [GXNetTool PostNetWithUrl:url body:param bodySytle:GXRequsetStyleBodyJSON header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqualToNumber:@(1)])
        {
            [self getQRcode:result[@"orderID"] orderQRCodeBlock:QRCodeblock];

        } else {
            [CZProgressHUD showProgressHUDWithText:result[@"msg"]];
            [CZProgressHUD hideAfterDelay:1.5];
        }

    } failure:^(NSError *error) {}];
}

+ (void)getQRcode:(NSString *)orderID orderQRCodeBlock:(orderQRCodeBlock)QRCodeblock
{
    //获取数据
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"tradeNo"] = orderID;
    param[@"payType"] = @"1";
    param[@"tradeType"] = @"NATIVE";

    [GXNetTool GetNetWithUrl:[KGSERVER_URL stringByAppendingPathComponent:@"/my/pay/PlaceOrder.do"] body:param header:nil response:GXResponseStyleJSON success:^(id result) {
        if ([result[@"success"] isEqualToString:@"true"]) {
            QRCodeblock(result[@"data"][@"code_url"]);
        }
        //隐藏菊花
        [CZProgressHUD hideAfterDelay:0];
    } failure:^(NSError *error) {}];
}

@end
