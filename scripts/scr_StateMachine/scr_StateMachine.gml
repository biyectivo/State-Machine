#macro print show_debug_message
	
#region FSM
		
	function State(_state_name) constructor {
		static num = 0;
		num = num + 1;
		state_id = num;
		state_name = _state_name;
		enter = function() {};
		step = function() {};
		leave = function() {};
		return self;
	}
		
	function Transition(_current_state_name, _new_state_name, _condition, _priority = 0) constructor {
		current_state_name = _current_state_name;
		new_state_name = _new_state_name;
		condition = _condition;
		priority = _priority;
	}
		
	function StateMachine(_name="") constructor {
		state_machine_name = _name;
		states = ds_map_create();
		transitions = [];
		current_state_name = "";
		state_name_history = [];
		max_state_name_history = 4; // Default
		
		set_max_state_name_history = function(_num_states) {
			max_state_name_history = max(2, _num_states);
		}
		
		previous_state_name  = function() {
			var _n = array_length(state_name_history);
			if (_n > 1) {
				return state_name_history[_n-2];
			}
			else {
				return "";
			}
		}
		
		init = function(_state_name) {
			current_state_name = _state_name;
			if (ds_exists(states, ds_type_map) && ds_map_exists(states, current_state_name)) states[? current_state_name].enter(); // Execute enter state for initial state
			array_push(state_name_history, current_state_name);
		}
		
		add = function(_state) {
			ds_map_add(states, _state.state_name, _state);
		}
		
		add_transition = function(_transition) {
			array_push(transitions, _transition);
		}
		
		step = function() {
			if (ds_exists(states, ds_type_map) && ds_map_exists(states, current_state_name)) {
				states[? current_state_name].step();
			}			
		}
		
		transition = function() {
			// Search for applicable transitions
			var _applicable_transitions = [];
			var _n = array_length(transitions);		
			for (var _i=0; _i<_n; _i++) {	
				var _trx = transitions[_i];
				//print("["+current_state_name+"] vs ["+_trx.current_state_name+"]: "+str(array_find(current_state_name, _trx.current_state_name)));
				if (array_find(current_state_name, _trx.current_state_name) != -1 && _trx.condition()) {
					array_push(_applicable_transitions, _trx);
				}
			}
			
			if (array_length(_applicable_transitions) > 0) {				
				// Sort by priority and then by newest state
				array_sort(_applicable_transitions, function(_e1, _e2) {
					if (_e1.priority == _e2.priority) {
						return states[? _e2.new_state_name].state_id - states[? _e1.new_state_name].state_id;
					}
					else {
						return _e1.priority - _e2.priority;
					}
				});
					
				var _transition = _applicable_transitions[0];
				print("Transition from "+current_state_name+" (id="+str(states[? current_state_name].state_id)+") to "+_transition.new_state_name+" (id="+str(states[? _transition.new_state_name].state_id)+"), trx priority="+str(_transition.priority));
				// Leave state				
				if (ds_exists(states, ds_type_map) && ds_map_exists(states, current_state_name)) states[? current_state_name].leave();
					
				// Enter new state
				current_state_name = _transition.new_state_name;
				if (ds_exists(states, ds_type_map) && ds_map_exists(states, current_state_name)) states[? current_state_name].enter();
				array_push(state_name_history, current_state_name);
				
				// Trim state history
				if (array_length(state_name_history) > max_state_name_history) {
					array_resize_from_end(state_name_history, max_state_name_history);
				}
			}
				
		}
		cleanup = function() {
			if (ds_exists(states, ds_type_map)) ds_map_destroy(states);
		}
	}
	
	
#endregion

#region Helper functions
	///@function			array_find
	///@description			looks for any of the things into the array
	///@param	{*}			_things		object/array of objects to search for
	///@param	{array}		_array		target array to search things in 
	///@return	{int}		the index of the first occurrence of anyy of the things looked for in the target array or -1 if not found
	function array_find(_things, _array) {
		
		
		if (!is_array(_things)) {
			var _lookup_array = [_things];
		}
		else {
			var _lookup_array = _things;
		}
		if (!is_array(_array)) {
			var _target_array = [_array];
		}
		else {
			var _target_array = _array;
		}
		
		var _n = array_length(_target_array);
		var _m = array_length(_lookup_array);
		var _j = 0;
		var _found = false;
		while (_j<_m && !_found) {
			var _i=0;			
			while (_i<_n && !_found) {
				if (_target_array[_i] == _lookup_array[_j]) {
					_found = true;
				}
				else {
					_i++;	
				}
			}
			if (!_found) {
				_j++;
			}
		}
		
		if (_found) {
			return _i;
		}
		else {
			return -1;
		}
	}
	
#endregion