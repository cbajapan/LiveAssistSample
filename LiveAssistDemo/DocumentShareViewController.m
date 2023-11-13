#import "DocumentShareViewController.h"

@implementation DocumentShareViewController {
    NSMutableArray *contentData;
    NSArray *urlData;
    NSString *contentSelected;
}

- (void) viewDidLoad {
    [self setupContentPickerView];
    [self setupUrlPickerView];
    
    [self.urlToShare setText:urlData[0]];
}

-(void) setupContentPickerView {
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSError *error;
    NSArray *resources = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];

    if (error != nil) {
        NSLog(@"Got error reading Resource bundle!");
    } else {
        if ([resources count]  >0) {
            contentData = [[NSMutableArray alloc] initWithCapacity:[resources count]];
            for (NSString *resource in resources) {
                if ([resource hasPrefix:@"Resource_"]) {
                    [contentData addObject:[resource substringWithRange:NSMakeRange(9, resource.length - 9)]];
                }
            }
            contentSelected = contentData[0];
        }
    }
    
    self.contentPicker.dataSource = self;
    self.contentPicker.delegate = self;
}

-(void) setupUrlPickerView {
    urlData = @[@"http://developer.apple.com",
                @"https://developer.apple.com/support/"];
    
    self.urlPicker.dataSource = self;
    self.urlPicker.delegate = self;
}


-  (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.urlPicker) {
        return [urlData count];
    }
    return [contentData count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.urlPicker) {
        return urlData[row];
    }
    return contentData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.urlPicker) {
        [self.urlToShare setText:urlData[row]];
    } else {
        contentSelected = contentData[row];
    }
}

#pragma mark - AssistSDKConsumerDocumentDelegate
- (void) onError:(ASDKSharedDocument *)document reason:(NSString *)reasonStr {
    NSLog(@"There was an error sharing the document %@ because %@", document.url, reasonStr);
}

- (void) onClosed:(ASDKSharedDocument *)document by:(AssistSDKDocumentCloseInitiator) whom {
    NSLog(@"Document %@ closed by %@", document.url, (whom==AssistSDKDocumentClosedByAgent)?@"agent":(whom==AssistSDKDocumentClosedByConsumer)?@"consumer":@"support ended");
}

- (void) logShareError:(NSError *) error {
    if (error != nil) {
        NSLog(@"%@", error);
    }
}

- (IBAction)consumerShareURL:(id)sender {
    
    NSURL *url = [[NSURL alloc] initWithString:self.urlToShare.text];
    
    NSError *shareError = [AssistSDK shareDocumentNSUrl:url delegate:self];
    [self logShareError:shareError];
}

- (IBAction)consumerShareContent:(id)sender {
    NSString *extension = [contentSelected pathExtension];
    NSString *resourceName = [[NSString stringWithFormat:@"Resource_%@",contentSelected] stringByDeletingPathExtension];
    NSURL *resourceUrl = [[NSBundle mainBundle] URLForResource:resourceName withExtension:extension];
    
    NSError *shareError = [AssistSDK shareDocumentNSUrl:resourceUrl delegate:self];
    [self logShareError:shareError];
}
@end