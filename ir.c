#include <ruby.h>
VALUE rb_cIR;

VALUE meth_initialize(){
  //TODO: initialize

  return INT2FIX(0);
}

VALUE meth_sendIr(VALUE self, VALUE varr){
  VALUE ret;
  int length = RARRAY_LEN(varr);
  int i;

  Check_Type(varr, T_ARRAY);

  for(i=0; i<length; i++){//XXX: Dummy 
    VALUE vval = rb_ary_entry(varr,i);
    Check_Type(vval, T_FIXNUM);
    int val = FIX2INT(vval);
    printf("%d\n", val);
  }

  ret = INT2FIX(0);
  return ret;
}

VALUE meth_recvIr(VALUE self){
  //TODO: receive
  
  return INT2FIX(0);
}

void Init_IR(void){
  rb_cIR = rb_define_class("IR", rb_cObject);

  rb_define_private_method(rb_cIR, "initialize", meth_initialize, 0);
  rb_define_method(rb_cIR, "sendIr", meth_sendIr, 1);
  rb_define_method(rb_cIR, "recvIr", meth_recvIr, 0);
}
