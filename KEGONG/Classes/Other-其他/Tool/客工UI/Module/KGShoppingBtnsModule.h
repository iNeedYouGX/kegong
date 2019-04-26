//
//  KGShoppingBtnsModule.h
//  KEGONG
//
//  Created by JasonBourne on 2019/4/24.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^shoppingTrolleyBlock)(void);

@interface KGShoppingBtnsModule : UIView
/** 实际支付 */
@property (nonatomic, strong) NSString *price;
/** 生成二维码 */
@property (nonatomic, copy) shoppingTrolleyBlock QRBlock;
/** 前往支付 */
@property (nonatomic, copy) shoppingTrolleyBlock buyBlock;
@end

NS_ASSUME_NONNULL_END
