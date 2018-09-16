//
//  ResetPasswordViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 29/01/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "FormButton.h"
#import "NotificarePushLib.h"
#import "Definitions.h"

@interface ResetPasswordViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) UITextField * confirmPasswordField;
@property (nonatomic, strong) FormButton * formButton;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:LS(@"title_signin")];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS(@"section_signin_header")];
    
    
    NSMutableArray * section1 = [NSMutableArray array];
    [section1 addObject:@{@"label":LS(@"password_label"), @"placeholder":LS(@"password_placeholder"), @"value":@""}];
    [section1 addObject:@{@"label":LS(@"confirm_password_label"), @"placeholder":LS(@"confirm_password_placeholder"), @"value":@""}];
    
    [[self navSections] addObject:section1];
    
    [[self tableView] reloadData];
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:MAIN_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    
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
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,SIGNIN_HEADER_HEIGHT)];
    [headerView setBackgroundColor:WILD_SAND_COLOR];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,tableView.frame.size.width,SIGNIN_HEADER_HEIGHT)];
    [imageView setImage:[UIImage imageNamed:@"key"]];
    [imageView setContentMode:UIViewContentModeCenter];
    
    [headerView addSubview:imageView];
    
    return headerView;
    
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,SIGNIN_FOOTER_HEIGHT)];
    [footerView setBackgroundColor:WILD_SAND_COLOR];
    
    [self setFormButton:[[FormButton alloc] initWithFrame:CGRectMake(10,10,tableView.frame.size.width - 20, 60)  andText:LS(@"reset_password_button_text") andTextColor:[UIColor whiteColor] andBgColor:MAIN_COLOR]];
    [[self formButton] addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:[self formButton]];
    
    return footerView;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return FORMS_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return SIGNIN_HEADER_HEIGHT;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return SIGNIN_FOOTER_HEIGHT;
    
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

-(void)resetPassword:(id)sender{
    
    [[self formButton] setEnabled:NO];
    
    if (![[[self passwordField] text] isEqualToString:[[self confirmPasswordField] text]]) {
        
        [self presentAlertViewForForm:LS(@"error_resetpass_passwords_match")];
        [[self formButton] setEnabled:YES];
        
    }else if ([[[self passwordField] text] length] < 5) {
        
        [self presentAlertViewForForm:LS(@"error_resetpass_small_password")];
        [[self formButton] setEnabled:YES];

    } else {
        
        [[[NotificarePushLib shared] authManager] resetPassword:[[self passwordField] text] withToken:[self token] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            if (!error) {
                [self presentAlertViewForForm:LS(@"success_resetpass")];
                [[self formButton] setEnabled:YES];
                
                [[self passwordField] setText:@""];
                [[self confirmPasswordField] setText:@""];
                
                [[self navigationController] popToRootViewControllerAnimated:YES];
            } else {
                [self presentAlertViewForForm:LS(@"error_resetpass")];
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
                             handler:^(UIAlertAction * action){}];
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
