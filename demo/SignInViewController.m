//
//  SignInViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 30/01/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "SignInViewController.h"
#import "Definitions.h"
#import "FormButton.h"
#import "NotificarePushLib.h"
#import "AppDelegate.h"

@interface SignInViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) UITextField * emailField;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) FormButton * formButton;
@property (nonatomic, strong) FormButton * signupButton;

@end

@implementation SignInViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    [self setTitle:LS(@"title_signin")];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS(@"section_signin_header")];
    
    
    NSMutableArray * section1 = [NSMutableArray array];
    [section1 addObject:@{@"label":LS(@"email_label"), @"placeholder":LS(@"email_placeholder"), @"value":@""}];
    [section1 addObject:@{@"label":LS(@"password_label"), @"placeholder":LS(@"password_placeholder"), @"value":@""}];
    [section1 addObject:@{@"label":LS(@"lost_password_button_text"), @"placeholder":@"", @"value":@""}];
    
    [[self navSections] addObject:section1];
    
    [[self tableView] reloadData];
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:[UIColor whiteColor]];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    [[self tableView] setBackgroundColor:WILD_SAND_COLOR];
    [[self view] setBackgroundColor:WILD_SAND_COLOR];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];

}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [[self navSections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[[self navSections] objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FormFieldCell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormFieldCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    
    [[cell textLabel] setText:[item objectForKey:@"label"]];
    [[cell textLabel] setFont:PROXIMA_NOVA_REGULAR_FONT(14)];
    
    if ([[item objectForKey:@"label"] isEqual:LS(@"password_label")]) {
        [self setPasswordField:[[UITextField alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width / 2, 40)]];
        [[self passwordField] setDelegate:self];
        [[self passwordField] setTextAlignment:NSTextAlignmentRight];
        [[self passwordField] setFont:PROXIMA_NOVA_THIN_FONT(14)];
        [[self passwordField] setPlaceholder:[item objectForKey:@"placeholder"]];
        [[self passwordField] setTag:[indexPath row] + 100];
        [[self passwordField] setSecureTextEntry:YES];
        [cell setAccessoryView:[self passwordField]];
    } else if ([[item objectForKey:@"label"] isEqual:LS(@"lost_password_button_text")]) {
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        [label setText:LS(@"lost_password_button_text")];
        [label setTextAlignment:NSTextAlignmentRight];
        [label setFont:PROXIMA_NOVA_REGULAR_FONT(14)];
        [label setTextColor:FACEBOOK_COLOR];
        [cell setAccessoryView:label];
        
    } else {
        [self setEmailField:[[UITextField alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width / 2, 40)]];
        [[self emailField] setDelegate:self];
        [[self emailField] setTextAlignment:NSTextAlignmentRight];
        [[self emailField] setFont:PROXIMA_NOVA_THIN_FONT(14)];
        [[self emailField] setPlaceholder:[item objectForKey:@"placeholder"]];
        [[self emailField] setTag:[indexPath row] + 100];
        [[self emailField] setKeyboardType:UIKeyboardTypeEmailAddress];
        [cell setAccessoryView:[self emailField]];
    }
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * item = (NSDictionary *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    if ([[item objectForKey:@"label"] isEqual:LS(@"lost_password_button_text")]) {
        
        [self goToLostPassword];
        
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,SIGNIN_HEADER_HEIGHT)];
    [headerView setBackgroundColor:WILD_SAND_COLOR];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width,SIGNIN_HEADER_HEIGHT)];
    [imageView setImage:[UIImage imageNamed:@"padlock"]];
    [imageView setContentMode:UIViewContentModeCenter];
    
    [headerView addSubview:imageView];

    return headerView;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,SIGNIN_FOOTER_HEIGHT)];
    [footerView setBackgroundColor:WILD_SAND_COLOR];

    [self setFormButton:[[FormButton alloc] initWithFrame:CGRectMake(10,10,tableView.frame.size.width - 20, 60)  andText:LS(@"signin_button_text") andTextColor:[UIColor whiteColor] andBgColor:MAIN_COLOR]];
    [[self formButton] addTarget:self action:@selector(doLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:[self formButton]];
    
    
    [self setSignupButton:[[FormButton alloc] initWithFrame:CGRectMake(10,80,tableView.frame.size.width - 20, 60)  andText:LS(@"signup_button_text") andTextColor:[UIColor whiteColor] andBgColor:MAIN_COLOR]];
    [[self signupButton] addTarget:self action:@selector(goToSignUp) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:[self signupButton]];
    
    return footerView;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return FORMS_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return SIGNIN_HEADER_HEIGHT;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return SIGNUP_FOOTER_HEIGHT;
    
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
    
    [[self tableView] scrollRectToVisible:CGRectMake(0, 0, 1, self.tableView.frame.size.height + SIGNUP_FOOTER_HEIGHT) animated:YES];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [[self tableView] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [textField resignFirstResponder];
    
}

-(void)doLogin:(id)sender{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    
    [[self formButton] setEnabled:NO];
    
    if ([[[self emailField] text] length] == 0) {
        
        [self presentAlertViewForForm:LS(@"error_signin_invalid_email")];
        [[self formButton] setEnabled:YES];
        
    }else if ([[[self passwordField] text] length] < 5) {
        
        [self presentAlertViewForForm:LS(@"error_signin_invalid_password")];
        [[self formButton] setEnabled:YES];
        
    } else {
        
        
        [[[NotificarePushLib shared] authManager] loginWithUsername:[[self emailField] text] andPassword:[[self passwordField] text] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            if (!error) {
                
                [[[NotificarePushLib shared] authManager] fetchAccountDetails:^(id  _Nullable response, NSError * _Nullable error) {
                    if (!error) {
                        
                        NotificareUser * user = (NotificareUser*)response;
                        
                        if([[user accessToken] isKindOfClass:[NSNull class]]){
                            
                            [[[NotificarePushLib shared] authManager] generateAccessToken:^(id  _Nullable response, NSError * _Nullable error) {
                                if (!error) {
                                    
                                    if(![settings objectForKey:@"memberCardSerial"]){
                                        
                                        [self createMemberCard:[user userName] andEmail:[user userID]];
                                        
                                    }
                                    [self goToProfile];
                                    
                                } else {
                                    [self presentAlertViewForForm:LS(@"error_signin")];
                                    [[self formButton] setEnabled:YES];
                                }
                            }];
                            
                        } else {
                            
                            if(![settings objectForKey:@"memberCardSerial"]){
                                
                                [self createMemberCard:[user userName] andEmail:[user userID]];
                                
                            }
                            
                            [self goToProfile];
                        }
                        
                    } else {
                        [self presentAlertViewForForm:LS(@"error_signin")];
                        [[self formButton] setEnabled:YES];
                    }
                }];
                
            } else {
                [[self formButton] setEnabled:YES];
                
                switch ([error code]) {
                    case kNotificareErrorCodeBadRequest:
                        [self presentAlertViewForForm:LS(@"error_signin_invalid_email")];
                        break;
                        
                    case kNotificareErrorCodeForbidden:
                        [self presentAlertViewForForm:LS(@"error_signin_invalid_password")];
                        break;
                        
                    default:
                        break;
                }
            }
        }];
        
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


-(void)back{
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
}


-(void)goToLostPassword{
    [self performSegueWithIdentifier:@"LostPassword" sender:self];
}

-(void)goToSignUp{
    [self performSegueWithIdentifier:@"SignUp" sender:self];
}


-(void)goToProfile{
    [self performSegueWithIdentifier:@"Profile" sender:self];
}

-(void)createMemberCard:(NSString*)name andEmail:(NSString*)email{

    [[self appDelegate] createMemberCard:name andEmail:email completionHandler:^(NSDictionary *info) {
        //
    } errorHandler:^(NSError *error) {
        //
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
