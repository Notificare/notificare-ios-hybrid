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

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIWebView * webView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, strong) NSURL * targetUrl;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation ViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openInbox) name:@"openInbox" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSettings) name:@"openSettings" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadURL:) name:@"reloadURL" object:nil];
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
                                                    name:@"reloadURL"
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
    
    NSString * file = [[NSBundle mainBundle] pathForResource:@"customScripts" ofType:@"js"];
    NSString * jsString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    [[self webView] stringByEvaluatingJavaScriptFromString:jsString];
}


-(void)openInbox{
    [self performSegueWithIdentifier:@"Inbox" sender:self];
}

-(void)openSettings{
    [self performSegueWithIdentifier:@"Settings" sender:self];
}

-(void)reloadURL:(NSNotification*)notification{
    [self setTargetUrl:[[notification userInfo] objectForKey:@"url"]];
    [self goToUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
