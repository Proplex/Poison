/**********************************************
 * mio is a tool for working with TXD2 files,
 * like the kudryavka utility did in Poison 1.x
 * it also keeps the tradition of being named
 * after a Little Buster.
 *
 * Copyright (c) 2014 Zodiac Labs.
 * You are free to do whatever you want with
 * this file -- provided this notice is
 * retained.
 **********************************************/

#include "data.h"
#include "txdplus.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <fcntl.h>

void usage(const char *name) {
    printf("%s: quick txd file tool, iteration 2\n", name);
    printf("usage: %s convert [-nico / -maki / -cherry] "
           "<input file> <output file>\n", name);
    printf("usage: %s survey <input file>\n", name);
    printf("usage: %s passwd <input file>\n\n", name);
      puts("note: The switches provided to convert determine the type "
           "of the output file.\n"
           "-nico: Padded maki-file. Leaks the least amount of information.\n"
           "-maki: Plain maki-file.\n"
           "-cherry: Unencrypted TXD binary. Absolutely no protection at all.");
}

int passwd(const char *file) {
    FILE *f = fopen(file, "r");
    if (!f) {
        perror("mio/passwd");
        return -1;
    }
    char magic[5] = { 0 };
    fread(&magic, 4, 1, f);
    //printf("%s\n", magic);
    uint32_t magic_const = ntohl(*magic);

    fseek(f, 0, SEEK_END);
    long plc = ftell(f);
    rewind(f);

    uint8_t *bytes = malloc(plc);
    fread(bytes, plc, 1, f);
    fclose(f);

    txd_intermediate_t loaded;
    if (magic_const == 0xE6A19C00) {
        printf("mio/passwd: note: You're adding a password to the cherry-file "
               "%s.\n", file);
        int err = txd_intermediate_from_buf(bytes, plc, &loaded);
        if (err != TXD_ERR_SUCCESS) {
            free(bytes);
            printf("mio/passwd: error: txd_intermediate_from_buf failed with "
                   "code %d\n", err);
            return -1;
        }
    } else {
        char *passwd = getpass("Password: ");
        uint8_t *dec = NULL;
        uint64_t sze = 0;
        printf("%s", bytes);
        int derr = txd_decrypt_buf((uint8_t *)passwd, strlen(passwd), bytes,
                                   plc, &dec, &sze);
        if (derr != TXD_ERR_SUCCESS) {
            free(bytes);
            printf("mio/passwd: error: txd_decrypt_buf failed with "
                   "code %d, did you type the correct password?\n", derr);
            return -1;
        }
        free(bytes);
        int err = txd_intermediate_from_buf(dec, sze, &loaded);
        if (err != TXD_ERR_SUCCESS) {
            printf("mio/passwd: error: txd_intermediate_from_buf failed with "
                   "code %d\n", err);
            return -1;
        }
        free(dec);
    }

    uint8_t *clear;
    uint64_t clearlen;
    int eerr = txd_export_to_buf(loaded, &clear, &clearlen);
    if (eerr != TXD_ERR_SUCCESS) {
        printf("mio/passwd: error: txd_export_to_buf failed with code %d\n",
               eerr);
        return -1;
    }

    uint8_t *e;
    uint64_t elen;
    char *npasswd = getpass("New password: ");
    if (magic_const == 'MAKi') {
        txd_encrypt_buf((uint8_t *)npasswd, strlen(npasswd), clear, clearlen,
                        &e, &elen, "mio 1.0", 0);
    } else {
        txd_encrypt_buf((uint8_t *)npasswd, strlen(npasswd), clear, clearlen,
                        &e, &elen, "mio 1.0", TXD_BIT_PADDED_FILE);
    }

    char *template = strdup(".si-XXXXXXXX");
    char *temp = mktemp(template);
    int fd = open(temp, O_CREAT | O_EXCL | O_WRONLY);
    if (fd == -1) {
        perror("mio/passwd/write");
        free(e);
        return -1;
    }
    write(fd, e, elen);
    close(fd);
    remove(file);
    rename(temp, file);
    free(template);
    free(e);
    txd_intermediate_free(loaded);
    return 0;
}

int main(int argc, const char * argv[]) {
    if (argc < 2) {
        usage(argv[0]);
        return 0;
    }
    const char *cmd = argv[1];
    if (!strcmp(cmd, "passwd") && argc == 3) {
        return passwd(argv[2]);
    }
    return 0;
}
