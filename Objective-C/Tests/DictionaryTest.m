//
//  DictionaryTest.m
//  CouchbaseLite
//
//  Copyright (c) 2017 Couchbase, Inc All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CBLTestCase.h"

@interface DictionaryTest : CBLTestCase

@end

@implementation DictionaryTest


- (void) testCreateDictionary {
    CBLMutableDictionary* address = [[CBLMutableDictionary alloc] init];
    AssertEqual(address.count, 0u);
    AssertEqualObjects([address toDictionary], @{});
    
    CBLMutableDocument* doc = [self createDocument: @"doc1"];
    [doc setValue: address forKey: @"address"];
    AssertEqual([doc dictionaryForKey: @"address"], address);
    
    CBLDocument* savedDoc = [self saveDocument: doc];
    AssertEqualObjects([[savedDoc dictionaryForKey: @"address"] toDictionary], @{});
}


- (void) testCreateDictionaryWithNSDictionary {
    NSDictionary* dict = @{@"street": @"1 Main street",
                           @"city": @"Mountain View",
                           @"state": @"CA"};
    CBLMutableDictionary* address = [[CBLMutableDictionary alloc] initWithData: dict];
    AssertEqualObjects([address valueForKey: @"street"], @"1 Main street");
    AssertEqualObjects([address valueForKey: @"city"], @"Mountain View");
    AssertEqualObjects([address valueForKey: @"state"], @"CA");
    AssertEqualObjects([address toDictionary], dict);
    
    CBLMutableDocument* doc = [self createDocument: @"doc1"];
    [doc setValue: address forKey: @"address"];
    AssertEqual([doc dictionaryForKey: @"address"], address);
    
    CBLDocument* savedDoc = [self saveDocument: doc];
    AssertEqualObjects([[savedDoc dictionaryForKey: @"address"] toDictionary], dict);
}


- (void) testGetValueFromNewEmptyDictionary {
    CBLMutableDictionary* dict = [[CBLMutableDictionary alloc] init];
    
    AssertEqual([dict integerForKey: @"key"], 0);
    AssertEqual([dict floatForKey: @"key"], 0.0f);
    AssertEqual([dict doubleForKey: @"key"], 0.0);
    AssertEqual([dict booleanForKey: @"key"], NO);
    AssertNil([dict blobForKey: @"key"]);
    AssertNil([dict dateForKey: @"key"]);
    AssertNil([dict numberForKey: @"key"]);
    AssertNil([dict valueForKey: @"key"]);
    AssertNil([dict stringForKey: @"key"]);
    AssertNil([dict dictionaryForKey: @"key"]);
    AssertNil([dict arrayForKey: @"key"]);
    AssertEqualObjects([dict toDictionary], @{});
    
    CBLMutableDocument* doc = [[CBLMutableDocument alloc] initWithID: @"doc1"];
    [doc setValue: dict forKey: @"dict"];
    
    CBLDocument* savedDoc = [self saveDocument: doc];
    CBLDictionary* savedDict = [savedDoc dictionaryForKey: @"dict"];
    AssertEqual([savedDict integerForKey: @"key"], 0);
    AssertEqual([savedDict floatForKey: @"key"], 0.0f);
    AssertEqual([savedDict doubleForKey: @"key"], 0.0);
    AssertEqual([savedDict booleanForKey: @"key"], NO);
    AssertNil([savedDict blobForKey: @"key"]);
    AssertNil([savedDict dateForKey: @"key"]);
    AssertNil([savedDict numberForKey: @"key"]);
    AssertNil([savedDict valueForKey: @"key"]);
    AssertNil([savedDict stringForKey: @"key"]);
    AssertNil([savedDict dictionaryForKey: @"key"]);
    AssertNil([savedDict arrayForKey: @"key"]);
    AssertEqualObjects([savedDict toDictionary], @{});
}


- (void) testSetNestedDictionaries {
    CBLMutableDocument* doc = [self createDocument: @"doc1"];
    
    CBLMutableDictionary *level1 = [[CBLMutableDictionary alloc] init];
    [level1 setValue: @"n1" forKey: @"name"];
    [doc setValue: level1 forKey: @"level1"];
    
    CBLMutableDictionary *level2 = [[CBLMutableDictionary alloc] init];
    [level2 setValue: @"n2" forKey: @"name"];
    [level1 setValue: level2 forKey: @"level2"];
    
    CBLMutableDictionary *level3 = [[CBLMutableDictionary alloc] init];
    [level3 setValue: @"n3" forKey: @"name"];
    [level2 setValue: level3 forKey: @"level3"];
    
    AssertEqualObjects([doc dictionaryForKey: @"level1"], level1);
    AssertEqualObjects([level1 dictionaryForKey: @"level2"], level2);
    AssertEqualObjects([level2 dictionaryForKey: @"level3"], level3);
    NSDictionary* dict = @{@"level1": @{@"name": @"n1",
                                        @"level2": @{@"name": @"n2",
                                                     @"level3": @{@"name": @"n3"}}}};
    AssertEqualObjects([doc toDictionary], dict);
    
    CBLDocument* savedDoc = [self saveDocument: doc];
    
    Assert([savedDoc dictionaryForKey: @"level1"] != level1);
    AssertEqualObjects([savedDoc toDictionary], dict);
}


- (void) testDictionaryArray {
    CBLMutableDocument* doc = [self createDocument: @"doc1"];
    NSArray* data = @[@{@"name": @"1"}, @{@"name": @"2"}, @{@"name": @"3"}, @{@"name": @"4"}];
    [doc setData: @{@"dicts": data}];
    
    CBLMutableArray* dicts = [doc arrayForKey: @"dicts"];
    AssertEqual(dicts.count, 4u);
    
    CBLMutableDictionary* d1 = [dicts dictionaryAtIndex: 0];
    CBLMutableDictionary* d2 = [dicts dictionaryAtIndex: 1];
    CBLMutableDictionary* d3 = [dicts dictionaryAtIndex: 2];
    CBLMutableDictionary* d4 = [dicts dictionaryAtIndex: 3];
    
    AssertEqualObjects([d1 stringForKey: @"name"], @"1");
    AssertEqualObjects([d2 stringForKey: @"name"], @"2");
    AssertEqualObjects([d3 stringForKey: @"name"], @"3");
    AssertEqualObjects([d4 stringForKey: @"name"], @"4");
    
    CBLDocument* savedDoc = [self saveDocument: doc];
    
    CBLArray* savedDicts = [savedDoc arrayForKey: @"dicts"];
    AssertEqual(savedDicts.count, 4u);
    
    CBLDictionary* savedD1 = [savedDicts dictionaryAtIndex: 0];
    CBLDictionary* savedD2 = [savedDicts dictionaryAtIndex: 1];
    CBLDictionary* savedD3 = [savedDicts dictionaryAtIndex: 2];
    CBLDictionary* savedD4 = [savedDicts dictionaryAtIndex: 3];
    
    AssertEqualObjects([savedD1 stringForKey: @"name"], @"1");
    AssertEqualObjects([savedD2 stringForKey: @"name"], @"2");
    AssertEqualObjects([savedD3 stringForKey: @"name"], @"3");
    AssertEqualObjects([savedD4 stringForKey: @"name"], @"4");
}


- (void) testReplaceDictionary {
    CBLMutableDocument* doc = [self createDocument: @"doc1"];
    CBLMutableDictionary *profile1 = [[CBLMutableDictionary alloc] init];
    [profile1 setValue: @"Scott Tiger" forKey: @"name"];
    [doc setValue: profile1 forKey: @"profile"];
    AssertEqualObjects([doc dictionaryForKey: @"profile"], profile1);
    
    CBLMutableDictionary *profile2 = [[CBLMutableDictionary alloc] init];
    [profile2 setValue: @"Daniel Tiger" forKey: @"name"];
    [doc setValue: profile2 forKey: @"profile"];
    AssertEqualObjects([doc dictionaryForKey: @"profile"], profile2);
    
    // Profile1 should be now detached:
    [profile1 setValue: @(20) forKey: @"age"];
    AssertEqualObjects([profile1 valueForKey: @"name"], @"Scott Tiger");
    AssertEqualObjects([profile1 valueForKey: @"age"], @(20));
    
    // Check profile2:
    AssertEqualObjects([profile2 valueForKey: @"name"], @"Daniel Tiger");
    AssertNil([profile2 valueForKey: @"age"]);
    
    // Save:
    CBLDocument* savedDoc = [self saveDocument: doc];
    
    Assert([savedDoc dictionaryForKey: @"profile"] != profile2);
    CBLDictionary* savedProfile2 = [savedDoc dictionaryForKey: @"profile"];
    AssertEqualObjects([savedProfile2 valueForKey: @"name"], @"Daniel Tiger");
}


- (void) testReplaceDictionaryDifferentType {
    CBLMutableDocument* doc = [self createDocument: @"doc1"];
    CBLMutableDictionary *profile1 = [[CBLMutableDictionary alloc] init];
    [profile1 setValue: @"Scott Tiger" forKey: @"name"];
    [doc setValue: profile1 forKey: @"profile"];
    AssertEqualObjects([doc dictionaryForKey: @"profile"], profile1);
    
    // Set string value to profile:
    [doc setValue: @"Daniel Tiger" forKey: @"profile"];
    AssertEqualObjects([doc valueForKey: @"profile"], @"Daniel Tiger");
    
    // Profile1 should be now detached:
    [profile1 setValue: @(20) forKey: @"age"];
    AssertEqualObjects([profile1 valueForKey: @"name"], @"Scott Tiger");
    AssertEqualObjects([profile1 valueForKey: @"age"], @(20));

    // Check whether the profile value has no change:
    AssertEqualObjects([doc valueForKey: @"profile"], @"Daniel Tiger");
    
    // Save:
    CBLDocument* savedDoc = [self saveDocument: doc];
    
    AssertEqualObjects([savedDoc valueForKey: @"profile"], @"Daniel Tiger");
}


- (void) testRemoveDictionary {
    CBLMutableDocument* doc = [self createDocument: @"doc1"];
    CBLMutableDictionary *profile1 = [[CBLMutableDictionary alloc] init];
    [profile1 setValue: @"Scott Tiger" forKey: @"name"];
    [doc setValue: profile1 forKey: @"profile"];
    AssertEqualObjects([doc dictionaryForKey: @"profile"], profile1);
    Assert([doc containsValueForKey: @"profile"]);
    
    // Remove profile
    [doc removeValueForKey: @"profile"];
    AssertNil([doc valueForKey: @"profile"]);
    AssertFalse([doc containsValueForKey: @"profile"]);
    
    // Profile1 should be now detached:
    [profile1 setValue: @(20) forKey: @"age"];
    AssertEqualObjects([profile1 valueForKey: @"name"], @"Scott Tiger");
    AssertEqualObjects([profile1 valueForKey: @"age"], @(20));
    
    // Check whether the profile value has no change:
    AssertNil([doc valueForKey: @"profile"]);
    
    // Save:
    CBLDocument* savedDoc = [self saveDocument: doc];
    
    AssertNil([savedDoc valueForKey: @"profile"]);
    AssertFalse([savedDoc containsValueForKey: @"profile"]);
}


- (void) testEnumeratingKeys {
    CBLMutableDictionary *dict = [[CBLMutableDictionary alloc] init];
    for (NSInteger i = 0; i < 20; i++) {
        [dict setValue: @(i) forKey: [NSString stringWithFormat:@"key%ld", (long)i]];
    }
    NSDictionary* content = [dict toDictionary];
    
    __block NSMutableDictionary* result = [NSMutableDictionary dictionary];
    __block NSUInteger count = 0;
    for (NSString* key in dict) {
        result[key] = [dict valueForKey: key];
        count++;
    }
    AssertEqualObjects(result, content);
    AssertEqual(count, content.count);
    
    // Update:
    
    [dict setValue: nil forKey: @"key2"];
    [dict setValue: @(20) forKey: @"key20"];
    [dict setValue: @(21) forKey: @"key21"];
    content = [dict toDictionary];
    
    result = [NSMutableDictionary dictionary];
    count = 0;
    for (NSString* key in dict) {
        result[key] = [dict valueForKey: key];
        count++;
    }
    AssertEqualObjects(result, content);
    AssertEqual(count, content.count);
    
    CBLMutableDocument* doc = [self createDocument: @"doc1"];
    [doc setValue: dict forKey: @"dict"];
    
    [self saveDocument: doc eval: ^(CBLDocument *d) {
        result = [NSMutableDictionary dictionary];
        count = 0;
        CBLDictionary* dictObj = [d dictionaryForKey: @"dict"];
        for (NSString* key in dictObj) {
            result[key] = [dictObj valueForKey: key];
            count++;
        }
        AssertEqualObjects(result, content);
        AssertEqual(count, content.count);
    }];
}


@end
