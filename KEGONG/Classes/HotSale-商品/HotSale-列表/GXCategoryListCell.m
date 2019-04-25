//
//  GXCategoryListCell.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/18.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "GXCategoryListCell.h"
#import "UIImageView+WebCache.h"

@interface GXCategoryListCell ()
/** 实付 */
@property (nonatomic, weak) IBOutlet UILabel *realPayLabel;
/** 名字 */
@property (nonatomic, weak) IBOutlet UILabel *goodsName;
/** 实付 */
@property (nonatomic, weak) IBOutlet UILabel *pointLabel;
/** 图片 */
@property (nonatomic, weak) IBOutlet UIImageView *bigImage;
@end

@implementation GXCategoryListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"GXCategoryListCell";
    GXCategoryListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)setModel:(NSDictionary *)model
{
    _model = model;
    self.goodsName.text = model[@"gname"];
    self.realPayLabel.text = [NSString stringWithFormat:@"¥%@", model[@"price"]];
    [self.bigImage sd_setImageWithURL:[NSURL URLWithString:[KGIMAGEURL stringByAppendingPathComponent:model[@"thumbnail"]]]];
    NSString *status = [NSString stringWithFormat:@" ¥%@", model[@"tagprice"]];
    self.pointLabel.attributedText = [status addStrikethroughWithRange:[status rangeOfString:status]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
