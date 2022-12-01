
import imp
from flask import Flask,request
from tinydb import TinyDB,where
from models import User,Tag,ESP32Pair


db = TinyDB('db.json')
userDB = db.table('users')
esp32PairDB = db.table('esp32')
code = "123556"
app = Flask(__name__)

espDistanceTotal = 0
espDistanceCount = 0
espDistanceAVR = 0

@app.route("/upsert_user/<codep>" , methods=["GET","POST"])
def upsertUser(codep):
    if codep!=code:
        return {}
    name = request.form['username']
    password = request.form['password']
    deviceID = request.form['deviceID']
    id = request.form['id']
    isLogin = True if request.form['isLogin']=='true' else False
    user = User(name=name,password=password,deviceID=deviceID,id=id,isLogin=isLogin)
    return user.upsertUser()
   
@app.route("/get_user/<codep>", methods=["GET","POST"])
def getUser(codep):
    if codep!=code:
        return {}
    name = request.form['username']
    password = request.form['password']
    deviceID = request.form['deviceID']
    user = userDB.search(where('name')==name and where('password')==password)
    
    if(user.count==0):return {}
    user = User(name=name,password=password,deviceID=deviceID,id=user[0]['id'])
    
    return user.getUser()

@app.route("/get_current_login/<codep>",methods=["GET","POST"])
def getCurrentLogin(codep):
    if codep!=code:
        return {}
    deviceID = request.form['deviceID']
    
    user = userDB.search(where('deviceID')==deviceID)
    
    if len(user)==0:
        return ""

    return user[0]

@app.route("/get_users")
def getUsers():
    users = userDB.all()
    return users

@app.route("/is_connected")
def isConnected():
    return 1
    

@app.route("/upsert_tag/<address>/<name>/<distance>",methods=["GET","POST"])
def upsertTag(address,name,distance):
    id = address
    distance = distance.split('-')
    position = distance[1]
    distance = distance[0]
    if position == "right": 
        tag = Tag(name=name,id=id,distance_left="na",distance_right=float(distance))
    else:
        tag = Tag(name=name,id=id,distance_left=float(distance),distance_right="na")
    tag.upsertUser()
    return tag.toJson()

@app.route("/upsert_esp32/<id>/<distance>/<reset>/<mode>",methods=["GET","POST"])
def upsertEsp(id,distance,reset,mode):
    global espDistanceTotal
    global espDistanceCount
    global espDistanceAVR
    espDistanceCount+=1.0
    espDistanceTotal+=float(distance)
    espDistanceAVR = espDistanceTotal/espDistanceCount
    
    esp32 = ESP32Pair(id=id,distance=round(espDistanceAVR,2),reset=reset,mode=mode)
    
    esp32.upsert()
    return esp32.toJson()


@app.route("/get_esp32/<id>",methods=["GET","POST"])
def getEsp(id):
    esp32 = esp32PairDB.all()
    
    
    if(esp32.count==0):return {}
    for x in esp32:
        if x['id']==id:
            esp32 = x
   
    esp322 = ESP32Pair(id=id,distance=esp32['distance'],reset=esp32['reset'],mode=esp32['mode'])
    return esp322.toJson()
    

@app.route("/test/<value>",methods=["GET","POST"])
def test(value):
    print(value)
    return ""

if __name__ == '__main__':
    app.run('0.0.0.0')