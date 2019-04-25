//
//  KGShoppingTrolleyCell.m
//  KEGONG
//
//  Created by JasonBourne on 2019/4/22.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "KGShoppingTrolleyCell.h"
#import "UIImageView+WebCache.h"

@interface KGShoppingTrolleyCell ()
@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *moneyLabel;
@property (nonatomic, weak) IBOutlet UIImageView *bgImage;
/** 选中按钮 */
@property (nonatomic, weak) IBOutlet UIImageView *selectedImage;
/** 购买数量 */
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;

@end

@implementation KGShoppingTrolleyCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"KGShoppingTrolleyCell";
    KGShoppingTrolleyCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    }
    return cell;
}

- (void)setModel:(KGShoppingTrolleyModel *)model
{
    _model = model;
    self.subTitleLabel.text = model.shopName;
    self.moneyLabel.text = [NSString stringWithFormat:@"¥%@", model.price];
    [self.bgImage sd_setImageWithURL:[NSURL URLWithString:model.shopImage]];
    self.numberLabel.text = model.amount;
    self.selectedImage.highlighted = model.isSelected;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size: 14];
    self.selectedImage.highlighted = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/** 加 */
- (IBAction)add
{
    if (!self.selectedImage.isHighlighted) {
        NSInteger number = [self.numberLabel.text integerValue];
        if (number == [self.model.shopCount integerValue]) return;
        number++;
        self.numberLabel.text = [NSString stringWithFormat:@"%ld", number];
        self.model.amount = self.numberLabel.text;
    }
}

/** 减 */
- (IBAction)move
{
    if (!self.selectedImage.isHighlighted) {
        NSInteger number = [self.numberLabel.text integerValue];
        if (number == 1) return;
        number--;
        self.numberLabel.text = [NSString stringWithFormat:@"%ld", number];
        self.model.amount = self.numberLabel.text;
    }
}

@end
