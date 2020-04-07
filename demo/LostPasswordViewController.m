//
//  LostPasswordViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 31/01/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "LostPasswordViewController.h"
#import "NotificarePushLib.h"
#import "Definitions.h"
#import "FormButton.h"

@interface LostPasswordViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;
@property (nonatomic, strong) UITextField * emailField;
@property (nonatomic, strong) FormButton * formButton;

@end

@implementation LostPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    [self setTitle:LS(@"title_lost_password")];
    
    [self setNavSections:[NSMutableArray array]];
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS(@"section_lost_password_header")];
    
    
    NSMutableArray * section1 = [NSMutableArray array];
    [section1 addObject:@{@"label":LS(@"email_label"), @"placeholder":LS(@"email_placeholder"), @"value":@""}];
    
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
    
    [self setEmailField:[[UITextField alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width / 2, 40)]];
    [[self emailField] setDelegate:self];
    [[self emailField] setTextAlignment:NSTextAlignmentRight];
    [[self emailField] setFont:PROXIMA_NOVA_THIN_FONT(14)];
    [[self emailField] setPlaceholder:[item objectForKey:@"placeholder"]];
    [[self emailField] setTag:[indexPath row] + 100];
    [[self emailField] setKeyboardType:UIKeyboardTypeEmailAddress];
    [cell setAccessoryView:[self emailField]];
    
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
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,LOST_PASSWORD_FOOTER_HEIGHT)];
    [footerView setBackgroundColor:WILD_SAND_COLOR];
    
    [self setFormButton:[[FormButton alloc] initWithFrame:CGRectMake(10,10,tableView.frame.size.width - 20, 60)  andText:LS(@"recover_button_text") andTextColor:[UIColor whiteColor] andBgColor:MAIN_COLOR]];
    [[self formButton] addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:[self formButton]];
    
    return footerView;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return FORMS_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return LOST_PASSWORD_HEADER_HEIGHT;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return LOST_PASSWORD_FOOTER_HEIGHT;
    
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
    
    if ([[[self emailField] text] length] == 0) {

        [self presentAlertViewForForm:LS(@"error_forgotpass_invalid_email")];
        [[self formButton] setEnabled:YES];
        
    } else {
        
        [[[NotificarePushLib shared] authManager] sendPassword:[[self emailField] text] completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            if (!error) {
                [self presentAlertViewForForm:LS(@"success_forgotpass")];
                [[self formButton] setEnabled:YES];
                [[self emailField] setText:@""];
                [[self emailField] resignFirstResponder];
                [[self navigationController] popToRootViewControllerAnimated:YES];
            } else {
                [self presentAlertViewForForm:LS(@"error_forgotpass")];
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
