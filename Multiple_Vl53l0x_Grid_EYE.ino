/* 
This is the program that read multiple Vl53l0x sensor and Grid-EYE sensor data 
Author: Zhangjie Chen, Stony Brook University
Date: Nov.15 2017 
*/

#include <Wire.h>
#include <VL53L0X.h>

#define XSHUT_pin4 24
#define XSHUT_pin3 26
#define XSHUT_pin2 28
#define XSHUT_pin1 22

//ADDRESS_DEFAULT 0b0101001 or 41
#define Sensor1_newAddress 52
#define Sensor2_newAddress 50
#define Sensor3_newAddress 51
#define Sensor4_newAddress 53

static uint16_t  Main_Delay = 73;
        uint8_t  aucThsBuf[2];              /* thermistor temperature        */
          short  g_ashRawTemp[64];          /* temperature of 64 pixels      */
        uint8_t  address;
       uint16_t  D1,D2,D3,D4;
        VL53L0X Sensor1;
        VL53L0X Sensor2;
        VL53L0X Sensor3;
        VL53L0X Sensor4;
       unsigned long T;
//-----------------------------------------------------------------------------------------
void bAMG_PUB_I2C_Read (uint8_t ucRegAddr, uint8_t ucSize, uint8_t* ucDstAddr)
{ 
    address = 0b1101000;
    uint8_t ucSize_t =0;
    Wire.beginTransmission(address);
    Wire.write(&ucRegAddr,1);
    Wire.endTransmission ();
    Wire.requestFrom(address, ucSize);
    for(int i=0;i<ucSize;i++)
    {
        if (Wire.available ()) 
        {
      *ucDstAddr++ = (uint8_t) (Wire.read());
        }
        else
        {
            return false;    
        }
    }
    
    return true;
}
//-------------------------------------------------------------------------------------------
void GE_SourceDataInitialize( void )
{
  for ( int i = 0; i < 64; i++ )
  {
    g_ashRawTemp[i] = 0xAAAA;
  }
}
//--------------------------------------------------------------------------------------------

void setup()
{ 
  GE_SourceDataInitialize( );
  pinMode(XSHUT_pin1, OUTPUT);
  pinMode(XSHUT_pin2, OUTPUT);
  pinMode(XSHUT_pin3, OUTPUT);
  pinMode(XSHUT_pin4, OUTPUT);
  digitalWrite(XSHUT_pin1, LOW);
  digitalWrite(XSHUT_pin2, LOW);
  digitalWrite(XSHUT_pin3, LOW);
  digitalWrite(XSHUT_pin4, LOW);
  delay(10);
  
  Serial.begin(115200);
  
  Wire.begin();
  //Change address of sensor and power up next one
  digitalWrite(XSHUT_pin4, HIGH);
  delay(10);
  Sensor4.setAddress(Sensor4_newAddress);
  delay(10);
  digitalWrite(XSHUT_pin3, HIGH);
  delay(10);
  Sensor3.setAddress(Sensor3_newAddress);
  delay(10);
  digitalWrite(XSHUT_pin2, HIGH);
  delay(10);
  Sensor2.setAddress(Sensor2_newAddress);
  delay(10);
  digitalWrite(XSHUT_pin1, HIGH);
  delay(10);
  Sensor1.setAddress(Sensor1_newAddress);
  delay(10);
  
  Sensor1.init();
  Sensor2.init();
  Sensor3.init();
  Sensor4.init();
  
  Sensor1.setTimeout(500);
  Sensor2.setTimeout(500);
  Sensor3.setTimeout(500);
  Sensor4.setTimeout(500);

  // Start continuous back-to-back mode (take readings as
  // fast as possible).  To use continuous timed mode
  // instead, provide a desired inter-measurement period in
  // ms (e.g. sensor.startContinuous(100)).
  Sensor1.startContinuous();
  Sensor2.startContinuous();
  Sensor3.startContinuous();
  Sensor4.startContinuous();
}

void loop()
{
  T = millis();
  Serial.println(T);
  
  bAMG_PUB_I2C_Read(0x0E, 2, aucThsBuf );
  
  for(int i=0;i<4;i++)
    {
        bAMG_PUB_I2C_Read(0x80+32*i, 32, (uint8_t *)g_ashRawTemp+i*32);
    }
  D1 = Sensor1.readRangeContinuousMillimeters();
  D2 = Sensor2.readRangeContinuousMillimeters();
  D3 = Sensor3.readRangeContinuousMillimeters();
  D4 = Sensor4.readRangeContinuousMillimeters();
  T = millis();
  Serial.println(T);
  Serial.print("***");
  Serial.write(aucThsBuf[0]);
  Serial.write(aucThsBuf[1]);
  for( int i = 0; i < 128; i++ )
      {
      Serial.write(*((uint8_t *)(g_ashRawTemp)+i));
      }
  
  Serial.write(lowByte(D1));
  Serial.write(highByte(D1));
  
  Serial.write(lowByte(D2));
  Serial.write(highByte(D2));
  
  Serial.write(lowByte(D3));
  Serial.write(highByte(D3));
 
  Serial.write(lowByte(D4));
  Serial.write(highByte(D4));
  Serial.print("\r\n");
  delay(Main_Delay);
}
