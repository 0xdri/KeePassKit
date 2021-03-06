//
//  KPKTestAutotypeNormalization.m
//  MacPass
//
//  Created by Michael Starke on 18.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KeePassKit.h"

@interface KPKTestAutotype : XCTestCase
@end

@implementation KPKTestAutotype

- (void)testCommandValidation {
  XCTAssertFalse(@"".validCommand, @"Emptry strings aren't valid commands");
}

- (void)testSimpleNormalization {
  XCTAssertTrue([@"Whoo %{%}{^}{SHIFT}+ {SPACE}{ENTER}^V%V~T".normalizedAutotypeSequence isEqualToString:@"Whoo{SPACE}{ALT}{PERCENT}{CARET}{SHIFT}{SHIFT}{SPACE}{SPACE}{ENTER}{CONTROL}V{ALT}V{ENTER}T"]);
}

- (void)testCommandRepetition {
  XCTAssertTrue([@"Whoo %{% 2}{^}{SHIFT 5}+ {SPACE}{ENTER}^V%V~T".normalizedAutotypeSequence isEqualToString:@"Whoo{SPACE}{ALT}{PERCENT}{PERCENT}{CARET}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SPACE}{SPACE}{ENTER}{CONTROL}V{ALT}V{ENTER}T"]);
  XCTAssertTrue([@"{TAB 5}TAB{TAB}{SHIFT}{SHIFT 10}ENTER{ENTER}{%%}".normalizedAutotypeSequence isEqualToString:@"{TAB}{TAB}{TAB}{TAB}{TAB}TAB{TAB}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}{SHIFT}ENTER{ENTER}{%%}"]);
}

- (void)testeBracketValidation {
  XCTAssertFalse(@"{BOOO}NO-COMMAND{TAB}{WHOO}{WHOO}{SPACE}!!!thisIsFun{{MISMATCH!!!}".validCommand);
  XCTAssertFalse(@"{{}}}}".validCommand);
  XCTAssertFalse(@"{}{}{{{}{{{{{{}}".validCommand);
  XCTAssertTrue(@"{}{}{}{}{}{      }ThisIsValid{}{STOP}".validCommand);
}

- (void)testKDBAutotypeImport {
  NSString *string = @"Auto-Type: {USERNAME}{TAB}{PASSWORD}{ENTER}\nAuto-Type-Window: Some Dialog - *\nAuto-Type-1: {USERNAME}{ENTER}\nAuto-Type-Window-1: * - Editor\nAuto-Type-Window-1: * - Notepad\nAuto-Type-Window-1: * - WordPad\nAuto-Type-2: {PASSWORD}{ENTER}\nAuto-Type-Window-2: Some Web Page - *";
  KPKAutotype *autotype = [KPKAutotype autotypeFromNotes:string];
}

- (void)testKDBAutotypeExport {
}

@end
