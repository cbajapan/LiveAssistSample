#import "WebViewController.h"
#import "SupportParameters.h"

@import AssistSDK;

@interface WebViewController ()

@property IBOutlet WKWebView *webview;
@property (nonatomic, retain) IBOutlet UIImageView *backButton;
@property (nonatomic, retain) IBOutlet UIImageView *forwardButton;
@property (nonatomic, retain) IBOutlet UIImageView *refreshButton;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)forwardButtonPressed:(id)sender;
- (IBAction)refreshButtonPressed:(id)sender;

@end

@implementation WebViewController


- (void) viewDidLoad {
    
    self.webview.navigationDelegate = self;
}


- (void) viewWillAppear:(BOOL)animated {
    NSURL* nsUrl = [NSURL URLWithString:[SupportParameters websiteAddress]];
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.webview loadRequest:request];
}

- (IBAction)backButtonPressed:(id)sender {
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }
}

- (IBAction)forwardButtonPressed:(id)sender {
    if ([self.webview canGoForward]) {
        [self.webview goForward];
    }
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self.webview reload];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

@end
