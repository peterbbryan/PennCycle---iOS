//
//  MapsViewController.m
//  penncycle
//
//  Created by Peter Bryan on 4/6/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import "MapsViewController.h"
#import <MapKit/MapKit.h>

@interface MapsViewController ()

@end

@implementation MapsViewController

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
    
    
    NSString *host = @"http://www.penncycle.org/mobile";
    NSString *action = @"bike_data";
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/", host, action]]];
    
    [request setValue:@"application/json-rpc" forHTTPHeaderField:@"Content-Type"];
    
    //[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    __block NSURLResponse* theResponse = nil;
    __block NSData *theData = nil;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        theResponse = response;
        theData = data;
        
        if (!error){
            
            NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
            
            NSMutableDictionary *location;
            for (location in array){
                
                CLLocationCoordinate2D coordinate;
                NSNumber *latitude = [location objectForKey:@"latitude"];
                coordinate.latitude = latitude.doubleValue;
                NSNumber *longitude = [location objectForKey:@"longitude"];
                coordinate.longitude = longitude.doubleValue;
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = coordinate;
                annotation.title = [@"" stringByAppendingString: [NSString stringWithFormat:@"%@", [location objectForKey:@"location"]]];
                [_map addAnnotation:annotation];
                
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }];
    
    
    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(39.952, -75.195);
    MKCoordinateRegion adjustedRegion = [_map regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 2000, 2000)];
    [_map setRegion:adjustedRegion animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
