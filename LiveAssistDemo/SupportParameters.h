#import <UIKit/UIKit.h>

@interface SupportParameters : UIViewController

+ (NSDictionary *)userDefaults;
//+ (NSDictionary*)getSupportParametersFromUserDefaultsWithcorrelationId : (NSString*) correlationId;
+(BOOL) isAutoStartSession;
+(NSString*) serverHost;
+(NSString*) websiteAddress;
+(NSString*) iconImage;
+ (NSString *)auditName;

@end
