self.hp = 3;

self.fsm = new StateMachine();

self.fsm.add("Idle", {
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
	},
	test: function(_param_array = undefined) {
		show_debug_message(_param_array == undefined ? "LA" : _param_array[0]);
	}
});

self.fsm.add("Move", {
	enter: function() {
		show_debug_message("Cambié a move");
	},
	step: function() {
		self.x = self.x + 5;
		self.y = self.y + 5;
	},
	leave: function() {
		show_debug_message("Bye move");	
	},
	test: function() {
		show_debug_message("LA");
	}
});

self.fsm.add("Die", {
	enter: function() {
		show_debug_message("Morí");
		self.image_index = 2;
	},
	leave: function() {
		show_debug_message("Voy a revivir...");
	},
	test: function() {
		show_debug_message("LA");
	}
});

self.fsm.add_transition("Idle", "Move", function() {
	return keyboard_check(vk_space);
});
self.fsm.add_transition("Move", "Idle", function() {
	return !keyboard_check(vk_space);
});
self.fsm.add_transition([], "Die", function() {
	return keyboard_check_pressed(vk_enter);
}, 100);




self.fsm.init("Idle");
