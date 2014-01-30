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


- (void)viewWillAppear:(BOOL)animated
{
    
    
    //Check bike
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/student_data/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [request setPostValue:[prefs objectForKey:@"penncard"] forKey:@"penncard"];
    
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
        
        if ([dict objectForKey:@"error"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Uh, oh! Something went wrong!" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
        }
        else{
            
            if ([dict objectForKey:@"current_ride"]){
            }
            else{
                
                CheckOutViewController *begin = [self.storyboard instantiateViewControllerWithIdentifier:@"checkout"];
                [self.navigationController pushViewController: begin animated:NO];
                return;
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
