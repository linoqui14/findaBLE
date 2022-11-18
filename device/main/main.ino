#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEServer.h>

#include <BLEAdvertisedDevice.h>
#include "WiFi.h"
#include <HTTPClient.h>
#include <EEPROM.h>

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
int pairID = 1011;

void RequestTask( void * parameter) {
  int count  = 0;
  for(;;) {
    if(WiFi.status() == WL_CONNECTED){
      if(count==0){
        count = 1;       
      }else{count = 0;}
      Serial.println("Device ID: "+String(DID));
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
            Serial.print("Distance: ");
            Serial.println(pow(10, (-77 - rssi)/(10*2.5)));          

            if(WiFi.status() == WL_CONNECTED){
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
  if(DID==255){
    EEPROM.write(0, 11);
    EEPROM.commit();
  }
  if(DID==11){
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
  // initWiFi();
  

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
  if(DID!=11){
    
// put your main code here, to run repeatedly:
    BLEScanResults foundDevices = pBLEScan->start(scanTime, false);
    Serial.print("Devices found: ");
    Serial.println(foundDevices.getCount());
    Serial.println("Scan done!");
    pBLEScan->clearResults();   // delete results fromBLEScan buffer to release memory  
  }
  
  delay(2000);
}
