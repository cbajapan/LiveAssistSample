#import <Foundation/Foundation.h>

@interface ShortCode : NSObject<NSURLSessionDelegate>

@property NSString *shortCode;
@property (readonly) NSString *cid;
@property (readonly) NSString *sessionToken;

+(void) fromServerUrl : (NSString*) serverUrl withSuccess : (void (^)(ShortCode *shortCode)) success failure: (void (^)(NSError *error)) failureBlock;

@end
