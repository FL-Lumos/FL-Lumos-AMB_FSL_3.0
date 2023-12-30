# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     draw_auto_result
   Description :    测试绘制自动化测试结果
   Author :       13401
   date：          2023/9/19
-------------------------------------------------
"""
#在auto_normal = [0,0.1, 0.5]; auto_abnormal = [0.3,0.8,0.9];auto_ae_normal = [0.2,0.4,0.6]; auto_ae_abnormal = [0.7,1];中分别存储了一段时序数据中，4种状态数据的位置的在时序数据上相对时间的百分比，请在长为X1宽为y1的矩形上形象的显示对应数据的位置，其中X1为时序数据的长度，y1为时序数据的位置
import matplotlib.pyplot as plt
import numpy as np
import scipy.io as ip
import os

def plt_auto_result():

    # 获取数据
    dataset_dic = ip.loadmat(r'.\data_temp\auto_result.mat')
    auto_normal = dataset_dic['auto_normal_temp']
    auto_abnormal = dataset_dic['auto_abnormal_temp']
    auto_ae_normal = dataset_dic['auto_ae_normal_temp']
    auto_ae_abnormal = dataset_dic['auto_ae_abnormal_temp']

    num_temp = auto_normal.shape[0] + auto_abnormal.shape[0] + auto_ae_normal.shape[0] + auto_ae_abnormal.shape[0]  

    if auto_normal.shape[0] == 0:
        auto_normal = np.array([[]])
    if auto_abnormal.shape[0] == 0:
        auto_abnormal = np.array([[]])
    if auto_ae_normal.shape[0] == 0:
        auto_ae_normal = np.array([[]])
    if auto_ae_abnormal.shape[0] == 0:
        auto_ae_abnormal = np.array([[]])

    

    # 创建一个num_tempx1的图像
    fig, ax = plt.subplots(figsize=(num_temp, 1/num_temp))

    # 生成数据和颜色
    data = np.linspace(0, 1, 101)
    colors = []
    for value in range(num_temp-1): 
        value = value/num_temp
        # 如果value在auto_normal[0]中，则颜色为绿色

        if value in auto_normal[0]:
            colors.append('green')

        elif value in auto_abnormal[0]:
            colors.append('red')

        elif value in auto_ae_normal[0]:
            colors.append('blue')

        elif value in auto_ae_abnormal[0]:
            colors.append('yellow')
        else:
            colors.append('white')

    print(colors)   



    # 绘制彩色条
    ax.bar(range(len(data)), [1] * len(data), color=colors)

    # 隐藏坐标轴
    ax.axis('off')

    os.remove(r'.\img\temp\2\auto_result_temp.png')

    plt.savefig(r'.\img\temp\2\auto_result_temp.png', bbox_inches='tight', pad_inches=0)

    # 显示图像
    # plt.show()

if __name__ == '__main__':
    plt_auto_result()
    # 清空文件夹2中的auto_result_temp.png文件



