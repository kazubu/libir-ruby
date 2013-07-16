#include <ruby.h>
#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include <sys/types.h>
#include "unistd.h"

#define LOW_STATE 0
#define HIGH_STATE 1

const int IRledPin = 18; //BCM18, wPi1
const int IRrecvPin = 4; //BCM4, wPi7

void sendIr(int irData[], int length){
  int i;

  for(i=0;i<length;i++){
    if(i%2 == 0){ //奇数データ目でON
      int microsecs = irData[i];
      while (microsecs > 6) {
        // 38 kHz is about 13 microseconds high and 13 microseconds low
        digitalWrite(IRledPin, HIGH); // this takes about 2 microseconds to happen
        delayMicrosecondsHard(7); // hang out for 11 microseconds
        digitalWrite(IRledPin, LOW); // this also takes about 2 microseconds
        delayMicrosecondsHard(16); // hang out for 11 microseconds
        microsecs -= 26;
      }
    }else{ //偶数データ目なら待つ
      delayMicrosecondsHard(irData[i]);
    }
  }

  digitalWrite(IRledPin, LOW); //fail-safe
}

VALUE readIr() {
  VALUE ret = rb_ary_new();

  while(digitalRead(IRrecvPin) == HIGH_STATE); // HIGHなら待ち続ける

  unsigned int lastChanged = micros();
  unsigned int now = 0;

  //  信号が来ている間はLOW(0)
  int lastSignal = LOW_STATE; //LOWなはず

  while(1){
    if(lastSignal == HIGH_STATE){
      while(digitalRead(IRrecvPin) == HIGH_STATE){
        if(micros() - lastChanged > 1000000){ //1秒以上HIGHのままだったら終わり
          return ret;
        }
      }
    }else{
      while(digitalRead(IRrecvPin) == LOW_STATE);
    }
    //  現在時刻を保存
    now = micros();
    //  信号のオンオフが変化するまでにかかった時間(マイクロ秒)を記録
    rb_ary_push(ret, INT2FIX(now-lastChanged));
    //  次の変化までの時間を計測できるよう準備
    lastChanged = now;

    if(lastSignal == HIGH_STATE){
      lastSignal = LOW_STATE;
    } else {
      lastSignal = HIGH_STATE;
    }
  }
}

VALUE meth_initialize(){
  if (wiringPiSetupGpio() == -1){
    rb_raise(rb_eFatal, "Couldn't setup wiringPi");
  }

  pinMode(IRledPin, OUTPUT);
  pinMode (IRrecvPin, INPUT);

  delayMicrosecondsHard(25000);

  return Qnil;
}

VALUE meth_sendIr(VALUE self, volatile VALUE varr){
  int length = RARRAY_LEN(varr);
  int i;

  Check_Type(varr, T_ARRAY);

  int arr[length];

  for(i=0; i<length; i++){
    VALUE vval = rb_ary_entry(varr,i);
    int val = NUM2INT(vval);
    arr[i] = val;
  }

  sendIr(arr, length);

  return Qnil;
}

VALUE meth_recvIr(VALUE self){
  return readIr();
}

void Init_IR(void){
  VALUE rb_cIR;
  rb_cIR = rb_define_class("IR", rb_cObject);

  rb_define_private_method(rb_cIR, "initialize", meth_initialize, 0);
  rb_define_method(rb_cIR, "sendIr", meth_sendIr, 1);
  rb_define_method(rb_cIR, "recvIr", meth_recvIr, 0);
}
