//
//  PINViewController.h
//  penncycle
//
//  Created by Peter Bryan on 1/26/14.
//  Copyright (c) 2014 PeterBryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PINViewController : UIViewController

@property (strong, nonatomic) NSString *penncard;
@property (weak, nonatomic) IBOutlet UITextField *pinField;

@end
