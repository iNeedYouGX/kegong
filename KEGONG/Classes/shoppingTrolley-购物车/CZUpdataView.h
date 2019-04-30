//
//  CZUpdataView.h
//  BestCity
//
//  Created by JasonBourne on 2019/3/16.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZUpdataView : UIView
+ (instancetype)updataView;
- (void)getQRCode:(NSString *)QRStr;
/** 判断是否是购物车过来的 */
@property (nonatomic, assign) BOOL isShoppingTrolley;
@end

NS_ASSUME_NONNULL_END
