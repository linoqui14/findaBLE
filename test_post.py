
from tinydb import TinyDB,where
from models import User,Tag,ESP32Pair,tagDB,esp32PairDB
import cmath
import time


def tag_pos(a, b, c):
    # p = (a + b + c) / 2.0
    # s = cmath.sqrt(p * (p - a) * (p - b) * (p - c))
    # y = 2.0 * s / c
    # x = cmath.sqrt(b * b - y * y)
    cos_a = (((b * b) + (c*c) - (a * a))) / (2 * b * c)
    x = b * cos_a
    y = b * cmath.sqrt(1 - (cos_a * cos_a))

    return round(x.real, 1), round(y.real, 1)



while True:
    c = esp32PairDB.get(where('id')=="1011")
    c = c['distance']
    tag = tagDB.get(where('espID')=='1011')
    b = tag['distance_left']

    a = tag['distance_right']
    print(tag_pos(a,b,c))
    time.sleep(0.5)
