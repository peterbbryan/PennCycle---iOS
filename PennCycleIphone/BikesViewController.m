//
//  BikesViewController.m
//  penncycle
//
//  Created by Peter Bryan on 1/29/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import "BikesViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@interface BikesViewController ()

@end

@implementation BikesViewController

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

    
    NSLog([bikes description]);
    
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
