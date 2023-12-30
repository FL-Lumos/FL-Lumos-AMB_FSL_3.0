# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     grid_based_data
   Description :    对deal_data_AD处理后的原始样本数据进行网格化处理
   Author :       YLF
   date：          2023/6/26
-------------------------------------------------
"""
import numpy as np
import matplotlib.pyplot as plt
# 设置matplotlib显示字体
from matplotlib import rcParams
rcParams['font.family'] = 'SimHei'


import scipy.io as ip
import scipy.io
import time
import os


class GgridBased:
    def __init__(self, dataset, k=[9]):
        self.dataset = dataset # 切割后的数据集
        self.k = k # 网格尺寸-列表
        # self.save_mat = save_mat # 保存生成的文件（1保存，0不保存）
        # self.plt_print_show = plt_print_show # 显示（1显示，0不显示）



    # 单个样本-单端-单尺寸：网格特征
    def grid_based_data_single(self, X_channel, Y_channel, k_temp):
        # grid_counts_single_temp = np.zeros((self.k[k_temp], self.k[k_temp]), dtype=int) # 每个网格特征图都要初始化为0
        # for i_data in range(self.dataset.shape[1]): # 遍历样本中的每个数据点
        #     x_index = (((self.dataset[X_channel, i_data] / np.max(np.abs(self.dataset[X_channel]))) + 1) // (
        #             2 / self.k[k_temp])).astype(int)  # +1是为了将负数转化为正数
        #     y_index = (((self.dataset[Y_channel, i_data] / np.max(np.abs(self.dataset[Y_channel]))) + 1) // (
        #             2 / self.k[k_temp])).astype(int)
        #     if x_index == self.k[k_temp]:
        #         x_index = self.k[k_temp] - 1
        #     if y_index == self.k[k_temp]:
        #         y_index = self.k[k_temp] - 1
        #     grid_counts_single_temp[y_index, x_index] += 1  # 注意：y_index、x_index的顺序，设计矩阵的方向

        normalized_coordinates = np.array([self.dataset[X_channel, :] / np.max(np.abs(self.dataset[X_channel])),
                                             self.dataset[Y_channel, :] / np.max(np.abs(self.dataset[Y_channel]))])

        # 计时
        start = time.time()
        # 映射坐标到3x3的网格范围
        row_indices = np.floor((normalized_coordinates[1] + 1) * self.k[k_temp] / 2).astype(int)  # floor 向下取整，astype 转换数据类
        col_indices = np.floor((normalized_coordinates[0] + 1) * self.k[k_temp] / 2).astype(int)

        # 限制索引在合法范围内
        row_indices = np.clip(row_indices, 0, self.k[k_temp] - 1)  # clip 限制范围，小于0的数变为0，大于2的数变为2
        col_indices = np.clip(col_indices, 0, self.k[k_temp] - 1)

        # 使用bincount函数计算每个网格中的点数
        grid_counts_single_temp = np.bincount(self.k[k_temp] * row_indices + col_indices, minlength=self.k[k_temp] * self.k[k_temp]).reshape(self.k[k_temp], self.k[k_temp])


        # 行翻转，确保网格轨迹矩阵的方向是从下到上（reshape的默认方向是从上到下）
        grid_matrix = np.flipud(grid_counts_single_temp)
        # print(grid_counts_single_temp)
        # 计时
        end = time.time()
        print('单个样本-单端-%d*%d网格特征计算时间：%.2f秒' % (self.k[k_temp], self.k[k_temp], end - start))


        return grid_counts_single_temp



    # 每个样本-多分支（x1y1、x2y2、x1y2、x2y1、x1x2、y1y2）-多尺寸（3*3、9*9、27*27）：网格特征
    def grid_based_data(self):

        grid_counts = {}

        # 所有尺寸的网格特征
        for i_k in range(len(self.k)):
            # 开始计算网格特征
            # 样本-单个尺寸网格特征-1、2端网格特征

            # x1、y1
            grid_counts_x1y1 = GgridBased.grid_based_data_single(self, X_channel=0, Y_channel=1, k_temp=i_k)
            # x2、y2
            grid_counts_x2y2 = GgridBased.grid_based_data_single(self, X_channel=2, Y_channel=3, k_temp=i_k)
            # x1、y2
            grid_counts_x1y2 = GgridBased.grid_based_data_single(self, X_channel=0, Y_channel=3, k_temp=i_k)
            # x2、y1
            grid_counts_x2y1 = GgridBased.grid_based_data_single(self, X_channel=2, Y_channel=1, k_temp=i_k)
            # x1、x2
            grid_counts_x1x2 = GgridBased.grid_based_data_single(self, X_channel=0, Y_channel=2, k_temp=i_k)
            # y1、y2
            grid_counts_y1y2 = GgridBased.grid_based_data_single(self, X_channel=1, Y_channel=3, k_temp=i_k)

            # # 显示对应的27*27尺度下-6种分支 的网格特征
            # plt.figure(figsize=(20, 10))
            # plt.subplot(321)
            # plt.imshow(grid_counts_x1y1[::-1, :], cmap=plt.cm.gray_r, interpolation='nearest')
            # # 注意:1.列的上下显示方向,2imshow会自动显示相对灰度图，不需要再归一化到0-255！！！
            # plt.subplot(322)
            # plt.imshow(grid_counts_x2y2[::-1, :], cmap=plt.cm.gray_r, interpolation='nearest')
            # plt.subplot(323)
            # plt.imshow(grid_counts_x1y2[::-1, :], cmap=plt.cm.gray_r, interpolation='nearest')
            # plt.subplot(324)
            # plt.imshow(grid_counts_x2y1[::-1, :], cmap=plt.cm.gray_r, interpolation='nearest')
            # plt.subplot(325)
            # plt.imshow(grid_counts_x1x2[::-1, :], cmap=plt.cm.gray_r, interpolation='nearest')
            # plt.subplot(326)
            # plt.imshow(grid_counts_y1y2[::-1, :], cmap=plt.cm.gray_r, interpolation='nearest')
            #
            # plt.suptitle('网格特征图', fontsize=20)
            # plt.show()

            # 把同一尺寸下 的6种分支的 网格特征 合并为一个grid_3（例grid_27）
            grid_counts_ports = np.array([grid_counts_x1y1, grid_counts_x2y2, grid_counts_x1y2, grid_counts_x2y1, grid_counts_x1x2, grid_counts_y1y2])
            grid_counts['grid_'+str(self.k[i_k])] = grid_counts_ports

        # 将样本原始的X1、Y1、X2、Y2、Z数据也保存到grid_counts中,方便后续先根据阈值进行异常检测
        grid_counts.update({'X1':self.dataset[0], 'Y1':self.dataset[1], 'X2':self.dataset[2], 'Y2':self.dataset[3],
                            'Z':self.dataset[4]})

        # #保存为.mat文件
        # if self.save_mat :
        #     time_stamp = time.strftime("%Y%m%d%H%M%S", time.localtime()) # 文件名加上时间戳
        #     file_name = 'AD_dataset_Grid_' + time_stamp + '.mat'
        #     # 主目录下存在a、b两个子文件夹，在b文件夹下需要运行scipy.io.savemat，将数据文件保存在a文件夹下
        #     scipy.io.savemat(r'..\dataset/'+file_name,
        #                      grid_counts)

        return grid_counts # 以字典类型，返回网格特征数据（key：grid_3、grid_9、grid_27、X1、Y1、X2、Y2、Z）

# 便于在matlab调用
def mat_grid_based_data(dataset):
    grid_based = GgridBased(dataset, k=[3, 9, 27])
    grid_counts = grid_based.grid_based_data()

    return grid_counts




# if __name__ == '__main__':




