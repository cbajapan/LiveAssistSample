#import <Foundation/Foundation.h>

@interface RowData : NSObject
- (id) initWithText:(NSString *) text toggle:(BOOL) toggle slider:(float) slider;

@property (nonatomic, retain) NSString *text;
@property (assign) BOOL toggle;
@property (assign) float slider;
@end
