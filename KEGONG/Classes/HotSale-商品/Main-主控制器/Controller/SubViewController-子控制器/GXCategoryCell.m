//
//  GXCategoryCell.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/17.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "GXCategoryCell.h"

@interface GXCategoryCell ()
/** 标题 */
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
/** 小方块 */
@property (nonatomic, weak) IBOutlet UIView *smallView;
@end

@implementation GXCategoryCell

+ (instancetype)cellwithTableView:(UITableView *)tableView
{
    static NSString *ID = @"GXCategoryCell";
    GXCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)setModel:(CZHotTitleModel *)model
{
    _model = model;
    self.titleLabel.text = model.gtname;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 14];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = CZGlobalLightGray;
    self.smallView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor = CZGlobalWhiteBg;
        self.smallView.hidden = NO;
    } else {
        self.contentView.backgroundColor = CZGlobalLightGray;
        self.smallView.hidden = YES;
    }

}

@end
