#import "Kudryavka.h"
#import "NKKeychainDataSerializer.h"
#import "NKCryptedFileDataSerializer.h"
#import "NKDummyDataSerializer.h"

@class NKKeychainDataSerializer, NKCryptedFileDataSerializer, NKDummyDataSerializer;

@implementation NKDataSerializer

+ (NKDataSerializer *)serializerUsingMethod:(NKSerializerType)method {
    switch (method) {
        case NKSerializerKeychain:
            return [[NKKeychainDataSerializer alloc] init];
        case NKSerializerCustomFile:
            return [[NKCryptedFileDataSerializer alloc] init];
        case NKSerializerNoop:
            return [[NKDummyDataSerializer alloc] init];
        default:
            return nil;
    }
}

- (BOOL)serializePrivateKey:(NSString *)thePrivateKey publicKey:(NSString *)thePublicKey options:(NSDictionary *)aDict error:(NSError **)error {
    [NSException raise:@"NKAbstractClassException" format:@"You idiot."];
    return NO;
}

- (NSDictionary *)loadKeysWithOptions:(NSDictionary *)aDict error:(NSError **)error {
    [NSException raise:@"NKAbstractClassException" format:@"You idiot."];
    return nil;
}

@end