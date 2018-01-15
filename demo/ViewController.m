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
#import <SafariServices/SafariServices.h>

@interface ViewController ()

@property (nonatomic, strong) WKWebView * webView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, strong) UIView * launchingView;
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMemberCard) name:@"openMemberCard" object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openCustomEvents) name:@"openCustomEvents" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadURL:) name:@"reloadURL" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInitialConfig) name:@"initialConfig" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewNotification) name:@"newNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertWithMessage:) name:@"showAlertWithMessage" object:nil];


}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openMemberCard"
                                                  object:nil];
    

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"openCustomEvents"
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
    
    [self setWebView:[[WKWebView alloc] initWithFrame:CGRectMake(0, 22, self.view.frame.size.width, self.view.frame.size.height - 22) configuration:[WKWebViewConfiguration new]]];
    
    [[[self webView] scrollView] setBounces:NO];
    [[self webView] setNavigationDelegate:self];
    [[self view] addSubview:[self webView]];
    
    [self setLaunchingView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)]];
    UIImageView * logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [logo setImage:[UIImage imageNamed:@"logo"]];
    [logo setContentMode:UIViewContentModeCenter];
    
    [[self launchingView] addSubview:logo];
    [[self view] addSubview:[self launchingView]];

    NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                    WKWebsiteDataTypeDiskCache,
                                                    //WKWebsiteDataTypeOfflineWebApplicationCache,
                                                    WKWebsiteDataTypeMemoryCache,
                                                    //WKWebsiteDataTypeLocalStorage,
                                                    //WKWebsiteDataTypeCookies,
                                                    //WKWebsiteDataTypeSessionStorage,
                                                    //WKWebsiteDataTypeIndexedDBDatabases,
                                                    //WKWebsiteDataTypeWebSQLDatabases
                                                    ]];
    //// All kinds of data
    //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    //// Date from
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    //// Execute
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        // Done
    }];
    
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self webView] loadRequest:nsRequest];
    });

}


-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler{
    
    if ([[[Configuration shared] getArray:@"nativeViews"] containsObject:[[[navigationAction request] URL] absoluteString]]) {
        
        [[self appDelegate] handleDeepLinks:[[navigationAction request] URL]];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        
    } else {
        if (!navigationAction.targetFrame.isMainFrame && [[[[navigationAction request] URL] host] isEqualToString:[[NSURL URLWithString:[[Configuration shared] getProperty:@"url"]] host]] ) {
            
            SFSafariViewController * sfController = [[SFSafariViewController alloc] initWithURL:[[navigationAction request] URL]];
            [self presentViewController:sfController animated:YES completion:^{
                
            }];
            
            decisionHandler(WKNavigationActionPolicyCancel);
            
        } else {
            
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
    
}

-(void)webView:(WKWebView *)webView didFailLoadWithError:(nonnull NSError *)error{
    NSLog(@"didFailLoadWithError %@", error);
    [self setIsLoading:NO];
}


-(void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    
    [[self activityIndicatorView]  stopAnimating];
    [[self activityIndicatorView] removeFromSuperview];
    
    [self setIsLoading:NO];
    
    [[self launchingView] removeFromSuperview];
    
    
    [self performSelector:@selector(evaluateJS) withObject:nil afterDelay:1.0];
}

-(void)evaluateJS{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if ([settings objectForKey:@"customJSFile"]) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(evaluateJS)
                                                   object:nil];
        
        NSString * badge = @"";
        
        if ( [[[NotificarePushLib shared] inboxManager] myBadge] && [[[NotificarePushLib shared] inboxManager] myBadge] > 0) {
            badge = [NSString stringWithFormat:@"%i", [[[NotificarePushLib shared] inboxManager] myBadge]];
        }
        
        [[self webView] evaluateJavaScript:[NSString stringWithFormat:[settings objectForKey:@"customJSFile"], badge] completionHandler:^(id result, NSError * _Nullable error) {
            //
        }];
    }
    
    /*
     
     THIS CAN BE USED FOR THE INITIAL CONFIG, JUST ADD A customScripts.js FILE
     
     [NSObject cancelPreviousPerformRequestsWithTarget:self
     selector:@selector(evaluateJS)
     object:nil];
     
     NSString * file = [[NSBundle mainBundle] pathForResource:@"customScripts" ofType:@"js"];
     NSString * jsString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
     
     NSString * badge = @"";
     
     if ( [[NotificarePushLib shared] myBadge]) {
     badge = [NSString stringWithFormat:@"%i", [[NotificarePushLib shared] myBadge]];
     }
     
     [[self webView] evaluateJavaScript:[NSString stringWithFormat:[settings objectForKey:@"customJSFile"], badge] completionHandler:^(id result, NSError * _Nullable error) {
     //
     }];
     */
}

-(void)onNewNotification {
    [self evaluateJS];
}



-(void)openSignUp{
    [self performSegueWithIdentifier:@"SignUp" sender:self];
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
                                 
                                 [[NotificarePushLib shared] logCustomEvent:[[alert textFields][0] text] withData:nil completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
                                     if (!error) {
                                         [self presentAlertViewForForm:LS(@"success_custom_event")];
                                     } else {
                                         [self presentAlertViewForForm:LS(@"error_custom_event")];
                                     }
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

-(void)openMemberCard{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if([settings objectForKey:@"memberCardSerial"]){
    
        NSString * url = [NSString stringWithFormat:@"https://push.notifica.re/pass/pkpass/%@", [settings objectForKey:@"memberCardSerial"]];
        NSURL *passbookUrl = [NSURL URLWithString:url];
        NSData *data = [[NSData alloc] initWithContentsOfURL:passbookUrl];
        NSError *error;
        
        //init a pass object with the data
        PKPass * pass = [[PKPass alloc] initWithData:data error:&error];
        
        if(!error){
            
            //present view controller to add the pass to the library
            PKAddPassesViewController * vc = [[PKAddPassesViewController alloc] initWithPass:pass];
            
            [vc setDelegate:self];
            
            [self presentViewController:vc animated:YES completion:^{
                //
            }];
            
        } else {
            [self presentAlertViewForForm:[error localizedDescription]];
        }

        
    } else {
        [self presentAlertViewForForm:LS(@"error_no_serial_found")];
    }
}


-(void)reloadURL:(NSNotification*)notification{
    [self setTargetUrl:[[notification userInfo] objectForKey:@"url"]];
    [self goToUrl];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

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
