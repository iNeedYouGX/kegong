//
//  KGMyClientCell.h
//  KEGONG
//
//  Created by JasonBourne on 2019/4/19.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KGMyClientCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *model;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
