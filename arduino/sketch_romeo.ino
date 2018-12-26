//i2c
#include <Wire.h>
 
#define SLAVE_ADDRESS 0x04
int pwm;
int motor_command;

//Standard PWM DC control
int E1 = 5;     //M1 Speed Control
int E2 = 6;     //M2 Speed Control
int M1 = 4;    //M1 Direction Control
int M2 = 7;    //M1 Direction Control

int trigPin = 9;    //Trig - green Jumper
int echoPin = 8;    //Echo - yellow Jumper

// Encoder parameters
int ENC_LEFT = 0;
int ENC_RIGHT = 1;

long Coder[2] = {0,0};

uint16_t nb_interrupts_left;
uint16_t nb_interrupts_right;
uint16_t duration;
byte bytes[6];

void stopp(void)                    
{
  digitalWrite(E1,LOW);
  digitalWrite(E2,LOW);   
  Coder[ENC_LEFT] = 0;  
  Coder[ENC_RIGHT] = 0;
  nb_interrupts_left = 0;
  nb_interrupts_right = 0;
  //duration = 0;
  pwm = 0; 
  motor_command = 0;
}   

void setup() 
{
  Wire.begin(SLAVE_ADDRESS);
  Serial.begin(115200);
  
  attachInterrupt(ENC_LEFT, L_Wheel_Count, CHANGE);     
  attachInterrupt(ENC_RIGHT, R_Wheel_Count, CHANGE); 
  
  int i;
  for(i=4;i<=7;i++)
    pinMode(i, OUTPUT); 
   
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  
  Wire.onReceive(receiveData);
  Wire.onRequest(sendData);
} 


void loop(void) 
{ 
  Serial.print(motor_command);
  Serial.print("-");
  Serial.println (pwm);
  if (motor_command == 0) {
    stopp(); 
  }
  else if (motor_command == 1) {
    advance (pwm, pwm);
  }
  else if (motor_command == 2) {
    turn_R (pwm, pwm);
  }
  else if (motor_command == 3) {
    turn_L (pwm, pwm);
  }
  else if (motor_command == 4) {
    back_off(pwm, pwm);
  }

  digitalWrite(trigPin, LOW);
  delayMicroseconds(5);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  pinMode(echoPin, INPUT);
  duration = pulseIn(echoPin, HIGH);
  
  delay(10);
}


// callback for sending data
void sendData(){
  bytes[0] = (nb_interrupts_right >> 8) & 0xFF;
  bytes[1] = nb_interrupts_right & 0xFF;
  bytes[2] = (nb_interrupts_left >> 8) & 0xFF;
  bytes[3] = nb_interrupts_left & 0xFF;
  bytes[4] = (duration >> 8) & 0xFF;
  bytes[5] = duration & 0xFF;
  Wire.write(bytes, 6);
}

// callback for received data
void receiveData(int byteCount){  
 while (Wire.available()<2);
 pwm = Wire.read();
 motor_command = Wire.read();
}


void back_off(byte a,byte b)          //Move forward
{
  analogWrite (E1,a);      //PWM Speed Control
  digitalWrite(M1,HIGH);    
  analogWrite (E2,b);    
  digitalWrite(M2,HIGH);
}  
void advance (byte a,byte b)          //Move backward
{
  analogWrite (E1,a);
  digitalWrite(M1,LOW);   
  analogWrite (E2,b);    
  digitalWrite(M2,LOW);
}
void turn_L (byte a,byte b)             //Turn Left
{
  analogWrite (E1,a);
  digitalWrite(M1,LOW);    
  analogWrite (E2,b);    
  digitalWrite(M2,HIGH);
}
void turn_R (byte a,byte b)             //Turn Right
{
  analogWrite (E1,a);
  digitalWrite(M1,HIGH);    
  analogWrite (E2,b);    
  digitalWrite(M2,LOW);
}


void L_Wheel_Count()
{
  Coder[ENC_LEFT] ++;  //count the left wheel encoder interrupts
  nb_interrupts_left = Coder[ENC_LEFT];  
}


void R_Wheel_Count()
{
  Coder[ENC_RIGHT] ++; //count the right wheel encoder interrupts
  nb_interrupts_right = Coder[ENC_RIGHT];
}




