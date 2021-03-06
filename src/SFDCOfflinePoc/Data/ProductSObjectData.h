//
//  ProductSObjectData.h
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SObjectData.h"

/**
 * Object to hold Product information.
 *
 * @author pvmagacho
 * @version 1.0
 */
@interface ProductSObjectData : SObjectData

@property (nonatomic, copy) NSNumber *amount;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSNumber *version;

@end
