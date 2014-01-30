//
//  CheckInViewController.h
//  penncycle
//
//  Created by Peter Bryan on 1/20/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CheckInViewController : UIViewController <CLLocationManagerDelegate>{
    NSMutableArray *stations;
}

@property (weak, nonatomic) IBOutlet UITableView *stationTable;
@property (weak, nonatomic) IBOutlet UILabel *nearest;

@end
