from pickle import FALSE
import re
from tinydb import TinyDB,where

dbUserJS = TinyDB('user.json')
roomDBJS = TinyDB('room.json')
tagDBJS = TinyDB('tag.json')
esp32PairDBJS = TinyDB('esp.json')

userDB = dbUserJS.table('users')
tagDB = tagDBJS.table('tags')
esp32PairDB = esp32PairDBJS.table('esp32')

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
    def __init__(self,name,id,distance_left,distance_right,espID):
        tagObj = tagDB.search(where('id')==id)
        self.id = id
        self.name = name
        self.isNew = True
        self.distance_left = distance_left
        self.distance_right = distance_right
        self.espID = espID
       
        # self.isLogin = False

        if  tagObj!=[] :
            tagObj = tagObj[0]

            if(distance_left=='na'):
                    self.distance_left = float(tagObj['distance_left'])

            if(distance_right=='na'):
                    self.distance_right = float(tagObj['distance_right'])
            self.id  = tagObj['id']
            self.isNew = False
            
    def toJson(self):
        return {
            'id':self.id,
            'name':self.name,
            'distance_left':self.distance_left,
            'distance_right':self.distance_right,
            'espID':self.espID,
        }

    
    
    def upsertUser(self):
        if not self.isNew:
            tagDB.update(self.toJson(),where('id') == self.id)
            return self.toJson()
        tagDB.insert(self.toJson())
        return self.toJson()


class ESP32Pair:
    def __init__(self,id,distance,reset,mode,roomID):
            # esp32PairObj = esp32PairDB.search(where('id')==id)
            self.id = id
            self.distance = distance
            self.roomID = roomID
            if reset!='na':
                self.reset = int(reset)
            else:
                self.reset = reset
            if mode!='na':
                self.mode = int(mode)
            else:
                self.mode = mode
                
            # if  esp32PairObj!=[] :
            #     esp32PairObj = esp32PairObj[0]
            #     if(reset=='na' and esp32PairObj['reset']!='na'):
            #         self.reset = int(esp32PairObj['reset'])
                    
            #     if(mode=='na' and esp32PairObj['mode']!='na'):
            #         self.mode = int(esp32PairObj['mode'])
            #     if(self.distance=="0.00"):
            #         self.distance = esp32PairObj['distance']
            #     if roomID!='na':
            #         self.roomID = esp32PairObj['roomID']
            #     self.id  = esp32PairObj['id']
            #     self.isNew = False
    def insert(self):
        esp32PairDB.insert(self.toJson())    
    def update(self):
        esp32PairDB.update(self.toJson(),where('id') == self.id)
    # def upsert(self):
    #     if not self.isNew:
    #         esp32PairDB.update(self.toJson(),where('id') == self.id)
    #         return self.toJson()
    #     esp32PairDB.insert(self.toJson())
    #     return self.toJson()  

    def toJson(self):
        return {
            'id':self.id,
            'distance':self.distance,
            'reset':self.reset,
            'mode':self.mode,
            'roomID':self.roomID       
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
