//
//  InboxViewController.m
//  demo
//
//  Created by Joel Oliveira on 20/12/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "InboxViewController.h"
#import "NotificarePushLib.h"
#import "Definitions.h"
#import "NSDate+TimeAgo.h"

@interface InboxViewController ()
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) IBOutlet UIView * loadingScreen;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) UILabel * emptyMessage;
@property (nonatomic, strong) UIView * loadingView;
@property (nonatomic, strong) UIActivityIndicatorView * spinnerView;
@property (nonatomic, strong) NSDictionary * notification;
@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:LS(@"title_inbox")];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS(@"section_item_about")];
    
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeInbox)];
    [leftButton setTintColor:MAIN_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];

    [self reloadData];
    
}


-(void)setupNavigationBar{
    
    if([self navSections] &&
       [[self navSections] count] > 0 &&
       [[[self navSections] objectAtIndex:0] count] > 0){
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeInbox)];
        [leftButton setTintColor:MAIN_COLOR];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
        [[self navigationItem] setRightBarButtonItem:self.editButtonItem];
        
    } else {
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close"] style:UIBarButtonItemStylePlain target:self action:@selector(closeInbox)];
        [leftButton setTintColor:MAIN_COLOR];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
        [[self navigationItem] setRightBarButtonItem:nil];
        
    }
    
    
}


-(void)reloadData{
    
    [[NotificarePushLib shared] fetchInbox:nil skip:[NSNumber numberWithInt:0] limit:[NSNumber numberWithInt:100] completionHandler:^(NSDictionary *info) {
        
        if([[info objectForKey:@"inbox"] count] == 0){
            [[self navSections] addObject:@[]];
            [[self spinnerView] removeFromSuperview];
            [[self emptyMessage] setHidden:NO];
        } else {
            [[self navSections] removeAllObjects];
            [[self navSections] addObject:[info objectForKey:@"inbox"]];
            [[self loadingView] removeFromSuperview];
        }
        
        [[self tableView] reloadData];
        [self setupNavigationBar];
        
    } errorHandler:^(NSError *error) {
        [[self navSections] removeAllObjects];
        [[self navSections] addObject:@[]];
        [[self tableView] reloadData];
         [self setupNavigationBar];
    }];
    
}


-(void)showEmptyView{
    [self setLoadingView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)]];
    
    [self setEmptyMessage:[[UILabel alloc] initWithFrame:CGRectMake(20, 0, [[UIScreen mainScreen] bounds].size.width - 40, [[UIScreen mainScreen] bounds].size.height)]];
    
    [self setSpinnerView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    self.spinnerView.center = CGPointMake(CGRectGetMidX([[UIScreen mainScreen] bounds]), CGRectGetMidY([[UIScreen mainScreen] bounds]));
    
    [[self emptyMessage] setText:LS(@"empty_inbox_text")];
    [[self emptyMessage] setFont:LATO_HAIRLINE_FONT(14)];
    [[self emptyMessage] setTextAlignment:NSTextAlignmentCenter];
    [[self emptyMessage] setNumberOfLines:2];
    [[self emptyMessage] setHidden:YES];
    
    [[self loadingView] setBackgroundColor:[UIColor whiteColor]];
    [[self loadingView] addSubview:[self emptyMessage]];
    [[self loadingView] addSubview:[self spinnerView]];
    [[self view] addSubview:[self loadingView]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self showEmptyView];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"newNotification" object:nil];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"newNotification"
                                                  object:nil];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self navSections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self navSections] objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"InboxCell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InboxCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    NotificareDeviceInbox * item = (NotificareDeviceInbox *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    
    cell.textLabel.text = [item message];
    cell.textLabel.numberOfLines = 4;
    cell.textLabel.font = LATO_FONT(14);
    
    NSArray* arrayDate = [[item time] componentsSeparatedByString: @"."];
    NSString* dateString = [arrayDate objectAtIndex: 0];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSDate * time = [dateFormat dateFromString:dateString];
    
    UILabel * date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [date setText:[time timeAgo]];
    [date setTextAlignment:NSTextAlignmentRight];
    [date setFont:LATO_LIGHT_FONT(11)];
    [cell setAccessoryView:date];
    
    if([item opened]){
        cell.textLabel.textColor = [UIColor grayColor];
        //[label setTextColor:[UIColor grayColor]];
        [date setTextColor:[UIColor grayColor]];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = LATO_FONT(14);
        [date setTextColor:[UIColor blackColor]];
    }
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return INBOX_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NotificareDeviceInbox * item = (NotificareDeviceInbox *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NotificarePushLib shared] openInboxItem:item];
        
    }];
    
}


-(void)clearInbox{
    
    [[NotificarePushLib shared] clearInbox:^(NSDictionary *info) {
        
        [[self navSections] removeAllObjects];
        [[self navSections] addObject:@[]];
        [[self tableView] reloadData];
        
    } errorHandler:^(NSError *error) {
        
    }];
    
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [[self tableView] setEditing:editing animated:YES];
    
    if(editing){
        UIBarButtonItem * clearButton = [[UIBarButtonItem alloc] initWithTitle:LS(@"clear_all") style:UIBarButtonItemStylePlain target:self action:@selector(clearInbox)];
        [[self navigationItem] setLeftBarButtonItem:clearButton];
    } else {
        [self setupNavigationBar];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NotificareDeviceInbox * item = (NotificareDeviceInbox *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        
        [[NotificarePushLib shared] removeFromInbox:item completionHandler:^(NSDictionary *info) {
            //
            
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[[self navSections] objectAtIndex:0] removeObject:item];
            [tableView endUpdates];
            
        } errorHandler:^(NSError *error) {
            //
        }];
        
    }
}


-(void)closeInbox{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
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
