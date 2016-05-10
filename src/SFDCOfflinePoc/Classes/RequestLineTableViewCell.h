//
//  RequestLineTableViewCell.h
//  SFDCOfflinePoc
//
//  Created by PAULO VITOR MAGACHO DA SILVA on 5/6/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SampleRequestSObjectData.h"
#import "AccountSObjectData.h"
#import "ProductSObjectData.h"

@interface RequestLineTableViewCell : UITableViewCell<UITextFieldDelegate>

@property(nonatomic, strong) SampleRequestSObjectData *object;
@property(nonatomic, assign) NSArray *hcpObjects;
@property(nonatomic, assign) NSArray *productObjects;

@property IBOutlet UIButton *hcpName;
@property IBOutlet UIButton *productName;
@property IBOutlet UILabel *hospitalClinic;
@property IBOutlet UILabel *hcpId;
@property IBOutlet UILabel *specialty;
@property IBOutlet UILabel *productCode;
@property IBOutlet UITextField *quantity;
@property IBOutlet UILabel *amount;


@end
