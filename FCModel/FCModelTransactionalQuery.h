//
//  FCModelTransactionalQuery.h
//  FCModelTest
//
//  Created by NUB04 on 26/07/18.
//  Copyright © 2018 Marco Arment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCModelTransactionalQuery : NSObject

@property (nonatomic, strong) NSString *query;
@property (nonatomic, strong) NSMutableArray *args;

@end
