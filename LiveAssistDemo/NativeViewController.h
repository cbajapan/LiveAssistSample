#import <UIKit/UIKit.h>

@interface NativeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
- (IBAction)stepperValueChanged:(id)sender;

- (IBAction)changeSensitiveMaskingSetting:(id)sender;
@end
