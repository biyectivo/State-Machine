hp = 3;

fsm = new StateMachine();

var _state = new State("Idle");
with (_state) {
	enter = function() {
		show_debug_message("Cambié a idle");
	}
	step = function() {
		if (get_timer() % 10^6 == 0) {
			other.image_index = (other.image_index+1) % 2;
		}
	}
	leave = function() {
		show_debug_message("Bye idle");	
	}
}
fsm.add(_state);

var _state = new State("Move");
with (_state) {
	enter = function() {
		show_debug_message("Cambié a move");
	}
	step = function() {
		other.x = other.x + 5;
		other.y = other.y + 5;
	}
	leave = function() {
		show_debug_message("Bye move");	
	}
}
fsm.add(_state);
	
var _state = new State("Die");
with (_state) {
	enter = function() {
		show_debug_message("Morí");
	}
	step = function() {
		other.image_index = 2;
	}		
}
fsm.add(_state);
	
fsm.add_transition(new Transition("Idle", "Move", function() {
	return keyboard_check(vk_space);
}));
fsm.add_transition(new Transition("Move", "Idle", function() {
	return !keyboard_check(vk_space);
}));
fsm.add_transition(new Transition(["Idle","Move"], "Die", function() {
	return keyboard_check_pressed(vk_enter);
}, 100));



fsm.init("Idle");
