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
    
    if (@available(iOS 13.0, *)) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    [self setTitle:LS(@"title_inbox")];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS(@"section_item_about")];
    
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [[self navigationItem] setLeftBarButtonItem:leftButton];

    [self reloadData];

}


-(void)setupNavigationBar{
    
    if([self navSections] &&
       [[self navSections] count] > 0 &&
       [[[self navSections] objectAtIndex:0] count] > 0){
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        [leftButton setTintColor:[UIColor whiteColor]];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
        [[self editButtonItem] setTintColor:[UIColor whiteColor]];
        [[self editButtonItem] setTitleTextAttributes:@{NSFontAttributeName:PROXIMA_NOVA_REGULAR_FONT(14)} forState:UIControlStateNormal];
        [[self editButtonItem] setTitle:LS(@"edit_button")];
        [[self navigationItem] setRightBarButtonItem:self.editButtonItem];
        
    } else {
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        [leftButton setTintColor:[UIColor whiteColor]];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
        [[self navigationItem] setRightBarButtonItem:nil];
        
    }
    
    
}


-(void)reloadData{
    
    [[[NotificarePushLib shared] inboxManager] fetchInbox:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if([response count] == 0){
                [[self navSections] addObject:@[]];
                [[self spinnerView] removeFromSuperview];
                [[self emptyMessage] setHidden:NO];
            } else {
                [[self navSections] removeAllObjects];
                [[self navSections] addObject:response];
                [[self loadingView] removeFromSuperview];
            }

            [[self tableView] reloadData];
            [self setupNavigationBar];
        } else {
            [[self navSections] removeAllObjects];
            [[self navSections] addObject:@[]];
            [[self tableView] reloadData];
            [self setupNavigationBar];
        }
    }];
    
}


-(void)showEmptyView{
    [self setLoadingView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)]];
    
    [self setEmptyMessage:[[UILabel alloc] initWithFrame:CGRectMake(20, 0, [[UIScreen mainScreen] bounds].size.width - 40, [[UIScreen mainScreen] bounds].size.height)]];
    
    [self setSpinnerView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    self.spinnerView.center = CGPointMake(CGRectGetMidX([[UIScreen mainScreen] bounds]), CGRectGetMidY([[UIScreen mainScreen] bounds]));
    
    [[self emptyMessage] setText:LS(@"empty_inbox_text")];
    [[self emptyMessage] setTextColor:MAIN_COLOR];
    [[self emptyMessage] setFont:PROXIMA_NOVA_THIN_FONT(14)];
    [[self emptyMessage] setTextAlignment:NSTextAlignmentCenter];
    [[self emptyMessage] setNumberOfLines:2];
    [[self emptyMessage] setHidden:NO];
    
    [[self loadingView] setBackgroundColor:[UIColor whiteColor]];
    [[self loadingView] addSubview:[self emptyMessage]];
    [[self loadingView] addSubview:[self spinnerView]];
    [[self view] addSubview:[self loadingView]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
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
    
    NotificareDeviceInbox * item = (NotificareDeviceInbox *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    static NSString *cellIdentifier = @"InboxCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel *title, *date;
    UIImageView *img;
    UITextView * message;
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        img = [[UIImageView alloc] initWithFrame:CGRectMake(10, ((INBOX_CELLHEIGHT / 2) / 2), (INBOX_CELLHEIGHT / 2) , (INBOX_CELLHEIGHT / 2) )];
        [img setContentMode:UIViewContentModeScaleAspectFill];
        [img setClipsToBounds:YES];
        [img setImage:[UIImage imageNamed:@"noAttachment"]];
        [img setTag:102];
        
        date = [[UILabel alloc] initWithFrame:CGRectMake((INBOX_CELLHEIGHT / 2) + 20, 8, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 20)];
        [date setFont:PROXIMA_NOVA_THIN_FONT(12)];
        [date setTag:100];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake((INBOX_CELLHEIGHT / 2) + 20, 25, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 20)];
        [title setFont:PROXIMA_NOVA_BOLD_FONT(14)];
        [title setTag:101];
        
        message = [[UITextView alloc] initWithFrame:CGRectMake((INBOX_CELLHEIGHT / 2) + 20, 37, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 80)];
        [message setFont:PROXIMA_NOVA_THIN_FONT(14)];
        [message setBackgroundColor:[UIColor clearColor]];
        message.textContainer.lineFragmentPadding = 0;
        [message setScrollEnabled:NO];
        [message setUserInteractionEnabled:NO];
        [message setTag:103];
        
        [[cell contentView] addSubview:title];
        [[cell contentView] addSubview:date];
        [[cell contentView] addSubview:message];
        [[cell contentView] addSubview:img];
        
    }
    
    title = (UILabel *)[cell.contentView viewWithTag:101];
    img = (UIImageView *)[cell.contentView viewWithTag:102];
    message = (UITextView *)[cell.contentView viewWithTag:103];
    date = (UILabel *)[cell.contentView viewWithTag:100];

    
    if ([item title] && [[item title] length] > 0) {
        [title setText:[item title]];
    } else {
        [title setText:@""];
    }
    
    [message setText:[item message]];
    
    [img setImage:[UIImage imageNamed:@"noAttachment"]];
    
    if ([item attachment] && [[item attachment] objectForKey:@"uri"]) {
        
        [img setHidden:NO];
        
        [date setFrame:CGRectMake((INBOX_CELLHEIGHT / 2) + 20, 8, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 20)];
         [title setFrame:CGRectMake((INBOX_CELLHEIGHT / 2) + 20, 25, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 20)];
         if ([item title]) {
            [message setFrame:CGRectMake((INBOX_CELLHEIGHT / 2) + 20, 37, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 80)];
        } else {
            [message setFrame:CGRectMake((INBOX_CELLHEIGHT / 2) + 20, 17, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 80)];
        }
        
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            NSURL *imageURL = [NSURL URLWithString:[[item attachment] objectForKey:@"uri"]];
            
            NotificareNetworkHost *notificareNetworkHost = [[NotificareNetworkHost alloc] initWithHostName:[imageURL host]
                                                                                                  isSecure:[[imageURL scheme] isEqualToString:@"https"]];
            [notificareNetworkHost setDefaultCachePolicy:NSURLRequestUseProtocolCachePolicy];
            
            NotificareNetworkOperation *imageOperation = [notificareNetworkHost operationWithHTTPMethod:@"GET" withPath:[imageURL path]];
            
            [imageOperation setSuccessHandler:^(NotificareNetworkOperation *operation) {
                [img setImage:[operation responseDataToImage]];
                [cell setNeedsLayout];
            }];
            
            [imageOperation setErrorHandler:^(NotificareNetworkOperation *operation, NSError *error) {
                NSLog(@"Notificare Loading Image: %@",error);
            }];
            
            [imageOperation buildRequest];
            
            [notificareNetworkHost startOperation:imageOperation];
        }
        
    } else {
        [img setHidden:YES];
        
        [date setFrame:CGRectMake(10, 8, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 20)];
        [title setFrame:CGRectMake(10, 25, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 20)];
        if ([item title] && [[item title] length] > 0) {
           [message setFrame:CGRectMake(10, 37, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 80)];
        } else {
           [message setFrame:CGRectMake(10, 17, self.view.frame.size.width - ((INBOX_CELLHEIGHT / 2) + 30), 80)];
        }
    }

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDate * utcDate = [dateFormat dateFromString:[item time]];
    
    //Make it Europe/Amsterdam
    [dateFormat setDateFormat:@"MMM dd, yyyy"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Amsterdam"]];
    
    [date setText:[NSString stringWithFormat:@"%@",[dateFormat stringFromDate:utcDate]]];
    
    
    if([item opened]){
        [title setTextColor:[UIColor grayColor]];
        [message setTextColor:[UIColor grayColor]];
        [date setTextColor:[UIColor grayColor]];
        [img setAlpha:.5];
    } else {
        [title setTextColor:[UIColor blackColor]];
        [message setTextColor:[UIColor blackColor]];
        [date setTextColor:[UIColor blackColor]];
        [img setAlpha:1];
    }
    
    [cell setNeedsLayout];
    
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    return cell;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return INBOX_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.001;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.001;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NotificareDeviceInbox * item = (NotificareDeviceInbox *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    [item setOpened:YES];
    [[self tableView] reloadData];
    
    [[[NotificarePushLib shared] inboxManager] openInboxItem:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            
            if ([response isKindOfClass:[UIViewController class]]) {
                UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
                [leftButton setTintColor:[UIColor whiteColor]];
                [[response navigationItem] setLeftBarButtonItem:leftButton];
            }
            
            [[NotificarePushLib shared] presentInboxItem:item inNavigationController:[self navigationController] withController:response];
            
        }
    }];
    
}   


-(void)clearInbox{
    
    [[[NotificarePushLib shared] inboxManager] clearInbox:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [[self navSections] removeAllObjects];
            [[self navSections] addObject:@[]];
            [[self tableView] reloadData];
            [self showEmptyView];
        }
    }];
    
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [[self tableView] setEditing:editing animated:YES];
    
    if(editing){
        UIBarButtonItem * clearButton = [[UIBarButtonItem alloc] initWithTitle:LS(@"clear_all") style:UIBarButtonItemStylePlain target:self action:@selector(clearInbox)];
        [clearButton setTintColor:[UIColor whiteColor]];
        [clearButton setTitleTextAttributes:@{NSFontAttributeName:PROXIMA_NOVA_REGULAR_FONT(14)} forState:UIControlStateNormal];
        [[self editButtonItem] setTitle:LS(@"done_button")];
        [[self navigationItem] setLeftBarButtonItem:clearButton];
        
    } else {
        [self setupNavigationBar];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NotificareDeviceInbox * item = (NotificareDeviceInbox *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        [[[NotificarePushLib shared] inboxManager] removeFromInbox:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
//            if (!error) {
//                [tableView beginUpdates];
//                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                [[[self navSections] objectAtIndex:0] removeObject:item];
//                [tableView endUpdates];
//
//                if ([[[self navSections] objectAtIndex:0] count] == 0) {
//                    [self showEmptyView];
//                }
//            }
        }];
    }
}

-(void)startDownloadInboxItemImage:(NSIndexPath*)indexPath{
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView * img = (UIImageView *)[cell.contentView viewWithTag:102];
    
    NotificareDeviceInbox * item = (NotificareDeviceInbox *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    if ([item attachment] && [[item attachment] objectForKey:@"uri"]) {
        NSURL *imageURL = [NSURL URLWithString:[[item attachment] objectForKey:@"uri"]];
        
        NotificareNetworkHost *notificareNetworkHost = [[NotificareNetworkHost alloc] initWithHostName:[imageURL host]
                                                                                              isSecure:[[imageURL scheme] isEqualToString:@"https"]];
        [notificareNetworkHost setDefaultCachePolicy:NSURLRequestUseProtocolCachePolicy];
        
        NotificareNetworkOperation *imageOperation = [notificareNetworkHost operationWithHTTPMethod:@"GET" withPath:[imageURL path]];
        
        [imageOperation setSuccessHandler:^(NotificareNetworkOperation *operation) {
            [img setImage:[operation responseDataToImage]];
        }];
        
        [imageOperation setErrorHandler:^(NotificareNetworkOperation *operation, NSError *error) {
            NSLog(@"Notificare Loading Image: %@",error);
        }];
        
        [imageOperation buildRequest];
        
        [notificareNetworkHost startOperation:imageOperation];
    }
}

- (void)loadImagesForOnscreenRows{
    
    if (self.navSections.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            [self startDownloadInboxItemImage:indexPath];
        }
    }
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//    scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//    scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


-(void)back{
    
    [[self navigationController] popViewControllerAnimated:YES];
    
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
