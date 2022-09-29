
import imp
from flask import Flask,request
from tinydb import TinyDB,where
from models import User


db = TinyDB('db.json')
userDB = db.table('users')
code = "123556"
app = Flask(__name__)


@app.route("/create_user/<codep>" , methods=["GET","POST"])
def createUser(codep):
    if codep!=code:
        return {}
    name = request.form['username']
    password = request.form['password']
    user = User(name=name,password=password)
    user.upsertUser()
    return user.toJson()
    
   
@app.route("/get_user/<codep>", methods=["GET","POST"])
def getUser(codep):
    if codep!=code:
        return {}
    name = request.form['username']
    password = request.form['password']
    print(name)
    user = User(name=name,password=password)
    return user.getUser()

@app.route("/get_users")
def getUsers():
    users = userDB.all()
    return users

@app.route("/is_connected")
def isConnected():
    return 1


if __name__ == '__main__':
    app.run('0.0.0.0')