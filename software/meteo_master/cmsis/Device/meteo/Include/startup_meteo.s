; * version  	V1.0.0
; * date 		2022-03-08
; * Author 		RG
; * 


; Stack Configuration
; Stack Size (in Bytes)	
;	为STACK数据段分配一段以Stack_Size为长度的内存空间，栈顶地址是_initial_sp

Stack_Size		EQU				0x00000200
				AREA    		STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem		SPACE			Stack_Size
__initial_sp

; Heap Configuration
; Heap Size (in Bytes)

Heap_Size		EQU				0x00000100
				AREA    		HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base														 ;堆的开始地址
Heap_Mem		SPACE			Heap_Size
__heap_limit													 ;堆的结束地址


				PRESERVE8										 ;指定当前文件按照8字节对齐
				THUMB											 ;表示后面的指令兼容THUMB指令集


; Vector Table Mapped to Address 0 at Rest
;EXPORT ：声明一个标号具有全局属性，可被外部的文件使用

				AREA    		RESET, DATA, READONLY			 ;开辟数据段，段名是RESET，只读
                EXPORT  		__Vectors						 ;连续空间的开始地址
				EXPORT  		__Vectors_End					 ;连续空间的结束地址
				EXPORT  		__Vectors_Size					 ;连续空间的大小

__Vectors       DCD    			__initial_sp              ; Top of Stack
                DCD    			Reset_Handler             ; Reset Handler
                DCD    			NMI_Handler               ; NMI Handler
                DCD    			HardFault_Handler         ; Hard Fault Handler
                DCD    			0                         ; Reserved
                DCD    			0                         ; Reserved
                DCD    			0                         ; Reserved
                DCD    			0                         ; Reserved
                DCD    			0                         ; Reserved
                DCD    			0                         ; Reserved
                DCD    			0                         ; Reserved
                DCD    			SVC_Handler               ; SVCall Handler
                DCD    			0                         ; Reserved
                DCD    			0                         ; Reserved
                DCD    			PendSV_Handler            ; PendSV Handler
                DCD    			SysTick_Handler           ; SysTick Handler
                DCD    			UARTRX0_Handler           ; UART 0 RX Handler
                DCD    			UARTTX0_Handler           ; UART 0 TX Handler
			    DCD    			UARTRX1_Handler           ; UART 0 RX Handler
                DCD    			UARTTX1_Handler           ; UART 0 TX Handler
                DCD    			PORT0_COMB_Handler        ; GPIO Port 0 Combined Handler
                DCD    			TIMER0_Handler            ; TIMER 0 handler
                DCD    			TIMER1_Handler            ; TIMER 1 handler
                DCD    			DUALTIMER_HANDLER         ; Dual timer handler
                DCD    			SPI_ALL_Handler           ; Combines SPI Handler
                DCD    			UARTOVF_Handler           ; UART Combined Overflow Handler
                DCD    			PORT0_0_Handler           ; GPIO Port 0 pin 0 Handler
                DCD    			PORT0_1_Handler           ; GPIO Port 0 pin 1 Handler
                DCD    			PORT0_2_Handler           ; GPIO Port 0 pin 2 Handler
                DCD    			PORT0_3_Handler           ; GPIO Port 0 pin 3 Handler
                DCD    			PORT0_4_Handler           ; GPIO Port 0 pin 4 Handler
                DCD    			PORT0_5_Handler           ; GPIO Port 0 pin 5 Handler
                DCD    			PORT0_6_Handler           ; GPIO Port 0 pin 6 Handler
                DCD    			PORT0_7_Handler           ; GPIO Port 0 pin 7 Handler
                DCD    			PORT0_8_Handler           ; GPIO Port 0 pin 8 Handler
                DCD    			PORT0_9_Handler           ; GPIO Port 0 pin 9 Handler
                DCD    			PORT0_10_Handler          ; GPIO Port 0 pin 10 Handler
                DCD    			PORT0_11_Handler          ; GPIO Port 0 pin 11 Handler
                DCD    			PORT0_12_Handler          ; GPIO Port 0 pin 12 Handler
                DCD    			PORT0_13_Handler          ; GPIO Port 0 pin 13 Handler
                DCD    			PORT0_14_Handler          ; GPIO Port 0 pin 14 Handler
                DCD    			PORT0_15_Handler          ; GPIO Port 0 pin 15 Handler
__Vectors_End

__Vectors_Size	EQU				__Vectors_End - __Vectors
                AREA            |.text|,CODE,READONLY


; Reset Handler (复位中断函数)
; SP：栈顶指针。栈用于存放局部变量、函数形参和返回值，为函数运行的必要条件。
; PC：程序计数器。用于读取程序指令。
; LR：保存函数调用的返回地址。
; 芯片上电以后，首先执行的便是Reset_Handler函数。

Reset_Handler   PROC
                EXPORT  		Reset_Handler             [WEAK]
                IMPORT  		SystemInit				 ; 首先调用SystemInit函数来初始化系统的各种时钟
                IMPORT  		__main					 ; 然后调用_main函数
                LDR     		R0, =SystemInit
                ; Initialise at least r8, r9 to avoid X in tests
                ; Only important for simulation where X can cause
                ; unexpected core behaviour
                MOV    			R8, R0
                MOV    			R9, R8
                BLX    			R0
                LDR    			R0, =__main
                BX     			R0
                ENDP


; Dummy Exception Handlers (infinite loops which can be modified)
; 其他中断异常服务函数，以及weak声明
NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler         [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
               EXPORT  SysTick_Handler            [WEAK]
               B       .
               ENDP
Default_Handler PROC
                EXPORT UARTRX0_Handler            [WEAK]
                EXPORT UARTTX0_Handler            [WEAK]
                EXPORT UARTRX1_Handler            [WEAK]
                EXPORT UARTTX1_Handler            [WEAK]
                EXPORT UARTRX2_Handler            [WEAK]
                EXPORT UARTTX2_Handler            [WEAK]
                EXPORT PORT0_COMB_Handler         [WEAK]
                EXPORT PORT1_COMB_Handler         [WEAK]
                EXPORT TIMER0_Handler             [WEAK]
                EXPORT TIMER1_Handler             [WEAK]
                EXPORT DUALTIMER_HANDLER          [WEAK]
                EXPORT SPI_ALL_Handler            [WEAK]
                EXPORT UARTOVF_Handler            [WEAK]
                EXPORT ETHERNET_Handler           [WEAK]
                EXPORT I2S_Handler                [WEAK]
                EXPORT DMA_Handler                [WEAK]
                EXPORT PORT0_0_Handler            [WEAK]
                EXPORT PORT0_1_Handler            [WEAK]
                EXPORT PORT0_2_Handler            [WEAK]
                EXPORT PORT0_3_Handler            [WEAK]
                EXPORT PORT0_4_Handler            [WEAK]
                EXPORT PORT0_5_Handler            [WEAK]
                EXPORT PORT0_6_Handler            [WEAK]
                EXPORT PORT0_7_Handler            [WEAK]
                EXPORT PORT0_8_Handler            [WEAK]
                EXPORT PORT0_9_Handler            [WEAK]
                EXPORT PORT0_10_Handler           [WEAK]
                EXPORT PORT0_11_Handler           [WEAK]
                EXPORT PORT0_12_Handler           [WEAK]
                EXPORT PORT0_13_Handler           [WEAK]
                EXPORT PORT0_14_Handler           [WEAK]
                EXPORT PORT0_15_Handler           [WEAK]
UARTRX0_Handler
UARTTX0_Handler
UARTRX1_Handler
UARTTX1_Handler
UARTRX2_Handler
UARTTX2_Handler
PORT0_COMB_Handler
PORT1_COMB_Handler
TIMER0_Handler
TIMER1_Handler
DUALTIMER_HANDLER
SPI_ALL_Handler
UARTOVF_Handler
ETHERNET_Handler
I2S_Handler
DMA_Handler
PORT0_0_Handler
PORT0_1_Handler
PORT0_2_Handler
PORT0_3_Handler
PORT0_4_Handler
PORT0_5_Handler
PORT0_6_Handler
PORT0_7_Handler
PORT0_8_Handler
PORT0_9_Handler
PORT0_10_Handler
PORT0_11_Handler
PORT0_12_Handler
PORT0_13_Handler
PORT0_14_Handler
PORT0_15_Handler
                B       .
                ENDP


                ALIGN


; User Initial Stack & Heap
; 将堆栈地址传递给库函数
; 在上面步骤中，调用了_main函数，然后_main函数调用库函数初始化堆栈，但库函数并不知道堆栈的大小
; 因此需要传递参数或声明标号

                IF      :DEF:__MICROLIB						 ; 条件编译选项，_MICROLIB

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap

__user_initial_stackheap PROC
                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR
                ENDP

                ALIGN

                ENDIF


                END
