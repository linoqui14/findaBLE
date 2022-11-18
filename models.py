from pickle import FALSE
import re
from tinydb import TinyDB,where

db = TinyDB('db.json')
userDB = db.table('users')
tagDB = db.table('tags')
esp32PairDB = db.table('esp32')
class User:
    def __init__(self,name,password,deviceID,id='n/a',isLogin = False):
        if id =='null':
            id = '12341231241241233123'
        userObj = userDB.search(where('id')==int(id))

        self.isLogin = isLogin
        self.id = len(userDB.all())
        self.name = name
        self.password = password
        self.isNew = True
        self.deviceID = deviceID
       
        # self.isLogin = False

        if  userObj!=[] :
            userObj = userObj[0]
            self.id  = int(userObj['id'])
            self.isNew = False
        
        

    def toJson(self):
        return {
            'id':self.id,
            'name':self.name,
            'password':self.password,
            'deviceID':self.deviceID,
            'isLogin':self.isLogin
        }

    def upsertUser(self):
        if not self.isNew:
            userDB.update(self.toJson(),where('id') == self.id)
            return self.toJson()
        userDB.insert(self.toJson())
        return self.toJson()
        
    def getUser(self):
        if self.isNew:
            return {}
        else: return self.toJson()
    
class Tag:
    def __init__(self,name,id,distance_left,distance_right):
        tagObj = tagDB.search(where('id')==id)
        self.id = id
        self.name = name
        self.isNew = True
        self.distance_left = distance_left
        self.distance_right = distance_right
       
        # self.isLogin = False

        if  tagObj!=[] :
            tagObj = tagObj[0]
            self.id  = tagObj['id']
            self.isNew = False
    def toJson(self):
        return {
            'id':self.id,
            'name':self.name,
            'distance_left':self.distance_left,
            'distance_right':self.distance_right,
        }

    def upsertUser(self):
        if not self.isNew:
            esp32PairDB.update(self.toJson(),where('id') == self.id)
            return self.toJson()
        esp32PairDB.insert(self.toJson())
        return self.toJson()


class ESP32Pair:
    def __init__(self,id,distance,scanMode):
            esp32PairObj = esp32PairDB.search(where('id')==id)
            self.id = id
            self.isNew = True
            self.distance = distance
            self.scanMode = scanMode

            if  esp32PairObj!=[] :
                esp32PairObj = esp32PairObj[0]
                self.id  = esp32PairObj['id']
                self.isNew = False

    def upsert(self):
        if not self.isNew:
            tagDB.update(self.toJson(),where('id') == self.id)
            return self.toJson()
        tagDB.insert(self.toJson())
        return self.toJson()  

    def toJson(self):
        return {
            'id':self.id,
            'distance':self.distance,
            'scanMode':self.scanMode,
        }
    
class Detector:
    def __init__(self,id,name,distance,time,status):
        self.name = name
        self.id = id
        self.distance = distance
        self.time = time
        self.status = status


class Room:
    def __init__(self,id,detector_id,name,status):
        self.detector_id = detector_id
        self.id = id
        self.name = name
        self.status = status

class Object:
    def __init__(self,id,user_id,object_name,assigned_name):
        self.user_id = user_id
        self.id = id
        self.object_name = object_name
        self.assigned_name = assigned_name

class Findable:
    def __init__(self,id,room_id,user_id,detector_id,object_id):
        self.user_id = user_id
        self.detector_id = detector_id
        self.object_id = object_id
        self.id = id
        self.room_id = room_id
