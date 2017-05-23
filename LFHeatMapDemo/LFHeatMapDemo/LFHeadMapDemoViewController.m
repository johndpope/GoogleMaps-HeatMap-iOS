//
//  LFHeadMapDemoViewController.m
//  LFHeatMapDemo
//
//  Created by Marla Na on 4/20/17.
//  Copyright (c) 2017 Marla Na. All rights reserved.
//

#import "LFHeadMapDemoViewController.h"
#import "LFHeatMap.h"
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface LFHeadMapDemoViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) GMSMapView *mapView;
@property (nonatomic, weak) IBOutlet MKMapView *mapViewt;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NSMutableArray *locations;
@property (nonatomic) NSMutableArray *weights;


@end


@implementation LFHeadMapDemoViewController

static NSString *const kLatitude = @"latitude";
static NSString *const kLongitude = @"longitude";
static NSString *const kMagnitude = @"magnitude";
float minlatitude;
float minlongitude;
float maxlatitude;
float maxlongitude;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get data
   NSString *dataFile = [[NSBundle mainBundle] pathForResource:@"quake" ofType:@"plist"];
    NSArray *quakeData = [[NSArray alloc] initWithContentsOfFile:dataFile];
    
    self.locations = [[NSMutableArray alloc] initWithCapacity:[quakeData count]];
    self.weights = [[NSMutableArray alloc] initWithCapacity:[quakeData count]];
    for (NSDictionary *reading in quakeData)
    {
        CLLocationDegrees latitude = [[reading objectForKey:kLatitude] doubleValue];
        CLLocationDegrees longitude = [[reading objectForKey:kLongitude] doubleValue];
        double magnitude = [[reading objectForKey:kMagnitude] doubleValue];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [self.locations addObject:location];
        
        [self.weights addObject:[NSNumber numberWithInteger:(magnitude * 10)]];
    }
    
    minlatitude = 90;
    minlongitude = 180;
    maxlatitude = 0;
    maxlongitude = -180;
    for(CLLocation *location in self.locations)
    {
        if(location.coordinate.latitude < minlatitude){
            minlatitude = location.coordinate.latitude;
        }
        if(location.coordinate.longitude < minlongitude){
            minlongitude = location.coordinate.longitude;
        }
        if(location.coordinate.latitude > maxlatitude) {
            maxlatitude = location.coordinate.latitude;
        }
        if(location.coordinate.longitude > maxlongitude){
            maxlongitude = location.coordinate.longitude;
        }
    }
    float a = maxlatitude - minlatitude;
    float b = maxlongitude - minlongitude;
    
    
    // set map region
   MKCoordinateSpan span = MKCoordinateSpanMake(10.0, 13.0);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(39.0, -77.0);
    self.mapViewt.region = MKCoordinateRegionMake(center, span);
    
    
    // create the map, set the delegate and initial camera, and add it to self.view
    [self.view layoutIfNeeded];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.5463 longitude:-81.3456 zoom:2];
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.delegate = self;
  //  _mapView.frame = CGRectMake(0, 0, 320, 568);
    [self.view addSubview:self.mapView];
    
    // create some markers so we have something to tap
    GMSMarker *marker1 = [[GMSMarker alloc] init];
    marker1.position = CLLocationCoordinate2DMake(28.5165, -81.3455);
    marker1.title = @"This is marker 1";
    marker1.map = self.mapView;
    
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake(28.5475, -81.3443);
    marker2.title = @"This is marker 2";
    marker2.map = self.mapView;

    
    
    // create overlay view for the heatmap image
   self.imageView = [[UIImageView alloc] initWithFrame:_mapView.frame];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.imageView];
    
    // show initial heat map
   /* self.slider.value = 0.5;
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 1;
    self.slider.alpha = 1; */
    [self sliderChanged:self.slider];
    

}

- (void)sliderChanged:(UISlider *)slider
{
    float boost = slider.value;
    UIImage *heatmap = [LFHeatMap heatMapForMapView:self.mapView boost:boost locations:self.locations weights:self.weights marla:self.mapViewt];
  // self.imageView.image = heatmap;
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(minlatitude-8 ,minlongitude);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(maxlatitude+8,maxlongitude);
    
    GMSCoordinateBounds *overlayBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:southWest
                                                                              coordinate:northEast];

    UIImage *icon = heatmap;
    GMSGroundOverlay *overlay =  [GMSGroundOverlay groundOverlayWithBounds:overlayBounds icon:icon];
    overlay.bearing = 0;
    overlay.map = _mapView;
    
    
   /* CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(28.5463,-81.3456);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(44.2,-120.1);
    
    GMSCoordinateBounds *overlayBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:southWest
                                                                              coordinate:northEast];
    UIImage *icon = [UIImage imageNamed:@"newark_nj_1922"];
    
    GMSGroundOverlay *overlay =
    [GMSGroundOverlay groundOverlayWithBounds:overlayBounds icon:heatmap];
    overlay.map = _mapView;*/
    
    
}

@end
