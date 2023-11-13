#import "ShortCode.h"
#import "SupportParameters.h"

@import AssistSDK;

@implementation ShortCode

static float SHORTCODE_REQUEST_TIMEOUT = 4.0f;
static const NSString *TOKEN_ENDPOINT = @"/assistserver/shortcode/consumer?appkey=";
static const NSString *CREATE_SHORTCODE_ENDPOINT = @"/assistserver/shortcode/create";
static const NSInteger TOKEN_CREATE_FORBIDDEN = 403L;


+(void) fromServerUrl:(NSString *)serverUrl withSuccess:(void (^)(ShortCode *))success failure:(void (^)(NSError *))failure {
    ShortCode* shortcode = [[ShortCode alloc] init];
    NSURLRequest *shortCodeRequest =  [ShortCode createShortCodeRequestFromServerUrl:serverUrl];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *requestCodesession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:shortcode delegateQueue:Nil];
    
    
    NSURLSessionDataTask *creatCodeTask = [requestCodesession dataTaskWithRequest:shortCodeRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error) {
            failure(error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *dictonary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if(jsonError){
            failure(jsonError);
            return;
        }
        
        shortcode.shortCode = dictonary[@"shortCode"];
        [shortcode requestTokenFromServerUrl:serverUrl withSuccess:^{
            success(shortcode);
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    }];
    
    [creatCodeTask resume];
}


-(void) requestTokenFromServerUrl : (NSString*) serverUrl withSuccess : (void (^)(void)) success failure:(void (^)(NSError *))failure  {
    
    NSURLRequest *sessionTokenRequest = [self createSessionTokenRequestFromServerUrl:serverUrl];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *requestTokenSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:Nil];
    
    
    NSURLSessionDataTask *requestTokenTask =
    [requestTokenSession dataTaskWithRequest:sessionTokenRequest
                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error) {
            failure(error);
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger respCode = ((NSHTTPURLResponse *) response).statusCode;
            if (respCode == TOKEN_CREATE_FORBIDDEN) {
                failure(nil);
                return;
            }
        }
        NSError *jsonError = nil;
        NSDictionary *dictonary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if(jsonError) {
            failure(jsonError);
            return;
        }
        
        self->_cid = dictonary[@"cid"];
        self->_sessionToken = dictonary[@"session-token"];
        success();
    }
    ];
    
    [requestTokenTask resume];
}

-(NSURLRequest*) createSessionTokenRequestFromServerUrl : (NSString*) serverUrl {
    NSDictionary *serverInfo = [AssistSDK parseServerInfo:serverUrl];
    NSString *host = serverInfo[@"host"];
    NSString *scheme = serverInfo[@"scheme"];
    int port = [serverInfo[@"port"] intValue];
    NSString *getTokenUrl = [NSString stringWithFormat:@"%@://%@:%d%@%@", scheme, host, port, TOKEN_ENDPOINT,_shortCode];
    
    NSString *fullUrl = getTokenUrl;
    if ([SupportParameters auditName]) {
        fullUrl = [NSString stringWithFormat:@"%@&auditName=%@", getTokenUrl, [SupportParameters auditName]];
    }
    NSMutableURLRequest *tokenRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullUrl]];
    [tokenRequest setHTTPMethod:@"GET"];
    [tokenRequest setTimeoutInterval:SHORTCODE_REQUEST_TIMEOUT];
    [tokenRequest setHTTPShouldHandleCookies:NO];
    
    return tokenRequest;
}

+(NSURLRequest*) createShortCodeRequestFromServerUrl : (NSString*) serverUrl {
    NSDictionary *serverInfo = [AssistSDK parseServerInfo:serverUrl];
    NSString *host = serverInfo[@"host"];
    NSString *scheme = serverInfo[@"scheme"];
    int port = [serverInfo[@"port"] intValue];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d%@", scheme, host, port, CREATE_SHORTCODE_ENDPOINT];
    
    NSString *fullUrl = url;
    if ([SupportParameters auditName]) {
        fullUrl = [NSString stringWithFormat:@"%@?auditName=%@", url, [SupportParameters auditName]];
    }
    
    NSMutableURLRequest *shortCodeRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:fullUrl]];
    [shortCodeRequest setHTTPMethod:@"PUT"];
    [shortCodeRequest setTimeoutInterval:SHORTCODE_REQUEST_TIMEOUT];
    [shortCodeRequest setHTTPShouldHandleCookies:NO];
    
    return shortCodeRequest;
}


// WARNING YOU SHOULD NEVER ACCEPT TRUST ALL CERTIFICATES..
// READ THIS FOR MORE INFORMATION..
// http://www.cs.utexas.edu/~shmat/shmat_ccs12.pdf
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}


@end
