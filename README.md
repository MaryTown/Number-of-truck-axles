# Number-of-truck-axles
 LSTM network for determination the number of dump truck axles.
 The network was trained on data recorded at the sand pit of the Russian company Gidrotransservice. It is planned to retrain on a larger dataset.
# Input
 The input is 4 voltage indicators from the strain gauges of the four-axis scales, which are transmitted to the system with a frequency of 1 Hz (which is not essential for solving the problem, but justifies why it is impossible to simply count the voltage surges on the extreme axis of the scales), the total weight on the scales,  two-point two-point standard deviation deviation on the right axis and two-point standard deviation on the left axis - 7 dimensions. The vector length of each dimension is 17. In 17 seconds, all dump trucks have time to drive onto the scales completely.
# Output
 The output has a number of dump truck axles - 2, 3, 4, 5 or 6.

# About
File LSTMnetwork.py contains the creation of a neural network, its training and a function that calls it, written in Python using TensorFlow and Keras.
File Recording-data.pas contains part of the Delphi program needed to record input vectors.
