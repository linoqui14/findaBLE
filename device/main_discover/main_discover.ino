#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEServer.h>

#include <BLEAdvertisedDevice.h>
#include "WiFi.h"
#include <HTTPClient.h>
#include <EEPROM.h>
#include <Arduino_JSON.h>


#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define EEPROM_SIZE 1

const char* ssid = "waypaynimama221x-far";
const char* password = "_Waypaynimama221xyz";

String serverName = "http://192.168.1.6:5000/";
TaskHandle_t requestTask;
int scanTime = 5; //In seconds
BLEScan* pBLEScan;
int DID;
int mode=255;
int pairID = 1011;
float pairDistance = 0.0;

void RequestTask( void * parameter) {
  int count  = 0;
  for(;;) {
    
    if(WiFi.status() == WL_CONNECTED){
      if(count==0){
        count = 1;       
      }else{count = 0;}
      
      HTTPClient http;
      String serverPath = serverName + "get_esp32/"+pairID;
      http.begin(serverPath.c_str());
      int httpResponseCode = http.GET();
      // Serial.println(httpResponseCode);
      if(httpResponseCode==200){
        String payload = http.getString();
        JSONVar myObject = JSON.parse(payload);
        JSONVar value = myObject["reset"];   
        String strValue =   JSON.stringify(value);
        int status = int(strValue[0]);
            
        //48 = 0
        //1 = advertise
        //0 = scan
        
               

        if(status == 49&&DID==11){
          JSONVar value = myObject["mode"];   
          String strValue =   JSON.stringify(value);
          mode = int(strValue[0]);
         
          if(mode==49){
            mode = 0;
          }
          else{
            mode = 1;
          }
          HTTPClient http;
          String serverPath = serverName+"/upsert_esp32/"+pairID+"/"+pairDistance+"/0/"+mode;
          http.begin(serverPath.c_str()); 
          int httpResponseCode = http.GET();
          delay(2000);           
          ESP.restart();      
        }
        
      }   
      else{
        HTTPClient http;
        String serverPath = serverName+"/upsert_esp32/"+pairID+"/"+pairDistance+"/na/"+"na";
        http.begin(serverPath.c_str()); 
        int httpResponseCode = http.GET();
      }   
      
      if(mode==1&&DID==10){
        HTTPClient http;
        String serverPath = serverName+"/upsert_esp32/"+pairID+"/"+pairDistance+"/0/"+mode;
        http.begin(serverPath.c_str()); 
        int httpResponseCode = http.GET();
      }
    }
    
    
    delay(1000);
    
  }
}

void initWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print('.');
    delay(1000);
  }
  Serial.println(WiFi.localIP());
}

class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
   void onResult(BLEAdvertisedDevice advertisedDevice) {
      
      // if(advertisedDevice.toString().find_first_of("iTAG            ")==5){
          // Serial.println("Advertised Device: %s", advertisedDevice.toString().c_str());
          // Serial.println(advertisedDevice.getName().compare("iTAG            "));
          //  Serial.println(advertisedDevice.getName().c_str());
          if(advertisedDevice.getName().compare("iTAG            ")==0||advertisedDevice.getName().compare("ESP32-11")==0){
            int rssi = advertisedDevice.getRSSI();
            Serial.println(advertisedDevice.getName().c_str());
            Serial.println(advertisedDevice.getAddress().toString().c_str());
                     
            if(advertisedDevice.getName().compare("ESP32-11")==0){
              pairDistance = pow(10, (-77 - rssi)/(10*2.5));
              // Serial.print("Distance: ");
              // Serial.println(pairDistance); 
            }
            if(WiFi.status() == WL_CONNECTED&&advertisedDevice.getName().compare("iTAG            ")==0){
              HTTPClient http;
              String name = advertisedDevice.getName().c_str();
              name.replace(" ","");
              String serverPath = serverName + "upsert_tag/"+advertisedDevice.getAddress().toString().c_str()+"/"+name+"/"+String(rssi);
              Serial.println(serverPath);     
              http.begin(serverPath.c_str());
              int httpResponseCode = http.GET();
            }         
          }
          
      // }
     
   }
};

void setup() {
  
  Serial.begin(115200);
  EEPROM.begin(EEPROM_SIZE);
  DID =  EEPROM.read(0);
  initWiFi();

  

  while(mode==255){
    HTTPClient http;  
    String serverPath = serverName + "get_esp32/"+pairID;
    http.begin(serverPath.c_str());
    int httpResponseCode = http.GET();

    String payload = http.getString();
    JSONVar myObject = JSON.parse(payload);
    JSONVar value = myObject["mode"];   
    String strValue =   JSON.stringify(value);
    mode = int(strValue[0]);
    if(mode==49){
      mode = 1;
      break;        
    }
    else{
      mode = 0;
      break;
    } 
         
    delay(1000);
  }
  
  
  Serial.println(mode);
  switch(mode){
    case 1:
      Serial.println("Mode: Advertise");
      break;
    case 0:
      Serial.println("Mode: Scanning");
      break;

    default:
      Serial.println("Mode: Undifined");   
      break;   
  }

  
  if(DID==255){
    EEPROM.write(0, 11);
    EEPROM.commit();
  }
  if(DID==11&&mode==1){
    BLEDevice::init("ESP32-11");
    BLEServer *pServer = BLEDevice::createServer();
    BLEService *pService = pServer->createService(SERVICE_UUID);
    BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                     CHARACTERISTIC_UUID,
                                     BLECharacteristic::PROPERTY_READ |
                                     BLECharacteristic::PROPERTY_WRITE
                                     );
    pCharacteristic->setValue("Hello World says Neil");
    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();
  }else{
    Serial.println("Scanning...");
    
    BLEDevice::init("");
    pBLEScan = BLEDevice::getScan(); //create new scan
    pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
    pBLEScan->setActiveScan(true); //active scan uses more power, but get results faster
    pBLEScan->setInterval(100);
    pBLEScan->setWindow(99);  // less or equal setInterval value
  }  
 
  

  xTaskCreatePinnedToCore(
      RequestTask, /* Function to implement the task */
      "RequestTask", /* Name of the task */
      10000,  /* Stack size in words */
      NULL,  /* Task input parameter */
      0,  /* Priority of the task */
      &requestTask,  /* Task handle. */
      0); /* Core where the task should run */

}

void loop() {
  if(mode!=1){
    
// put your main code here, to run repeatedly:
    BLEScanResults foundDevices = pBLEScan->start(scanTime, false);
    Serial.print("Devices found: ");
    Serial.println(foundDevices.getCount());
    Serial.println("Scan done!");
    pBLEScan->clearResults();   // delete results fromBLEScan buffer to release memory  
  }
  
  delay(2000);
}
