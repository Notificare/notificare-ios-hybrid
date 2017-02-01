//
//  SettingsViewController.m
//  demo
//
//  Created by Joel Oliveira on 20/12/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "SettingsViewController.h"
#import "NotificarePushLib.h"
#import "Definitions.h"
#import "Configuration.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"

@interface SettingsViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) IBOutlet UIView * loadingScreen;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) UIDatePicker * startPicker;
@property (nonatomic, strong) UIDatePicker * endPicker;
@property (strong, nonatomic) MFMailComposeViewController *mailComposer;



#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)


@end

@implementation SettingsViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:LS(@"title_settings")];

    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:MAIN_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewBecameActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

-(void)viewBecameActive{
    
    //[self performSelector:@selector(refreshView) withObject:nil afterDelay:.5];
    [self refreshView];
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    [self refreshView];
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}



-(void)refreshView{
    
    
    [[self navSections] removeAllObjects];
    [[self sectionTitles] removeAllObjects];
    
    [[self sectionTitles] addObject:LS(@"section_item_settings_notifications")];
    NSMutableArray * section1 = [NSMutableArray array];
    [section1 addObject:@{@"label":LS(@"settings_notifications_title"), @"segue":@"", @"description":LS(@"settings_notifications_description")}];
    
    if ([[[Configuration shared] getDictionary:@"config"] objectForKey:@"useLocationServices"]) {
        
        [section1 addObject:@{@"label":LS(@"settings_notifications_location_services"), @"segue":@"", @"description":LS(@"settings_notifications_location_services_description")}];
        
    }
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        
        
        [[[NotificarePushLib shared] notificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            //
            
            if ([settings authorizationStatus] == UNNotificationSettingEnabled) {
                
                
                [[NotificarePushLib shared] fetchDoNotDisturb:^(NSDictionary *info) {
                    //
                    
                    if([info objectForKey:@"start"] && [info objectForKey:@"end"]){
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"HH:mm"];
                        NSString *startTime = [dateFormatter stringFromDate:[info objectForKey:@"start"]];
                        NSString *endTime = [dateFormatter stringFromDate:[info objectForKey:@"end"]];
                        
                        
                        [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_description"), @"value":@"true"}];
                        
                        [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times_start"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_start_description"), @"value":startTime}];
                        
                        [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times_end"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_end_description"), @"value":endTime}];
                        
                    } else {
                        [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_description"), @"value":@"false"}];
                    }
                    
                    
                    
                    [[self navSections] addObject:section1];
                    
                    
                    [[self sectionTitles] addObject:LS(@"section_item_settings_about")];
                    NSMutableArray * section2 = [NSMutableArray array];
                    [section2 addObject:@{@"label":LS(@"settings_feedback"), @"segue":@"Feedback"}];
                    [section2 addObject:@{@"label":LS(@"settings_app_version"), @"segue":@""}];
                    [[self navSections] addObject:section2];
                    
                    [[self tableView] reloadData];
                    
                } errorHandler:^(NSError *error) {
                    //
                }];
                
                
                
            } else {
                
                
                [[self navSections] addObject:section1];
                
                [[self sectionTitles] addObject:LS(@"section_item_settings_about")];
                NSMutableArray * section2 = [NSMutableArray array];
                [section2 addObject:@{@"label":LS(@"settings_feedback"), @"segue":@"Feedback"}];
                [section2 addObject:@{@"label":LS(@"settings_app_version"), @"segue":@""}];
                [[self navSections] addObject:section2];
                
                [[self tableView] reloadData];
                
            }
            
            
        }];
        
        
        
    } else {
        
        
        if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
            
            [[self navSections] addObject:section1];
            
            [[self sectionTitles] addObject:LS(@"section_item_settings_about")];
            NSMutableArray * section2 = [NSMutableArray array];
            [section2 addObject:@{@"label":LS(@"settings_feedback"), @"segue":@"Feedback"}];
            [section2 addObject:@{@"label":LS(@"settings_app_version"), @"segue":@""}];
            [[self navSections] addObject:section2];
            
            [[self tableView] reloadData];
            
        } else {
            
            
            [[NotificarePushLib shared] fetchDoNotDisturb:^(NSDictionary *info) {
                //
                
                if([info objectForKey:@"start"] && [info objectForKey:@"end"]){
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"HH:mm"];
                    NSString *startTime = [dateFormatter stringFromDate:[info objectForKey:@"start"]];
                    NSString *endTime = [dateFormatter stringFromDate:[info objectForKey:@"end"]];
                    
                    
                    [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_description"), @"value":@"true"}];
                    
                    [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times_start"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_start_description"), @"value":startTime}];
                    
                    [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times_end"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_end_description"), @"value":endTime}];
                    
                } else {
                    [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_description"), @"value":@"false"}];
                }
                
                
                [[self navSections] addObject:section1];
                
                
                [[self sectionTitles] addObject:LS(@"section_item_settings_about")];
                NSMutableArray * section2 = [NSMutableArray array];
                [section2 addObject:@{@"label":LS(@"settings_feedback"), @"segue":@"Feedback"}];
                [section2 addObject:@{@"label":LS(@"settings_app_version"), @"segue":@""}];
                [[self navSections] addObject:section2];
                
                [[self tableView] reloadData];
                
                
            } errorHandler:^(NSError *error) {
                //
            }];
            
            
        }
        
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self navSections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self navSections] objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([indexPath section] == 0){
        
        if([indexPath row] == 0){
            
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
            
            NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            
            
            cell.textLabel.text = [item objectForKey:@"label"];
            cell.textLabel.font = LATO_FONT(16);
            
            cell.detailTextLabel.text = [item objectForKey:@"description"];
            cell.detailTextLabel.font = LATO_LIGHT_FONT(12);
            cell.detailTextLabel.numberOfLines = 2;
            
            UISwitch * notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [cell setAccessoryView:notificationSwitch];
            [notificationSwitch addTarget:self action:@selector(toggleNotifications:) forControlEvents:UIControlEventValueChanged];
            
            
            if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
                
                [notificationSwitch setOn:NO];
            } else {
                [notificationSwitch setOn:YES];
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
            
        } else if([indexPath row] == 1){
            
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
            
            NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            
            
            cell.textLabel.text = [item objectForKey:@"label"];
            cell.textLabel.font = LATO_FONT(16);
            
            cell.detailTextLabel.text = [item objectForKey:@"description"];
            cell.detailTextLabel.font = LATO_LIGHT_FONT(12);
            cell.detailTextLabel.numberOfLines = 2;
            
            UISwitch * notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [cell setAccessoryView:notificationSwitch];
            [notificationSwitch addTarget:self action:@selector(toggleLocationServices:) forControlEvents:UIControlEventValueChanged];
            
            
            if ([[NotificarePushLib shared] checkLocationUpdates]) {
                [notificationSwitch setOn:YES];
            } else {
                [notificationSwitch setOn:NO];
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
            
        } else if([indexPath row] == 2){
            
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
            
            NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            
            
            cell.textLabel.text = [item objectForKey:@"label"];
            cell.textLabel.font = LATO_FONT(16);
            
            cell.detailTextLabel.text = [item objectForKey:@"description"];
            cell.detailTextLabel.font = LATO_LIGHT_FONT(12);
            cell.detailTextLabel.numberOfLines = 2;
            
            UISwitch * notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [cell setAccessoryView:notificationSwitch];
            [notificationSwitch addTarget:self action:@selector(toggleQuietTimes:) forControlEvents:UIControlEventValueChanged];
            
            if ([[item objectForKey:@"value"] isEqualToString:@"false"]) {
                
                [notificationSwitch setOn:NO];
            } else {
                [notificationSwitch setOn:YES];
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
            
        } else {
            
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
            
            NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
            
            
            cell.textLabel.text = [item objectForKey:@"label"];
            cell.textLabel.font = LATO_FONT(16);
            
            
            cell.detailTextLabel.text = [item objectForKey:@"description"];
            cell.detailTextLabel.font = LATO_LIGHT_FONT(12);
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"HH:mm"];
            NSDate *date = [dateFormat dateFromString:[NSString stringWithFormat:@"%@", [item objectForKey:@"value"]]];
            
            
            if ([[item objectForKey:@"label"] isEqualToString:LS(@"settings_notifications_quiet_times_start")]) {
                self.startPicker = [[UIDatePicker alloc] init];
                self.startPicker.frame = CGRectMake(0, 0, 100, 60); // set frame as your need
                self.startPicker.datePickerMode = UIDatePickerModeTime;
                self.startPicker.date = date;
                [cell setAccessoryView:[self startPicker]];
                [[self startPicker] addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
            } else {
                self.endPicker = [[UIDatePicker alloc] init];
                self.endPicker.frame = CGRectMake(0, 0, 100, 60); // set frame as your need
                self.endPicker.datePickerMode = UIDatePickerModeTime;
                self.endPicker.date = date;
                [cell setAccessoryView:[self endPicker]];
                [[self endPicker] addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
            }
            
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
            
        }
        
        
    } else {
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
        
        NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        UILabel * label = (UILabel *)[cell viewWithTag:100];
        [label setText:[item objectForKey:@"label"]];
        [label setFont:LATO_FONT(16)];
        
        if ( [[item objectForKey:@"label"] isEqualToString:LS(@"app_version")] ) {
            
            UILabel * accessoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            accessoryLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            accessoryLabel.font = LATO_LIGHT_FONT(14);
            accessoryLabel.textAlignment = NSTextAlignmentRight;
            [cell setAccessoryView:accessoryLabel];
            
        } else {
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            
        }
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
        
    }
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ([indexPath section] == 0) ? ([indexPath row] == 3 || [indexPath row] == 4) ? DEFAULT_CELLHEIGHT : SETTINGS_CELLHEIGHT : DEFAULT_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return HEADER_CELLHEIGHT;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString * item = (NSString *)[[self sectionTitles] objectAtIndex:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,HEADER_CELLHEIGHT)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5,tableView.frame.size.width,HEADER_CELLHEIGHT)];
    
    headerLabel.text = [item uppercaseString];
    headerLabel.font = LATO_FONT(14);
    headerLabel.backgroundColor = [UIColor clearColor];
    
    
    [headerView addSubview:headerLabel];
    
    
    return headerView;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    if ([[item objectForKey:@"label"] isEqualToString:LS(@"settings_title_topics")]) {
        [self performSegueWithIdentifier:@"Topics" sender:self];
    }
    
    if ([[item objectForKey:@"label"] isEqualToString:LS(@"settings_title_feedback")]) {
        
        if([MFMailComposeViewController canSendMail]){
            
            [self openMailClient];
            
        }
        
    }
}


-(void)toggleNotifications:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
        //
    }];
}

-(void)toggleLocationServices:(id)sender{
    
    if ([[NotificarePushLib shared] checkLocationUpdates]) {
        
        [[NotificarePushLib shared] stopLocationUpdates];
        
    } else {
        
        [[NotificarePushLib shared] startLocationUpdates];
    }
}

-(void)toggleQuietTimes:(id)sender{
    
    if ([(UISwitch *)sender isOn]) {
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSDate *startTime = [dateFormat dateFromString:@"00:00"];
        NSDate *endTime = [dateFormat dateFromString:@"08:00"];
        
        [[NotificarePushLib shared] updateDoNotDisturb:startTime endTime:endTime completionHandler:^(NSDictionary *info) {
            [self refreshView];
        } errorHandler:^(NSError *error) {
            [self refreshView];
        }];
        
    } else {
        
        [[NotificarePushLib shared] clearDoNotDisturb:^(NSDictionary *info) {
            [self refreshView];
        } errorHandler:^(NSError *error) {
            [self refreshView];
        }];
    }
    
}


-(void)timeChanged:(id)sender{
    
    [[NotificarePushLib shared] updateDoNotDisturb:self.startPicker.date endTime:self.endPicker.date completionHandler:^(NSDictionary *info) {
        [self refreshView];
    } errorHandler:^(NSError *error) {
        
    }];
    
}


-(void)back{
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
}

-(void)openMailClient{
    
    [self setMailComposer:[[MFMailComposeViewController alloc] init]];
    NSArray* recipients = [[[Configuration shared] getProperty:@"email"] componentsSeparatedByString: @","];
    [[self mailComposer] setMailComposeDelegate:self];
    [[self mailComposer] setToRecipients:recipients];
    [[self mailComposer] setSubject:LS(@"your_subject")];
    [[self mailComposer] setMessageBody:LS(@"your_message") isHTML:NO];
    
    [self presentViewController:[self mailComposer] animated:YES completion:^{
        
    }];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    switch (result){
        case MFMailComposeResultCancelled:
            
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent:
            
            break;
        case MFMailComposeResultFailed:
            
            break;
        default:
            
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


@end
