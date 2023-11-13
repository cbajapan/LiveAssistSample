#import "SupportParameters.h"
#import "DynamicMasker.h"
static const NSString * const AUDIT_NAME = @"Consumer (iOS)";
static const NSString * const AUDIT_NAME_KEY = @"auditName";

@implementation SupportParameters

+ (NSDictionary*)userDefaults {
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];

    parameters[@"acceptSelfSignedCerts"] = @YES;
    
    [SupportParameters setDictonaryKey:@"destination"
                          forDictonary:&parameters
                      fromDefaultValue:@"targettedAgent"];
    
    [SupportParameters setDictonaryKey:@"username"
                          forDictonary:&parameters
                      fromDefaultValue:@"username"];
    
    [SupportParameters setDictonaryKey:@"correlationId"
                          forDictonary:&parameters
                      fromDefaultValue:@"correlationId"];

    NSString *correlationId = parameters[@"correlationId"];

    parameters[@"uui"] = [SupportParameters hexadecimalCodeForString:correlationId];
    
    if([parameters[@"destination"] length] == 0){
        [parameters removeObjectForKey:@"destination"];
    }
    
    NSSet *maskedTags = [[DynamicMasker sharedInstance] maskedTags];
    if (maskedTags && [maskedTags count] >0) {
        parameters[@"maskingTags"] = maskedTags;
        parameters[@"maskColor"] = [UIColor blueColor];
    }
    
    parameters[AUDIT_NAME_KEY] = [SupportParameters auditName];
    
    return parameters;
}

+ (NSString *)hexadecimalCodeForString : (NSString *) string {
    NSMutableString *hexCode = nil;
    
    if (string && string.length > 0) {
        const char *utf8 = [string UTF8String];
        hexCode = [NSMutableString string];
        while (*utf8) {
            [hexCode appendFormat:@"%02X", *utf8++ & 0x00FF];
        }
    }
    
    return hexCode;
}



+ (BOOL)isAutoStartSession {
  NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
  return [settings boolForKey:@"autostart"];
}

+ (NSString*)serverHost {
  return [SupportParameters getSettingForKey:@"serverAddress"];
}

+ (NSString*)websiteAddress {
  return [SupportParameters getSettingForKey:@"websiteAddress"];
}

+ (NSString*)iconImage {
  return [SupportParameters getSettingForKey:@"iconImage"];
}

+ (NSString *)auditName {
    return [AUDIT_NAME stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (NSString*)getSettingForKey:(NSString*)key {
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  NSString* setting = [userDefaults stringForKey:key];
  if (setting == nil || [setting length] == 0) {
    NSLog(@"WARNING %@ configuration is empty", key);
  }
  return setting;
}

+ (void)setDictonaryKey:(NSString*)key
           forDictonary:(NSMutableDictionary**) dictonaryReference
                       fromDefaultValue:(NSString*)defaultValue {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dictonary = *dictonaryReference;
    
    NSString* stringValue = [settings stringForKey:defaultValue];
    
    if (stringValue && ([stringValue length] > 0)) {
        dictonary[key] = stringValue;
    }
    
}

@end
