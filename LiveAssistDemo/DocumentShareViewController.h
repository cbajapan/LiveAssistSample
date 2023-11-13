#import <UIKit/UIKit.h>

@import AssistSDK;

@interface DocumentShareViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDelegate,UIPickerViewDataSource,
AssistSDKConsumerDocumentDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *urlPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *contentPicker;
- (IBAction)consumerShareURL:(id)sender;
- (IBAction)consumerShareContent:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *urlToShare;

@end
