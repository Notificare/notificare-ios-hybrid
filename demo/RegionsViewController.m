//
//  RegionsViewController.m
//  hybrid
//
//  Created by Joel Oliveira on 29/01/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "RegionsViewController.h"
#import "AppDelegate.h"
#import "NotificarePushLib.h"
#import "RegionsMarker.h"

#define MAP_PADDING 20

@interface RegionsViewController ()

@property (nonatomic, strong) IBOutlet MKMapView * mapView;
@property (nonatomic, strong) NSMutableArray * circles;
@property (nonatomic, strong) NSMutableArray * markers;
@property (nonatomic, strong) NSMutableArray * overlays;


@end

@implementation RegionsViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
    
    [self setTitle:LS(@"title_regions")];
    
    [self setupNavigationBar];
    
    
    [[self mapView] setDelegate:self];
    
    if([[NotificarePushLib shared] locationServicesEnabled]){
        [[self mapView] setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
        [[self mapView] setShowsUserLocation:YES];
    }
    
    [[self mapView] setMapType:MKMapTypeStandard];
    [[self mapView] setShowsPointsOfInterest:YES];
    [[self mapView] setShowsBuildings:NO];

    
}

-(void)setupNavigationBar{
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftButton setTintColor:MAIN_COLOR];
    [[self navigationItem] setLeftBarButtonItem:leftButton];
    
}

-(void)back{
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
}

-(void)populateMap{
    
    
    [[self mapView] removeOverlays:[self overlays]];
    [[self mapView] removeAnnotations:[self markers]];
    
    NSMutableArray * markers = [NSMutableArray array];
    NSMutableArray * regions = [NSMutableArray array];
    

    [[NotificarePushLib shared] doCloudHostOperation:@"GET" path:@"/region" URLParams:@{@"skip":@"0",@"limit":@"250"} customHeaders:nil bodyJSON:nil completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (response && [response objectForKey:@"regions"] && [[response objectForKey:@"regions"] count] > 0) {
                
                for (NSDictionary * region in [response objectForKey:@"regions"]) {
                    
                    if (region && ![[region objectForKey:@"advancedGeometry"] isKindOfClass:[NSNull class]]) {
                        
                        NSMutableArray * coordinates = [[[region objectForKey:@"advancedGeometry"] objectForKey:@"coordinates"] objectAtIndex:0];
                        
                        CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * [coordinates count]);
                        
                        for (int i=0; i < [coordinates count]; i++) {
                            NSArray * c = [coordinates objectAtIndex:i];
                            coords[i] = CLLocationCoordinate2DMake([[c objectAtIndex:1] floatValue], [[c objectAtIndex:0] floatValue]);
                        }
                        
                        MKPolygon * polygon = [MKPolygon polygonWithCoordinates:coords count:[coordinates count]];
                        
                        NSMutableArray * points = [[region objectForKey:@"geometry"] objectForKey:@"coordinates"];
                        CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[points objectAtIndex:1] floatValue], [[points objectAtIndex:0] floatValue]);
                        
                        RegionsMarker *annotation = [[RegionsMarker alloc] initWithName:[region objectForKey:@"name"] address:(![[region objectForKey:@"address"] isKindOfClass:[NSNull class]]) ? [region objectForKey:@"address"] : @"" coordinate:center] ;
                        [markers addObject:annotation];
                        
                        [regions addObject:polygon];
                        
                    } else {
                        
                        NSMutableArray * coordinates = [[region objectForKey:@"geometry"] objectForKey:@"coordinates"];
                        CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[coordinates objectAtIndex:1] floatValue], [[coordinates objectAtIndex:0] floatValue]);
                        RegionsMarker *annotation = [[RegionsMarker alloc] initWithName:[region objectForKey:@"name"] address: (![[region objectForKey:@"address"] isKindOfClass:[NSNull class]]) ? [region objectForKey:@"address"] : @"" coordinate:center];
                        [markers addObject:annotation];
                        MKCircle *circle = [MKCircle circleWithCenterCoordinate:center radius:[[region objectForKey:@"distance"] floatValue]];
                        [regions addObject:circle];
                        
                    }
                    
                }
                
                
            }
            
            [self setOverlays:regions];
            [self setMarkers:markers];
            [[self mapView] addOverlays:regions];
            [[self mapView] addAnnotations:markers];
        }
    }];
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    static NSString *identifier = @"RegionsMarker";
    
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
    }
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:YES];
    [annotationView setImage:(annotation == [mapView userLocation]) ? [UIImage imageNamed:@"userLocation"] : [UIImage imageNamed:@"regionLocation"]];
    
    [annotationView setAnnotation:annotation];
    [annotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    
    return annotationView;
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay{
    
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        [circleView setFillColor:MAIN_COLOR];
        [circleView setStrokeColor:[UIColor clearColor]];
        [circleView setAlpha:0.5f];
        return circleView;
    } else {
        
        MKPolygonRenderer * polygonView = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        [polygonView setFillColor:MAIN_COLOR];
        [polygonView setStrokeColor:[UIColor clearColor]];
        [polygonView setAlpha:0.5f];
        return polygonView;
    }
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
}


- (void)setRegion:(MKMapView *)mapView{
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate([annotation coordinate]);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(MAP_PADDING, MAP_PADDING, MAP_PADDING, MAP_PADDING) animated:YES];
    
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if([view annotation] != [mapView userLocation]){
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[view annotation] coordinate].latitude,[[view annotation] coordinate].longitude);
        
        //create MKMapItem out of coordinates
        MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
        
        if (destination && [destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)]){
            
            //iOS 6
            [destination setName:[[view annotation] title]];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                           addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, destination, nil]
                           launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                     forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
            
            
            [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeDriving:MKLaunchOptionsDirectionsModeKey}];
            
        } else{
            
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]){
                
                NSString* url = [NSString stringWithFormat: @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=transit",[[mapView userLocation] coordinate].latitude,[[mapView userLocation] coordinate].longitude,[[view annotation] coordinate].latitude,[[view annotation] coordinate].longitude];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
                
            }else{
                //using iOS 5 which has the Google Maps application
                NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",[[mapView userLocation] coordinate].latitude,[[mapView userLocation] coordinate].longitude,[[view annotation] coordinate].latitude,[[view annotation] coordinate].longitude];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
            }
            
        }
    }
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
    
    [self populateMap];
    
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
