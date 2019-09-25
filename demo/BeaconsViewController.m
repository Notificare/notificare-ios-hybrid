//
//  BeaconsViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 14/02/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "BeaconsViewController.h"
#import "NotificarePushLib.h"
#import "Definitions.h"
#import "AppDelegate.h"

@interface BeaconsViewController ()
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) UILabel * emptyMessage;
@property (nonatomic, strong) UIView * loadingView;

@end

@implementation BeaconsViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    [self setTitle:LS(@"title_beacons")];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS(@"section_item_about")];
    
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    [self setLoadingView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)]];
    
    
    [self setEmptyMessage:[[UILabel alloc] initWithFrame:CGRectMake(20, 0, [[UIScreen mainScreen] bounds].size.width - 40, [[UIScreen mainScreen] bounds].size.height)]];
    
    [[self emptyMessage] setText:LS(@"empty_beacons_text")];
    [[self emptyMessage] setFont:LATO_LIGHT_FONT(14)];
    [[self emptyMessage] setTextAlignment:NSTextAlignmentCenter];
    [[self emptyMessage] setNumberOfLines:2];
    [[self emptyMessage] setTextColor:MAIN_COLOR];
    
    [[self loadingView] setBackgroundColor:[UIColor whiteColor]];
    
    [self showEmptyView];
}


-(void)setupNavigationBar{
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:MAIN_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    [[self navigationItem] setRightBarButtonItem:nil];
    
    
}


-(void)reloadData{
    
    if ([[[self appDelegate] beacons] count] > 0) {
        [[self navSections] removeAllObjects];
        [[self navSections] addObject:[[self appDelegate] beacons]];
        [[self loadingView] removeFromSuperview];
        [[self tableView] reloadData];
    } else {
        [[self navSections] removeAllObjects];
        [[self tableView] reloadData];
        [self showEmptyView];
    }
    
}


-(void)showEmptyView{

    [[self loadingView] addSubview:[self emptyMessage]];
    [[self view] addSubview:[self loadingView]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    [self showEmptyView];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"beaconsReload" object:nil];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"beaconsReload"
                                                  object:nil];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self navSections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self navSections] objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BeaconCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    NotificareBeacon * item = (NotificareBeacon *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [item beaconName];
    cell.textLabel.font = LATO_FONT(14);
    
    //cell.detailTextLabel.text = [[item bea] objectForKey:@"message"];
    //cell.detailTextLabel.numberOfLines = 4;
    //cell.detailTextLabel.font = LATO_LIGHT_FONT(12);
    
    UIImageView * signalImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    
    if([[item beacon] proximity] == CLProximityImmediate){
        [signalImage setImage:[UIImage imageNamed:@"immediate"]];
    } else if ([[item beacon] proximity] == CLProximityNear) {
        [signalImage setImage:[UIImage imageNamed:@"near"]];
    } else if ([[item beacon] proximity] == CLProximityFar) {
        [signalImage setImage:[UIImage imageNamed:@"far"]];
    } else {
        [signalImage setImage:[UIImage imageNamed:@"unkown"]];
    }
    
    [signalImage setContentMode:UIViewContentModeCenter];
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [view addSubview:signalImage];
    [cell setAccessoryView:view];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;

}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return BEACONS_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.001;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.001;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    
}




-(void)back{
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
