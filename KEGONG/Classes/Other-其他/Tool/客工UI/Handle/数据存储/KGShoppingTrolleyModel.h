//
//  KGShoppingTrolleyModel.h
//  test2
//
//  Created by JasonBourne on 2019/4/22.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KGShoppingTrolleyModel : NSObject
/** 商品的ID */
@property (nonatomic, strong) NSString *goodsId;
/** 照片 */
@property (nonatomic, strong) NSString *shopImage;
/** 商品名字 */
@property (nonatomic, strong) NSString *shopName;
/** 价格 */
@property (nonatomic, strong) NSString *price;
/** 商品个数 */
@property (nonatomic, strong) NSString *amount;
/** 商品总数 */
@property (nonatomic, strong) NSString *shopCount;

/** 是否选中 */
@property (nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
