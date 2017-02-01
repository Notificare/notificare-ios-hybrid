//
//  ViewController.m
//  demo
//
//  Created by Joel Oliveira on 18/12/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Configuration.h"
#import "ResetPasswordViewController.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIWebView * webView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, strong) NSURL * targetUrl;
@property (nonatomic, strong) NSString * token;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation ViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self evaluateJS];  
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openInbox) name:@"openInbox" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSettings) name:@"openSettings" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openRegions) name:@"openRegions" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSignIn) name:@"openSignIn" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSignUp) name:@"openSignUp" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openProfile) name:@"openProfile" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openResetPassword:) name:@"openResetPassword" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openCustomEvents) name:@"openCustomEvents" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAssets) name:@"openAssets" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadURL:) name:@"reloadURL" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInitialConfig) name:@"initialConfig" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewNotification) name:@"newNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertWithMessage:) name:@"showAlertWithMessage" object:nil];

}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openInbox"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openSettings"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openRegions"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openSignIn"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openSignUp"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openProfile"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openResetPassword"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openCustomEvents"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openAssets"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"reloadURL"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"initialConfig"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"newNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"showAlertWithMessage"
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self setActivityIndicatorView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    [[self activityIndicatorView] setHidden:YES];
    [[self activityIndicatorView]  setCenter:CGPointMake( self.view.frame.size.width/2 + 10, self.view.frame.size.height /2 + 10)];
    [[self activityIndicatorView]  setContentMode:UIViewContentModeCenter];
    
    UIView * statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 22)];
    [statusBar setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:statusBar];

    [[self view]  setBackgroundColor:[UIColor whiteColor]];

}

-(void)onInitialConfig{
    //Is it first time?
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if(![settings boolForKey:@"OnBoardingFinished"]){
        
        [[self navigationController] performSegueWithIdentifier:@"OnBoarding" sender:self];
        
    }
    
    [self goToUrl];
}


-(void)goToUrl{
    
    if (![self targetUrl]) {
        [self setTargetUrl:[NSURL URLWithString:[[Configuration shared] getProperty:@"url"]]];
    }
    
    NSURLRequest *nsRequest=[NSURLRequest requestWithURL:[self targetUrl]];
    [[self webView] loadRequest:nsRequest];

}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    
    [self setIsLoading:YES];
    
    [[self view] addSubview:[self activityIndicatorView]];
    [[self activityIndicatorView]  startAnimating];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError %@", error);
    
    [self setIsLoading:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [[self activityIndicatorView]  stopAnimating];
    [[self activityIndicatorView] removeFromSuperview];
    
    [self setIsLoading:NO];
    
    [self performSelector:@selector(evaluateJS) withObject:nil afterDelay:1.0];
    
}


/**
 * Listen to clicks or events with known URL schemes
 */
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ([[[Configuration shared] getArray:@"nativeViews"] containsObject:[request URL]]) {
        
        [[self appDelegate] handleDeepLinks:[request URL]];
        
        return NO;
        
    } else if (![[[request URL] host] isEqualToString:[[NSURL URLWithString:[[Configuration shared] getProperty:@"url"]] host]] && ![self isLoading]) {
    
        [[UIApplication sharedApplication] openURL:[request URL] options:@{} completionHandler:^(BOOL success) {
            
        }];
        return NO;
    }
    
    return YES;
    
}

-(void)evaluateJS{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(evaluateJS)
                                               object:nil];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    NSString * badge = @"";
    
    if ( [[NotificarePushLib shared] myBadge] ) {
       badge = [NSString stringWithFormat:@"%i", [[NotificarePushLib shared] myBadge]];
    }
    
    [[self webView] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:[settings objectForKey:@"customJSFile"], badge]];
}

-(void)onNewNotification {
    [self evaluateJS];
}

-(void)openInbox{
    [self performSegueWithIdentifier:@"Inbox" sender:self];
}

-(void)openSettings{
    [self performSegueWithIdentifier:@"Settings" sender:self];
}

-(void)openRegions{
    [self performSegueWithIdentifier:@"Regions" sender:self];
}

-(void)openSignIn{
    [self performSegueWithIdentifier:@"SignIn" sender:self];
}

-(void)openSignUp{
    [self performSegueWithIdentifier:@"SignUp" sender:self];
}

-(void)openProfile{
    [self performSegueWithIdentifier:@"Profile" sender:self];
}

-(void)openCustomEvents{
    
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle: APP_NAME
                                  message:LS(@"register_custom_event")
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = LS(@"type_event_name");
    }];

    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:LS(@"send")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             
                             if([[[alert textFields][0] text] length] == 0 ){
                                 [self presentAlertViewForForm:LS(@"error_custom_event_name")];
                             } else {
                                 [[NotificarePushLib shared] logCustomEvent:[[alert textFields][0] text] withData:nil completionHandler:^(NSDictionary * _Nonnull info) {
                                     [self presentAlertViewForForm:LS(@"success_custom_event")];
                                 } errorHandler:^(NSError * _Nonnull error) {
                                     [self presentAlertViewForForm:LS(@"error_custom_event")];
                                 }];
                             }
                             
                         }];
    [alert addAction:ok];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:LS(@"cancel")
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action){}];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{

        
    }];

    
}

-(void)openAssets{
    [self performSegueWithIdentifier:@"Assets" sender:self];
}

-(void)reloadURL:(NSNotification*)notification{
    [self setTargetUrl:[[notification userInfo] objectForKey:@"url"]];
    [self goToUrl];
}

-(void)openResetPassword:(NSNotification *) notification
{
    [self setToken:[[notification userInfo] valueForKey:@"token"]];
    [self performSegueWithIdentifier:@"ResetPassword" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ResetPassword"])
    {
        ResetPasswordViewController *vc = [segue destinationViewController];
        [vc setToken:[self token]];
    }
}


-(void)showAlertWithMessage:(NSNotification *)notification
{
    [self presentAlertViewForForm:[[notification userInfo] valueForKey:@"message"]];
}

-(void)presentAlertViewForForm:(NSString *)message{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle: APP_NAME
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:LS(@"ok")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){}];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
