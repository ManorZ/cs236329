close all; clear; clc;
load("hw1_2\MIT6_057IAP19_hw2\googlePrices.mat")
endValueInit100 = tradeStock(100, price, lows, peaks)
endValueInit100K = tradeStock(100000, price, lows, peaks)
