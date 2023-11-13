#import "TabViewController.h"
#import "HTTPSConnectionHandler.h"
#import "SupportParameters.h"
#import "DynamicMasker.h"
#import "ShortCode.h"
#import "ConnectionView.h"

static NSString * const StartSupportTitle = @"Share my screen with the support agent";
static NSString * const StartSupportMessage = @"";
static NSString * const AssistCallMessage = @"Call support and then share";
static NSString * const ShortCodeMessage = @"Already on a call, want to share";
static NSString * const CancelMessage = @"I don't need help";
static NSString * const ShortCodeTitle = @"Quote the following code to your support agent";
static NSString * const DismissMessage = @"I don't need help";
static NSString * const StartSupportSelectorStr = @"startSupport:";

static float const FromRightHandSide = 200.0f;
static float const FromBottom = 80.0f;
static float const EndSupportTextWidth = 160.0f;
static float const EndSupportTextHeight = 40.0f;

/*!
 * Change this to true if want to use re-connection API
*/
static bool const ReconnectListening = false;

#define CXLA_DEFAULT_ICON_IMAGE @"black"


@implementation TabViewController {
    UIAlertController *shortCodePresenter;
    NSDictionary *supportParameters;
    NSSet *maskedTags;
    UIButton *liveAssistButton;
    UIButton *endSupportButton;
    
    ConnectionView *connectView;
}

- (void) enableLiveAssistButton {
    NSArray *actions = [liveAssistButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    
    if (![actions containsObject:StartSupportSelectorStr]) {
        NSLog(@"Enabling live support button.");
        [liveAssistButton addTarget:self action:@selector(startSupport:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        NSLog(@"Button already enabled.");
    }
}

- (void) disableLiveAssistButton {
    NSArray *actions = [liveAssistButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside];
    
    if ([actions containsObject:StartSupportSelectorStr]) {
        NSLog(@"Disabling live support button.");
        [liveAssistButton removeTarget:self action:@selector(startSupport:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        NSLog(@"Button already disabled.");
    }

}

- (void) setEndShortCodeSupportButtonPosition {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    endSupportButton.frame = CGRectMake(screenSize.width - FromRightHandSide, screenSize.height - FromBottom, EndSupportTextWidth, EndSupportTextHeight);
}

- (void) viewDidLayoutSubviews {
    [self setEndShortCodeSupportButtonPosition];
}

- (void) addEndShortCodeSupportButton {
    endSupportButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [endSupportButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [endSupportButton.layer setBorderWidth:2.0f];
    
    [endSupportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [endSupportButton setBackgroundColor:[UIColor whiteColor]];
    
    [endSupportButton addTarget:self
               action:@selector(endShortCodeSupport:)
     forControlEvents:UIControlEventTouchUpInside];
    [endSupportButton setTitle:@"End Support" forState:UIControlStateNormal];
    
    [self setEndShortCodeSupportButtonPosition];
    [self hideEndSupportButton];
    
    [self.view addSubview:endSupportButton];
}

- (void) showEndSupportButton {
    endSupportButton.hidden = NO;
}

- (void) hideEndSupportButton {
    endSupportButton.hidden = YES;
}

- (IBAction) endShortCodeSupport:(id) sender {
    NSLog(@"Ending short code support");
    [self hideEndSupportButton];
    [self enableLiveAssistButton];
    [AssistSDK endSupport];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the delegate here in case of "auto start"
    [AssistSDK addDelegate:self];

    maskedTags = [NSSet setWithObjects:[NSNumber numberWithInteger:500], [NSNumber numberWithInteger:501],
                  [NSNumber numberWithInteger:502], [NSNumber numberWithInteger:503],
                  [NSNumber numberWithInteger:504], [NSNumber numberWithInteger:505],
                  [NSNumber numberWithInteger:506],
                   nil];
    
    [DynamicMasker createWithHiddenTags:[[NSSet alloc] init] maskedTags:maskedTags];
    
    NSString *imageName = [SupportParameters iconImage];
    
    connectView = [[ConnectionView alloc] init];
    
    supportParameters = [SupportParameters userDefaults];
    
    NSString *useIcon = [NSString stringWithFormat:@"%@.png",imageName];
    
    UIImage *iconImage = [UIImage imageNamed:useIcon];
    
    if (iconImage == nil) {
        //Image file not found
        UIAlertController *alert = [self createAlertForTitle:@"Icon Image Not Found" message:@"The Assist icon image configured in Settings was not found. Using default icon image."];
        [self presentViewController:alert animated:YES completion:nil];
        imageName = CXLA_DEFAULT_ICON_IMAGE;
        useIcon = [NSString stringWithFormat:@"%@.png", imageName];
        iconImage = [UIImage imageNamed:useIcon];
    }
    
    liveAssistButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [liveAssistButton setImage: iconImage forState: UIControlStateNormal];
    [liveAssistButton setImage: iconImage forState: UIControlStateHighlighted];
    
    [self enableLiveAssistButton];
    
    [self addEndShortCodeSupportButton];
    
    [liveAssistButton setFrame: CGRectMake(10, 10, 100, 100)];
    //Added to make button draggable
    liveAssistButton.userInteractionEnabled = YES;
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(buttonDragged:)];
    [liveAssistButton addGestureRecognizer:gesture];
    //end added to make button draggable
    [self.view addSubview: liveAssistButton];
    
    [self.view addSubview:connectView];
    
    // Set user agent (the only problem is that we can't modify the User-Agent later in the program)
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Safari/528.16", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
    [self setupOpenUrlDelegate];

}


-(void) setupOpenUrlDelegate {
    AppDelegate *delegate =   (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.openUrlDelegate = self;
}


//button draggable code
- (void)buttonDragged:(UIPanGestureRecognizer *)gesture
{
    UILabel *button = (UILabel *)gesture.view;
    CGPoint translation = [gesture translationInView:button];
    
    // move label
    button.center = CGPointMake(button.center.x + translation.x,
                                button.center.y + translation.y);
    
    // reset translation
    [gesture setTranslation:CGPointZero inView:button];
}

// Present either the short code or error message if not supplied.
- (void) presentShortCodeResult:(NSString *)shortCode {
    NSString *message = (shortCode)?[NSString stringWithFormat:@"%@", shortCode] : @"An error occurred obtaining the Code!";
    
    UIAlertController *presenter = [UIAlertController alertControllerWithTitle:ShortCodeTitle
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
    
    if (shortCode) {
        UIFont *font = [UIFont systemFontOfSize:20.0f];
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        NSMutableAttributedString *shortCodeMessage = [[NSMutableAttributedString alloc] initWithString:message attributes:attributes];
        [presenter setValue:shortCodeMessage forKey:@"attributedMessage"];
    }
    else {
        [presenter setTitle:message];
    }
    // Store as want to dismiss when agent joins.
    shortCodePresenter = presenter;
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:DismissMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self enableLiveAssistButton];
        [presenter dismissViewControllerAnimated:YES completion:nil];
        
        [self->connectView reset];
        self->shortCodePresenter = nil;
        [self hideEndSupportButton];
        [AssistSDK endSupport];
    }];
    
    [presenter addAction:dismiss];
    
    [self presentViewController:presenter animated:YES completion:nil];
}

-(void) requestShortCode {
     NSString *serverUrl = [SupportParameters serverHost];
    
     [ShortCode fromServerUrl:serverUrl withSuccess:^(ShortCode *shortCode) {
 

         NSDictionary *shortCodeParameters =
        [self shortCodeParametersWithCorrelationId:shortCode.cid sessionToken:shortCode.sessionToken];
        
         dispatch_async(dispatch_get_main_queue(), ^{
             [self showEndSupportButton];
             [self presentShortCodeResult:shortCode.shortCode];
             [self startLiveAssistWithSupportParameters:shortCodeParameters];
         });
         
    } failure:^(NSError *error) {
        [self presentShortCodeResult:nil];
    }];
}

// The main entry point for audio/video and Short Code Assist calls.
- (IBAction) startSupport:(id) sender {
    
    // Present an alert view where one can choose whether to make a normal live assist
    // support call, optionally specifying the correlationId, or to do this after requesting
    // a short-code (that can be given to the agent).

    UIAlertController *chooseSupport = [UIAlertController alertControllerWithTitle:StartSupportTitle
                                                                           message:StartSupportMessage
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *assistCall = [UIAlertAction actionWithTitle:AssistCallMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [chooseSupport dismissViewControllerAnimated:YES completion:nil];
        [self startLiveAssistWithSupportParameters:[SupportParameters userDefaults]];
        
    }];
    
    [chooseSupport addAction:assistCall];
    
    UIAlertAction *shortCodeShare = [UIAlertAction actionWithTitle:ShortCodeMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [chooseSupport dismissViewControllerAnimated:YES completion:nil];
        [self requestShortCode];
    }];
    
    [chooseSupport addAction:shortCodeShare];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:CancelMessage style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [chooseSupport dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [chooseSupport addAction:cancel];
    
    [self presentViewController:chooseSupport animated:YES completion:nil];
}

- (void) startLiveAssistWithSupportParameters : (NSDictionary*) parameters {
    NSString *server = [SupportParameters serverHost];
    
    [self disableLiveAssistButton];
    
    [connectView reset];
    
    NSLog(@"Starting with server %@ with parameters %@", server,parameters);

    // Add the delegate here to assign it to any subsequent support sessions.
    [AssistSDK addDelegate:self];
    [AssistSDK startSupport:server supportParameters:parameters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In this demo app, automatically accept the screen share request.
// By default, the iOS SDK will present a dialog requesting whether the user wishes to
// accept the screen share request or not. By:
// 1) Conforming to ASDKScreenShareRequestedDelegate;
// 2) Calling, prior to starting support,
//       config[@"screenShareRequestedDelegate"] = self;    // or whatever class conforms to the protocol;
// 3) Implementing assistSDKScreenShareRequested,
// the application can override this behaviour.
- (void) assistSDKScreenShareRequested:(void (^)(void))allow deny:(void (^)(void))deny {
    
    NSLog(@"Request for screen share called.");
    
    // If a short code is being presented, dismiss it.
    if (shortCodePresenter) {
        [shortCodePresenter dismissViewControllerAnimated:YES completion:nil];
        shortCodePresenter = nil;
    }
    
    allow();    // OR deny() if want to automatically reject all screen share requests.
}


-(NSDictionary *) shortCodeParametersWithCorrelationId : (NSString *) correlationId sessionToken : (NSString*) sessionToken {
    NSMutableDictionary *shortCodeParameters = [[NSMutableDictionary alloc] initWithDictionary:[SupportParameters userDefaults]];
    
    shortCodeParameters[@"sessionToken"] = sessionToken;
    shortCodeParameters[@"correlationId"] = correlationId;
    shortCodeParameters[@"screenShareRequestedDelegate"] = self;
    [shortCodeParameters removeObjectForKey:@"destination"];
    shortCodeParameters[@"acceptSelfSignedCerts"] = @YES;
    shortCodeParameters[@"auditName"] = @"Consumer (iOS)";
    
    if (ReconnectListening)
    {
        shortCodeParameters[@"connectionDelegate"] = connectView;
        shortCodeParameters[@"retryIntervals"] = @[@2.0, @5.0, @10.0, @15.0];
        shortCodeParameters[@"initialConnectionTimeout"] = [NSNumber numberWithFloat:2.0f];
        shortCodeParameters[@"maxReconnectTimeouts"] = @[@1.0f];
    }
    return shortCodeParameters;
}


#pragma mark - AssistSDKDocumentDelegate

/**
 * The following 3 methods are deprecated.
 * Use the onError, onOpened and onClosed methods.
 */
//- (void) assistSDKDidOpenDocument:(NSNotification*)notification {
//    NSLog(@"   DOCUMENT OPENED FROM CONSUMER!!!!!");
//}
//- (void) assistSDKUnableToOpenDocument:(NSNotification*)notification {
//    NSLog(@"   DOCUMENT OPEN FAILED FROM CONSUMER!!!!!");
//}
//- (void) assistSDKDidCloseDocument:(NSNotification*)notification {
//    NSLog(@"   DOCUMENT CLOSED FROM CONSUMER!!!!!");
//}


- (void) onError:(ASDKSharedDocument *)document reason:(NSString *)reasonStr {
    NSLog(@"There was an error sharing the document %@ because %@", document.url, reasonStr);
}

- (void) onClosed:(ASDKSharedDocument *)document by:(AssistSDKDocumentCloseInitiator) whom {
    NSLog(@"Document %@ closed by %@", document.url, (whom==AssistSDKDocumentClosedByAgent)?@"agent":(whom==AssistSDKDocumentClosedByConsumer)?@"consumer":@"support ended");
}

- (void) onOpened:(ASDKSharedDocument *)document {
    NSLog(@"Document %@ opened. Metadata is %@.", document.url, document.metadata);
}

-(void) openWithUrl:(NSURL *)url {
    NSError *shareError = [AssistSDK shareDocumentNSUrl:url delegate:self];
    if (shareError != nil) {
        NSLog(@"%@", shareError);
    }
}

- (void) supportCallDidEnd{
    NSLog(@"Your support call has ended.");
    [self enableLiveAssistButton];
}

- (void) assistSDKDidEncounterError:(NSNotification*)notification {

    [self reportError:[notification object]];
    [self enableLiveAssistButton];
    [self hideEndSupportButton];
}

-(void) reportError : (NSError*) error {
 
    NSLog(@"Got error %@", error);
    
    UIAlertController *alert = nil;
    
    switch (error.code) {
        case ASDKERRMicrophoneNotAuthorized:
        case ASDKERRCameraNotAuthorized:
            alert = [self createAlertForTitle:@"Permission Error" message:@"Please authorise your camera / microphone"];
            break;
        case ASDKERRAssistSessionCreationFailure:
            alert = [self createAlertForTitle:@"Session Failure" message:@"A session could not be initiated."];
            break;
        case ASDKERRCalleeNotFound:
        case ASDKERRCalleeBusy:
            alert = [self createAlertForTitle:@"No agents available" message:@"There are currently no agents available. Please try again."];
            break;
        default:
            break;
    }

    if (alert) {
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (UIAlertController *)createAlertForTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    return alert;
}


@end
