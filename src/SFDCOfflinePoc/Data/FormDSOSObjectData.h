//
//  FormDSOSObjectData.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SObjectData.h"

/**
 * Object to hold FormDSO information.
 *
 * @author pvmagacho
 * @version 1.0
 */
@interface FormDSOSObjectData : SObjectData

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *locationName;
@property (nonatomic, copy) NSString *shipTo;

@end
