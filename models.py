import re
from tinydb import TinyDB,where

db = TinyDB('db.json')
userDB = db.table('users')

class User:
    def __init__(self,name,password,deviceID):
        self.isLogin = False
        userObj = userDB.search(where('name')==name)
        if  userObj!=[] :
            userObj = userObj[0]
            if userObj['password']==password :
                self.id  = int(userObj['id'])
                self.name = userObj['name']
                self.password = userObj['password']
                self.deviceID = userObj['deviceID']

                self.isNew = False
            elif name != userObj['name']:
                self.name = name
                self.password = password
                self.id = len(userDB.all())
                self.isNew = True
                self.deviceID = deviceID
                self.isLogin = False
            else:
                return
        else:
            self.name = name
            self.password = password
            self.id = len(userDB.all())
            self.isNew = True
            self.deviceID = deviceID
            self.isLogin = False
        

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
            userDB.update({'name':self.name},where('id') == self.id)
            return 1
        userDB.insert(self.toJson())
        
    def getUser(self):
        if self.isNew:
            return {}
        else: return self.toJson()
    


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
