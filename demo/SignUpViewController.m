//
//  SignUpViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 29/01/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "SignUpViewController.h"
#import "Definitions.h"
#import "FormButton.h"
#import "NotificarePushLib.h"
#import "Configuration.h"
#import "GravatarHelper.h"
#import "AppDelegate.h"

@interface SignUpViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) UITextField * nameField;
@property (nonatomic, strong) UITextField * emailField;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) UITextField * confirmPasswordField;
@property (nonatomic, strong) FormButton * formButton;
@property (nonatomic, strong) NSDictionary * passTemplate;
@property (nonatomic, assign) BOOL isCreationFinished;

@end

@implementation SignUpViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    [self setTitle:LS(@"title_signup")];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS(@"section_signin_header")];
    
    
    NSMutableArray * section1 = [NSMutableArray array];
    [section1 addObject:@{@"label":LS(@"name_label"), @"placeholder":LS(@"name_placeholder"), @"value":@""}];
    [section1 addObject:@{@"label":LS(@"email_label"), @"placeholder":LS(@"email_placeholder"), @"value":@""}];
    [section1 addObject:@{@"label":LS(@"password_label"), @"placeholder":LS(@"password_placeholder"), @"value":@""}];
    [section1 addObject:@{@"label":LS(@"confirm_password_label"), @"placeholder":LS(@"confirm_password_placeholder"), @"value":@""}];
    
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
    [[cell textLabel] setFont:LATO_FONT(14)];
    
    if ([[item objectForKey:@"label"] isEqual:LS(@"password_label")]) {
        [self setPasswordField:[[UITextField alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width / 2, 40)]];
        [[self passwordField] setDelegate:self];
        [[self passwordField] setTextAlignment:NSTextAlignmentRight];
        [[self passwordField] setFont:LATO_LIGHT_FONT(14)];
        [[self passwordField] setPlaceholder:[item objectForKey:@"placeholder"]];
        [[self passwordField] setTag:[indexPath row] + 100];
        [[self passwordField] setSecureTextEntry:YES];
        [cell setAccessoryView:[self passwordField]];
    } else if ([[item objectForKey:@"label"] isEqual:LS(@"confirm_password_label")]) {
        [self setConfirmPasswordField:[[UITextField alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width / 2, 40)]];
        [[self confirmPasswordField] setDelegate:self];
        [[self confirmPasswordField] setTextAlignment:NSTextAlignmentRight];
        [[self confirmPasswordField] setFont:LATO_LIGHT_FONT(14)];
        [[self confirmPasswordField] setPlaceholder:[item objectForKey:@"placeholder"]];
        [[self confirmPasswordField] setTag:[indexPath row] + 100];
        [[self confirmPasswordField] setSecureTextEntry:YES];
        [cell setAccessoryView:[self confirmPasswordField]];
    } else if ([[item objectForKey:@"label"] isEqual:LS(@"name_label")]) {
        [self setNameField:[[UITextField alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width / 2, 40)]];
        [[self nameField] setDelegate:self];
        [[self nameField] setTextAlignment:NSTextAlignmentRight];
        [[self nameField] setFont:LATO_LIGHT_FONT(14)];
        [[self nameField] setPlaceholder:[item objectForKey:@"placeholder"]];
        [[self nameField] setTag:[indexPath row] + 100];
        [[self nameField] setKeyboardType:UIKeyboardTypeDefault];
        [cell setAccessoryView:[self nameField]];
    }  else {
        [self setEmailField:[[UITextField alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width / 2, 40)]];
        [[self emailField] setDelegate:self];
        [[self emailField] setTextAlignment:NSTextAlignmentRight];
        [[self emailField] setFont:LATO_LIGHT_FONT(14)];
        [[self emailField] setPlaceholder:[item objectForKey:@"placeholder"]];
        [[self emailField] setTag:[indexPath row] + 100];
        [[self emailField] setKeyboardType:UIKeyboardTypeEmailAddress];
        [cell setAccessoryView:[self emailField]];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,SIGNIN_HEADER_HEIGHT)];
    [headerView setBackgroundColor:WILD_SAND_COLOR];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width,SIGNIN_HEADER_HEIGHT)];
    [imageView setImage:[UIImage imageNamed:@"account"]];
    [imageView setContentMode:UIViewContentModeCenter];
    
    [headerView addSubview:imageView];
    
    return headerView;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,SIGNIN_FOOTER_HEIGHT)];
    [footerView setBackgroundColor:WILD_SAND_COLOR];
    
    [self setFormButton:[[FormButton alloc] initWithFrame:CGRectMake(10,10,tableView.frame.size.width - 20, 60)  andText:LS(@"signup_button_text") andTextColor:[UIColor whiteColor] andBgColor:MAIN_COLOR]];
    [[self formButton] addTarget:self action:@selector(createAccount:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:[self formButton]];
    
    return footerView;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return FORMS_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return SIGNUP_HEADER_HEIGHT;
    
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

-(void)createAccount:(id)sender{
    
    [[self formButton] setEnabled:NO];
    
    if ([[[self nameField] text] length] == 0) {
        
        [self presentAlertViewForForm:LS(@"error_create_account_name")];
        [[self formButton] setEnabled:YES];
        
        
    } else if ([[[self emailField] text] length] == 0) {
        
        [self presentAlertViewForForm:LS(@"error_create_account_invalid_email")];
        [[self formButton] setEnabled:YES];
        
        
    } else if (![[[self passwordField] text] isEqualToString:[[self confirmPasswordField] text]]) {
        
        [self presentAlertViewForForm:LS(@"error_create_account_passwords_match")];
        [[self formButton] setEnabled:YES];
        
    }else if ([[[self confirmPasswordField] text] length] < 5) {

        [self presentAlertViewForForm:LS(@"error_create_account_small_password")];
        [[self formButton] setEnabled:YES];
        
    } else {
        
        [[[NotificarePushLib shared] authManager] createAccount:[[[self emailField] text] lowercaseString] withName:[[self nameField] text] andPassword:[[self passwordField] text] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            if (!error) {
                [[self appDelegate] createMemberCard:[[self nameField] text] andEmail:[[[self emailField] text] lowercaseString] completionHandler:^(NSDictionary *info) {
                    
                    [[self formButton] setEnabled:YES];
                    
                    [[self emailField] setText:@""];
                    [[self nameField] setText:@""];
                    [[self passwordField] setText:@""];
                    [[self confirmPasswordField] setText:@""];
                    
                    [self setIsCreationFinished:YES];
                    [self presentAlertViewForForm:LS(@"success_create_account")];
                    
                } errorHandler:^(NSError *error) {
                    [self presentAlertViewForForm:LS(@"error_create_member_card")];
                }];
            } else {
                [self presentAlertViewForForm:LS(@"error_create_account")];
                [[self formButton] setEnabled:YES];
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
                             handler:^(UIAlertAction * action){
                             
                                 if ([self isCreationFinished]) {
                                     
                                     [[self navigationController] popViewControllerAnimated:YES];
                                     
                                 }
                                 
                             }];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


-(void)back{
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
