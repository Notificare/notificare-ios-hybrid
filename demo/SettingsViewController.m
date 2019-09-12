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
    
    if (@available(iOS 13.0, *)) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    [self setTitle:LS(@"title_settings")];

    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:MAIN_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    [self refreshView];

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
    
    
    if ([[NotificarePushLib shared] allowedUIEnabled]) {
        
        [[NotificarePushLib shared] fetchDoNotDisturb:^(id  _Nullable response, NSError * _Nullable error) {
            if (!error) {
                
                NotificareDeviceDnD * dnd = (NotificareDeviceDnD*)response;
                
                if([dnd start] && [dnd end]){
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"HH:mm"];
                    NSString *startTime = [dateFormatter stringFromDate:[dnd start]];
                    NSString *endTime = [dateFormatter stringFromDate:[dnd end]];
                    
                    
                    [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_description"), @"value":@"true"}];
                    
                    [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times_start"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_start_description"), @"value":startTime}];
                    
                    [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times_end"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_end_description"), @"value":endTime}];
                    
                } else {
                    [section1 addObject:@{@"label":LS(@"settings_notifications_quiet_times"), @"segue":@"", @"description":LS(@"settings_notifications_quiet_times_description"), @"value":@"false"}];
                }
                
                
                
                [[self navSections] addObject:section1];
                
                
                [self handleTags];
                
            }
        }];
        
    } else {
        [[self navSections] addObject:section1];
        [self handleTags];
    }
    
}


-(void)handleTags{

    [[NotificarePushLib shared] fetchTags:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (response) {
                
                [[self sectionTitles] addObject:LS(@"section_item_settings_tags")];
                NSMutableArray * section2 = [NSMutableArray array];
                
                if ([response containsObject:@"tag_press"]) {
                    [section2 addObject:@{@"label":LS(@"settings_tag_press_label"), @"segue":@"tag_press", @"description":LS(@"settings_tag_press_description"), @"value":@1}];
                } else {
                    [section2 addObject:@{@"label":LS(@"settings_tag_press_label"), @"segue":@"tag_press", @"description":LS(@"settings_tag_press_description"), @"value":@0}];
                }
                
                
                if ([response containsObject:@"tag_newsletter"]) {
                    [section2 addObject:@{@"label":LS(@"settings_tag_newsletter_label"), @"segue":@"tag_newsletter", @"description":LS(@"settings_tag_newsletter_description"), @"value":@1}];
                } else {
                    [section2 addObject:@{@"label":LS(@"settings_tag_newsletter_label"), @"segue":@"tag_newsletter", @"description":LS(@"settings_tag_newsletter_description"), @"value":@0}];
                }
                
                if ([response containsObject:@"tag_events"]) {
                    [section2 addObject:@{@"label":LS(@"settings_tag_events_label"), @"segue":@"tag_events", @"description":LS(@"settings_tag_events_description"), @"value":@1}];
                } else {
                    [section2 addObject:@{@"label":LS(@"settings_tag_events_label"), @"segue":@"tag_events", @"description":LS(@"settings_tag_events_description"), @"value":@0}];
                }
                
                [[self navSections] addObject:section2];
                
            }
            
            [[self sectionTitles] addObject:LS(@"section_item_settings_about")];
            NSMutableArray * section3 = [NSMutableArray array];
            [section3 addObject:@{@"label":LS(@"settings_feedback"), @"segue":@"Feedback"}];
            [section3 addObject:@{@"label":LS(@"settings_app_version"), @"segue":@""}];
            [[self navSections] addObject:section3];
            
            
            
            [[self tableView] reloadData];
        } else {
            [[self tableView] reloadData];
        }
    }];
    
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
            
            
            if ([[NotificarePushLib shared] allowedUIEnabled]) {
                [notificationSwitch setOn:YES];
            } else {
                [notificationSwitch setOn:NO];
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
            
            
            if ([[NotificarePushLib shared] locationServicesEnabled]) {
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
        
        
    } else if ([indexPath section] == 1) {
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
        
        NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        cell.textLabel.text = [item objectForKey:@"label"];
        cell.textLabel.font = LATO_FONT(16);
        
        cell.detailTextLabel.text = [item objectForKey:@"description"];
        cell.detailTextLabel.font = LATO_LIGHT_FONT(12);
        cell.detailTextLabel.numberOfLines = 2;
        
        UISwitch * notificationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [cell setAccessoryView:notificationSwitch];
        
        if ([[item objectForKey:@"segue"] isEqualToString:@"tag_press"]) {
            [notificationSwitch addTarget:self action:@selector(toggleTagPress:) forControlEvents:UIControlEventValueChanged];
        } else if ([[item objectForKey:@"segue"] isEqualToString:@"tag_newsletter"]) {
            [notificationSwitch addTarget:self action:@selector(toggleTagNewsletter:) forControlEvents:UIControlEventValueChanged];
        } else if ([[item objectForKey:@"segue"] isEqualToString:@"tag_events"]) {
            [notificationSwitch addTarget:self action:@selector(toggleTagEvents:) forControlEvents:UIControlEventValueChanged];
        }
        
        
        if ([[item objectForKey:@"value"] isEqual:@0]) {
            [notificationSwitch setOn:NO];
        } else {
            [notificationSwitch setOn:YES];
        }
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
        
    } else {
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
        
        NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        UILabel * label = (UILabel *)[cell viewWithTag:100];
        [label setText:[item objectForKey:@"label"]];
        [label setFont:LATO_FONT(16)];
        
        if ( [[item objectForKey:@"label"] isEqualToString:LS(@"settings_app_version")] ) {
            
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
    
    return ([indexPath section] == 0) ? ([indexPath row] == 3 || [indexPath row] == 4) ? DEFAULT_CELLHEIGHT : SETTINGS_CELLHEIGHT : ([indexPath section] == 1) ? SETTINGS_CELLHEIGHT : DEFAULT_CELLHEIGHT;
    
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
    
    if ([[item objectForKey:@"label"] isEqualToString:LS(@"settings_feedback")]) {
        
        if([MFMailComposeViewController canSendMail]){
            
            [self openMailClient];
            
        }
        
    }
}


-(void)toggleNotifications:(id)sender{
    
    if ([(UISwitch *)sender isOn]) {
        [[NotificarePushLib shared] registerForNotifications];
    } else {
        [[NotificarePushLib shared] unregisterForNotifications];
    }
    
}

-(void)toggleLocationServices:(id)sender{
    
    if ([(UISwitch *)sender isOn]) {
        [[NotificarePushLib shared] startLocationUpdates];
    } else {
        [[NotificarePushLib shared] stopLocationUpdates];
    }
}

-(void)toggleQuietTimes:(id)sender{
    
    if ([(UISwitch *)sender isOn]) {
        
        NSDate *date = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *sComponents = [gregorian components: NSUIntegerMax fromDate: date];
        [sComponents setHour:0];
        [sComponents setMinute:0];
        NSDate *startTime = [gregorian dateFromComponents:sComponents];
        
        NSDateComponents *eComponents = [gregorian components: NSUIntegerMax fromDate: date];
        [eComponents setHour:8];
        [eComponents setMinute:0];
        NSDate *endTime = [gregorian dateFromComponents:eComponents];
        
        NotificareDeviceDnD * dnd = [NotificareDeviceDnD new];
        [dnd setStart:startTime];
        [dnd setEnd:endTime];
        
        [[NotificarePushLib shared] updateDoNotDisturb:dnd completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            [self refreshView];
        }];
        
    } else {
        
        [[NotificarePushLib shared] clearDoNotDisturb:^(id  _Nullable response, NSError * _Nullable error) {
             [self refreshView];
        }];

    }
    
}


-(void)timeChanged:(id)sender{
    
    NotificareDeviceDnD * dnd = [NotificareDeviceDnD new];
    [dnd setStart:self.startPicker.date];
    [dnd setEnd:self.endPicker.date];
    
    [[NotificarePushLib shared] updateDoNotDisturb:dnd completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        [self refreshView];
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


-(void)toggleTagPress:(id)sender{
    
    if ([(UISwitch *)sender isOn]) {
        
        [[NotificarePushLib shared] addTags:@[@"tag_press"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            
        }];
        
    } else {
        
        [[NotificarePushLib shared] removeTag:@"tag_press" completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            
        }];

    }
    
}

-(void)toggleTagNewsletter:(id)sender{
    
    if ([(UISwitch *)sender isOn]) {
        
        [[NotificarePushLib shared] addTags:@[@"tag_newsletter"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            
        }];

    } else {
        
        [[NotificarePushLib shared] removeTag:@"tag_newsletter" completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            
        }];
        
    }
    
}

-(void)toggleTagEvents:(id)sender{
    
    if ([(UISwitch *)sender isOn]) {
        
        [[NotificarePushLib shared] addTags:@[@"tag_events"] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            
        }];
        
    } else {
        
        [[NotificarePushLib shared] removeTag:@"tag_events" completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            
        }];
        
    }
    
}


@end
