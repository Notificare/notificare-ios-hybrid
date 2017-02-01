//
//  PreferencesViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 01/02/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "PreferencesViewController.h"
#import "Definitions.h"
#import "FormButton.h"
#import "NotificarePushLib.h"

@interface PreferencesViewController ()

@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UITableViewController * tableViewController;
@property (nonatomic, strong) NSMutableArray * navSections;
@property (nonatomic, strong) NSMutableArray * sectionTitles;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:LS(@"loading")];
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:MAIN_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    [[self tableView] setBackgroundColor:WILD_SAND_COLOR];
    [[self view] setBackgroundColor:WILD_SAND_COLOR];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    [self setTitle:LS([[self preference] preferenceLabel])];
    
    [self setNavSections:[NSMutableArray array]];
    
    NSMutableArray * segments = [NSMutableArray array];
    for (NotificareSegment * seg in [[self preference] preferenceOptions]) {
        [segments addObject:seg];
    }
    
    [[self navSections] addObject:segments];
    
    [self setSectionTitles:[NSMutableArray array]];
    [[self sectionTitles] addObject:LS([[self preference] preferenceLabel])];
    
    [[self tableView] reloadData];
    
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
    
    NotificareSegment * item = (NotificareSegment *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    
    [[cell textLabel] setText:[item segmentLabel]];
    [[cell textLabel] setFont:LATO_LIGHT_FONT(14)];
    
    if([[[self preference] preferenceType] isEqualToString:@"choice"]){
        
        if([item selected]){
            
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    if([[[self preference] preferenceType] isEqualToString:@"select"]){
        
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [cell setAccessoryView:mySwitch];
        [mySwitch setTag:(([indexPath section] * 100) + [indexPath row])];
        
        if([item selected]){
            [mySwitch setOn:YES];
        }
        
        [mySwitch addTarget:self action:@selector(OnSegmentsChanged:) forControlEvents:UIControlEventValueChanged];
        
    }
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return DEFAULT_CELLHEIGHT;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.001;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.001;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if([[[self preference] preferenceType] isEqualToString:@"choice"]){
        
        NotificareSegment * item = (NotificareSegment *)[[[self navSections] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
        
        UITableViewCell * checkCell = [tableView cellForRowAtIndexPath:indexPath];
        
        if([checkCell accessoryType] != UITableViewCellAccessoryCheckmark){
            
            checkCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [[NotificarePushLib shared] addSegment:item toPreference:[self preference] completionHandler:^(NSDictionary *info) {
                [self back];
            } errorHandler:^(NSError *error) {
                //
            }];
            
        }
        
    }
    
}


-(void)OnSegmentsChanged:(id)sender{
    
    UISwitch *tempSwitch = (UISwitch *)sender;
    NotificareSegment * item = [[[self navSections] objectAtIndex:[tempSwitch tag] / 100] objectAtIndex:[tempSwitch tag] % 100];
    
    if([tempSwitch isOn]){
        
        [[NotificarePushLib shared] addSegment:item toPreference:[self preference] completionHandler:^(NSDictionary *info) {
            //
        } errorHandler:^(NSError *error) {
            //
        }];
        
    }else{
        
        [[NotificarePushLib shared] removeSegment:item fromPreference:[self preference] completionHandler:^(NSDictionary *info) {
            //
        } errorHandler:^(NSError *error) {
            //
        }];
        
    }
    
}


-(void)back{
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
