#include <stm8l15x.h>
#include <stm8l15x_gpio.h>
#include <stm8l15x_usart.h>
#include <stm8l15x_syscfg.h>
#include <stm8l15x_clk.h>

// 简单延时函数
void Delay(uint32_t count) {
    while(count--) {
        __asm__("nop");
    }
}

// 串口发送单个字符函数（已注释）

void USART_SendChar(USART_TypeDef* USARTx, uint8_t ch) {
    // 等待发送数据寄存器为空
    while(USART_GetFlagStatus(USARTx, USART_FLAG_TXE) == RESET);
    // 发送数据
    USART_SendData8(USARTx, ch);
    // 等待发送完成
    while(USART_GetFlagStatus(USARTx, USART_FLAG_TC) == RESET);
}


// 串口发送字符串函数（已注释）
void USART_SendString(USART_TypeDef* USARTx, const char* str) {
    while(*str) {
        USART_SendChar(USARTx, *str++);
    }
}

int main(void) {
    // 配置PA2为普通GPIO输出（推挽输出，高速）
    // GPIO_Init(GPIOA, GPIO_Pin_2, GPIO_Mode_Out_PP_Low_Fast);
    
    // 串口配置代码（已注释）
    // 1. 使能USART1时钟
    CLK_PeripheralClockConfig(CLK_Peripheral_USART1, ENABLE);
    
    // 2. 配置PA2为USART1_TX (复用推挽输出)
    GPIO_Init(GPIOA, GPIO_Pin_2, GPIO_Mode_Out_PP_High_Fast);
    
    // 3. 配置PA3为USART1_RX (浮空输入)
    GPIO_Init(GPIOA, GPIO_Pin_3, GPIO_Mode_In_FL_No_IT);
    
    // 4. 重映射USART1到PA2(TX)和PA3(RX)
    SYSCFG_REMAPPinConfig(REMAP_Pin_USART1TxRxPortA, ENABLE);
    
    // 5. 初始化USART1: 115200波特率, 8位数据, 1位停止位, 无校验, 发送和接收模式
    // 注意：USART_Mode_Rx | USART_Mode_Tx = 0x0C，使用union绕过SDCC枚举类型检查
    {
        union {
            uint8_t u8;
            USART_Mode_TypeDef mode;
        } usart_mode_workaround;
        usart_mode_workaround.u8 = USART_Mode_Rx | USART_Mode_Tx;
        USART_Init(USART1, 
                   115200,
                   USART_WordLength_8b,
                   USART_StopBits_1,
                   USART_Parity_No,
                   usart_mode_workaround.mode);
    }
    
    // 6. 使能USART1
    USART_Cmd(USART1, ENABLE);
    
    // 7. 发送"hello world"字符串
    USART_SendString(USART1, "hello world\r\n");
    
    while(1) {
        // PA2引脚反转
        // GPIO_ToggleBits(GPIOA, GPIO_Pin_2);
        // 延时，约500ms（根据时钟频率调整）
        Delay(50000);
    }
}