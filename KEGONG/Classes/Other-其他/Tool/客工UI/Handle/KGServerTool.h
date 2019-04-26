//
//  KGServerTool.h
//  KEGONG
//
//  Created by JasonBourne on 2019/4/24.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
typedef void(^orderQRCodeBlock)(NSString *, NSString *);
@interface KGServerTool : NSObject
/** 创建订单生成二维码*/
+ (void)createOrderQRCode:(NSDictionary *)param orderQRCodeBlock:(orderQRCodeBlock) QRCodeblock;
@end
NS_ASSUME_NONNULL_END
