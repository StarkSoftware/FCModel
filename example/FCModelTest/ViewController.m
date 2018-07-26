//
//  ViewController.m
//  FCModelTest
//
//  Created by Marco Arment on 9/14/13.
//  Copyright (c) 2013 Marco Arment. All rights reserved.
//

#import "ViewController.h"
#import "PersonCell.h"
#import "Person.h"

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface ViewController ()
@property (nonatomic, copy) NSArray *people;
@end

@implementation ViewController

- (id)init { return [super initWithNibName:@"ViewController" bundle:nil]; }

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self clearDB];
    //UINib *cellNib = [UINib nibWithNibName:@"PersonCell" bundle:nil];
    //[self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"PersonCell"];
    
    //[self reloadPeople:nil];
    //[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reloadPeople:) name:FCModelChangeNotification object:Person.class];
}

-(void) clearDB
{
    [Person executeUpdateQuery:@"DELETE FROM $T"];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"testDB.sqlite3"]];
    
    [queue inDatabase:^(FMDatabase *db) {
        for (int i = 0; i < 3000; i++) {
            NSLog(@"ROW --> %d", i);
            Person *p = [Person new];
            
            FCModelTransactionalQuery *tt = [p saveInTransaction:^{
                p.name = [NSString stringWithFormat:@"%d ,%@", i, [RandomThings randomName]];
                p.colorName = @"FF3838";
            }];
            
            [db executeUpdate:tt.query withArgumentsInArray:tt.args];
            
            NSLog(@"RES");
            /*
            NSLog(@"ROW --> %@", [p saveInTransaction:^{
             
            }]);
             */
        }
    }];
    
}

- (void)reloadPeople:(NSNotification *)notification
{
    self.people = [Person allInstances];
    NSLog(@"Reloading with %lu people", (unsigned long) self.people.count);
    [self.collectionView reloadData];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:FCModelChangeNotification object:Person.class];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [Person executeUpdateQuery:self.queryField.text arguments:nil];
    return NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return 1; }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.people.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PersonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PersonCell" forIndexPath:indexPath];
    [cell configureWithPerson:self.people[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Person *p = (Person *) self.people[indexPath.row];
    [p save:^{
        p.taps++;
    }];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


@end
