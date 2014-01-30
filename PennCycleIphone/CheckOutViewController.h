//
//  CheckOutViewController.h
//  penncycle
//
//  Created by Peter Bryan on 1/30/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CheckOutViewController : UIViewController{
    NSMutableArray *bikes;
}

@property (weak, nonatomic) IBOutlet UITableView *bikeTable;

@end
