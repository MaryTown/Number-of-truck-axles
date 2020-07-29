# Импорт библиотек и классов
from __future__ import print_function
import tensorflow as tf
from tensorflow import keras
from keras.models import Sequential
from keras.layers import Dense, LSTM, GRU, Dropout
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from keras.callbacks import ModelCheckpoint

# Размерность данных
input_dim = 7
seq_max_len = 17
out_dim = 1
count = 1832
test_count = 275

# Импорт данных и приведение двумерного массива к трёхмерному для входа в LSTM
xx = pd.read_excel('All_x.xlsx', header=None, encoding='latin-1').values
print("shape of xx: ", xx.shape)
x_train = np.random.randint(0, 1, size=(count, seq_max_len, input_dim))
print("shape of x_train: ", x_train.shape)

xx_test = pd.read_excel('F_test_x.xlsx', header=None, encoding='latin-1').values
x_test = np.random.randint(0, 1, size=(test_count, seq_max_len, input_dim))

for i in range(count):
    for m in range(seq_max_len):
        x_train[i, m, ] = xx[seq_max_len*i+m, ]

for i in range(test_count):
    for m in range(seq_max_len):
        x_test[i, m, ] = xx_test[seq_max_len*i+m, ]
        
y_train = pd.read_excel('All_y.xlsx', header=None, encoding='latin-1').values
y_test = pd.read_excel('F_test_y.xlsx', header=None, encoding='latin-1').values

# Создание слоёв нейронной сети
model = Sequential()
model.add(LSTM(count, return_sequences=True, input_shape=(seq_max_len, input_dim)))
model.add(LSTM(128))
model.add(Dropout(0.5))
model.add(Dense(1, activation = 'relu'))

# Настройки функции оптимизации, функции потерь и метрики оценки работы модели
model.compile(optimizer = 'Adam', loss = 'mean_squared_error', metrics = ['accuracy'])

# Сохранение наилучшей модели (весов) для её дальнейшего использования
model_save_path='best_model.h5'
checkpoint_callback = ModelCheckpoint(model_save_path, monitor='val_accuracy', 
save_best_only=True)

# Запуск модели с настройками
history = model.fit(x_train, y_train, epochs = 150, batch_size = 256, 
			validation_split=0.2, callbacks=[checkpoint_callback])

# Построение графика для анализа точности работы нейронной сети
plt.plot(history.history['accuracy'], label='Доля верных ответов на обучающем наборе')
plt.plot(history.history['val_accuracy'],label='Доля верных ответов на тестовом 
наборе')
plt.xlabel('Эпохи обучения')
plt.ylabel('Доля верных ответов')
plt.legend()
plt.show()

# Прогон тестовых данных, которые НЕ использовались при обучении
scores = model.evaluate(x_test, y_test, verbose=1)
print("Доля верных ответов на тестовых данных, в процентах: ", round(scores[1]*100,4))

# Функция вызова обученной модели
from tensorflow.keras.models import load_model
import pandas as pd
import numpy as np

def neuro(x):
    model = load_model('best_model.h5')
    xx = pd.read_excel(x, header=None, encoding='latin-1'). values
    x_test = np.random.randint(0, 1, size=(1, seq_max_len, input_dim))
    for i in range(seq_max_len):
        x_test[0, i, ] = xx[i, ]
    prediction = model.predict(x_test)
    axles = round(prediction[0, 0], 0)
    return axles

axles = neuro('example_x.xlsx')
print('Число осей этого самосвала: ', axles)
