
import imp
from flask import Flask,request
from tinydb import TinyDB,where
from models import User,Tag


db = TinyDB('db.json')
userDB = db.table('users')
code = "123556"
app = Flask(__name__)


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
    

@app.route("/upsert_tag/<address>/<_name>/<_distance>",methods=["GET","POST"])
def upsertTag(address,_name,_distance):
    name = _name
    id = address
    distance = _distance
    tag = Tag(name=name,id=id,distance=distance)
    tag.upsertUser()
    return tag.toJson()

@app.route("/test/<value>",methods=["GET","POST"])
def test(value):
    print(value)
    return ""

if __name__ == '__main__':
    app.run('0.0.0.0')