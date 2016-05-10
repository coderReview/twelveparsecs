//
//  ProductSObjectDataSpec.m
//  SFDCOfflinePoc
//
//  Created by pvmagacho on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "ProductSObjectDataSpec.h"
#import "ProductSObjectData.h"

NSString * const kProductAmountField        = ADD_NAMESPACE(@"Amount__c");
NSString * const kProductCodeField          = ADD_NAMESPACE(@"Code__c");
NSString * const kProductVersionField       = ADD_NAMESPACE(@"Version__c");

@implementation ProductSObjectDataSpec

- (id)init {
    NSString *objectType = ADD_NAMESPACE(@"KSRA_Product__c");
    NSArray *objectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kSObjectIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectOwnerIdField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductAmountField searchable:NO],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductCodeField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductVersionField searchable:YES]
                                   ];
    NSArray *updateObjectFieldSpecs = @[ [[SObjectDataFieldSpec alloc] initWithFieldName:kObjectNameField searchable:YES],
                                   [[SObjectDataFieldSpec alloc] initWithFieldName:kProductAmountField searchable:NO],
                                         [[SObjectDataFieldSpec alloc] initWithFieldName:kProductCodeField searchable:YES],
                                         [[SObjectDataFieldSpec alloc] initWithFieldName:kProductVersionField searchable:YES]
                                   ];

    // Any searchable fields would likely require index specs, if you're searching directly against SmartStore.
    NSArray *indexSpecs = @[ [[SFSoupIndex alloc] initWithPath:kObjectNameField indexType:kSoupIndexTypeString columnName:kObjectNameField],
                             [[SFSoupIndex alloc] initWithPath:kProductCodeField indexType:kSoupIndexTypeString columnName:kProductCodeField]
                             ];
    NSString *soupName = @"Products";
    NSString *orderByFieldName = kObjectNameField;
    
    
    // ktb 1.27.2016 took this out since I want to show all products.
    //self.whereClause = [NSString stringWithFormat:@"OwnerId = '%@'", [self.class currentUserID]];

    return [self initWithObjectType:objectType objectFieldSpecs:objectFieldSpecs updateObjectFieldSpecs:updateObjectFieldSpecs
                         indexSpecs:indexSpecs soupName:soupName orderByFieldName:orderByFieldName];
}

#pragma mark - Abstract overrides

+ (SObjectData *)createSObjectData:(NSDictionary *)soupDict {
    return [[ProductSObjectData alloc] initWithSoupDict:soupDict];
}

@end
