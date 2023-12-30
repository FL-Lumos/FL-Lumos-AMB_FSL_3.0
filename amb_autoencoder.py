# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     MNIST_autoencoder
   Description :   参考处理MNIST数据集的卷积自编码器，编写处理amb数据集的卷积自编码器
   Author :       13401
   date：          2023/7/12
-------------------------------------------------
"""
import os
os.environ["KMP_DUPLICATE_LIB_OK"]="TRUE" # 消除关于多个libiomp5md.dll的警告

import matplotlib.pyplot as plt  # plotting library
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
import time

# 自编码器模型


# 1.加载数据集（给一个路径，自动把每一尺度的所有数据作为一个字典的值输出）
class GetData():
    def __init__(self, data_path):
        self.data_path = data_path # 原始数据路径

    def load_data(self):
        data_grid = {} # 创建一个字典，用于存储每一端的每一尺度的数据

        p = ip.loadmat(self.data_path)  # loadmat将.mat文件作为一个字典读入
        for key in p.keys():
            if key[0:4] == 'grid':
                grid_temp = p[key]
                data_grid[key] = grid_temp[:,:, np.newaxis, :, :] #np.newaxis

        return data_grid



# 2.单个数据集转Tensor通用方法
class ListToTensor(Dataset):
    def __init__(self, data):
        self.data = data

    def __len__(self): # 返回数据集大小
        return len(self.data)

    def __getitem__(self, idx):
        sample = self.data[idx]
        '''
         预留数据预处理位置
        '''
        sample = torch.tensor(sample, dtype=torch.float32) / 255.0 # 转Tensor，并归一化
        return sample



# 3.数据集划分,并构建数据加载器
class SplitLodarDataset():
    def __init__(self, data_path, train_ratio, val_ratio, batch_size, normal_data=True):
        self.data_path = data_path # 原始数据路径
        self.train_ratio = train_ratio # 训练集比例
        self.val_ratio = val_ratio # 验证集比例
        self.batch_size = batch_size
        self.normal_data = normal_data # 是否为正常数据

    def to_tensor_data(self):
        # 1.读取数据
        get_data_temp = GetData(self.data_path)
        data_grids = get_data_temp.load_data()

        # 2.转换为Tensor
        processed_data = {}
        xy_keys = ['x1y1', 'x2y2', 'x1y2', 'x2y1', 'x1x2', 'y1y2']

        for key in data_grids.keys():
            for i in range(len(data_grids[key])):
                processed_data[key+'_'+xy_keys[i]] = ListToTensor(data_grids[key][i])

        return processed_data

    # 将正常数据集分为训练集、验证集和测试集
    def split_normal_dataset(self, data_temp):
        # data_temp 的
        train_data, val_data, test_data = [], [], []
        train_loader, valid_loader, test_loader_normal = [], [], []
        m = len(data_temp)
        train_size = int(m * self.train_ratio)
        val_size = int(m * self.val_ratio)
        test_size = int(m - train_size - val_size)
        train_data, val_data, test_data = random_split(data_temp, [train_size, val_size, test_size])

        # 构建数据加载器，用于迭代加载数据
        train_loader = DataLoader(train_data, batch_size=self.batch_size)
        valid_loader = DataLoader(val_data, batch_size=self.batch_size)
        test_loader_normal = DataLoader(test_data, batch_size=self.batch_size)

        return train_data, val_data, test_data, train_loader, valid_loader, test_loader_normal


    def split_abnormal_dataset(self, data_temp):
        # 异常测试集
        test_loader_1 = DataLoader(data_temp, batch_size=self.batch_size)


        return test_loader_1

    # 划分tensor数据集,并构建数据加载器
    def loader_dataset(self):
        train_data, val_data, test_data, train_loader, valid_loader, test_normal_loader, test_abnormal_loader = {}, {}, {}, {}, {}, {}, {}
        processed_data = self.to_tensor_data()
        if self.normal_data:
            for key in processed_data.keys():
                train_data[key], val_data[key], test_data[key], train_loader[key], valid_loader[key], test_normal_loader[key] = self.split_normal_dataset(processed_data[key])

            # 输出训练集和验证集的大小
            print('训练集大小：', len(train_loader[key].dataset))
            print('验证集大小：', len(valid_loader[key].dataset))
            print('正常数据-测试集大小：', len(test_normal_loader[key].dataset))

            return train_loader, valid_loader, test_normal_loader
        else:
            for key in processed_data.keys():
                test_abnormal_loader[key] = self.split_abnormal_dataset(processed_data[key])

            print('异常数据-测试集大小：', len(test_abnormal_loader[key].dataset))

            return test_abnormal_loader

# 噪声函数
def add_noise(image_batch, noise_factor):
    noisy_image_batch = image_batch + noise_factor * torch.randn(*image_batch.shape)
    noisy_image_batch = torch.clip(noisy_image_batch, 0., 1.) # 将张量中的元素限制在指定的范围内
    #return noisy_image_batch # 暂停添加噪声
    return image_batch


# 2.构建卷积自编码器模型
# 编码器
class Encoder(nn.Module):
    def __init__(self, encoded_space_dim):
        super().__init__()

        # x1y1
        # 第一个分支的：
        # 卷积层
        self.encoder_cnn_3_x1y1 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=1, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=1),
            nn.ReLU(True)
        )

        # 展平层
        self.flatten_3_x1y1 = nn.Flatten(start_dim=1)

        # 激活层
        self.encoder_lin_3_x1y1 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第二个分支的：
        self.encoder_cnn_9_x1y1 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=0),
            nn.ReLU(True)
        )
        self.flatten_9_x1y1 = nn.Flatten(start_dim=1)
        self.encoder_lin_9_x1y1 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第三个分支的：
        self.encoder_cnn_27_x1y1 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=2, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=2, padding=0),
            nn.ReLU(True)
        )
        self.flatten_27_x1y1 = nn.Flatten(start_dim=1)
        self.encoder_lin_27_x1y1 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # x2y2
        # 第一个分支的：
        self.encoder_cnn_3_x2y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=1, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=1),
            nn.ReLU(True)
        )
        self.flatten_3_x2y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_3_x2y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第二个分支的：
        self.encoder_cnn_9_x2y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=0),
            nn.ReLU(True)
        )
        self.flatten_9_x2y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_9_x2y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第三个分支的：
        self.encoder_cnn_27_x2y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=2, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=2, padding=0),
            nn.ReLU(True)
        )
        self.flatten_27_x2y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_27_x2y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # x1y2
        # 第一个分支的：
        self.encoder_cnn_3_x1y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=1, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=1),
            nn.ReLU(True)
        )
        self.flatten_3_x1y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_3_x1y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第二个分支的：
        self.encoder_cnn_9_x1y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=0),
            nn.ReLU(True)
        )
        self.flatten_9_x1y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_9_x1y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第三个分支的：
        self.encoder_cnn_27_x1y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=2, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=2, padding=0),
            nn.ReLU(True)
        )
        self.flatten_27_x1y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_27_x1y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # x2y1
        # 第一个分支的：
        self.encoder_cnn_3_x2y1 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=1, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=1),
            nn.ReLU(True)
        )
        self.flatten_3_x2y1 = nn.Flatten(start_dim=1)
        self.encoder_lin_3_x2y1 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第二个分支的：
        self.encoder_cnn_9_x2y1 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=0),
            nn.ReLU(True)
        )
        self.flatten_9_x2y1 = nn.Flatten(start_dim=1)
        self.encoder_lin_9_x2y1 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第三个分支的：
        self.encoder_cnn_27_x2y1 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=2, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=2, padding=0),
            nn.ReLU(True)
        )
        self.flatten_27_x2y1 = nn.Flatten(start_dim=1)
        self.encoder_lin_27_x2y1 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # x1x2
        # 第一个分支的：
        self.encoder_cnn_3_x1x2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=1, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=1),
            nn.ReLU(True)
        )
        self.flatten_3_x1x2 = nn.Flatten(start_dim=1)
        self.encoder_lin_3_x1x2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第二个分支的：
        self.encoder_cnn_9_x1x2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=0),
            nn.ReLU(True)
        )
        self.flatten_9_x1x2 = nn.Flatten(start_dim=1)
        self.encoder_lin_9_x1x2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第三个分支的：
        self.encoder_cnn_27_x1x2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=2, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=2, padding=0),
            nn.ReLU(True)
        )
        self.flatten_27_x1x2 = nn.Flatten(start_dim=1)
        self.encoder_lin_27_x1x2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # y1y2
        # 第一个分支的：
        self.encoder_cnn_3_y1y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=1, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=1),
            nn.ReLU(True)
        )
        self.flatten_3_y1y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_3_y1y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第二个分支的：
        self.encoder_cnn_9_y1y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=1, padding=0),
            nn.ReLU(True)
        )
        self.flatten_9_y1y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_9_y1y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )

        # 第三个分支的：
        self.encoder_cnn_27_y1y2 = nn.Sequential(
            nn.Conv2d(1, 8, 3, stride=2, padding=1), # 1表示输入通道数，8表示输出通道数，3表示卷积核大小，stride=2表示步长为2，padding=1表示填充1
            nn.ReLU(True), # ReLU激活函数
            nn.Conv2d(8, 16, 3, stride=2, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.Conv2d(16, 32, 3, stride=2, padding=0),
            nn.ReLU(True)
        )
        self.flatten_27_y1y2 = nn.Flatten(start_dim=1)
        self.encoder_lin_27_y1y2 = nn.Sequential(
            nn.Linear(3 * 3 * 32, 128), # 3*3*32表示输入维度，128表示输出维度
            nn.ReLU(True),
            nn.Linear(128, encoded_space_dim) # encoded_space_dim表示输出维度
        )


    def forward(self, grid_3, grid_9, grid_27):
        # x1y1
        # 3*3
        grid_3[0] = self.encoder_cnn_3_x1y1(grid_3[0])
        grid_3[0] = self.flatten_3_x1y1(grid_3[0])
        grid_3[0] = self.encoder_lin_3_x1y1(grid_3[0])

        # 9*9
        grid_9[0] = self.encoder_cnn_9_x1y1(grid_9[0])
        grid_9[0] = self.flatten_9_x1y1(grid_9[0])
        grid_9[0] = self.encoder_lin_9_x1y1(grid_9[0])

        # 27*27
        grid_27[0] = self.encoder_cnn_27_x1y1(grid_27[0])
        grid_27[0] = self.flatten_27_x1y1(grid_27[0])
        grid_27[0] = self.encoder_lin_27_x1y1(grid_27[0])

        # x2y2
        # 3*3
        grid_3[1] = self.encoder_cnn_3_x1y1(grid_3[1])
        grid_3[1] = self.flatten_3_x1y1(grid_3[1])
        grid_3[1] = self.encoder_lin_3_x1y1(grid_3[1])

        # 9*9
        grid_9[1] = self.encoder_cnn_9_x1y1(grid_9[1])
        grid_9[1] = self.flatten_9_x1y1(grid_9[1])
        grid_9[1] = self.encoder_lin_9_x1y1(grid_9[1])

        # 27*27
        grid_27[1] = self.encoder_cnn_27_x1y1(grid_27[1])
        grid_27[1] = self.flatten_27_x1y1(grid_27[1])
        grid_27[1] = self.encoder_lin_27_x1y1(grid_27[1])

        # x1y2
        # 3*3
        grid_3[2] = self.encoder_cnn_3_x1y1(grid_3[2])
        grid_3[2] = self.flatten_3_x1y1(grid_3[2])
        grid_3[2] = self.encoder_lin_3_x1y1(grid_3[2])

        # 9*9
        grid_9[2] = self.encoder_cnn_9_x1y1(grid_9[2])
        grid_9[2] = self.flatten_9_x1y1(grid_9[2])
        grid_9[2] = self.encoder_lin_9_x1y1(grid_9[2])

        # 27*27
        grid_27[2] = self.encoder_cnn_27_x1y1(grid_27[2])
        grid_27[2] = self.flatten_27_x1y1(grid_27[2])
        grid_27[2] = self.encoder_lin_27_x1y1(grid_27[2])

        # x2y1
        # 3*3
        grid_3[3] = self.encoder_cnn_3_x1y1(grid_3[3])
        grid_3[3] = self.flatten_3_x1y1(grid_3[3])
        grid_3[3] = self.encoder_lin_3_x1y1(grid_3[3])

        # 9*9
        grid_9[3] = self.encoder_cnn_9_x1y1(grid_9[3])
        grid_9[3] = self.flatten_9_x1y1(grid_9[3])
        grid_9[3] = self.encoder_lin_9_x1y1(grid_9[3])

        # 27*27
        grid_27[3] = self.encoder_cnn_27_x1y1(grid_27[3])
        grid_27[3] = self.flatten_27_x1y1(grid_27[3])
        grid_27[3] = self.encoder_lin_27_x1y1(grid_27[3])

        # x1x2
        # 3*3
        grid_3[4] = self.encoder_cnn_3_x1y1(grid_3[4])
        grid_3[4] = self.flatten_3_x1y1(grid_3[4])
        grid_3[4] = self.encoder_lin_3_x1y1(grid_3[4])

        # 9*9
        grid_9[4] = self.encoder_cnn_9_x1y1(grid_9[4])
        grid_9[4] = self.flatten_9_x1y1(grid_9[4])
        grid_9[4] = self.encoder_lin_9_x1y1(grid_9[4])

        # 27*27
        grid_27[4] = self.encoder_cnn_27_x1y1(grid_27[4])
        grid_27[4] = self.flatten_27_x1y1(grid_27[4])
        grid_27[4] = self.encoder_lin_27_x1y1(grid_27[4])

        # y1y2
        # 3*3
        grid_3[5] = self.encoder_cnn_3_x1y1(grid_3[5])
        grid_3[5] = self.flatten_3_x1y1(grid_3[5])
        grid_3[5] = self.encoder_lin_3_x1y1(grid_3[5])

        # 9*9
        grid_9[5] = self.encoder_cnn_9_x1y1(grid_9[5])
        grid_9[5] = self.flatten_9_x1y1(grid_9[5])
        grid_9[5] = self.encoder_lin_9_x1y1(grid_9[5])

        # 27*27
        grid_27[5] = self.encoder_cnn_27_x1y1(grid_27[5])
        grid_27[5] = self.flatten_27_x1y1(grid_27[5])
        grid_27[5] = self.encoder_lin_27_x1y1(grid_27[5])



        return grid_3, grid_9, grid_27


# 解码器
class Decoder(nn.Module):
    def __init__(self, encoded_space_dim):
        super().__init__()

        # x1y1
        # 第一个分支的反卷积：
        self.decoder_lin_3_x1y1 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_3_x1y1 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_3_x1y1 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=1, padding=1),
            nn.ReLU(True)
        )

        # 第二个分支的反卷积：
        self.decoder_lin_9_x1y1 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_9_x1y1 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_9_x1y1 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=0, output_padding=0), # 输出尺寸为5*5
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1, output_padding=0),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # 第三个分支的反卷积：
        self.decoder_lin_27_x1y1 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_27_x1y1 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_27_x1y1 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=2, padding=0, output_padding=0),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=2, padding=1, output_padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # x2y2
        # 第一个分支的反卷积：
        self.decoder_lin_3_x2y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_3_x1y1 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_3_x2y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=1, padding=1),
            nn.ReLU(True)
        )

        # 第二个分支的反卷积：
        self.decoder_lin_9_x2y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_9_x2y2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_9_x2y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=0, output_padding=0),  # 输出尺寸为5*5
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1, output_padding=0),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # 第三个分支的反卷积：
        self.decoder_lin_27_x2y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_27_x2y2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_27_x2y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=2, padding=0, output_padding=0),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=2, padding=1, output_padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # x1y2
        # 第一个分支的反卷积：
        self.decoder_lin_3_x1y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_3_x1y2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_3_x1y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=1, padding=1),
            nn.ReLU(True)
        )

        # 第二个分支的反卷积：
        self.decoder_lin_9_x1y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_9_x1y2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_9_x1y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=0, output_padding=0),  # 输出尺寸为5*5
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1, output_padding=0),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # 第三个分支的反卷积：
        self.decoder_lin_27_x1y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_27_x1y2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_27_x1y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=2, padding=0, output_padding=0),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=2, padding=1, output_padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # x2y1
        # 第一个分支的反卷积：
        self.decoder_lin_3_x2y1 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_3_x2y1 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_3_x2y1 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=1, padding=1),
            nn.ReLU(True)
        )

        # 第二个分支的反卷积：
        self.decoder_lin_9_x2y1 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_9_x2y1 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_9_x2y1 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=0, output_padding=0),  # 输出尺寸为5*5
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1, output_padding=0),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # 第三个分支的反卷积：
        self.decoder_lin_27_x2y1 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_27_x2y1 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_27_x2y1 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=2, padding=0, output_padding=0),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=2, padding=1, output_padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # x1x2
        # 第一个分支的反卷积：
        self.decoder_lin_3_x1x2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_3_x1x2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_3_x1x2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=1, padding=1),
            nn.ReLU(True)
        )

        # 第二个分支的反卷积：
        self.decoder_lin_9_x1x2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_9_x1x2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_9_x1x2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=0, output_padding=0),  # 输出尺寸为5*5
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1, output_padding=0),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # 第三个分支的反卷积：
        self.decoder_lin_27_x1x2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_27_x1x2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_27_x1x2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=2, padding=0, output_padding=0),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=2, padding=1, output_padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # y1y2
        # 第一个分支的反卷积：
        self.decoder_lin_3_y1y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_3_y1y2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_3_y1y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=1),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=1, padding=1),
            nn.ReLU(True)
        )

        # 第二个分支的反卷积：
        self.decoder_lin_9_y1y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_9_y1y2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_9_y1y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=1, padding=0, output_padding=0),  # 输出尺寸为5*5
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=1, padding=1, output_padding=0),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )

        # 第三个分支的反卷积：
        self.decoder_lin_27_y1y2 = nn.Sequential(
            nn.Linear(encoded_space_dim, 128),
            nn.ReLU(True),
            nn.Linear(128, 3 * 3 * 32),
            nn.ReLU(True)
        )
        self.unflatten_27_y1y2 = nn.Unflatten(1, (32, 3, 3))
        self.decoder_cnn_27_y1y2 = nn.Sequential(
            nn.ConvTranspose2d(32, 16, 3, stride=2, padding=0, output_padding=0),
            nn.BatchNorm2d(16),
            nn.ReLU(True),
            nn.ConvTranspose2d(16, 8, 3, stride=2, padding=1, output_padding=1),
            nn.ReLU(True),
            nn.ConvTranspose2d(8, 1, 3, stride=2, padding=1, output_padding=0),
            nn.ReLU(True)
        )


    def forward(self, grid_3, grid_9, grid_27):
        # x1y1
        # 3*3
        grid_3[0] = self.decoder_lin_3_x1y1(grid_3[0])
        grid_3[0]  = self.unflatten_3_x1y1(grid_3[0])
        grid_3[0]  = self.decoder_cnn_3_x1y1(grid_3[0])

        # 9*9
        grid_9[0] = self.decoder_lin_9_x1y1(grid_9[0])
        grid_9[0] = self.unflatten_9_x1y1(grid_9[0])
        grid_9[0] = self.decoder_cnn_9_x1y1(grid_9[0])

        # 27*27
        grid_27[0] = self.decoder_lin_27_x1y1(grid_27[0])
        grid_27[0] = self.unflatten_27_x1y1(grid_27[0])
        grid_27[0] = self.decoder_cnn_27_x1y1(grid_27[0])

        # x2y2
        # 3*3
        grid_3[1] = self.decoder_lin_3_x1y1(grid_3[1])
        grid_3[1]  = self.unflatten_3_x1y1(grid_3[1])
        grid_3[1]  = self.decoder_cnn_3_x1y1(grid_3[1])

        # 9*9
        grid_9[1] = self.decoder_lin_9_x1y1(grid_9[1])
        grid_9[1] = self.unflatten_9_x1y1(grid_9[1])
        grid_9[1] = self.decoder_cnn_9_x1y1(grid_9[1])

        # 27*27
        grid_27[1] = self.decoder_lin_27_x1y1(grid_27[1])
        grid_27[1] = self.unflatten_27_x1y1(grid_27[1])
        grid_27[1] = self.decoder_cnn_27_x1y1(grid_27[1])

        # x1y2
        # 3*3
        grid_3[2] = self.decoder_lin_3_x1y1(grid_3[2])
        grid_3[2]  = self.unflatten_3_x1y1(grid_3[2])
        grid_3[2]  = self.decoder_cnn_3_x1y1(grid_3[2])

        # 9*9
        grid_9[2] = self.decoder_lin_9_x1y1(grid_9[2])
        grid_9[2] = self.unflatten_9_x1y1(grid_9[2])
        grid_9[2] = self.decoder_cnn_9_x1y1(grid_9[2])

        # 27*27
        grid_27[2] = self.decoder_lin_27_x1y1(grid_27[2])
        grid_27[2] = self.unflatten_27_x1y1(grid_27[2])
        grid_27[2] = self.decoder_cnn_27_x1y1(grid_27[2])

        # x2y1
        # 3*3
        grid_3[3] = self.decoder_lin_3_x1y1(grid_3[3])
        grid_3[3]  = self.unflatten_3_x1y1(grid_3[3])
        grid_3[3]  = self.decoder_cnn_3_x1y1(grid_3[3])

        # 9*9
        grid_9[3] = self.decoder_lin_9_x1y1(grid_9[3])
        grid_9[3] = self.unflatten_9_x1y1(grid_9[3])
        grid_9[3] = self.decoder_cnn_9_x1y1(grid_9[3])

        # 27*27
        grid_27[3] = self.decoder_lin_27_x1y1(grid_27[3])
        grid_27[3] = self.unflatten_27_x1y1(grid_27[3])
        grid_27[3] = self.decoder_cnn_27_x1y1(grid_27[3])

        # x1x2
        # 3*3
        grid_3[4] = self.decoder_lin_3_x1y1(grid_3[4])
        grid_3[4]  = self.unflatten_3_x1y1(grid_3[4])
        grid_3[4]  = self.decoder_cnn_3_x1y1(grid_3[4])

        # 9*9
        grid_9[4] = self.decoder_lin_9_x1y1(grid_9[4])
        grid_9[4] = self.unflatten_9_x1y1(grid_9[4])
        grid_9[4] = self.decoder_cnn_9_x1y1(grid_9[4])

        # 27*27
        grid_27[4] = self.decoder_lin_27_x1y1(grid_27[4])
        grid_27[4] = self.unflatten_27_x1y1(grid_27[4])
        grid_27[4] = self.decoder_cnn_27_x1y1(grid_27[4])

        # y1y2
        # 3*3
        grid_3[5] = self.decoder_lin_3_x1y1(grid_3[5])
        grid_3[5]  = self.unflatten_3_x1y1(grid_3[5])
        grid_3[5]  = self.decoder_cnn_3_x1y1(grid_3[5])

        # 9*9
        grid_9[5] = self.decoder_lin_9_x1y1(grid_9[5])
        grid_9[5] = self.unflatten_9_x1y1(grid_9[5])
        grid_9[5] = self.decoder_cnn_9_x1y1(grid_9[5])

        # 27*27
        grid_27[5] = self.decoder_lin_27_x1y1(grid_27[5])
        grid_27[5] = self.unflatten_27_x1y1(grid_27[5])
        grid_27[5] = self.decoder_cnn_27_x1y1(grid_27[5])

        return grid_3, grid_9, grid_27



# 训练模型
def train_epoch(encoder, decoder, device, dataloader, loss_fn, optimizer, noise_factor=0.3):
    # 训练模式
    encoder.train()
    decoder.train()
    train_loss = [] # 存储每个batch的损失值
    max_batch = len(next(iter(dataloader.values()))) # dataloader第一个键值对的值的长度



    # 遍历数据集中的每个batch
    batch_count = 1 # 从1开始，记录当前batch的索引
    grid_3 = dataloader['grid_3_x1y1']


    for grid_3_0, grid_3_1, grid_3_2, grid_3_3, grid_3_4, grid_3_5, \
        grid_9_0, grid_9_1, grid_9_2, grid_9_3, grid_9_4, grid_9_5, \
        grid_27_0, grid_27_1, grid_27_2, grid_27_3, grid_27_4, grid_27_5 \
        in zip(dataloader['grid_3_x1y1'], dataloader['grid_3_x2y2'], dataloader['grid_3_x1y2'], dataloader['grid_3_x2y1'], dataloader['grid_3_x1x2'], dataloader['grid_3_y1y2'],
                                  dataloader['grid_9_x1y1'], dataloader['grid_9_x2y2'], dataloader['grid_9_x1y2'], dataloader['grid_9_x2y1'], dataloader['grid_9_x1x2'], dataloader['grid_9_y1y2'],
                                  dataloader['grid_27_x1y1'], dataloader['grid_27_x2y2'], dataloader['grid_27_x1y2'], dataloader['grid_27_x2y1'], dataloader['grid_27_x1x2'], dataloader['grid_27_y1y2']
                                    ):

        # 将数据加载到所选设备(GPU)上
        image_grid_3_0, image_grid_3_1, image_grid_3_2, image_grid_3_3, image_grid_3_4, image_grid_3_5 = grid_3_0.to(device), grid_3_1.to(device), grid_3_2.to(device), grid_3_3.to(device), grid_3_4.to(device), grid_3_5.to(device)
        image_grid_9_0, image_grid_9_1, image_grid_9_2, image_grid_9_3, image_grid_9_4, image_grid_9_5 = grid_9_0.to(device), grid_9_1.to(device), grid_9_2.to(device), grid_9_3.to(device), grid_9_4.to(device), grid_9_5.to(device)
        image_grid_27_0, image_grid_27_1, image_grid_27_2, image_grid_27_3, image_grid_27_4, image_grid_27_5 = grid_27_0.to(device), grid_27_1.to(device), grid_27_2.to(device), grid_27_3.to(device), grid_27_4.to(device), grid_27_5.to(device)



        # 编码-数据
        encoded_data_3, encoded_data_9, encoded_data_27 = encoder([image_grid_3_0, image_grid_3_1, image_grid_3_2, image_grid_3_3, image_grid_3_4, image_grid_3_5],
                                                                    [image_grid_9_0, image_grid_9_1, image_grid_9_2, image_grid_9_3, image_grid_9_4, image_grid_9_5],
                                                                    [image_grid_27_0, image_grid_27_1, image_grid_27_2, image_grid_27_3, image_grid_27_4, image_grid_27_5]) # 输出编码后的数据

        # 解码-数据
        decoded_data_3, decoded_data_9, decoded_data_27 = decoder(encoded_data_3, encoded_data_9, encoded_data_27) # 输出解码后的数据

        # 计算重构误差损失函数（基于解码后的数据和加噪声的原始数据之间的--均方误差）
        loss = loss_fn(decoded_data_3[0], image_grid_3_0) + loss_fn(decoded_data_3[1], image_grid_3_1) + loss_fn(decoded_data_3[2], image_grid_3_2) + loss_fn(decoded_data_3[3], image_grid_3_3) + loss_fn(decoded_data_3[4], image_grid_3_4) + loss_fn(decoded_data_3[5], image_grid_3_5) + \
                loss_fn(decoded_data_9[0], image_grid_9_0) + loss_fn(decoded_data_9[1], image_grid_9_1) + loss_fn(decoded_data_9[2], image_grid_9_2) + loss_fn(decoded_data_9[3], image_grid_9_3) + loss_fn(decoded_data_9[4], image_grid_9_4) + loss_fn(decoded_data_9[5], image_grid_9_5) + \
                loss_fn(decoded_data_27[0], image_grid_27_0) + loss_fn(decoded_data_27[1], image_grid_27_1) + loss_fn(decoded_data_27[2], image_grid_27_2) + loss_fn(decoded_data_27[3], image_grid_27_3) + loss_fn(decoded_data_27[4], image_grid_27_4) + loss_fn(decoded_data_27[5], image_grid_27_5)


        # 反向传播，更新参数
        optimizer.zero_grad() # 梯度清零，防止下一批次梯度累加
        loss.backward() # 反向传播，计算梯度
        optimizer.step() # 更新模型参数

        # 显示第*个batch对应的损失值
        print('\t partial train loss (%d batch): %f' % (batch_count, loss.data))
        batch_count += 1
        train_loss.append(loss.detach().cpu().numpy())

    # 每个平均值、最大值、最小值、中位数和两个四分位数（每个batch是一个数）
    return np.mean(train_loss), np.max(train_loss), np.min(train_loss), train_loss



# 评估模型
def test_epoch(encoder, decoder, device, dataloader, loss_fn):
    # 评估模式
    encoder.eval()
    decoder.eval()
    val_loss = [] # 存储每个batch的损失值

    with torch.no_grad(): # 不用计算梯度
        # 存储每个测试batch的损失值
        conc_out_3 = [] # 存储每个batch的输出结果
        conc_out_9 = [] # 存储每个batch的输出结果
        conc_out_27 = [] # 存储每个batch的输出结果

        conc_label_3 = [] # 存储每个batch的标签
        conc_label_9 = [] # 存储每个batch的标签
        conc_label_27 = [] # 存储每个batch的标签

        for grid_3_0, grid_3_1, grid_3_2, grid_3_3, grid_3_4, grid_3_5, \
                grid_9_0, grid_9_1, grid_9_2, grid_9_3, grid_9_4, grid_9_5, \
                grid_27_0, grid_27_1, grid_27_2, grid_27_3, grid_27_4, grid_27_5 \
                in zip(dataloader['grid_3_x1y1'], dataloader['grid_3_x2y2'], dataloader['grid_3_x1y2'],
                       dataloader['grid_3_x2y1'], dataloader['grid_3_x1x2'], dataloader['grid_3_y1y2'],
                       dataloader['grid_9_x1y1'], dataloader['grid_9_x2y2'], dataloader['grid_9_x1y2'],
                       dataloader['grid_9_x2y1'], dataloader['grid_9_x1x2'], dataloader['grid_9_y1y2'],
                       dataloader['grid_27_x1y1'], dataloader['grid_27_x2y2'], dataloader['grid_27_x1y2'],
                       dataloader['grid_27_x2y1'], dataloader['grid_27_x1x2'], dataloader['grid_27_y1y2']
                       ):
            # 将数据加载到所选设备(GPU)上
            image_grid_3_0, image_grid_3_1, image_grid_3_2, image_grid_3_3, image_grid_3_4, image_grid_3_5 = grid_3_0.to(
                device), grid_3_1.to(device), grid_3_2.to(device), grid_3_3.to(device), grid_3_4.to(
                device), grid_3_5.to(device)
            image_grid_9_0, image_grid_9_1, image_grid_9_2, image_grid_9_3, image_grid_9_4, image_grid_9_5 = grid_9_0.to(
                device), grid_9_1.to(device), grid_9_2.to(device), grid_9_3.to(device), grid_9_4.to(
                device), grid_9_5.to(device)
            image_grid_27_0, image_grid_27_1, image_grid_27_2, image_grid_27_3, image_grid_27_4, image_grid_27_5 = grid_27_0.to(
                device), grid_27_1.to(device), grid_27_2.to(device), grid_27_3.to(device), grid_27_4.to(
                device), grid_27_5.to(device)

            # 编码-数据
            encoded_data_3, encoded_data_9, encoded_data_27 = encoder(
                [image_grid_3_0, image_grid_3_1, image_grid_3_2, image_grid_3_3, image_grid_3_4, image_grid_3_5],
                [image_grid_9_0, image_grid_9_1, image_grid_9_2, image_grid_9_3, image_grid_9_4, image_grid_9_5],
                [image_grid_27_0, image_grid_27_1, image_grid_27_2, image_grid_27_3, image_grid_27_4,
                 image_grid_27_5])  # 输出编码后的数据

            # 解码-数据
            decoded_data_3, decoded_data_9, decoded_data_27 = decoder(encoded_data_3, encoded_data_9,
                                                                      encoded_data_27)  # 输出解码后的数据

            # 计算重构误差损失函数（基于解码后的数据和加噪声的原始数据之间的--均方误差）
            loss = loss_fn(decoded_data_3[0], image_grid_3_0) + loss_fn(decoded_data_3[1], image_grid_3_1) + loss_fn(
                decoded_data_3[2], image_grid_3_2) + loss_fn(decoded_data_3[3], image_grid_3_3) + loss_fn(
                decoded_data_3[4], image_grid_3_4) + loss_fn(decoded_data_3[5], image_grid_3_5) + \
                   loss_fn(decoded_data_9[0], image_grid_9_0) + loss_fn(decoded_data_9[1], image_grid_9_1) + loss_fn(
                decoded_data_9[2], image_grid_9_2) + loss_fn(decoded_data_9[3], image_grid_9_3) + loss_fn(
                decoded_data_9[4], image_grid_9_4) + loss_fn(decoded_data_9[5], image_grid_9_5) + \
                   loss_fn(decoded_data_27[0], image_grid_27_0) + loss_fn(decoded_data_27[1],
                                                                          image_grid_27_1) + loss_fn(decoded_data_27[2],
                                                                                                     image_grid_27_2) + loss_fn(
                decoded_data_27[3], image_grid_27_3) + loss_fn(decoded_data_27[4], image_grid_27_4) + loss_fn(
                decoded_data_27[5], image_grid_27_5)


            val_loss.append(loss.detach().cpu().numpy())


    return np.mean(val_loss), np.max(val_loss), np.min(val_loss), val_loss # 只在需要的时候才读val_loss的值


# 显示模型如何重构测试数据集中的图像
def plot_ae_outputs(encoder,decoder,data_temp,n=5):
    plt.figure(figsize=(10,4.5))
    #每10个epoch绘制一次
    if epoch % 10 == 0:
        for i in range(n):
            # 绘制第i个样本的重构图像
            # 加载原始图像
            ax = plt.subplot(2,n,i+1)

            # 要增加两个维度
            img = data_temp[i][0].unsqueeze(0).unsqueeze(0).to(device)

            # 编码解码图像
            encoder.eval()
            decoder.eval()
            with torch.no_grad():
                rec_img  = decoder(encoder(img))

            # 绘制原始图像
            plt.imshow(img.cpu().squeeze().numpy(), cmap='gist_gray')
            ax.get_xaxis().set_visible(False)
            ax.get_yaxis().set_visible(False)
            if i == n//2: # 在一行图片上添加一个标题
                ax.set_title('Original images')

            # 绘制重构图像
            ax = plt.subplot(2, n, i + 1 + n)
            plt.imshow(rec_img.cpu().squeeze().numpy(), cmap='gist_gray')
            ax.get_xaxis().set_visible(False)
            ax.get_yaxis().set_visible(False)
            if i == n//2:
                ax.set_title('Reconstructed images')
        plt.show()






