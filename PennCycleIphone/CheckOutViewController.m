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
- (void)viewDidLoad
{
    self.navigationItem.hidesBackButton = YES;
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    NSURL *url = [NSURL URLWithString:@"http://www.penncycle.org/mobile/bike_data/"];
    
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
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks!" message:[@"Bike checked out successfully! Combo: " stringByAppendingString:[dict objectForKey:@"combo"]] delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
            [alert show];
            
            CheckOutViewController *begin = [self.storyboard instantiateViewControllerWithIdentifier:@"checkout"];
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
