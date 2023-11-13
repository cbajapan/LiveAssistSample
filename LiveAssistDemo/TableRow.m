#import "TableRow.h"
#import "RowData.h"

@implementation TableRow {
    NSIndexPath *currentIndexPath;
}

__strong static NSMutableDictionary *rows = nil;

+ (void) initialize {
    rows = [NSMutableDictionary new];
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) loadRowData:(NSIndexPath *)indexPath items:(long) items {
    currentIndexPath = indexPath;
    
    UITextField *tf = (UITextField *)[[self contentView] viewWithTag:TXT_ID_TAG];
    UISwitch *sw = (UISwitch *)[[self contentView] viewWithTag:SWITCH_ID_TAG];
    UISlider *slider = (UISlider *)[[self contentView] viewWithTag:SLIDER_ID_TAG];
    UILabel *label = (UILabel *)[[self contentView] viewWithTag:LABEL_ID_TAG];
    
    NSString *labTxt = [NSString stringWithFormat:@"%ld",indexPath.section * items + indexPath.row];
    
    [label setText:labTxt];
    [tf setAccessibilityLabel:labTxt];
    
    RowData *populate = rows[indexPath];
    if (populate) {
        [tf setText:[populate text]];
        [sw setOn:[populate toggle]];
        [slider setValue:[populate slider]];
    } else {
        [tf setText:@""];
        [sw setOn:YES];
        [slider setValue:0.5f];
    }
}

- (void) prepareForReuse {
    UITextField *tf = (UITextField *)[[self contentView] viewWithTag:TXT_ID_TAG];
    UISwitch *sw = (UISwitch *)[[self contentView] viewWithTag:SWITCH_ID_TAG];
    UISlider *slider = (UISlider *)[[self contentView] viewWithTag:SLIDER_ID_TAG];
    
    RowData *rowToUpdate = [[RowData alloc] initWithText:[tf text] toggle:[sw isOn] slider:[slider value]];
    
    rows[currentIndexPath] = rowToUpdate;
}

@end
