self.fsm = new StateMachine();
self.hp = 3;

self.fsm.add("Idle", {
	"enter": function() {
		show_debug_message("entering idle {0}", self.hp);
	},
	"exit" : function() {
		show_debug_message("exiting idle");
	}
});
self.fsm.add("Test", {
	"step": function() {
		show_debug_message(self.hp);
	}
});
self.fsm.add_transition("Idle", "Test", function() {
	return keyboard_check(vk_space);
});
self.fsm.add_transition("Test", "Idle", function() {
	return keyboard_check_released(vk_space);
});
self.fsm.init("Idle");
