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

@end

@implementation ViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES];

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
        
        [self performSegueWithIdentifier:@"OnBoarding" sender:self];
    
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
    
    [[self view] addSubview:[self activityIndicatorView]];
    [[self activityIndicatorView]  startAnimating];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didFailLoadWithError %@", error);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [[self activityIndicatorView]  stopAnimating];
    [[self activityIndicatorView] removeFromSuperview];
    
    [webView stringByEvaluatingJavaScriptFromString:@"$('.menuMobileContent > .menu').first().append('<a href=\"codept://code.pt/inbox\">INBOX</a>');"];
    
}


/**
 * Listen to clicks or events with known URL schemes
 */
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ([[[Configuration shared] getArray:@"nativeViews"] containsObject:[request URL]]) {
        
        [[self appDelegate] handleDeepLinks:[request URL]];
        
        return NO;
    }
    
    return YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
