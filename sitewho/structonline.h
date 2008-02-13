#include <stdint.h>
#include <inttypes.h>

/* Force structure alignment to 4 bytes (for 64bit support). */
#pragma pack(push, 4)

/* 32-bit time values (for 64bit support). */
typedef int32_t time32_t;

typedef struct {
    int32_t     tv_sec;
    int32_t     tv_usec;
} timeval32_t;

#if ( GLVERSION == 201 )
struct ONLINE {
    char        tagline[64];     /* The users tagline */
    char        username[24];    /* The username of the user */
    char        status[256];     /* The status of the user, idle, RETR, etc */
    int16_t     ssl_flag;        /* 0 = no ssl, 1 = ssl on control, 2 = ssl on control and data */
    char        host[256];       /* The host the user is comming from (with ident) */
    char        currentdir[256]; /* The users current dir (fullpath) */
    int32_t     groupid;         /* The groupid of the users primary group */
    time32_t    login_time;      /* The login time since the epoch (man 2 time) */
    timeval32_t tstart;          /* replacement for last_update. */
    timeval32_t txfer;           /* The time of the last succesfull transfer. */
    uint64_t    bytes_xfer;      /* bytes transferred so far. */
    uint64_t    bytes_txfer;     /* bytes transferred in the last loop (speed limiting) */
    int32_t     procid;          /* The processor id of the process */
};

#elif ( GLVERSION == 200 )
#warning Compiling for glftpd 2.00
struct ONLINE {
    char        tagline[64];     /* The users tagline */
    char        username[24];    /* The username of the user */
    char        status[256];     /* The status of the user, idle, RETR, etc */
    int16_t     ssl_flag;        /* 0 = no ssl, 1 = ssl on control, 2 = ssl on control and data */
    char        host[256];       /* The host the user is comming from (with ident) */
    char        currentdir[256]; /* The users current dir (fullpath) */
    int32_t     groupid;         /* The groupid of the users primary group */
    time32_t    login_time;      /* The login time since the epoch (man 2 time) */
    timeval32_t tstart;          /* replacement for last_update. */
    timeval32_t txfer;           /* The time of the last succesfull transfer. */
    uint64_t    bytes_xfer;      /* bytes transferred so far. */
    int32_t     procid;          /* The processor id of the process */
};
#else
#warning Compiling for glftpd 1.32
struct ONLINE {
    char        tagline[64];     /* The users tagline */
    char        username[24];    /* The username of the user */
    char        status[256];     /* The status of the user, idle, RETR, etc */
    char        host[256];       /* The host the user is comming from (with ident) */
    char        currentdir[256]; /* The users current dir (fullpath) */
    int32_t     groupid;         /* The groupid of the users primary group */
    time32_t    login_time;      /* The login time since the epoch (man 2 time) */
    timeval32_t tstart;          /* replacement for last_update. */
    uint32_t    bytes_xfer;      /* bytes transferred so far. */
    int32_t     procid;          /* The processor id of the process */
}		__attribute__((deprecated));
#endif

/* Restore default structure alignment for non-critical structures. */
#pragma pack(pop)

