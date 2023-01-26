
from flask import Flask,request
# from models import User,Tag,ESP32Pair,tagDB
from util import kalman_filter,particle_filter
from pymongo import MongoClient
import datetime
uri = "mongodb+srv://cluster0.yhuewdl.mongodb.net/?authSource=%24external&authMechanism=MONGODB-X509&retryWrites=true&w=majority"
client = MongoClient(uri,
                     tls=True,
                     tlsCertificateKeyFile='sert.pem')
 

# Connect to the test db 
db=client['findable']

dbUserJS=db['users']
roomDBJS=db['rooms']
tagDBJS=db['tags']
esp32PairDBJS=db['esps']
logDB=db['logDB']

# dbUserJS = TinyDB('user.json')
# roomDBJS = TinyDB('room.json')
# tagDBJS = TinyDB('tag.json')
# esp32PairDBJS = TinyDB('esp.json')

# userDB = dbUserJS.user
# esp32PairDB = esp32PairDBJS.table('esp32')
# roomDB = roomDBJS.table('room')

code = "123556"
app = Flask(__name__)
import cmath

espDistances = []
tags = []
tagsWithRDistance = []
def tag_pos(a, b, c,id):
    isRecorded = False
    currentTag = []
    # p = (a + b + c) / 2.0
    # s = cmath.sqrt(p * (p - a) * (p - b) * (p - c))
    # y = 2.0 * s / c
    # x = cmath.sqrt(b * b - y * y)
    cos_a = (((b * b) + (c*c) - (a * a))) / (2 * b * c)
    x = b * cos_a
    y = b * cmath.sqrt(1 - (cos_a * cos_a))
    for tagwd in tagsWithRDistance:
        if tagwd['id'] == id:
            isRecorded = True
            break

    if isRecorded:
        for tag in tagsWithRDistance:
            if tag['id'] == id:
                xTotal = 0
                yTotal = 0
                xAVG = 0
                yAVG = 0
                for xv in tag['x']:
                    xTotal+=xv
                for yv in tag['y']:
                    yTotal+=yv
                xAVG = xTotal/len(tag['x'])
                yAVG = yTotal/len(tag['y'])
                tag['x'].append(x)
                tag['y'].append(y)
                return {'x':round(xAVG.real, 2), 'y':round(yAVG.real, 2)}
                
        pass
    else:
        tagsWithRDistance.append({
            'id':id,
            'x':[x,],
            'y':[y,]
        })
    
    return {'x':round(x.real, 2), 'y':round(y.real, 2)}
@app.route("/reset_tag_pos" , methods=["GET","POST"])
def resetTagPos():
    tagID = request.form['tagID']
    for x in tagsWithRDistance:
        if x['id'] == tagID:
            x['x'] = [0,]
            x['y'] = [0,]
            break
    return ""

def resetTagPosHalf(tagID):
    for x in tagsWithRDistance:
        if x['id'] == tagID:
            x['x'].clear()
            x['y'].clear()
            break
    return ""
@app.route("/get_tag_pos" , methods=["GET","POST"])
def getTagPos():
    tagID = request.form['tagID']
    try:
        c = esp32PairDBJS.find_one({'id':"1011"})
        c = c['distance']
        tag = tagDBJS.find_one({'id':tagID})
        b = tag['distance_left']
        a = tag['distance_right']
        pos = tag_pos(a,b,c,tag['id'])
        for x in tagsWithRDistance:
            if x['id'] == tag['id']:
                print(len(x['x']))
                if len(x['x'])>=20:
                    return pos
                if len(x['x'])>=35:
                    # resetTagPosHalf(tagID)
                    pass
                break
        
        return {"x":-1.0,'y':-1.0,'len':len(x['x'])}
    except:
        filtered_distances = kalman_filter(espDistances,A=1, H=1, Q=1.6, R=6)
        print(len(espDistances))
        if len(espDistances)>20:
            total = 0
            for x in espDistances:
                total+=x
            avg = round(total/len(espDistances),2)
        
        distance = round(pow(10,((avg) - (filtered_distances[-1]))/(10*2.5)),2)

        c = distance
        tag = tagDBJS.find_one({'espID':"1011"})
        if(tag==None):
            return {"x":-1.0,'y':-1.0,'len':len(x['x'])}

        b = tag['distance_left']
        a = tag['distance_right']

        pos = tag_pos(a,b,c,tag['id'])
        for x in tagsWithRDistance:
            if x['id'] == tag['id']:
                if len(x['x'])>=20:
                    return pos
                break
        
        return {"x":-1.0,'y':-1.0,'len':len(x['x'])}

@app.route("/get_logs" , methods=["GET","POST"])
def getLogs():
    userID = request.form['userID']
    logs = []
    logsJS = logDB.find({'userID':userID})
    for x in logsJS:
        logs.append(x)
    return logs

@app.route("/add_log" , methods=["GET","POST"])
def addLog():
    userID = request.form['userID']
    roomID = request.form['roomID']
    status = request.form['status']
    current_time = datetime.datetime.now()
    size = logDB.find()
    count = 0
    for x in size:
        count+=1
    
    logDB.insert_one({
        '_id':count,
        'id':count,
        'userID':userID,
        'roomID':roomID,
        'status':status,
        'log_time':current_time
    })
    return ""
@app.route("/insert_user/<codep>" , methods=["GET","POST"])
def insertUser(codep):
    if codep!=code:
        return {}
    name = request.form['username']
    password = request.form['password']
    deviceID = request.form['deviceID']
    id = request.form['id']
    size = dbUserJS.find()
    count = 0
    for x in size:
        count+=1
    # isLogin = True if request.form['isLogin']=='true' else False
    dbUserJS.insert_one({
        '_id':count,
        'name':name,
        'password':password,
        'deviceID':deviceID,
        'id':count,
        'isLogin':False
    })
    return {
        'name':name,
        'password':password,
        'deviceID':deviceID,
        'id':count,
        'isLogin':False
    }
   
@app.route("/get_user/<codep>", methods=["GET","POST"])
def getUser(codep):
    if codep!=code:
        return {}
    name = request.form['username']
    password = request.form['password']
    deviceID = request.form['deviceID']

    user = dbUserJS.find_one({'name':name,'password':password})
    # user = userDB.search(where('name')==name and where('password')==password)
    
    # if(user.count==0):return {}
    # user = User(name=name,password=password,deviceID=deviceID,id=user[0]['id'])
    print(user)
    return user

@app.route("/get_current_login/<codep>",methods=["GET","POST"])
def getCurrentLogin(codep):
    if codep!=code:
        return {}
    deviceID = request.form['deviceID']
    
    user = dbUserJS.find_one({'deviceID':deviceID})
    
    if len(user)==0:
        return ""

    return user

@app.route("/get_users",methods=["GET","POST"])
def getUsers():
    users = []
    usersJS = dbUserJS.find()
    for x in usersJS:
        users.append(x)
    print(users)
    return users

@app.route("/is_connected")
def isConnected():
    return "1"
    
@app.route("/get_tag",methods=["GET","POST"])
def getTag():
    tags_get = []
    tagsJs = tagDBJS.find()
    for x in tagsJs:
        tags_get.append(x)
    return tags_get

@app.route("/get_tag_where_id",methods=["GET","POST"])
def getTagWhereID():
    id = request.form['id']
    print(id)
    tagsJs = tagDBJS.find_one({'id':id})
    return tagsJs
@app.route("/get_tag_where_id_userid",methods=["GET","POST"])
def getTagWhereIDUserID():
    id = request.form['id']
    userID = request.form['userID']
    print(id)
    tagsJs = tagDBJS.find_one({'id':id,'userID':int(userID)})
    return tagsJs

@app.route("/get_tag_where_userid",methods=["GET","POST"])
def getTagWhereUserID():
    userID = request.form['userID']
    tagsJs = tagDBJS.find({'userID':int(userID)})
    tags = []
    for x in tagsJs:
        tags.append(x)
    print(tags)
    if tagsJs==None:return []
    return tags

@app.route("/upsert_tag/<address>/<name>/<distance>/<espID>",methods=["GET","POST"])
def upsertTag(address,name,distance,espID):
    id = address
    # print(id)
    distance = distance.split('(-)')
    position = distance[1]
    distance = distance[0]
    r_distance = 0
    l_distance = 0
    current_time = datetime.datetime.now()
    # if position == "right": 
    #     r_distance = float(distance)
    #     tag = Tag(name=name,id=id,distance_left="na",distance_right=float(distance),espID=espID)
    # else:
    #     l_distance = float(distance)
    #     tag = Tag(name=name,id=id,distance_left=float(distance),distance_right="na",espID=espID)
    # tag.upsertUser()

    try:
        
        for tg in tags:
            if tg['id']==id:
                this_tag = tg
                break
        # print(tags.index(this_tag))
        if len(this_tag['distance_left'])>50:
            if position=='left' and distance!='na':
                this_tag['distance_left'][-1] = float(distance)
            if position=='right' and distance!='na':
                this_tag['distance_right'][-1] = float(distance)
            
        else:
           
            if position=='left' and distance!='na':
                this_tag['distance_left'].append(float(distance))
            if position=='right' and distance!='na':
                this_tag['distance_right'].append(float(distance))
        print(len(tags))
        if len(this_tag['distance_left'])>10 and len(this_tag['distance_right'])>10:
            filtered_distance_left = kalman_filter(this_tag['distance_left'][1:],A=1, H=1, Q=1.6, R=6)
            filtered_distance_right = kalman_filter(this_tag['distance_right'][1:],A=1, H=1, Q=1.6, R=6)
            filtered_distance_left_particle = particle_filter(filtered_distance_left,A=1, H=1, Q=1.6, R=6,quant_particles=100)
            filtered_distance_right_particle = particle_filter(filtered_distance_right,A=1, H=1, Q=1.6, R=6,quant_particles=100)
            total_a = 0
            total_b = 0
            for x in filtered_distance_left_particle:
                total_a+=x
            for y in filtered_distance_right_particle:
                total_b+=y

            avg_a = round(total_a/len(filtered_distance_left_particle),2)
            avg_b = round(total_b/len(filtered_distance_right_particle),2)
            
            distance_a = round(pow(10,((-77) - (filtered_distance_left_particle[-1]))/(10*2.5)),2)
            distance_b = round(pow(10,((-77) - (filtered_distance_right_particle[-1]))/(10*2.5)),2)
        #     # print(filtered_distance_left)
        #     # print(filtered_distance_right)
        #     # tagDB.update({'distance_right':distance_b,'distance_left':distance_a},where('id')==id)
            if tagDBJS.find_one({'id':id}) == None:
                print(id)
                tagDBJS.insert_one({
                    '_id':id,
                    'id':id,
                    'name':name,
                    'date_update':current_time,
                    'espID':espID,
                    'distance_right':distance_b,
                    'distance_left':distance_a,
                    'userID':-1
                })
            else:
                tagDBJS.update_one({'id':id},{'$set':{'distance_right':distance_b,'distance_left':distance_a,'date_update':current_time,}})
    except:
        tags.append(
            {
                'id':id,
                'distance_left':[l_distance],
                'distance_right':[r_distance]
                    
            }
        )
    return "1"

@app.route("/update_user",methods=["GET","POST"])
def updateUser():
    id = request.form['id']
    name = request.form['username']
    password = request.form['password']
    deviceID = request.form['deviceID']
    isLogin = True if request.form['isLogin']=='true' else False
    
    dbUserJS.update_one({'id':int(id)},{"$set":{'name':name,'password':password,'isLogin':isLogin,'deviceID':deviceID}})
    return "1"

@app.route("/update_tag_name",methods=["GET","POST"])
def updateTagName():
    id = request.form['id']
    name = request.form['name']
    tagDBJS.update_one({'id':id},{"$set":{'name':name,}})
    return '1'
@app.route("/update_tag_userid",methods=["GET","POST"])
def updateTagUserID():
    id = request.form['id']
    userID = request.form['userID']
    tagDBJS.update_one({'id':id},{"$set":{'userID':int(userID),}})
    return '1'


@app.route("/insert_esp32/<id>",methods=["GET","POST"])
def insertESP32(id):
    esp32 = esp32PairDBJS.insert({'_id':id,'id':id,'distance':0,'reset':0,'mode':0})
    return "1"

def resetESPdistance():
    espDistances.clear()
    return '1'
@app.route("/update_esp32_reset/<id>",methods=["GET","POST"])
def updateESP32Reset(id):
    resetESPdistance()
    esp32PairDBJS.update_one({'id':id},{"$set":{'reset':1}})
    return "1"

@app.route("/deleteESP32/<id>",methods=["GET","POST"])
def deleteESP32(id):
    # esp32PairDB.remove(where("id")==id)
    return "1"

@app.route("/update_esp32_mode/<id>/<mode>",methods=["GET","POST"])
def updateESP32Mode(id,mode):
    resetESPdistance()
    esp32PairDBJS.update_one({'id':id},{"$set":{'mode':int(mode),'reset':0}})
    return "1"


@app.route("/update_esp32_distance/<id>/<distance>",methods=["GET","POST"])
def updateESPDistance(id,distance):
    if len(espDistances)<100:
        espDistances.append(float(distance))
    else :espDistances[-1] = float(distance)
    # test = [-65,-56,-72,-50,-55]
    filtered_distances = kalman_filter(espDistances,A=1, H=1, Q=1.6, R=6)
    print(len(espDistances))
    if len(espDistances)>10:
        total = 0
        for x in espDistances:
            total+=x
        avg = round(total/len(espDistances),2)
        distance = round(pow(10,((avg) - (filtered_distances[-1]))/(10*2.5)),3)
        esp32PairDBJS.update_one({'id':id},{'$set':{'distance':distance}})

    else: esp32PairDBJS.update_one({'id':id},{'$set':{'distance':0.0}})
   
    return "1"

@app.route("/update_esp32_room",methods=["GET","POST"])
def updateRoomESP32():
    esp32PairDBJS.update_one({'id':id},{'$set':{'roomID':request.form['roomID']}})
    return "1"
    
@app.route("/get_esp32/<id>",methods=["GET","POST"])
def getEsp(id):
    
    esp32 =esp32PairDBJS.find_one({'id':id})
    # if(esp32.count==0):return {}
    # for x in esp32:
    #     if x['id']==id:
    #         esp32 = x
   
    # esp322 = ESP32Pair(id=id,distance=esp32['distance'],reset=esp32['reset'],mode=esp32['mode'])
    # esp32 = {'reset':esp32['reset'],'mode':esp32['mode']}
    return esp32
@app.route("/get_esp32_with_room",methods=["GET","POST"])
def getEspWithRoom():
    roomID = request.form['roomID']
    esp32 = esp32PairDBJS.find_one({"roomID":roomID})
    return esp32
    
@app.route("/update_room",methods=["GET","POST"])
def updateRoom():
    roomID = request.form['id']
    userID = request.form['userID']
    newuserID = request.form['newuserID']
    esp32ID = request.form['esp32ID']
    roomName = request.form['name']
    roomDBJS.update_one({'id':roomID,'userID':userID,'esp32ID':esp32ID},{"$set":{'name':roomName,'userID':newuserID}})
    return ""

@app.route("/insert_room/",methods=["GET","POST"])
def insertRoom():
    all_room = []
    size = roomDBJS.find()
    for x in size:
        all_room.append(x)
    userID = request.form['userID']
    name = request.form['name']
    esp32ID = request.form['esp32ID']
    room = roomDBJS.find_one({'userID':userID,'esp32ID':esp32ID})
    print(room)
    if room !=None:
        return "0"

    roomDBJS.insert_one(
        {
            '_id':str(len(all_room)),
            'id':str(len(all_room)),
            'userID':userID,
            'name':name,
            'esp32ID':esp32ID
        })
    return str(len(all_room))

@app.route("/get_room/",methods=["GET","POST"])
def getRoom():
    # rooms = roomDB.get(where('userID')==request.form['userID'])
    rooms = []
    userID = request.form['userID']
    roomsJS = roomDBJS.find({'userID':userID})
    for x in roomsJS:
        rooms.append(x)
    # print(request.form['userID'])
    return rooms
    # print("ASdasd")
    # return "asdasd"

@app.route("/get_room_where_esp",methods=["GET","POST"])
def getRoomWhereESP():
    esp32ID = request.form['esp32ID']
    userID = request.form['userID']
    print(userID)
    room = roomDBJS.find_one({'esp32ID':esp32ID,'userID':userID})
    print(room)
    return room


# if __name__ == '__main__':
#     app.run('0.0.0.0')
