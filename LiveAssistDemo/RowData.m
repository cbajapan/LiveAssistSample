#import "RowData.h"

@implementation RowData

- (id) initWithText:(NSString *) text  toggle:(BOOL) toggle slider:(float) slider {
    
    if (self = [super init]) {
        _text = text;
        _slider = slider;
        _toggle = toggle;
    }
    return self;
}
@end
