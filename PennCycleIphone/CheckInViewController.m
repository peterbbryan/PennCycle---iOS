//
//  CheckInViewController.m
//  penncycle
//
//  Created by Peter Bryan on 1/20/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import "CheckInViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "CheckOutViewController.h"
#import <MapKit/MapKit.h>


@interface CheckInViewController ()

@end

@implementation CheckInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction)currentCombo:(id)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bike Combo" message:[prefs objectForKey:@"combo"] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    self.navigationItem.hidesBackButton = YES;
    
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
                [_maps addAnnotation:annotation];
                
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }];
    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(39.949, -75.195);
    MKCoordinateRegion adjustedRegion = [_maps regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 2000, 2000)];
    [_maps setRegion:adjustedRegion animated:YES];
    
    
    
    //Check bike
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/verify/"];
    
    ASIFormDataRequest *request2 = [ASIFormDataRequest requestWithURL:url];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [request2 setPostValue:[prefs objectForKey:@"penncard"] forKey:@"penncard"];
    [request2 setPostValue:[prefs objectForKey:@"pin"] forKey:@"pin"];
    
    [request2 startSynchronous];
    
    NSError *error = [request2 error];
    if (!error) {
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[request2 responseData] options:0 error:nil];
        
        NSLog([dict description]);
        
        if ([dict objectForKey:@"error"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            
            if ([dict objectForKey:@"current_ride"] == [NSNull null]){
                
                CheckOutViewController *begin = [self.storyboard instantiateViewControllerWithIdentifier:@"checkout"];
                [self.navigationController pushViewController: begin animated:NO];
                return;
                
            }
            else{
               
            }
            
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/station_data/"];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        
        NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSMutableArray *newArray = [NSMutableArray array];
        stations = array;
        
        for (NSDictionary *i in stations){
            NSMutableDictionary *dict = [i mutableCopy];
            NSNumber *latitude = [i objectForKey:@"latitude"];
            NSNumber *longitude = [i objectForKey:@"longitude"];
            CLLocation *local = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            CLLocation *currentLocation = locationManager.location;
            int path = [stations indexOfObject:i];
            [dict setObject:[NSNumber numberWithDouble:[currentLocation distanceFromLocation:local]] forKey:@"distance"];
            [newArray addObject:dict];
        }
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        stations = [newArray sortedArrayUsingDescriptors:[NSMutableArray arrayWithObject:descriptor]];
        
        NSLog([stations description]);
        
        [_stationTable reloadData];
        
        _nearest.text = [@"Nearest location: " stringByAppendingString:[[stations objectAtIndex:0] objectForKey:@"name"]];
        
    }];
    
	// Do any additional setup after loading the view.
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    
    cell.textLabel.text = [[stations objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/checkin/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [request setPostValue:[prefs objectForKey:@"penncard"] forKey:@"penncard"];
    [request setPostValue:[prefs objectForKey:@"pin"] forKey:@"pin"];
    [request setPostValue:[[stations objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"station"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        
        if ([dict objectForKey:@"error"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Incorrect PIN" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checked in!" message:@"Thanks for checking in your bike! Make sure to lock up!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
            
            CheckOutViewController *begin = [self.storyboard instantiateViewControllerWithIdentifier:@"checkout"];
            [self.navigationController pushViewController: begin animated:NO];
        }
    }
}

-(IBAction)checkIn:(id)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/checkin/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [request setPostValue:[prefs objectForKey:@"penncard"] forKey:@"penncard"];
    [request setPostValue:[prefs objectForKey:@"pin"] forKey:@"pin"];
    [request setPostValue:[[stations objectAtIndex:0] objectForKey:@"name"] forKey:@"station"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        
        if ([dict objectForKey:@"error"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checked in!" message:@"Thanks for checking in your bike! Make sure to lock up!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
            
            
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alert show];
    }

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"All stations (ranked by distance)";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
