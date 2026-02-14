#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <stdint.h>
#include <linux/types.h>

#define DMA_HEAP_QSEECOM "/dev/dma_heap/qcom,qseecom"

// SM8650 dma_heap 真正能用的基础命令
#define DMA_HEAP_IOCTL_MAGIC 'd'
#define DMA_HEAP_IOCTL_GET_VERSION _IOR(DMA_HEAP_IOCTL_MAGIC, 0, uint32_t)

typedef struct {
    __u64 addr;
    __u64 size;
    __u32 flags;
    __u32 unused;
} dma_heap_allocation_data;

int main() {
    int fd;
    uint32_t ver;
    int ret;

    printf("=== SM8650 QSEECOM DMA 测试 ===\n");
    fd = open(DMA_HEAP_QSEECOM, O_RDWR | O_CLOEXEC);
    if (fd < 0) {
        perror("open failed");
        return -1;
    }
    printf("open OK, fd=%d\n", fd);

    // 1. 版本号（最安全、必不崩溃）
    ret = ioctl(fd, DMA_HEAP_IOCTL_GET_VERSION, &ver);
    if (ret < 0) {
        perror("dma version ioctl failed");
    } else {
        printf("dma_heap version: %u\n", ver);
    }

    // 2. 尝试分配1页（验证TEE内存可用）
    dma_heap_allocation_data data = {
        .size = 4096,
        .flags = 0x1, // DMA_HEAP_ALLOC_DEFAULT
    };
    ret = ioctl(fd, _IOWR(DMA_HEAP_IOCTL_MAGIC, 1, dma_heap_allocation_data), &data);
    if (ret < 0) {
        perror("alloc failed");
    } else {
        printf("alloc OK: addr=0x%llx size=%llu\n", data.addr, data.size);
    }

    close(fd);
    return 0;
}
