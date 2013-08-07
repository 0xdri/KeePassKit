//
//  KPKLegacyHeaderWriter.m
//  MacPass
//
//  Created by Michael Starke on 08.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KPKLegacyHeaderWriter.h"
#import "KPKLegacyFormat.h"
#import "KPKTree.h"
#import "KPKMetaData.h"

#import "NSData+Random.h"

@interface KPKLegacyHeaderWriter () {
  KPKLegacyHeader _header;
  KPKTree *_tree;
}

@end

@implementation KPKLegacyHeaderWriter

- (id)initWithTree:(KPKTree *)tree {
  self = [super init];
  if(self) {
    _tree = tree;
    _masterSeed = [NSData dataWithRandomBytes:16];
    _encryptionIv = [NSData dataWithRandomBytes:16];
    _transformSeed = [NSData dataWithRandomBytes:32];
  }
  return self;
}

- (uint32_t)transformationRounds {
  return _header.keyEncRounds;
}

- (void)writeHeaderData:(NSMutableData *)data {
  _header.signature1 = CFSwapInt32HostToLittle(KPK_LEGACY_SIGNATURE_1);
  _header.signature2 = CFSwapInt32HostToLittle(KPK_LEGACY_SIGNATURE_2);
  _header.flags = CFSwapInt32HostToLittle( KPKLegacyEncryptionSHA2 | KPKLegacyEncryptionRijndael );
  _header.version = CFSwapInt32HostToLittle(KPK_LEGACY_FILE_VERSION);
  
  /* Master seed and encryption iv */
  [_masterSeed getBytes:_header.masterSeed length:sizeof(_header.masterSeed)];
  [_encryptionIv getBytes:_header.encryptionIv length:sizeof(_header.encryptionIv)];
  
  /* Number of groups (minus the root) */
  uint32_t numberOfGroups = (uint32_t)[[_tree allGroups] count] - 1;
  _header.groups = CFSwapInt32HostToLittle(numberOfGroups);
  
  /* Number of entries */
  uint32_t numberOfEntries = (uint32_t)[[_tree allEntries] count] - 1;
  _header.entries = CFSwapInt32HostToLittle(numberOfEntries);
  
  /* Skip the content hash for now, it will get filled in after the content is written */
  
  /* Master seed #2 */
  [_transformSeed getBytes:_header.masterSeed2 length:sizeof(_header.masterSeed2)];
  
  /*
   Number of key encryption rounds
   Since we use 64 bits in the new format
   we have to clamp to the maxium possible
   size in 32 bit legacy format
   */
  uint32_t rounds = (uint32_t)MIN(_tree.metaData.rounds, UINT32_MAX);
  _header.keyEncRounds = CFSwapInt32HostToLittle(rounds);
  
  // Write out the header
  [data appendBytes:&_header length:sizeof(_header)];
}

@end