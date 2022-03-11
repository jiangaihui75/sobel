# sobel

<img width="415" alt="image" src="https://user-images.githubusercontent.com/94519594/157878766-4ab3fbf1-1ace-4e0a-b11b-766c82008374.png">

1.软件环境：ISE 14.7、Modelsim、Matlab 

2.硬件环境：spartan6-xc6slx9   芯片、FPGA  开发板3. 项目描述： 
(1)通过 MATLAB 将一副彩色图像（200*200）转换为 8bit 格式的数据； 

(2)通过串口助手把数据发给板卡；FPGA 端调用二级 FIFO 构成一个流水的 3*3 的矩阵，经过 Gx，Gy 算子运算并与设定阈值比较后得到的结果存到RAM 中，并由 VGA 显示； 
（3）实现效果：VGA 以每秒 60 帧速率动态移动显示 Sobel 算法处理后的图像。
