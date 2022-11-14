#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEServer.h>

#include <BLEAdvertisedDevice.h>
#include "WiFi.h"
#include <HTTPClient.h>
#include <EEPROM.h>

#define EEPROM_SIZE 1

const char* ssid = "waypaynimama221x-far";
const char* password = "_Waypaynimama221xyz";

String serverName = "http://192.168.1.6:5000/";
TaskHandle_t requestTask;
int scanTime = 5; //In seconds
BLEScan* pBLEScan;



void RequestTask( void * parameter) {
  int count  = 0;
  for(;;) {
    if(WiFi.status() == WL_CONNECTED){
      if(count==0){
        count = 1;       
      }else{count = 0;}
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
          // Serial.printf("Advertised Device: %s", advertisedDevice.toString().c_str());
          // Serial.println(advertisedDevice.getName().compare("iTAG            "));
          if(advertisedDevice.getName().compare("iTAG            ")==0){
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
  int DID =  EEPROM.read(0);
  if(DID==255){
    EEPROM.write(0, 11);
    EEPROM.commit();
  }
  if(DID==11){
    BLE.setLocalName("MyArduinoDevice");
  }  
  Serial.println(DID);

  
  Serial.println("Scanning...");
  initWiFi();
  BLEDevice::init("");
  pBLEScan = BLEDevice::getScan(); //create new scan
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setActiveScan(true); //active scan uses more power, but get results faster
  pBLEScan->setInterval(100);
  pBLEScan->setWindow(99);  // less or equal setInterval value

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
  // put your main code here, to run repeatedly:
  BLEScanResults foundDevices = pBLEScan->start(scanTime, false);
  Serial.print("Devices found: ");
  Serial.println(foundDevices.getCount());
  Serial.println("Scan done!");
  pBLEScan->clearResults();   // delete results fromBLEScan buffer to release memory
  delay(2000);
}
