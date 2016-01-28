//
//  SampleRequestDetailViewController.h
//  SFDCOfflinePoc
//
//  Created by PAULO VITOR MAGACHO DA SILVA on 1/24/16.
//  Copyright © 2016 Topcoder Inc. All rights reserved.
//

#import "SampleRequestDetailViewController.h"
#import "SampleRequestSObjectDataSpec.h"
#import "SampleRequestSObjectData.h"
#import "ProductSObjectData.h"
#import "ContactSObjectData.h"

#define kTagContact 1000
#define kTagProduct 1001
#define kTagStatus 1002

@interface SampleRequestDetailViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) SampleRequestSObjectData *sampleRequest;
@property (nonatomic, strong) SObjectDataManager *dataMgr;
@property (nonatomic, copy) void (^saveBlock)(void);
@property (nonatomic, strong) NSArray *dataRows;
@property (nonatomic, strong) NSArray *sampleRequestDataRows;
@property (nonatomic, strong) NSArray *deleteButtonDataRow;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL sampleRequestUpdated;
@property (nonatomic, assign) BOOL isNewSampleRequest;

@property (nonatomic, assign) NSInteger editTextTag;
@property (nonatomic, strong) NSArray *statusArray;
@property (nonatomic, strong) ContactSObjectData *contactObject;
@property (nonatomic, strong) ProductSObjectData *productObject;

// View / UI properties
@property (nonatomic, strong) UIPickerView *pickerView;

@end

@implementation SampleRequestDetailViewController {
    BOOL isCurrentUser;
}

@synthesize contactMgr;
@synthesize productMgr;

- (id)initForNewSampleRequestWithDataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock {
    return [self initWithSampleRequest:nil dataManager:dataMgr saveBlock:saveBlock];
}

- (id)initWithSampleRequest:(SampleRequestSObjectData *)sampleRequest dataManager:(SObjectDataManager *)dataMgr saveBlock:(void (^)(void))saveBlock {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (sampleRequest == nil) {
            self.isNewSampleRequest = YES;
            self.sampleRequest = [[SampleRequestSObjectData alloc] init];
        } else {
            self.isNewSampleRequest = NO;
            self.sampleRequest = sampleRequest;
        }
        self.dataMgr = dataMgr;
        self.saveBlock = saveBlock;
        self.isEditing = NO;

        self.statusArray = @[ @"Requested", @"Scheduled", @"Delivered" ];

        self.pickerView = [[UIPickerView alloc] init];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        self.pickerView.showsSelectionIndicator = YES;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    self.contactObject = self.isNewSampleRequest ? [self.contactMgr.dataRows objectAtIndex:0] : [self.contactMgr findById:self.sampleRequest.contactId];
    self.productObject = self.isNewSampleRequest ? [self.productMgr.dataRows objectAtIndex:0] : [self.productMgr findById:self.sampleRequest.productId];

    self.dataRows = [self dataRowsFromSampleRequest];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self configureInitialBarButtonItems];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    isCurrentUser = self.isNewSampleRequest || [self.sampleRequest.ownerId isEqualToString:[SObjectDataSpec currentUserID]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isNewSampleRequest) {
        [self editSampleRequest];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.sampleRequestUpdated && self.saveBlock != NULL) {
        dispatch_async(dispatch_get_main_queue(), self.saveBlock);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataRows count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SampleRequestDetailCellIdentifier";

    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSArray *sampleRequestData = self.dataRows[indexPath.section];
    if (indexPath.section < [self.sampleRequestDataRows count]) {
        if (self.isEditing) {
            cell.textLabel.text = nil;
            UITextField *editField = sampleRequestData[3];
            editField.frame = cell.contentView.bounds;
            if (sampleRequestData[1] == kSampleRequestNameField ||
                sampleRequestData[1] == kSampleRequestAuthorizedUsersField) {
                editField.delegate = self; // will disable the text field
            }
            [self textFieldAddLeftMargin:editField];
            [cell.contentView addSubview:editField];
        } else {
            UITextField *editField = sampleRequestData[3];
            [editField removeFromSuperview];
            NSString *rowValueData = sampleRequestData[2];
            cell.textLabel.text = rowValueData;
        }
    } else {
        UIButton *deleteButton = sampleRequestData[1];
        deleteButton.frame = cell.contentView.bounds;
        [cell.contentView addSubview:deleteButton];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataRows[section][0];
}

#pragma mark - UIPickerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *value = nil;

    if (self.editTextTag == kTagContact) {
        self.contactObject = [self.contactMgr.dataRows objectAtIndex:row];
        value = [self formatNameFromContact:self.contactObject];
    } else if (self.editTextTag == kTagProduct) {
        self.productObject = [self.productMgr.dataRows objectAtIndex:row];
        value = [self formatNameFromProduct:self.productObject];
    } else if (self.editTextTag == kTagStatus) {
        value = [self.statusArray objectAtIndex:row];
    }

    UITextField *textField = (UITextField *) [self.view viewWithTag:self.editTextTag];
    textField.text = value;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.editTextTag == kTagContact) {
        return self.contactMgr.dataRows.count;
    } else if (self.editTextTag == kTagProduct) {
        return self.productMgr.dataRows.count;
    } else if (self.editTextTag == kTagStatus) {
        return self.statusArray.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow: (NSInteger)row forComponent:(NSInteger)component {
    if (self.editTextTag == kTagContact) {
        ContactSObjectData *obj = [self.contactMgr.dataRows objectAtIndex:row];
        return [self formatNameFromContact:obj];
    } else if (self.editTextTag == kTagProduct) {
        return [[self.productMgr.dataRows objectAtIndex:row] name];
    } else if (self.editTextTag == kTagStatus) {
        return [self.statusArray objectAtIndex:row];
    }
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return textField.tag == kTagStatus || ((textField.tag == kTagContact || textField.tag == kTagProduct) && isCurrentUser);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (![self textFieldShouldBeginEditing:textField]) {
        return;
    }

    self.editTextTag = textField.tag;
    NSInteger row = 0;

    [self.pickerView reloadAllComponents];
    [textField reloadInputViews];

    if (self.editTextTag == kTagContact) {
        row = [self.contactMgr.dataRows indexOfObject:self.contactObject];
    } else if (self.editTextTag == kTagProduct) {
        row = [self.productMgr.dataRows indexOfObject:self.productObject];
    } else if (self.editTextTag == kTagStatus) {
        row = [self.statusArray indexOfObject:textField.text];
    }
    row = row == NSNotFound ? 0 : row;

    [self.pickerView selectRow:row inComponent:0 animated:NO];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self deleteSampleRequest];
    }
}

#pragma mark - Private methods

- (void)configureInitialBarButtonItems {
    if (self.isNewSampleRequest) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSampleRequest)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editSampleRequest)];
    }
    self.navigationItem.leftBarButtonItem = nil;
}

- (NSArray *)dataRowsFromSampleRequest {
    if (self.isNewSampleRequest) {
        self.sampleRequestDataRows = @[ @[ @"Contact",
                                     kSampleRequestContactField,
                                     [[self class] emptyStringForNullValue:[self formatNameFromContact:self.contactObject]],
                                     [self dataTextFieldPicker:[self formatNameFromContact:self.contactObject] tag:kTagContact] ],
                                  @[ @"Product",
                                     kSampleRequestProductField,
                                     [[self class] emptyStringForNullValue:[self formatNameFromProduct:self.productObject]],
                                     [self dataTextFieldPicker:[self formatNameFromProduct:self.productObject] tag:kTagProduct] ],
                                  @[ @"Quantity",
                                     kSampleRequestQuantityField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.quantity.stringValue],
                                     [self dataTextField:self.sampleRequest.quantity.stringValue] ],
                                  @[ @"Status",
                                     kSampleRequestStatusField,
                                     [[self class] emptyStringForNullValue:@"Requested"],
                                     [self dataTextFieldPicker:@"Requested" tag:kTagStatus] ],
                                  @[ @"Delivery Date",
                                     kSampleRequestDeliveryDateField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.deliveryDate],
                                    [self dataTextField:self.sampleRequest.deliveryDate] ]
                                  ];
    } else {
        self.sampleRequestDataRows = @[ @[ @"Name",
                                     kSampleRequestNameField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.name ? self.sampleRequest.name : @"Please sync"],
                                     [self dataTextField:self.sampleRequest.name ? self.sampleRequest.name : @"Please sync"] ],
                                  @[ @"Contact",
                                     kSampleRequestContactField,
                                     [[self class] emptyStringForNullValue:[self formatNameFromContact:self.contactObject]],
                                     [self dataTextFieldPicker:[self formatNameFromContact:self.contactObject] tag:kTagContact] ],
                                  @[ @"Product",
                                     kSampleRequestProductField,
                                     [[self class] emptyStringForNullValue:[self formatNameFromProduct:self.productObject]],
                                     [self dataTextFieldPicker:[self formatNameFromProduct:self.productObject] tag:kTagProduct] ],
                                  @[ @"Quantity",
                                     kSampleRequestQuantityField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.quantity.stringValue],
                                     [self dataTextField:self.sampleRequest.quantity.stringValue] ],
                                  @[ @"Status",
                                     kSampleRequestStatusField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.status],
                                     [self dataTextFieldPicker:self.sampleRequest.status tag:kTagStatus] ],
                                 @[ @"Delivery Date",
                                     kSampleRequestDeliveryDateField,
                                     [[self class] emptyStringForNullValue:self.sampleRequest.deliveryDate],
                                    [self dataTextField:self.sampleRequest.deliveryDate] ],
                                 @[ @"Authorized Users",
                                     kSampleRequestAuthorizedUsersField,
                                    [[self class] emptyStringForNullValue:[self formatAuthorizedUsers]],
                                    [self dataTextField:[self formatAuthorizedUsers]] ]

                                 ];
    }

    self.deleteButtonDataRow = @[ @"", [self deleteButtonView] ];

    NSMutableArray *workingDataRows = [NSMutableArray array];
    [workingDataRows addObjectsFromArray:self.sampleRequestDataRows];
    if (!self.isNewSampleRequest) {
        [workingDataRows addObject:self.deleteButtonDataRow];
    }
    return workingDataRows;
}

- (void)editSampleRequest {
    self.isEditing = YES;
    if (!self.isNewSampleRequest) {
        // Buttons will already be set for new contact case.
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditSampleRequest)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSampleRequest)];
    }
    [self.tableView reloadData];
    __weak SampleRequestDetailViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.dataRows[0][3] becomeFirstResponder];
    });
}

- (void)cancelEditSampleRequest {
    self.isEditing = NO;
    [self configureInitialBarButtonItems];
    [self.tableView reloadData];
}

- (void)saveSampleRequest {
    [self configureInitialBarButtonItems];

    self.sampleRequestUpdated = NO;
    for (NSArray *fieldArray in self.sampleRequestDataRows) {
        NSString *fieldName = fieldArray[1];
        NSString *origFieldData = fieldArray[2];
        id newFieldData = ((UITextField *)fieldArray[3]).text;
        if ((self.isNewSampleRequest && newFieldData) || ![newFieldData isEqualToString:origFieldData]) {
            if (fieldName == kSampleRequestContactField) {
                newFieldData = self.contactObject.objectId;
                if (!newFieldData) {
                    return;
                }
            } else if (fieldName == kSampleRequestProductField) {
                newFieldData = self.productObject.objectId;
                if (!newFieldData) {
                    return;
                }
            } else if (fieldName == kSampleRequestQuantityField) {
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                newFieldData = [f numberFromString:newFieldData];
                if (!newFieldData) {
                    return;
                }
            } else if (fieldName == kSampleRequestDeliveryDateField) {
                NSString *date = newFieldData;
                if (!date || date.length == 0) {
                    continue;
                }
            }
            [self.sampleRequest updateSoupForFieldName:fieldName fieldValue:newFieldData];
            self.sampleRequestUpdated = YES;
        }
    }

    if (self.sampleRequestUpdated) {
        if (self.isNewSampleRequest) {
            [self.dataMgr createLocalData:self.sampleRequest];
        } else {
            [self.dataMgr updateLocalData:self.sampleRequest];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.tableView reloadData];
    }
}

- (void)deleteSampleRequestConfirm {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this sample request?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)deleteSampleRequest {
    [self.dataMgr deleteLocalData:self.sampleRequest];
    self.sampleRequestUpdated = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextField *)dataTextField:(NSString *)propertyValue {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.text = propertyValue;
    return textField;
}

- (UITextField *)dataTextFieldPicker:(NSString *)propertyValue tag:(NSInteger) tag {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.delegate = self;
    textField.tag = tag;
    textField.text = propertyValue;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                   target:self action:@selector(pickerDone:)];
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:
                          CGRectMake(0, self.view.frame.size.height-
                                     self.pickerView.frame.size.height-50, 320, 50)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             doneButton, nil];
    [toolBar setItems:toolbarItems];
    textField.inputView = self.pickerView;
    textField.inputAccessoryView = toolBar;

    return textField;
}

- (UIButton *)deleteButtonView {
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setTitle:@"Delete Sample Request" forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    deleteButton.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [deleteButton addTarget:self action:@selector(deleteSampleRequestConfirm) forControlEvents:UIControlEventTouchUpInside];
    return deleteButton;
}

- (void)pickerDone:(id) sender {
    [[self.view viewWithTag:self.editTextTag] resignFirstResponder];
}

- (void)textFieldAddLeftMargin:(UITextField *)textField {
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, textField.frame.size.height)];
    leftView.backgroundColor = textField.backgroundColor;
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (NSString *)emptyStringForNullValue:(id)origValue {
    if (origValue == nil || origValue == [NSNull null]) {
        return @"";
    } else {
        return origValue;
    }
}

- (NSString *)formatAuthorizedUsers {
    NSArray *userRecords = self.sampleRequest.userRecords;
    if (!userRecords) return @"";

    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < userRecords.count; i++) {
        NSDictionary *userDict = [[userRecords objectAtIndex:i] objectForKey:@"User__r"];
        [string appendString:[userDict objectForKey:@"Name"]];
        if (i < userRecords.count - 1) {
            [string appendString:@", "];
        }
    }
    return string;
}

- (NSString *)formatNameFromProduct:(ProductSObjectData *)product {
    return product ? product.name : (self.sampleRequest.productName ? self.sampleRequest.productName : @"");
}

- (NSString *)formatNameFromContact:(ContactSObjectData *)contact {
    if (!contact) {
        return self.sampleRequest.contactName ? self.sampleRequest.contactName : @"";
    }

    NSString *firstName = [contact.firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastName = [contact.lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (firstName == nil && lastName == nil) {
        return @"";
    } else if (firstName == nil && lastName != nil) {
        return lastName;
    } else if (firstName != nil && lastName == nil) {
        return firstName;
    } else {
        return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
}

@end