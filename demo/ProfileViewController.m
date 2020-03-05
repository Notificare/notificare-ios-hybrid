//
//  ProfileViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 30/01/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "ProfileViewController.h"
#import "Definitions.h"
#import "FormButton.h"
#import "NotificarePushLib.h"
#import "GravatarHelper.h"
#import "PreferencesViewController.h"

@interface ProfileViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) UITextField * emailField;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) NSMutableArray * segments;
@property (nonatomic, strong) NSMutableArray * userData;
@property (nonatomic, strong) NotificareUser * user;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic, strong) UIView * loadingView;
@property (nonatomic, strong) NotificareUserPreference * selectedPreference;
@property (nonatomic, strong) MFMailComposeViewController *  mailComposer;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    [self setTitle:LS(@"title_profile")];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS(@"section_profile_user")];
    [[self sectionTitles] addObject:LS(@"section_profile_segments")];
    
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    [[self tableView] setBackgroundColor:WILD_SAND_COLOR];
    [[self view] setBackgroundColor:WILD_SAND_COLOR];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    [self loadAccount];
    
    [self showLoadingView];
    
    [[NotificarePushLib shared] fetchUserData:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (response && [response count] > 0) {
                UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"done"] style:UIBarButtonItemStylePlain target:self action:@selector(updateUser)];
                [rightButton setTintColor:[UIColor whiteColor]];
                [[self navigationItem] setRightBarButtonItem:rightButton];
            }
        } else{
            [[self navigationItem] setRightBarButtonItem:nil];
        }
    }];

}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

-(void)showLoadingView{
    [self setActivityIndicatorView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    [[self activityIndicatorView]  setCenter:CGPointMake( self.view.frame.size.width /2-5, self.view.frame.size.height /2-5)];
    [[self activityIndicatorView]  setContentMode:UIViewContentModeCenter];
    [[self activityIndicatorView] setHidden:NO];
    [[self activityIndicatorView] startAnimating];
    
    [self setLoadingView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)]];
    [[self loadingView] setBackgroundColor:[UIColor whiteColor]];
    [[self loadingView] addSubview:[self activityIndicatorView]];
    [[self view] addSubview:[self loadingView]];
}

-(void)loadAccount{
    
    [[[NotificarePushLib shared] authManager] fetchAccountDetails:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error)  {
            [self setUser:response];
             [self loadSegments];
        }
    }];

}

-(void)loadSegments{
    
    [self setSegments:[NSMutableArray array]];
    
    [[[NotificarePushLib shared] authManager] fetchUserPreferences:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            for (NotificareUserPreference * preference in response){
                [[self segments] addObject:preference];
            }
            
            [self loadUserData];
        } else {
            [self loadSegments];
        }
    }];
}



-(void)loadUserData{
    
    [[NotificarePushLib shared] fetchUserData:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self setUserData:response];
            [self setupTable];
        }
    }];
   
}


-(void)setupTable{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    [[self activityIndicatorView] setHidden:YES];
    [[self loadingView] removeFromSuperview];
    
    [self setNavSections:[NSMutableArray array]];
    
    NSMutableArray * userCell = [NSMutableArray array];
    
    if([self user] && [[self user] userName] && [[self user] userID]){
        [userCell addObject:@{
                              @"type": @"static",
                              @"key": @"name",
                              @"value":[[self user] userName],
                              @"label":LS(@"name_label")}];
        
        [userCell addObject:@{
                              @"type": @"static",
                              @"key": @"email",
                              @"value":[[self user] userID],
                              @"label":LS(@"email_label")}];
        
        if ([[self user] accessToken]) {
            [userCell addObject:@{
                                  @"type": @"static",
                                  @"key": @"access_token",
                                  @"value":[[self user] accessToken],
                                  @"label":LS(@"access_token_label")}];
        }
        
        
        if ([self userData] && [[self userData] count] > 0) {
            
            for (NotificareUserData * field in [self userData]) {
                
                [userCell addObject:@{
                                      @"type": @"editable",
                                      @"tag": [NSString stringWithFormat:@"%lu", (unsigned long) (200 +  [[self userData] indexOfObject:field])],
                                      @"key": [field key],
                                      @"value": [field value],
                                      @"label": [field label]}];
                
            }
            
        }
        
        if([settings objectForKey:@"memberCardSerial"]){

            [userCell addObject:@{@"type": @"static",
                                  @"key": @"",
                                  @"value": [NSNull new],
                                  @"label":LS(@"button_open_pass")}];
        }
        
        
        [userCell addObject:@{@"type": @"static",
                              @"key": @"",
                              @"value": [NSNull new],
                              @"label":LS(@"button_resetpass")}];
        
        [userCell addObject:@{@"type": @"static",
                              @"key": @"",
                              @"value": [NSNull new],
                              @"label":LS(@"button_generate_token")}];
        
        [userCell addObject:@{@"type": @"static",
                              @"key": @"",
                              @"value": [NSNull new],
                              @"label":LS(@"button_logout")}];
        
    }
    
    
    [[self navSections] addObject:userCell];
    [[self navSections] addObject:[self segments]];

    
    [[self tableView] reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self navSections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self navSections] objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if([indexPath section] == 0){
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FormFieldCell"];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormFieldCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        [[cell textLabel] setText:[item objectForKey:@"label"]];
        [[cell textLabel] setFont:LATO_FONT(14)];
        
        if ([[item objectForKey:@"value"] isKindOfClass:[NSNull class]]) {
            
            [cell setAccessoryView:nil];
            
        } else {
            
            if ([[item objectForKey:@"type"] isEqual:@"editable"]) {
                
                UITextField * field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width /2, 40)];
                [field setFont:LATO_LIGHT_FONT(14)];
                [field setTextAlignment:NSTextAlignmentRight];
                [field setTag:[[item objectForKey:@"tag"] intValue]];
                [field setPlaceholder:LS(@"type_something")];
                [field setDelegate:self];
                
                if ([item objectForKey:@"value"]) {
                    [field setText:[item objectForKey:@"value"]];
                }
                
                [cell setAccessoryView:field];
                
            } else {
                
                UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width  /2, 40)];
                [label setText:[item objectForKey:@"value"]];
                [label setTextAlignment:NSTextAlignmentRight];
                [label setFont:LATO_LIGHT_FONT(14)];
                [cell setAccessoryView:label];
                
            }
        }
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
        
    } else {
    
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentCell"];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SegmentCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        NotificareUserPreference * item = (NotificareUserPreference *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        [[cell textLabel] setText:[item preferenceLabel]];
        [[cell textLabel] setFont:LATO_FONT(14)];
        
        
        if([[item preferenceType] isEqualToString:@"single"]){
            NotificareSegment * seg = (NotificareSegment *)[[item preferenceOptions] firstObject];
            [[cell detailTextLabel] setText:[seg segmentLabel]];
            [[cell detailTextLabel] setFont:LATO_FONT(14)];
            UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [cell setAccessoryView:mySwitch];
            [mySwitch setTag:(([indexPath section] * 100) + [indexPath row])];
            
            if([seg selected]){
                [mySwitch setOn:YES];
            }
            
            [mySwitch addTarget:self action:@selector(OnSegmentsChanged:) forControlEvents:UIControlEventValueChanged];
            
        }
        
        if([[item preferenceType] isEqualToString:@"choice"]){
            
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width /2, cell.frame.size.height /2)];
            
            for (NotificareSegment * seg in [item preferenceOptions]) {
                //
                if([seg selected]){
                    [label setText:[seg segmentLabel]];
                    [label setTextAlignment:NSTextAlignmentRight];
                    [label setTextColor:[UIColor grayColor]];
                    [label setFont:LATO_LIGHT_FONT(14)];
                    [cell setAccessoryView:label];
                }
            }
            
        }
        
        if([[item preferenceType] isEqualToString:@"select"]){
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }

}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    if([[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]] isKindOfClass:[NotificareUserPreference class]]){
        
        NotificareUserPreference * item = (NotificareUserPreference *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        if(![[item preferenceType] isEqualToString:@"single"]){
            [self setSelectedPreference:item];
            [self performSegueWithIdentifier:@"Preferences" sender:self];
        }
        
        
    } else {
        
        
        NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        if([[item objectForKey:@"label"] isEqualToString:LS(@"button_resetpass")]){
            
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle: APP_NAME
                                          message:LS(@"button_resetpass")
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = LS(@"new_password_label");
                textField.secureTextEntry = YES;
            }];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = LS(@"confirm_new_password_label");
                textField.secureTextEntry = YES;
            }];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:LS(@"change")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                                    
                                     if([[[alert textFields][0] text] length] == 0 || [[[alert textFields][1] text] length] == 0){
                                         [self presentAlertViewForForm:LS(@"error_password_changepass")];
                                     } else if (![[[alert textFields][0] text] isEqualToString:[[alert textFields][1] text]]) {
                                         [self presentAlertViewForForm:LS(@"error_create_account_passwords_match")];
                                     } else if ([[[alert textFields][0] text] length] < 5) {
                                         [self presentAlertViewForForm:LS(@"error_create_account_small_password")];
                                     } else {
                                         
                                         [[[NotificarePushLib shared] authManager] changePassword:[[alert textFields][0] text] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
                                             if (!error) {
                                                 [self presentAlertViewForForm:LS(@"success_message_changepass")];
                                             } else {
                                                 [self presentAlertViewForForm:LS(@"error_message_changepass")];
                                             }
                                         }];
                                     }
                                     
                                 }];
            [alert addAction:ok];
            
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:LS(@"cancel")
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action){}];
            [alert addAction:cancel];
            
            [self showLoadingView];
            
            [self presentViewController:alert animated:YES completion:^{
                
                [[self activityIndicatorView] setHidden:YES];
                [[self loadingView] removeFromSuperview];
                
            }];
            
            
        } else if([[item objectForKey:@"label"] isEqualToString:LS(@"button_generate_token")]){
            
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle: APP_NAME
                                          message:LS(@"confirm_generate_token_text")
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:LS(@"yes")
                                 style:UIAlertActionStyleDestructive
                                 handler:^(UIAlertAction * action){
                                     
                                     UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                                     
                                     UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                     [cell setAccessoryView:activityView];
                                     [activityView startAnimating];
                                     
                                     [cell setUserInteractionEnabled:NO];
                                     [self generateNewToken];
                                     
                                 }];
            [alert addAction:ok];
            
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:LS(@"no")
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action){}];
            [alert addAction:cancel];
            
            [self showLoadingView];
            
            [self presentViewController:alert animated:YES completion:^{
                
                [[self activityIndicatorView] setHidden:YES];
                [[self loadingView] removeFromSuperview];
                
            }];
            
        } else if([[item objectForKey:@"label"] isEqualToString:LS(@"button_open_pass")]){
            
            [self openMemberCard];
            
        } else if([[item objectForKey:@"label"] isEqualToString:LS(@"button_logout")]){
            
            [self logout];
            
        }  else if([[item objectForKey:@"label"] isEqualToString:LS(@"access_token_label")]){
            
            if([item objectForKey:@"value"] && ![[item objectForKey:@"value"] isKindOfClass:[NSNull class]]){
                
                if([MFMailComposeViewController canSendMail]){
                    NSArray* recipients = [[NSString stringWithFormat:@"%@@pushmail.notifica.re", [item objectForKey:@"value"]] componentsSeparatedByString: @","];
                    [self setMailComposer:[[MFMailComposeViewController alloc] init]];
                    [[self mailComposer] setMailComposeDelegate:self];
                    [[self mailComposer] setToRecipients:recipients];
                    [[self mailComposer] setSubject:LS(@"mail_subject_text")];
                    [[self mailComposer] setMessageBody:LS(@"mail_body_text") isHTML:NO];
                    
                    [self showLoadingView];
                    [self presentViewController:[self mailComposer] animated:YES completion:^{
                        
                        [[self activityIndicatorView] setHidden:YES];
                        [[self loadingView] removeFromSuperview];
                        
                    }];
                    
                }
            }
            
            
        }
        
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == 0) {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,USER_HEADER_HEIGHT)];
        [headerView setBackgroundColor:WILD_SAND_COLOR];
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width,USER_HEADER_HEIGHT)];
        
        [imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[GravatarHelper getGravatarURL:[[self user] userID]]]]];
        
        imageView.layer.masksToBounds = YES;
        
        [imageView setContentMode:UIViewContentModeCenter];
        
        [headerView addSubview:imageView];
        
        return headerView;
        
    } else {
    
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SEGMENT_HEADER_HEIGHT)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 10, SEGMENT_HEADER_HEIGHT)];
        [label setText:[[self sectionTitles] objectAtIndex:section]];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:LATO_FONT(14)];
        [label setBackgroundColor:[UIColor clearColor]];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        [headerView addSubview:label];
        return headerView;
    }
    
    
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    return nil;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return DEFAULT_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == 0){
        return USER_HEADER_HEIGHT;
    } else {
        return SEGMENT_HEADER_HEIGHT;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0;
    
}

-(void)OnSegmentsChanged:(id)sender{
    
    UISwitch *tempSwitch = (UISwitch *)sender;
    NotificareUserPreference * item = [[[self navSections] objectAtIndex:[tempSwitch tag] / 100] objectAtIndex:[tempSwitch tag] % 100];
    
    
    if([[item preferenceType] isEqualToString:@"single"]){
        
        
        NotificareSegment * seg = [[item preferenceOptions] objectAtIndex:0];
        
        if([tempSwitch isOn]){
            
            [[[NotificarePushLib shared] authManager] addSegment:seg toPreference:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@ - %@", response, error);
            }];
            
        }else{
 
            [[[NotificarePushLib shared] authManager] removeSegment:seg fromPreference:item completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
                NSLog(@"%@ - %@", response, error);
            }];
            
        }
        
    }
    
}


-(void)updateUser{
    
    NSMutableArray * userData = [NSMutableArray array];
    
    for (NSDictionary * dict in [[self navSections] objectAtIndex:0]) {
        
        if ([[dict objectForKey:@"type"] isEqualToString:@"editable"]) {
            
            UITextField *myField = (UITextField *)[self.view viewWithTag:[[dict objectForKey:@"tag"] intValue]];
            
            if ([[myField text] length] > 0) {
                NotificareUserData * data = [NotificareUserData new];
                [data setKey:[dict objectForKey:@"key"]];
                [data setValue:[myField text]];
                [data setLabel:[dict objectForKey:@"label"]];
                [userData addObject:data];
            }

            [myField resignFirstResponder];
        }
    }
    

    [[NotificarePushLib shared] updateUserData:userData completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self presentAlertViewForForm:LS(@"success_message_update_user_data")];
        } else {
           [self presentAlertViewForForm:LS(@"error_message_update_user_data")];
        }
    }];
    
}



-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
}

-(void)generateNewToken{
    
    [[[NotificarePushLib shared] authManager] generateAccessToken:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self loadAccount];
            [self presentAlertViewForForm:LS(@"success_message_generate_token")];
        } else {
            [self presentAlertViewForForm:LS(@"success_message_generate_token")];
        }
    }];

}


-(void)logout{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle: APP_NAME
                                  message:LS(@"confirm_logout_text")
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:LS(@"yes")
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action){
                                 
                                 [[[NotificarePushLib shared] authManager] logoutAccount];
                                 [self back];
                                 
                             }];
    [alert addAction:ok];
    
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:LS(@"no")
                         style:UIAlertActionStyleCancel
                         handler:^(UIAlertAction * action){}];
    [alert addAction:cancel];
    
    [self showLoadingView];
    [self presentViewController:alert animated:YES completion:^{
        
        [[self activityIndicatorView] setHidden:YES];
        [[self loadingView] removeFromSuperview];
        
    }];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    if (result == MFMailComposeResultSent) {
    
        [self becomeFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^{
            
            [self presentAlertViewForForm:LS(@"mail_success_text")];
            
        }];
        
    } else if (result == MFMailComposeResultFailed) {
    
        [self presentAlertViewForForm:LS(@"mail_error_text")];
        
    } else {
        [self becomeFirstResponder];
        [self dismissViewControllerAnimated:YES completion:^{

        }];
    }
    
}

-(void)openMemberCard{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if([settings objectForKey:@"memberCardSerial"]){
        
        NSString * url = [NSString stringWithFormat:@"https://push.notifica.re/pass/pkpass/%@", [settings objectForKey:@"memberCardSerial"]];
        NSURL *passbookUrl = [NSURL URLWithString:url];
        NSData *data = [[NSData alloc] initWithContentsOfURL:passbookUrl];
        NSError *error;
        
        //init a pass object with the data
        PKPass * pass = [[PKPass alloc] initWithData:data error:&error];
        
        if(!error){
            
            //present view controller to add the pass to the library
            PKAddPassesViewController * vc = [[PKAddPassesViewController alloc] initWithPass:pass];
            
            [self showLoadingView];
            [self presentViewController:vc animated:YES completion:^{
                [[self activityIndicatorView] setHidden:YES];
                [[self loadingView] removeFromSuperview];
            }];
            
        } else {
            [self presentAlertViewForForm:[error localizedDescription]];
        }
        
        
    } else {
        [self presentAlertViewForForm:LS(@"error_no_serial_found")];
    }
}

-(void)presentAlertViewForForm:(NSString *)message{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle: APP_NAME
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:LS(@"ok")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){}];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Preferences"])
    {
        PreferencesViewController *vc = [segue destinationViewController];
        [vc setPreference:[self selectedPreference]];
    }
}

-(void)back{
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
