/// @description 
fsm.step();
fsm.transition();
if (keyboard_check_pressed(ord("1"))) fsm.trigger("Idle");