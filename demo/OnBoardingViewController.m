//
//  OnBoardingViewController.m
//  demo
//
//  Created by Joel Oliveira on 19/12/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "OnBoardingViewController.h"
#import "NotificarePushLib.h"
#import "Definitions.h"

@implementation NSString (StripXMLTags)

- (NSString *)stripXMLTags
{
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>\\s*" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end

@interface OnBoardingViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;
@property (nonatomic, strong) NSMutableArray * images;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (assign, nonatomic) BOOL pageControlUsed;

@end

@implementation OnBoardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    [self setPageControlUsed:YES];
    
    [self setImages:[NSMutableArray new]];
    
    [[self scrollView] setPagingEnabled:YES];
    [[self scrollView] setShowsHorizontalScrollIndicator:NO];
    [[self scrollView] setShowsVerticalScrollIndicator:NO];
    [[self scrollView] setScrollsToTop:NO];
    [[self scrollView] setDelegate:self];
    [[self scrollView] setBackgroundColor:[UIColor whiteColor]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadOnBoarding) name:@"onReady" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadOnBoarding{
    
    [[NotificarePushLib shared] fetchAssets:@"ONBOARDING" completionHandler:^(NSArray * _Nonnull info) {
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * [info count], self.scrollView.bounds.size.height);
        
  
        for (NotificareAsset * asset in info) {
           
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];

            NSMutableDictionary * assetObj = [NSMutableDictionary new];

            NSURL *imageURL = [NSURL URLWithString:[asset assetUrl]];
            
            
            NotificareNetworkHost *notificareNetworkHost = [[NotificareNetworkHost alloc] initWithHostName:[imageURL host]
                                                                                                  isSecure:[[imageURL scheme] isEqualToString:@"https"]];
            [notificareNetworkHost setDefaultCachePolicy:NSURLRequestUseProtocolCachePolicy];
            
            
            NotificareNetworkOperation *imageOperation = [notificareNetworkHost operationWithHTTPMethod:@"GET" withPath:[imageURL path]];
            
            [imageOperation setSuccessHandler:^(NotificareNetworkOperation *operation) {
                
                [imageView setImage:[operation responseDataToImage]];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
      
            }];
            
            [imageOperation setErrorHandler:^(NotificareNetworkOperation *operation, NSError *error) {
                
                NSLog(@"Notificare Loading Image: %@",error);
            }];
            
            [imageOperation buildRequest];
            
            [notificareNetworkHost startOperation:imageOperation];
            
            
            [assetObj setObject:imageView forKey:@"assetView"];
            [assetObj setObject:[asset assetTitle] forKey:@"assetTitle"];
            [assetObj setObject:[asset assetDescription] forKey:@"assetDescription"];
            [assetObj setObject:[asset assetButton] forKey:@"assetButton"];
            [assetObj setObject:[asset assetMetaData] forKey:@"assetMetaData"];
            [[self images] addObject:assetObj];
            
        }
        
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
        
        [[self pageControl] setNumberOfPages:[[self images] count]];
        [[self pageControl] setCurrentPage:0];

        
    } errorHandler:^(NSError * _Nonnull error) {
        //
    }];
}


- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if ([self pageControlUsed]) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [[self pageControl] setCurrentPage:page];
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setPageControlUsed:NO];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setPageControlUsed:NO];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0){
        return;
    }
    if (page >= [[self images] count]){
        return;
    }
    
    
    
    // replace the placeholder if necessary
    UIImageView * imageview = [[[self images] objectAtIndex:page] objectForKey:@"assetView"];
    [imageview setBackgroundColor:[UIColor whiteColor]];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width - 40, 120)];
    [label setFont:LATO_LIGHT_FONT(20)];
    [label setTextColor:[UIColor blackColor]];
    [label setNumberOfLines:0];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:[[[self images] objectAtIndex:page] objectForKey:@"assetTitle"]];

    NSDictionary * buttonObj = [[[self images] objectAtIndex:page] objectForKey:@"assetButton"];
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width - 40, 48)];
    [button.titleLabel setFont:LATO_FONT(20)];
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button setBackgroundColor:[UIColor redColor]];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button setTitle:[buttonObj objectForKey:@"label"] forState:UIControlStateNormal];
    
    SEL mySelector = NSSelectorFromString([buttonObj objectForKey:@"action"]);
    
    [button addTarget:self action:mySelector forControlEvents:UIControlEventTouchUpInside];
    
    if ((NSNull *)imageview == [NSNull null]) {
        [[self images] replaceObjectAtIndex:page withObject:imageview];
    }
    
    // add the controller's view to the scroll view
    if (imageview != nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        imageview.frame = frame;
        //label.frame = frame;
        
        
        CGRect labelFrame = label.frame;
        labelFrame.origin.x = self.scrollView.frame.size.width * page + 20;
        labelFrame.origin.y = self.scrollView.frame.size.height - 220;
        label.frame = labelFrame;
        
        CGRect buttonFrame = button.frame;
        buttonFrame.origin.x = self.scrollView.frame.size.width * page + 20;
        buttonFrame.origin.y = self.scrollView.frame.size.height - 100;
        button.frame = buttonFrame;
        
        
        [[self scrollView] addSubview:imageview];
        [[self scrollView] addSubview:label];
        [[self scrollView] addSubview:button];
    }
    
    
}

-(void)goToNotifications{

    [[self pageControl] setCurrentPage:1];
    [self loadScrollViewWithPage:1];
    [self loadScrollViewWithPage:2];
    [[self scrollView] setContentOffset:CGPointMake(self.scrollView.frame.size.width * 1, 0) animated:YES];
    
}

-(void)goToLocationServices{

    [[self pageControl] setCurrentPage:2];
    [self loadScrollViewWithPage:2];
    [self loadScrollViewWithPage:3];
    [[self scrollView] setContentOffset:CGPointMake(self.scrollView.frame.size.width * 2, 0) animated:YES];
    
    [[NotificarePushLib shared] registerForNotifications];
}

-(void)goToApp{

    [[NotificarePushLib shared] startLocationUpdates];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setBool:YES forKey:@"OnBoardingFinished"];
        [settings synchronize];
        
    }];
}

@end
