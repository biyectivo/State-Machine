/// @description 
self.fsm.step();
self.fsm.transition();
if (keyboard_check_pressed(ord("1"))) self.fsm.trigger("Idle");
if (keyboard_check_pressed(ord("2"))) {
	
	show_debug_message(self.fsm.function_exists("test"));
	show_debug_message(self.fsm.function_exists("test2"));
	//self.fsm.__states[$ self.fsm.get_current_state_name()].functions.test()
	self.fsm.call("test");
	self.fsm.call("test", ["Tribalistas"]);
}