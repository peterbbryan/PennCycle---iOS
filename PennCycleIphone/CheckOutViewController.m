//
//  CheckOutViewController.m
//  penncycle
//
//  Created by Peter Bryan on 1/30/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import "CheckOutViewController.h"
#import "ASIFormDataRequest.h"
#import "CheckInViewController.h"

@interface CheckOutViewController ()

@end

@implementation CheckOutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
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
                
            }
            else{
            
                CheckInViewController *begin = [self.storyboard instantiateViewControllerWithIdentifier:@"checkin"];
                [self.navigationController pushViewController: begin animated:NO];
                return;
                
            }
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    
    
    self.navigationItem.hidesBackButton = YES;
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/bike_data/"];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        
        NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSMutableArray *newArray = [NSMutableArray array];
        bikes = array;
        
        for (NSDictionary *i in bikes){
            NSMutableDictionary *dict = [i mutableCopy];
            NSNumber *latitude = [i objectForKey:@"latitude"];
            NSNumber *longitude = [i objectForKey:@"longitude"];
            CLLocation *local = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            CLLocation *currentLocation = locationManager.location;
            int path = [bikes indexOfObject:i];
            [dict setObject:[NSNumber numberWithDouble:[currentLocation distanceFromLocation:local]] forKey:@"distance"];
            [newArray addObject:dict];
        }
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        bikes = [newArray sortedArrayUsingDescriptors:[NSMutableArray arrayWithObject:descriptor]];
        
        bikes = [bikes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(status == %@)", @"available"]];
        
        [_bikeTable reloadData];
        
    }];
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Available bikes (ranked by distance)";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return bikes.count;
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
    
    NSMutableDictionary *bike = [bikes objectAtIndex:indexPath.row];
    cell.textLabel.text = [[[[[bike objectForKey:@"location"] stringByAppendingString:@": #"] stringByAppendingString:[bike objectForKey:@"name"]] stringByAppendingString:@", "] stringByAppendingString:[bike objectForKey:@"manufacturer"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/checkout/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:[prefs objectForKey:@"penncard"] forKey:@"penncard"];
    [request setPostValue:[prefs objectForKey:@"pin"] forKey:@"pin"];
    [request setPostValue:[[bikes objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"bike"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        
        NSData *response = [request responseData];
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
                
        if(![dict objectForKey:@"error"]){
            
            [prefs setObject:[dict objectForKey:@"combo"] forKey:@"combo"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:[@"Bike checked out successfully! Combo: " stringByAppendingString:[dict objectForKey:@"combo"]] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
            
            CheckInViewController *begin = [self.storyboard instantiateViewControllerWithIdentifier:@"checkin"];
            [self.navigationController pushViewController: begin animated:NO];
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[dict objectForKey:@"error"] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
