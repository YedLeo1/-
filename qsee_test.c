#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>

// 高通 QSEECOM 基础定义（高通公开头文件提取）
#define QSEECOM_IOCTL_MAGIC 'q'

#define QSEECOM_IOCTL_GET_VERSION \
    _IOR(QSEECOM_IOCTL_MAGIC, 1, unsigned int)

#define QSEECOM_DEVICE "/dev/dma_heap/qcom,qseecom"

int main() {
    int fd;
    unsigned int version = 0;
    int ret;

    printf("=== QSEECOM 测试（一加13T / SM8650 SPSS）===\n");
    printf("打开设备: %s\n", QSEECOM_DEVICE);

    fd = open(QSEECOM_DEVICE, O_RDWR);
    if (fd < 0) {
        perror("open 失败");
        return -1;
    }
    printf("open 成功: fd = %d\n", fd);

    // 测试最简单的 IOCTL：获取 QSEE 版本
    printf("发送 IOCTL: QSEECOM_IOCTL_GET_VERSION\n");
    ret = ioctl(fd, QSEECOM_IOCTL_GET_VERSION, &version);
    if (ret < 0) {
        perror("ioctl 失败");
    } else {
        printf("ioctl 成功！QSEE 版本: %u\n", version);
    }

    close(fd);
    return 0;
}
