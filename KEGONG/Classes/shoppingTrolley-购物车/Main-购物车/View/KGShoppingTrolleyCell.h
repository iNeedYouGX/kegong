//
//  KGShoppingTrolleyCell.h
//  KEGONG
//
//  Created by JasonBourne on 2019/4/22.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KGShoppingTrolleyModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface KGShoppingTrolleyCell : UITableViewCell
/** 数据模型 */
@property (nonatomic, strong) KGShoppingTrolleyModel *model;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
