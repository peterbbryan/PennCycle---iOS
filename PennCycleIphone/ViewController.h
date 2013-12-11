//
//  ViewController.h
//  PennCycleIphone
//
//  Created by Peter Bryan on 10/19/13.
//  Copyright (c) 2013 PeterBryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *maps;
@property (weak, nonatomic) IBOutlet UITextField *pennCardTextField;

@end
