//
//  RequestLineTableViewCell.m
//  SFDCOfflinePoc
//
//  Created by PAULO VITOR MAGACHO DA SILVA on 5/6/16.
//  Copyright © 2016 Salesforce. All rights reserved.
//

#import "RequestLineTableViewCell.h"
#import "WYPopoverController.h"

@interface RequestLineTableViewCell ()

@property (nonatomic, strong) WYPopoverController *popOverController;

@end

@implementation RequestLineTableViewCell

@synthesize hcpObjects;
@synthesize productObjects;

- (void)awakeFromNib {
    [super awakeFromNib];

    [_quantity setText:@"0"];
    [_amount setText:@"$0.0"];
}

- (void)setObject:(SampleRequestSObjectData *)object {
    _object = object;

    if (object.accountId) {
        [_hcpName setTitle:[[self findAccount:object.accountId] name] forState:UIControlStateNormal];
    } else {
        [_hcpName setTitle:@"Select a value" forState:UIControlStateNormal];
    }
    if (object.productId) {
        [_productName setTitle:[[self findProduct:object.productId] name] forState:UIControlStateNormal];
        CGFloat value = [[[self findProduct:object.productId] amount] floatValue] * [self.object.quantity intValue];
        [_amount setText:[NSString stringWithFormat:@"%4.2f", value]];
    } else {
        [_productName setTitle:@"Select a value" forState:UIControlStateNormal];
    }
    [_hospitalClinic setText:object.accountId ? [[self findAccount:object.accountId] hospitalClinic] : @"-"];
    [_hcpId setText:object.accountId ? [[self findAccount:object.accountId] hcpId] : @"-"];
    [_specialty setText:object.accountId ? [[self findAccount:object.accountId] specialty] : @"-"];
    [_productCode setText:object.productId ? [[self findProduct:object.productId] code]: @"-"];
}

- (AccountSObjectData *)findAccount:(NSString *) objId {
    for (AccountSObjectData *obj in self.hcpObjects) {
        if ([obj.objectId isEqualToString:objId]) {
            return obj;
        }
    }
    return nil;
}

- (ProductSObjectData *)findProduct:(NSString *) objId {
    for (ProductSObjectData *obj in self.productObjects) {
        if ([obj.objectId isEqualToString:objId]) {
            return obj;
        }
    }
    return nil;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text &&
        [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        self.object.quantity = [NSNumber numberWithInt:textField.text.intValue];

        if (_object.productId) {
            CGFloat value = [[[self findProduct:self.object.productId] amount] floatValue] * [self.object.quantity intValue];
            [_amount setText:[NSString stringWithFormat:@"%4.2f", value]];
        }
    } else {
        textField.text = @"0";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // allow backspace
    if (!string.length)
    {
        return YES;
    }

    // Prevent invalid character input, if keyboard is numberpad
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            // BasicAlert(@"", @"This field accepts only numeric entries.");
            return NO;
        }
    }

    return YES;
}

@end
