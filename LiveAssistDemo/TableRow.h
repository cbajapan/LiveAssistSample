#import <UIKit/UIKit.h>

#define LABEL_ID_TAG 1000
#define TXT_ID_TAG 1001
#define SLIDER_ID_TAG 1002
#define SWITCH_ID_TAG 1003

@interface TableRow : UITableViewCell

- (void) loadRowData:(NSIndexPath *)indexPath items:(long) items;

@end
