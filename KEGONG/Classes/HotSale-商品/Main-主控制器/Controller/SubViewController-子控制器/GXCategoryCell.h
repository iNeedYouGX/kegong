//
//  GXCategoryCell.h
//  KEGONG
//
//  Created by JasonBourne on 2019/4/17.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZHotTitleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GXCategoryCell : UITableViewCell
/** 数据 */
@property (nonatomic, strong) CZHotTitleModel *model;
+ (instancetype)cellwithTableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
