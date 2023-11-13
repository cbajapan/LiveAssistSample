#import "NativeViewController.h"
#import "TableRow.h"
#import "DynamicMasker.h"

long const RowCnt = 25L;
long const ScrollViewTag = 600L;
long const StepperValTag = 700L;

NSString * const WebShareUrl = @"http://developer.apple.com";
NSString * const WebShareContent = @"Resource_10276-KB-WebRTC";
int const ScrollContentMax = 25;

@implementation NativeViewController

- (void) addScrollViewContents {
    UIScrollView *scrollView = [self.view viewWithTag:ScrollViewTag];
    
    scrollView.scrollEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, ScrollContentMax * 30);
    
    for (int idx = 0; idx < ScrollContentMax; idx++) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0,idx * 30, scrollView.frame.size.width, 30)];
        
        [lab setText:[NSString stringWithFormat:@"Scroll View Content %d", idx]];
        
        [scrollView addSubview:lab];
    }
}

- (void) viewDidLoad {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self addScrollViewContents];
    
    [[DynamicMasker sharedInstance] storeHiddenOrMaskedViews:[self.view subviews]];
    
    [[DynamicMasker sharedInstance] setHidingAndMasking:false];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RowCnt;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Table View";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableRow *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    [cell loadRowData:indexPath items:RowCnt];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0f;
}

- (IBAction)stepperValueChanged:(id)sender {
    UILabel *val = [self.view viewWithTag:StepperValTag];
    
    [val setText:[NSString stringWithFormat:@"%.f", _stepper.value]];
}

- (IBAction)changeSensitiveMaskingSetting:(id)sender {
    UISwitch *maskSwitch = (UISwitch *)sender;
    
    [[DynamicMasker sharedInstance] setHidingAndMasking:[maskSwitch isOn]?true:false];
}

@end
