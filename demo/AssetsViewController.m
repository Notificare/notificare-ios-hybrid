//
//  AssetsViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 01/02/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "AssetsViewController.h"
#import "Definitions.h"
#import "NotificarePushLib.h"

@interface AssetsViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * gridObjects;
@property (nonatomic, strong) UIView * highlightView;
@property (nonatomic, strong) UILabel * introLabel;
@property (nonatomic, strong) UIView * introView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicatorView;

@end

@implementation AssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:LS(@"title_storage")];
    
//    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
//    [leftButton setTintColor:MAIN_COLOR];
//    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchAlert)];
//    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search"] style:UIBarButtonItemStylePlain target:self action:@selector(showSearchAlert)];
    [rightButton setTintColor:[UIColor whiteColor]];
    [[self navigationItem] setRightBarButtonItem:rightButton];
    
    [[self collectionView] setBackgroundColor:WILD_SAND_COLOR];
    [[self view] setBackgroundColor:WILD_SAND_COLOR];
    
    [self setHighlightView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)]];
    [[self highlightView] setBackgroundColor:[UIColor blackColor]];
    
    [self setActivityIndicatorView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    [[self activityIndicatorView] setCenter:CGPointMake( self.view.frame.size.width /2-5, self.view.frame.size.height /2-5)];
    [[self activityIndicatorView]  setContentMode:UIViewContentModeCenter];
    [[self activityIndicatorView] setHidden:NO];
    [[self activityIndicatorView] startAnimating];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    [self setGridObjects:[NSMutableArray array]];
    
    [self showIntroView];
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}


-(void)showIntroView{
    [self setIntroView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)]];
    
    [self setIntroLabel:[[UILabel alloc] initWithFrame:CGRectMake(40, self.view.bounds.size.height / 2 - 30, self.view.bounds.size.width - 80, 60)]];
    [[self introLabel] setText:LS(@"storage_intro_text")];
    [[self introLabel] setTextColor:MAIN_COLOR];
    [[self introLabel] setFont:PROXIMA_NOVA_THIN_FONT(16)];
    [[self introLabel] setTextAlignment:NSTextAlignmentCenter];
    [[self introLabel] setNumberOfLines:3];
    
    [[self introView] addSubview:[self introLabel]];
    [[self view] addSubview:[self introView]];
}

-(void)showSearchAlert{

    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle: APP_NAME
                                  message:LS(@"storage_search_text")
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = LS(@"type_asset_group_name");
    }];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:LS(@"search")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             
                             if([[[alert textFields][0] text] length] == 0){
                                 [self presentAlertViewForForm:LS(@"storage_search_error")];
                             } else {
                                 [self searchAssets:[[alert textFields][0] text]];
                             }
                             
                         }];
    [alert addAction:ok];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:LS(@"cancel")
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action){}];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        

        
    }];
    
}

-(void)searchAssets:(NSString *)search{
    
    [[self introLabel] setHidden:YES];
    [[self introView] addSubview:[self activityIndicatorView]];
    
    
    [[NotificarePushLib shared] fetchAssets:search completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [self setGridObjects:[NSMutableArray arrayWithArray:response]];
            [[self collectionView] reloadData];
            [[self activityIndicatorView] removeFromSuperview];
            [[self introView] removeFromSuperview];
        } else {
            [[self activityIndicatorView] removeFromSuperview];
            
            if(![[self introView] isDescendantOfView:[self view]]){
                [self showIntroView];
            }
            
            [self setGridObjects:[NSMutableArray array]];
            [[self collectionView] reloadData];
            [[self introLabel] setText:LS(@"storage_empty_text")];
            [[self introLabel] setHidden:NO];
        }
    }];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self gridObjects] count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"CollectionCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NotificareAsset * item = (NotificareAsset *)[[self gridObjects] objectAtIndex:[indexPath row]];
    
    UIImageView * image = (UIImageView *)[cell viewWithTag:100];
    
    if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"image/jpeg"] ||
       [[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"image/gif"] ||
       [[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"image/png"]){
        
        [self downloadImageWithURL:[NSURL URLWithString:[item assetUrl]] completionBlock:^(BOOL succeeded, UIImage *img) {
            if (succeeded) {
                
                [image setImage:img];
            }
        }];
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"video/mp4"]){
        
        [image setImage:[UIImage imageNamed:@"video"]];
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"application/pdf"]){
        
        [image setImage:[UIImage imageNamed:@"pdf"]];
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"application/json"]){
        
        [image setImage:[UIImage imageNamed:@"json"]];
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"text/javascript"]){
        
        [image setImage:[UIImage imageNamed:@"javascript"]];
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"text/css"]){
        
        [image setImage:[UIImage imageNamed:@"css"]];
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"text/html"]){
        
        [image setImage:[UIImage imageNamed:@"html"]];
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"audio/mp3"]){
        
        [image setImage:[UIImage imageNamed:@"sound"]];
        
    } else {
        
        [image setImage:[UIImage imageNamed:@"text"]];
    }
    
    [cell setBackgroundColor:WILD_SAND_COLOR];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NotificareAsset * item = (NotificareAsset *)[[self gridObjects] objectAtIndex:[indexPath row]];
    
    if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"image/jpeg"] ||
       [[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"image/gif"] ||
       [[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"image/png"]){
        
        
        [self downloadImageWithURL:[NSURL URLWithString:[item assetUrl]] completionBlock:^(BOOL succeeded, UIImage *img) {
            if (succeeded) {
                
                [self openHighlightView:img];
                
            }
        }];
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"video/mp4"]){
        
        
        NSURL * target = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[item assetUrl]]];
        
        if(target && [target scheme] && [target host]){
            [[UIApplication sharedApplication] openURL:target];
        }
        
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"application/pdf"]){
        
        NSURL * target = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[item assetUrl]]];
        
        if(target && [target scheme] && [target host]){
            [[UIApplication sharedApplication] openURL:target];
        }
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"text/html"]){
        
        NSURL * target = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[item assetUrl]]];
        
        if(target && [target scheme] && [target host]){
            [[UIApplication sharedApplication] openURL:target];
        }
        
    } else if([[[item assetMetaData] objectForKey:@"contentType"] isEqualToString:@"audio/mp3"]){
        
        NSURL * target = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[item assetUrl]]];
        
        if(target && [target scheme] && [target host]){
            [[UIApplication sharedApplication] openURL:target];
        }
        
    }
}

#pragma mark Collection view layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((collectionView.frame.size.width / 2)-12, 95);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2,8,0,8);  // top, left, bottom, right
}


- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url
            completionHandler:^(NSData *imageData,
                                NSURLResponse *response,
                                NSError *fileError) {

                                if ( !fileError ){
                                    
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        //useless optimization as it seems to be decoded while UIImageView is displayed
                                        UIImage *image = [UIImage imageWithData:imageData];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (image) {
                                                completionBlock(YES,image);
                                            }
                                        });
                                    });

                                } else{
                                    completionBlock(NO,nil);
                                }
                
            }] resume];
    
}

-(void)openHighlightView:(UIImage *)theImage{
    
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(10, 80, 44, 44)];
    [button addTarget:self action:@selector(closeHighlightView) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [image setImage:theImage];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    
    [[self highlightView] addSubview:image];
    [[self highlightView] addSubview:button];
    
    [[self highlightView] setAlpha:0.0];
    
    [[self view] addSubview:[self highlightView]];
    
    //fade in
    [UIView animateWithDuration:.5f animations:^{
        
        [[self highlightView] setAlpha:1.0f];
        
    } completion:nil];
    
}

-(void)closeHighlightView {

    //fade out
    [UIView animateWithDuration:.5f animations:^{
        
        [[self highlightView] setAlpha:0.0f];
        
    } completion:nil];
    
}

-(void)back{
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
