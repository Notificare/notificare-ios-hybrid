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

    [self setActivityIndicatorView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    [[self activityIndicatorView] setHidden:YES];
    [[self activityIndicatorView]  setCenter:CGPointMake( self.view.frame.size.width/2 + 10, self.view.frame.size.height /2 + 10)];
    [[self activityIndicatorView]  setContentMode:UIViewContentModeCenter];
    
    [[[self webView] scrollView] setContentInset:UIEdgeInsetsMake(22, 0, 0, 0)];
    [[[self webView] scrollView] setBackgroundColor:[UIColor whiteColor]];
    [[self webView] setBackgroundColor:[UIColor whiteColor]];
    
    UIView * statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 22)];
    [statusBar setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:statusBar];
    
    
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

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [[self activityIndicatorView]  stopAnimating];
    [[self activityIndicatorView] removeFromSuperview];
    
    //[[self webView] stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0.0, 110.0)"];
    
}

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx
{
    NSLog(@"%@", ctx);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
