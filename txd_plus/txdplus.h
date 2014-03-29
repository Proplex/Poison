#ifndef ObjectiveTox_txdplus_h
#define ObjectiveTox_txdplus_h

/* Outer envelope functions. cc txd_crypto.c */

extern const int32_t TXD_ERR_DECRYPT_FAILED;
extern const uint32_t TXD_BIT_PADDED_FILE;

int txd_encrypt_buf(const uint8_t *password, uint64_t passlen,
                    const uint8_t *clear_in, uint64_t clear_len,
                    uint8_t **out, uint64_t *out_size,
                    const char *comment, uint32_t flags);

int txd_decrypt_buf(const uint8_t *password, uint64_t passlen,
                    const uint8_t *encr_in, uint64_t encr_len,
                    uint8_t **out, uint64_t *out_size);

#endif
