# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     anomaly_detection
   Description :    读取.mat文件，根据设定的区间数据点，自动扫描它附近的8000个点的异常情况
   Author :       13401
   date：          2023/8/15
-------------------------------------------------
"""
# 设置中文显示
import os
os.environ["KMP_DUPLICATE_LIB_OK"]="TRUE" # 消除关于多个libiomp5md.dll的警告
#设置matplotlib显示中文
import grid_based_data # 导入网格化处理数据的类
import matplotlib.pyplot as plt  # plotting library
# 设置matplotlib显示字体
from matplotlib import rcParams
rcParams['font.family'] = 'SimHei'
import numpy as np  # this module is useful to work with numerical arrays
import pandas as pd
import random
import torch
import torchvision
from torchvision import transforms
from torch.utils.data import Dataset, DataLoader, random_split
from torch import nn
import torch.nn.functional as F
import torch.optim as optim
import scipy.io as ip
import os
from amb_autoencoder import Encoder, Decoder
import warnings
warnings.filterwarnings("ignore") # 关闭警告





def split_data(raw_data_range_X, raw_data_range_Y, obvious_fault_value, possible_failure_value, grid_counts):
    # 读取正常数据，主要用于训练
    p = grid_counts
    X1,  Y1, X2,  Y2, Z, grid_3, grid_9 ,grid_27 = p['X1'], p['Y1'], p['X2'], p['Y2'], p['Z'], p['grid_3'], p['grid_9'], p['grid_27']

    # 将待检测数据划分为正常数据，疑似异常数据，明显异常数据
    status_value = 0 # 当前运行状态(0正常，1明显异常，2疑似异常，3重构正常，4重构异常)
    damage_degree_value = 0 # 用x,y中最大绝对振动幅值来表示损伤程度

    if (np.max(np.abs(X1)) > raw_data_range_X*obvious_fault_value or np.max(np.abs(Y1)) > raw_data_range_Y*obvious_fault_value) and (np.max(np.abs(X2)) > raw_data_range_X*obvious_fault_value or np.max(np.abs(Y2)) > raw_data_range_Y*obvious_fault_value) :
        status_value = 1.3
        print('当前运行状态 明显异常 （ 1、2端-超过警戒阈值：%s）' % obvious_fault_value)
    elif (np.max(np.abs(X1)) > raw_data_range_X*obvious_fault_value or np.max(np.abs(Y1)) > raw_data_range_Y*obvious_fault_value) :
        status_value = 1.1
        print('当前运行状态 明显异常 （1端-超过警戒阈值：%s）' % obvious_fault_value)
    elif (np.max(np.abs(X2)) > raw_data_range_X*obvious_fault_value or np.max(np.abs(Y2)) > raw_data_range_Y*obvious_fault_value) :
        status_value = 1.2
        print('当前运行状态 明显异常 （2端-超过警戒阈值：%s）' % obvious_fault_value)
    elif (np.max(np.abs(X1)) > raw_data_range_X*possible_failure_value) or (np.max(np.abs(Y1)) > raw_data_range_Y*possible_failure_value) or (np.max(np.abs(X2)) > raw_data_range_X*possible_failure_value) or (np.max(np.abs(Y2)) > raw_data_range_Y*possible_failure_value) :
        status_value = 2
        print('当前运行状态 疑似异常 （ 1、2端-超过警戒阈值：%s）' % possible_failure_value)
    else:
        status_value = 0
        print('当前运行状态 正常 （处于警戒阈值：%s 以内）' % possible_failure_value)

    damage_degree_value = max(np.max(np.abs(X1))/raw_data_range_X, np.max(np.abs(Y1))/raw_data_range_Y, np.max(np.abs(X2))/raw_data_range_X, np.max(np.abs(Y2))/raw_data_range_Y)
    return status_value, damage_degree_value


# 调用amb_autoencoder中的自编码器，对进行疑似异常数据进行检测
def autoencoder_detect(grid_counts):
    # 记录状态值
    status_value = 2

    # 读取需要检测的数据
    raw_dataset = grid_counts

    # 读取疑似异常数据
    # 3*3 的6中分支网格特征
    grid_3_x1y1_possible = raw_dataset['grid_3'][0]
    grid_3_x2y2_possible = raw_dataset['grid_3'][1]
    grid_3_x1y2_possible = raw_dataset['grid_3'][2]
    grid_3_x2y1_possible = raw_dataset['grid_3'][3]
    grid_3_x1x2_possible = raw_dataset['grid_3'][4]
    grid_3_y1y2_possible = raw_dataset['grid_3'][5]

    # 9*9 的6中分支网格特征
    grid_9_x1y1_possible = raw_dataset['grid_9'][0]
    grid_9_x2y2_possible = raw_dataset['grid_9'][1]
    grid_9_x1y2_possible = raw_dataset['grid_9'][2]
    grid_9_x2y1_possible = raw_dataset['grid_9'][3]
    grid_9_x1x2_possible = raw_dataset['grid_9'][4]
    grid_9_y1y2_possible = raw_dataset['grid_9'][5]

    # 27*27 的6中分支网格特征
    grid_27_x1y1_possible = raw_dataset['grid_27'][0]
    grid_27_x2y2_possible = raw_dataset['grid_27'][1]
    grid_27_x1y2_possible = raw_dataset['grid_27'][2]
    grid_27_x2y1_possible = raw_dataset['grid_27'][3]
    grid_27_x1x2_possible = raw_dataset['grid_27'][4]
    grid_27_y1y2_possible = raw_dataset['grid_27'][5]

    # # 用于matplotlib调用时的断点调试
    # import pdb
    # pdb.set_trace()

    # 加载模型
    model_encoder = Encoder(encoded_space_dim=4)
    model_decoder = Decoder(encoded_space_dim=4)


    # 读取编码器模型参数
    model_encoder.load_state_dict(torch.load(r'.\pt\encoder_parameter_20230920005936.pt'))
    # 读取解码器模型参数
    model_decoder.load_state_dict(torch.load(r'.\pt\decoder_parameter_20230920005936.pt'))

    # 从loss_value_threshold.txt中读取阈值
    with open(r'.\txt\val_loss_max.txt', 'r') as f:
        loss_value_threshold = float(f.read())

    with open(r'.\txt\val_loss_x1y1_max.txt', 'r') as f:
        loss_value_threshold_x1y1 = float(f.read())

    with open(r'.\txt\val_loss_x2y2_max.txt', 'r') as f:
        loss_value_threshold_x2y2 = float(f.read())


    # 设置模型为评估模式
    model_encoder.eval()
    model_decoder.eval()

    device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
    print(f'Selected device: {device}')

    # 将模型加载到所选设备上
    model_encoder.to(device)
    model_decoder.to(device)

    # 开始检测

    # 1 将数据转化为张量
    grid_3_x1y1_possible_tensor = torch.from_numpy(grid_3_x1y1_possible).float() / 255.0
    grid_3_x1y1_possible_tensor = grid_3_x1y1_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_3_x2y2_possible_tensor = torch.from_numpy(grid_3_x2y2_possible).float() / 255.0
    grid_3_x2y2_possible_tensor = grid_3_x2y2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_3_x1y2_possible_tensor = torch.from_numpy(grid_3_x1y2_possible).float() / 255.0
    grid_3_x1y2_possible_tensor = grid_3_x1y2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_3_x2y1_possible_tensor = torch.from_numpy(grid_3_x2y1_possible).float() / 255.0
    grid_3_x2y1_possible_tensor = grid_3_x2y1_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_3_x1x2_possible_tensor = torch.from_numpy(grid_3_x1x2_possible).float() / 255.0
    grid_3_x1x2_possible_tensor = grid_3_x1x2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_3_y1y2_possible_tensor = torch.from_numpy(grid_3_y1y2_possible).float() / 255.0
    grid_3_y1y2_possible_tensor = grid_3_y1y2_possible_tensor.unsqueeze(0).unsqueeze(0)

    grid_9_x1y1_possible_tensor = torch.from_numpy(grid_9_x1y1_possible).float() / 255.0
    grid_9_x1y1_possible_tensor = grid_9_x1y1_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_9_x2y2_possible_tensor = torch.from_numpy(grid_9_x2y2_possible).float() / 255.0
    grid_9_x2y2_possible_tensor = grid_9_x2y2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_9_x1y2_possible_tensor = torch.from_numpy(grid_9_x1y2_possible).float() / 255.0
    grid_9_x1y2_possible_tensor = grid_9_x1y2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_9_x2y1_possible_tensor = torch.from_numpy(grid_9_x2y1_possible).float() / 255.0
    grid_9_x2y1_possible_tensor = grid_9_x2y1_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_9_x1x2_possible_tensor = torch.from_numpy(grid_9_x1x2_possible).float() / 255.0
    grid_9_x1x2_possible_tensor = grid_9_x1x2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_9_y1y2_possible_tensor = torch.from_numpy(grid_9_y1y2_possible).float() / 255.0
    grid_9_y1y2_possible_tensor = grid_9_y1y2_possible_tensor.unsqueeze(0).unsqueeze(0)

    grid_27_x1y1_possible_tensor = torch.from_numpy(grid_27_x1y1_possible).float() / 255.0
    grid_27_x1y1_possible_tensor = grid_27_x1y1_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_27_x2y2_possible_tensor = torch.from_numpy(grid_27_x2y2_possible).float() / 255.0
    grid_27_x2y2_possible_tensor = grid_27_x2y2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_27_x1y2_possible_tensor = torch.from_numpy(grid_27_x1y2_possible).float() / 255.0
    grid_27_x1y2_possible_tensor = grid_27_x1y2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_27_x2y1_possible_tensor = torch.from_numpy(grid_27_x2y1_possible).float() / 255.0
    grid_27_x2y1_possible_tensor = grid_27_x2y1_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_27_x1x2_possible_tensor = torch.from_numpy(grid_27_x1x2_possible).float() / 255.0
    grid_27_x1x2_possible_tensor = grid_27_x1x2_possible_tensor.unsqueeze(0).unsqueeze(0)
    grid_27_y1y2_possible_tensor = torch.from_numpy(grid_27_y1y2_possible).float() / 255.0
    grid_27_y1y2_possible_tensor = grid_27_y1y2_possible_tensor.unsqueeze(0).unsqueeze(0)

    # 将数据加载到所选设备上
    grid_3_x1y1_possible_tensor, grid_3_x2y2_possible_tensor, grid_3_x1y2_possible_tensor, grid_3_x2y1_possible_tensor, grid_3_x1x2_possible_tensor, grid_3_y1y2_possible_tensor = grid_3_x1y1_possible_tensor.to(
        device), grid_3_x2y2_possible_tensor.to(device), grid_3_x1y2_possible_tensor.to(device), grid_3_x2y1_possible_tensor.to(device), grid_3_x1x2_possible_tensor.to(device), grid_3_y1y2_possible_tensor.to(device)
    grid_9_x1y1_possible_tensor, grid_9_x2y2_possible_tensor, grid_9_x1y2_possible_tensor, grid_9_x2y1_possible_tensor, grid_9_x1x2_possible_tensor, grid_9_y1y2_possible_tensor = grid_9_x1y1_possible_tensor.to(
        device), grid_9_x2y2_possible_tensor.to(device), grid_9_x1y2_possible_tensor.to(device), grid_9_x2y1_possible_tensor.to(device), grid_9_x1x2_possible_tensor.to(device), grid_9_y1y2_possible_tensor.to(device)
    grid_27_x1y1_possible_tensor, grid_27_x2y2_possible_tensor, grid_27_x1y2_possible_tensor, grid_27_x2y1_possible_tensor, grid_27_x1x2_possible_tensor, grid_27_y1y2_possible_tensor = grid_27_x1y1_possible_tensor.to(
        device), grid_27_x2y2_possible_tensor.to(device), grid_27_x1y2_possible_tensor.to(device), grid_27_x2y1_possible_tensor.to(device), grid_27_x1x2_possible_tensor.to(device), grid_27_y1y2_possible_tensor.to(device)

    # 将数据输入模型
    grid_3_output, grid_9_output, grid_27_output = model_encoder(
        [grid_3_x1y1_possible_tensor, grid_3_x2y2_possible_tensor, grid_3_x1y2_possible_tensor, grid_3_x2y1_possible_tensor, grid_3_x1x2_possible_tensor, grid_3_y1y2_possible_tensor],
        [grid_9_x1y1_possible_tensor, grid_9_x2y2_possible_tensor, grid_9_x1y2_possible_tensor, grid_9_x2y1_possible_tensor, grid_9_x1x2_possible_tensor, grid_9_y1y2_possible_tensor],
        [grid_27_x1y1_possible_tensor, grid_27_x2y2_possible_tensor, grid_27_x1y2_possible_tensor, grid_27_x2y1_possible_tensor, grid_27_x1x2_possible_tensor, grid_27_y1y2_possible_tensor])

    grid_3_output, grid_9_output, grid_27_output = model_decoder(grid_3_output, grid_9_output, grid_27_output)
    # 计算重构误差
    loss = torch.nn.MSELoss()  # 定义损失函数

    # 计算每个分支的重构误差
    loss_x1y1_value = loss(grid_3_output[0], grid_3_x1y1_possible_tensor) + loss(grid_9_output[0], grid_9_x1y1_possible_tensor) + loss(grid_27_output[0], grid_27_x1y1_possible_tensor)
    loss_x2y2_value = loss(grid_3_output[1], grid_3_x2y2_possible_tensor) + loss(grid_9_output[1], grid_9_x2y2_possible_tensor) + loss(grid_27_output[1], grid_27_x2y2_possible_tensor)
    loss_x1y2_value = loss(grid_3_output[2], grid_3_x1y2_possible_tensor) + loss(grid_9_output[2], grid_9_x1y2_possible_tensor) + loss(grid_27_output[2], grid_27_x1y2_possible_tensor)
    loss_x2y1_value = loss(grid_3_output[3], grid_3_x2y1_possible_tensor) + loss(grid_9_output[3], grid_9_x2y1_possible_tensor) + loss(grid_27_output[3], grid_27_x2y1_possible_tensor)
    loss_x1x2_value = loss(grid_3_output[4], grid_3_x1x2_possible_tensor) + loss(grid_9_output[4], grid_9_x1x2_possible_tensor) + loss(grid_27_output[4], grid_27_x1x2_possible_tensor)
    loss_y1y2_value = loss(grid_3_output[5], grid_3_y1y2_possible_tensor) + loss(grid_9_output[5], grid_9_y1y2_possible_tensor) + loss(grid_27_output[5], grid_27_y1y2_possible_tensor)

    # 计算总的重构误差
    loss_value = loss_x1y1_value + loss_x2y2_value + loss_x1y2_value + loss_x2y1_value + loss_x1x2_value + loss_y1y2_value

    # 判断是否为异常数据
    # if loss_value > 10*loss_value_threshold:
    #     status_value = 4
    #     print('当前运行状态 重构 异常 (重构误差：%s)' % loss_value.item())
    #
    # else:
    #     status_value = 3
    #     print('当前运行状态 重构 正常 (重构误差：%s)' % loss_value.item())
    if loss_value > loss_value_threshold * 2: # 如果总的重构误差大于阈值的2倍

        # 将异常数据的序号存储起来

        if (loss_x1y1_value > loss_value_threshold_x1y1) and (loss_x2y2_value > loss_value_threshold_x2y2):
            status_value = 3.3
            print("重构误差为{}".format(loss_value))

        elif loss_x1y1_value > loss_value_threshold_x1y1:
            status_value = 3.1
            print("重构误差为{}".format(loss_value))

        elif loss_x2y2_value > loss_value_threshold_x2y2:
            status_value = 3.2
            print("重构误差为{}".format(loss_value))

        else:
            status_value = 3
            print('当前运行状态 重构 正常 (重构误差：%s)' % loss_value.item())

    # 绘制重构误差图：共2*3*6共36张子图
      
    
    # 3*3 的6种分支网格特征 子图
    plt.figure(figsize=(10, 5), facecolor='w') # 背景无色
    plt.subplot(6, 6, 1)
    plt.imshow(grid_3_x1y1_possible, cmap='gray')
    plt.subplot(6, 6, 4)
    plt.imshow(grid_3_output[0].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 7)
    plt.imshow(grid_3_x2y2_possible, cmap='gray')
    plt.subplot(6, 6, 10)
    plt.imshow(grid_3_output[1].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 13)
    plt.imshow(grid_3_x1y2_possible, cmap='gray')
    plt.subplot(6, 6, 16)
    plt.imshow(grid_3_output[2].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 19)
    plt.imshow(grid_3_x2y1_possible, cmap='gray')
    plt.subplot(6, 6, 22)
    plt.imshow(grid_3_output[3].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 25)
    plt.imshow(grid_3_x1x2_possible, cmap='gray')
    plt.subplot(6, 6, 28)
    plt.imshow(grid_3_output[4].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 31)
    plt.imshow(grid_3_y1y2_possible, cmap='gray')
    plt.subplot(6, 6, 34)
    plt.imshow(grid_3_output[5].cpu().detach().numpy()[0, 0, :, :], cmap='gray')

    # 9*9 的6种分支网格特征 子图
    plt.subplot(6, 6, 2)
    plt.imshow(grid_9_x1y1_possible, cmap='gray')
    plt.subplot(6, 6, 5)
    plt.imshow(grid_9_output[0].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 8)
    plt.imshow(grid_9_x2y2_possible, cmap='gray')
    plt.subplot(6, 6, 11)
    plt.imshow(grid_9_output[1].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 14)
    plt.imshow(grid_9_x1y2_possible, cmap='gray')
    plt.subplot(6, 6, 17)
    plt.imshow(grid_9_output[2].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 20)
    plt.imshow(grid_9_x2y1_possible, cmap='gray')
    plt.subplot(6, 6, 23)
    plt.imshow(grid_9_output[3].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 26)
    plt.imshow(grid_9_x1x2_possible, cmap='gray')
    plt.subplot(6, 6, 29)
    plt.imshow(grid_9_output[4].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 32)
    plt.imshow(grid_9_y1y2_possible, cmap='gray')
    plt.subplot(6, 6, 35)
    plt.imshow(grid_9_output[5].cpu().detach().numpy()[0, 0, :, :], cmap='gray')

    # 27*27 的6种分支网格特征 子图
    plt.subplot(6, 6, 3)
    plt.imshow(grid_27_x1y1_possible, cmap='gray')
    plt.subplot(6, 6, 6)
    plt.imshow(grid_27_output[0].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 9)
    plt.imshow(grid_27_x2y2_possible, cmap='gray')
    plt.subplot(6, 6, 12)
    plt.imshow(grid_27_output[1].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 15)
    plt.imshow(grid_27_x1y2_possible, cmap='gray')
    plt.subplot(6, 6, 18)
    plt.imshow(grid_27_output[2].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 21)
    plt.imshow(grid_27_x2y1_possible, cmap='gray')
    plt.subplot(6, 6, 24)
    plt.imshow(grid_27_output[3].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 27)
    plt.imshow(grid_27_x1x2_possible, cmap='gray')
    plt.subplot(6, 6, 30)
    plt.imshow(grid_27_output[4].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.subplot(6, 6, 33)
    plt.imshow(grid_27_y1y2_possible, cmap='gray')
    plt.subplot(6, 6, 36)
    plt.imshow(grid_27_output[5].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.suptitle('3尺寸_6分支_网格特征重构图', fontsize=20)

    # 保存总图片
    # 清空文件夹1中的图片
    for i in os.listdir(r'.\img\temp\1'):
        os.remove(r'.\img\temp\1\{}'.format(i))


    plt.savefig(r'.\img\temp\1\3尺寸_6分支_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)
    # plt.show()

    # 分别保存其中的36张子图
    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_x1y1_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X1Y1_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_output[0].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X1Y1_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_x2y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X2Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_output[1].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X2Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_x1y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X1Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_output[2].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X1Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_x2y1_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X2Y1_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_output[3].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X2Y1_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_x1x2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X1X2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_output[4].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\3_X1X2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_y1y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\3_Y1Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_3_output[5].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\3_Y1Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    # 9*9 的6种分支网格特征 子图
    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_x1y1_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X1Y1_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_output[0].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X1Y1_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_x2y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X2Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_output[1].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X2Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_x1y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X1Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_output[2].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X1Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_x2y1_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X2Y1_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_output[3].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X2Y1_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_x1x2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X1X2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_output[4].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\9_X1X2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_y1y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\9_Y1Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_9_output[5].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\9_Y1Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    # 27*27 的6种分支网格特征 子图
    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_x1y1_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X1Y1_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_output[0].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X1Y1_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_x2y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X2Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_output[1].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X2Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_x1y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X1Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_output[2].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X1Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_x2y1_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X2Y1_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_output[3].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X2Y1_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_x1x2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X1X2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_output[4].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\27_X1X2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_y1y2_possible, cmap='gray')
    plt.savefig(r'.\img\temp\1\27_Y1Y2_原始_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)

    plt.figure(figsize=(10, 5), facecolor='w')
    plt.imshow(grid_27_output[5].cpu().detach().numpy()[0, 0, :, :], cmap='gray')
    plt.savefig(r'.\img\temp\1\27_Y1Y2_重构_网格特征重构图_temp.png', bbox_inches='tight',pad_inches = 0)



    return status_value

def mat_anomaly_detection():

    dataset_dic = ip.loadmat(r'.\data_temp\processed_data_temp.mat')
    dataset = dataset_dic['data']

    # b = 0
    # 1.基于目前的8000个数据点，进行网格化处理
    grid_counts_temp = grid_based_data.mat_grid_based_data(dataset)

    # 2.开始进行异常检测
    # 2.1 根据运动幅度将数据判断为正常数据、疑似异常数据或明显异常数据，进行初步异常检测
    status_value_temp, damage_degree_value_temp = split_data(5,5, 0.8, 0.25, grid_counts_temp)
    # 2.2 如果判断为疑似异常数据，则利用自编码器进行检测


############################################ 深度学习-故障检测模块 ############################################
################## 可以通过在这一部分添加其它的故障检测方法（函数），实现更加丰富的故障检测方法 ##########################
    if status_value_temp == 2:
        status_value_temp = autoencoder_detect(grid_counts_temp) # 轴心轨迹-自编码器检测




############################################ 深度学习-故障检测模块 ############################################


    print('status_value_temp:{}'.format(status_value_temp))

    return [status_value_temp, damage_degree_value_temp]
    ##return status_value_temp







# 调试
if __name__ == '__main__':
    # 从processed_data.mat文件中，读取数据在，作为dataset
    status_value_temp, damage_degree_value_temp = mat_anomaly_detection()
    b = 0


