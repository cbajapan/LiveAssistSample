#import "ConnectionView.h"

@implementation ConnectionView {
    UILabel *statusText;
    UILabel *reconnectionInfo;
    UIButton *retryNow, *giveUp, *dismiss;
    bool dismissError;
    bool connected;
    int connectCnt;
    ASDKConnector *myConnector;
    NSError *reportedError;
    
    int myAttemptCnt, myMaxAttempts;
    float myInSeconds;
    NSTimer *updateRetry;
}

- (UIButton *) createButtonAt:(CGRect) rect text:(NSString *) text handler:(SEL) handler {
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    [button setFrame:rect];
    [button setTitle:text forState:UIControlStateNormal];
    button.userInteractionEnabled = YES;
    [button addTarget:self action:handler forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
- (instancetype) init {
    if (self = [super initWithFrame:CGRectMake(300, 300, 400, 200)]) {
        
        dismissError = false;
        connected = false;
        connectCnt = 0;
        
        statusText = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 300, 40)];
        reconnectionInfo = [[UILabel alloc] initWithFrame:CGRectMake(50, 80, 300 , 40)];
        
        [statusText setTextAlignment:UITextAlignmentCenter];
        [reconnectionInfo setTextAlignment:UITextAlignmentCenter];
        
        retryNow = [self createButtonAt:CGRectMake(10, 150, 120, 50) text:@"Retry Now" handler:@selector(doRetryNow:)];
        giveUp = [self createButtonAt:CGRectMake(140, 150, 120, 50) text:@"Give Up" handler:@selector(doGiveUp:)];
        dismiss = [self createButtonAt:CGRectMake(270, 150, 120, 50) text:@"Dismiss" handler:@selector(doDismiss:)];

        [self setHidden:YES];
        [self setBackgroundColor:[UIColor grayColor]];
        
        [self addSubview:statusText];
        [self addSubview:reconnectionInfo];
        [self addSubview:retryNow];
        [self addSubview:giveUp];
        [self addSubview:dismiss];
    }
    return self;
}

- (IBAction) doRetryNow:(id) sender {
    
    [self cancelUpdateTimer];
    
    [myConnector reconnect:2.0f];
}
- (IBAction) doGiveUp:(id) sender {
    [self cancelUpdateTimer];
    
    [myConnector terminate:reportedError];
}
- (IBAction) doDismiss:(id) sender {
    
    [self cancelUpdateTimer];
    
    [self setHidden:YES];
    if (!connected) {
        dismissError = true;
    }
}

- (void) reset {
    [self cancelUpdateTimer];
    
    [retryNow setHidden:NO];
    [giveUp setHidden:NO];
    [dismiss setHidden:NO];
    
    dismissError = false;
    connected = false;
    connectCnt = 0;
    
    [self setHidden:YES];
}

- (void) cancelUpdateTimer {
    if (updateRetry) {
        [updateRetry invalidate];
        updateRetry = nil;
    }
}

#pragma mark - ASDKConnectionStatusDelegate
- (void) onDisconnect:(NSError *) reason connector:(ASDKConnector *) connector {
    NSLog(@"Connection lost!!! %@", reason);
    
    reportedError = reason;
    
    [self cancelUpdateTimer];
    
    [retryNow setHidden:NO];
    [giveUp setHidden:NO];
    
    myConnector = connector;
    connected = false;
    if (!dismissError) {
        [self setHidden:NO];
        
        [statusText setText:@"Connection Lost!"];
    }
}

- (void) onConnect {
    NSLog(@"Connection established!!");
    [self cancelUpdateTimer];
    
    connected = true;
    [retryNow setHidden:YES];
    [giveUp setHidden:YES];
    
    if (connectCnt > 0) {
        [self setHidden:NO];
        [statusText setText:@"Connection re-established!"];
        [reconnectionInfo setText:@""];
    }
    connectCnt++;
    dismissError = false;
}

- (void) onTerminated:(NSError *) reason {
    
    [self cancelUpdateTimer];
    
    NSLog(@"Connection terminated! %@", reason);
    connected = false;

    if (reason.code == ASDKAssistSupportEnded) {
        [self setHidden:YES];
    }
    else {
        [self setHidden:NO];

        [statusText setText:@"Given up!"];
        [reconnectionInfo setText:@""];
    
        [retryNow setHidden:YES];
        [giveUp setHidden:YES];
    }
}

- (void) updateRetryTime {
    
    myInSeconds--;
    
    if (myInSeconds > 0.0) {
        [reconnectionInfo setText:[NSString stringWithFormat:@"Re-connecting in %.1f (%i of %i)", myInSeconds, myAttemptCnt, myMaxAttempts]];
    }
}

- (void) willRetry:(float) inSeconds attempt:(int) attempt of:(int) maxAttempts connector:(ASDKConnector *) connector {
    
    myInSeconds = inSeconds;
    myAttemptCnt = attempt;
    myMaxAttempts = maxAttempts;
    
    NSLog(@"Will attempt to re-connect in %f seconds (%i of %i)", inSeconds, attempt, maxAttempts);
    myConnector = connector;
    
    if (!dismissError) {
        [reconnectionInfo setText:[NSString stringWithFormat:@"Re-connecting in %.1f (%i of %i)", inSeconds, attempt, maxAttempts]];
        
        [self cancelUpdateTimer];
        
        updateRetry = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self
                                                            selector:@selector(updateRetryTime)
                                                            userInfo:nil
                                                            repeats:YES];
    }
}

@end
