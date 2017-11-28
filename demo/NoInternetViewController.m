//
//  NoInternetViewController.m
//  demo
//
//  Created by Joel Oliveira on 20/12/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "NoInternetViewController.h"
#import "Definitions.h"

@interface NoInternetViewController ()
@property (nonatomic, strong) UILabel * noNetworkText;
@end

@implementation NoInternetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNoNetworkText:[[UILabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 80, self.view.frame.size.width - 40, 80)]];
    [[self noNetworkText] setText:LS(@"no_network_text")];
    [[self noNetworkText] setTextAlignment:NSTextAlignmentCenter];
    [[self noNetworkText] setFont:LATO_FONT(14)];
    [[self noNetworkText] setNumberOfLines:2];
    
    [[self view] addSubview:[self noNetworkText]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
