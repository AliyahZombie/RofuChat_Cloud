#ifndef ROFU_H
#define ROFU_H
#ifdef __cplusplus
extern "C" {
#endif
/* UTF-8 NUL-terminated JSON config. Release the returned JSON with rofu_free_string. */
char *rofu_start(const char *config_json);
int rofu_stop(void);
void rofu_free_string(char *s);
#ifdef __cplusplus
}
#endif
#endif
