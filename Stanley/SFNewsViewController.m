//
//  SFNewsViewController.m
//  Stanley
//
//  Created by Eric Horacek on 2/15/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "SFNewsViewController.h"
#import "Announcement.h"
#import "SFAnnouncementTableViewCell.h"

NSString * const SFNewsTableViewCellReuseIdentifier = @"SFNewsTableViewCellReuseIdentifier";

@interface SFNewsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)reloadData;

@end

@implementation SFNewsViewController

- (void)loadView
{
    self.tableView = [[MSPlainTableView alloc] init];
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 110.0;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Announcement"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:@"dayPublished"
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error;
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    NSAssert2(fetchSuccessful, @"Unable to fetch %@, %@", fetchRequest.entityName, [error debugDescription]);
    
    [self.tableView registerClass:SFAnnouncementTableViewCell.class forCellReuseIdentifier:SFNewsTableViewCellReuseIdentifier];
    
    [self reloadData];
}

#pragma mark - SFFilmsViewController

- (void)reloadData
{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/announcements.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"Fetched announcements %@", [mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Announcement load failed with error: %@", error);
    }];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFAnnouncementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SFNewsTableViewCellReuseIdentifier];
    Announcement *announcement = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.announcement = announcement;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    NSString *title;
    if (sectionInfo.objects.count != 0) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.doesRelativeDateFormatting = YES;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        Announcement *announcement = sectionInfo.objects[0];
        title = [dateFormatter stringFromDate:[announcement.published beginningOfDay]];
    }
    return [title uppercaseString];
}

- (NSString *)tableView:(UITableView *)tableView detailForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    NSString *detail;
    if (sectionInfo.objects.count != 0) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEEE, MMM d";
        Announcement *announcement = sectionInfo.objects[0];
        detail = [dateFormatter stringFromDate:[announcement.published beginningOfDay]];
    }
    return [detail uppercaseString];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MSPlainTableViewHeaderView *headerView = [[MSPlainTableViewHeaderView alloc] init];
    headerView.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerView.detailTextLabel.text = [self tableView:tableView detailForHeaderInSection:section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26.0;
}

@end
