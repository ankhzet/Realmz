//
//  AZRGoalPropertySelector.h
//  Realmz
//
//  Created by Ankh on 06.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZRObjectProperty;

typedef NS_ENUM(NSUInteger, AZRPropertySelectorComparator) {
	AZRPropertySelectorComparatorLess = 1,
	AZRPropertySelectorComparatorGreater = 2,
	AZRPropertySelectorComparatorEqual = 4,
};


@interface AZRGoalPropertySelector : NSObject

@property (nonatomic) NSString *property;
@property (nonatomic) float value;
@property (nonatomic) AZRPropertySelectorComparator comparator;

- (id) initWithPropertyName: (NSString *) name;

- (BOOL) matchProperty:(AZRObjectProperty *)property;

@end
