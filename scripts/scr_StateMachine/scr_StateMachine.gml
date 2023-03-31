#region FSM
	
	function State(_state_name) constructor {
		static num = 0;
		num += 1;
		
		self.target_id = noone;
		self.state_id = num;
		self.state_name = _state_name;
		self.enter = function() {};
		self.step = function() {};
		self.leave = function() {};
		return self;
	}
		
	function Transition(_current_state_name, _new_state_name, _condition, _priority = 0) constructor {
		self.target_id = noone;
		self.current_state_name = _current_state_name;
		self.new_state_name = _new_state_name;
		self.condition = _condition;
		self.priority = _priority;
	}
		
	function StateMachine(_name="") constructor {
		self.target_id = other.id;
		self.state_machine_name = _name;
		self.states = ds_map_create();
		self.transitions = [];
		self.current_state_name = "";
		self.state_name_history = [];
		self.max_state_name_history = 4; // Default
		
		self.set_max_state_name_history = function(_num_states) {
			self.max_state_name_history = max(2, _num_states);
		}
		
		self.previous_state_name  = function() {
			var _n = array_length(self.state_name_history);
			return _n > 0 ? self.state_name_history[_n-1] : "";
		}
		
		self.init = function(_state_name) {
			array_push(self.state_name_history, self.current_state_name);
			self.current_state_name = _state_name;
			if (ds_exists(self.states, ds_type_map) && ds_map_exists(self.states, self.current_state_name))			self.states[? self.current_state_name].enter(); // Execute enter state for initial state		
		}
		
		self.add = function(_state) {
			ds_map_add(self.states, _state.state_name, _state);
			self.states[? _state.state_name].target_id = self.target_id;
			return _state;
		}
		
		self.add_transition = function(_transition) {
			_transition.target_id = self.target_id;
			array_push(self.transitions, _transition);
			return _transition;
		}
		
		self.step = function() {
			if (ds_exists(self.states, ds_type_map) && ds_map_exists(self.states, self.current_state_name))		self.states[? self.current_state_name].step();
		}
		
		self.trigger = function(_state_name) {			
			// Leave state				
			if (ds_exists(self.states, ds_type_map) && ds_map_exists(self.states, self.current_state_name))		self.states[? self.current_state_name].leave();
			// Push current
			array_push(self.state_name_history, self.current_state_name);
			// Set and enter new state
			self.current_state_name = _state_name;			
			if (ds_exists(self.states, ds_type_map) && ds_map_exists(self.states, self.current_state_name))		self.states[? self.current_state_name].enter();
			
				
			// Trim state history
			if (array_length(self.state_name_history) > self.max_state_name_history)							array_resize_from_end(self.state_name_history, self.max_state_name_history);
		}
		
		self.transition = function() {
			// Search for applicable transitions
			var _applicable_transitions = [];
			var _n = array_length(self.transitions);		
			for (var _i=0; _i<_n; _i++) {	
				var _trx = self.transitions[_i];
				if (array_find_any(_trx.current_state_name, self.current_state_name) != -1 && _trx.condition())		array_push(_applicable_transitions, _trx);
			}
			
			if (array_length(_applicable_transitions) > 0) {				
				// Sort by priority and then by newest state
				array_sort(_applicable_transitions, function(_e1, _e2) {
					if (_e1.priority == _e2.priority) {
						return self.states[? _e2.new_state_name].state_id - self.states[? _e1.new_state_name].state_id;
					}
					else {
						return _e1.priority - _e2.priority;
					}
				});
				
				// Trigger the transition
				var _transition = _applicable_transitions[0];
				self.trigger(_transition.new_state_name);
			}
				
		}
		self.cleanup = function() {
			if (ds_exists(self.states, ds_type_map))	ds_map_destroy(self.states);
		}
		
		return self;
	}

	
	

#endregion
