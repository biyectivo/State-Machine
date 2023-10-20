hp = 3;

fsm = new StateMachine();

fsm.add("Idle", {
	enter: function() {
		show_debug_message("Cambié a idle");
		self.image_index = 0;
	},
	step: function() {
		if (fsm.get_state_timer() % 10 == 0) {
			self.image_index = (self.image_index+1) % 2;
		}
	},
	leave: function() {
		show_debug_message("Bye idle");	
	}
});

fsm.add("Move", {
	enter: function() {
		show_debug_message("Cambié a move");
	},
	step: function() {
		self.x = self.x + 5;
		self.y = self.y + 5;
	},
	leave: function() {
		show_debug_message("Bye move");	
	}
});

fsm.add("Die", {
	enter: function() {
		show_debug_message("Morí");
		self.image_index = 2;
	},
	leave: function() {
		show_debug_message("Voy a revivir...");
	}
});

fsm.add_transition("Idle", "Move", function() {
	return keyboard_check(vk_space);
});
fsm.add_transition("Move", "Idle", function() {
	return !keyboard_check(vk_space);
});
fsm.add_transition([], "Die", function() {
	return keyboard_check_pressed(vk_enter);
}, 100);




fsm.init("Idle");
