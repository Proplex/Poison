#import <Foundation/Foundation.h>
#import <Kudryavka/Kudryavka.h>

void usage(const char *name) {
    printf("usage: %s show <name-of-file>\n", name);
    printf("usage: %s changepass <name-of-file>\n", name);
    printf("usage: %s convert <name-of-v1-file> <name-of-output-file>\n", name);
}

int verb_show(int argc, const char *argv[]) {
    if (argc < 3) {
        puts("show: no file specified");
        return 1;
    }
    NSData *d = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[2]]];
    if (!d) {
        puts("show: can't read file");
        return 1;
    }
    char *pass = getpass("file password? > ");
    NKDataSerializer *kud = [[NKDataSerializer alloc] init];
    NSDictionary *dict = [kud decryptDataBlob:d withPassword:[NSString stringWithUTF8String:pass]];
    if (!dict) {
        puts("show: file corrupt, or password incorrect");
        return 1;
    }
    printf("%s\n", [[dict description] UTF8String]);
    return 0;
}

int verb_cp(int argc, const char *argv[]) {
    if (argc < 4) {
        puts("changepass: no file specified");
        return 1;
    }
    NSData *d = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[2]]];
    if (!d) {
        puts("changepass: can't read file");
        return 1;
    }
    char *pass = getpass("file password? > ");
    NKDataSerializer *kud = [[NKDataSerializer alloc] init];
    NSData *clear = [kud decryptedDataFromBlob:d password:[NSString stringWithUTF8String:pass]];
    if (!clear) {
        puts("changepass: file corrupt, or password incorrect");
        return 1;
    }
    char *newpass = getpass("new password? > ");
    char *newpass2 = getpass("type it again for good measure > ");
    if (strcmp(newpass, newpass2)) {
        puts("changepass: new passwords didn't match.");
        return 1;
    }
    NSData *o = [kud encryptedBlobWithData:clear password:[NSString stringWithUTF8String:pass]];
    BOOL success = [o writeToFile:[NSString stringWithUTF8String:argv[3]] atomically:YES];
    if (!success) {
        puts("changepass: couldn't save new file; please check that intermediate directories exist, and that you have permission to write to them");
        return 1;
    }
    return 0;
}

int verb_conv(int argc, const char *argv[]) {
    puts("convert: sorry, this function isn't implemented");
    return 0;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        puts("KudryavkaTool version 1.1.");
        if (argc < 2) {
            usage(argv[0]);
            return 0;
        }
        if (!strcmp(argv[1], "show")) {
            return verb_show(argc, argv);
        } else if (!strcmp(argv[1], "changepass")) {
            return verb_cp(argc, argv);
        } else if (!strcmp(argv[1], "convert")) {
            return verb_conv(argc, argv);
        } else {
            usage(argv[0]);
            return 0;
        }
    }
    return 0;
}

