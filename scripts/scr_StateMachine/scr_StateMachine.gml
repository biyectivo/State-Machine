/// @feather ignore all

#macro STATE_MACHINE_VERSION "2026.10.1"

#region FSM

    show_debug_message($"You are using [State Machine] version {STATE_MACHINE_VERSION} by manta ray!");

    /// @function							StateMachine(_name)
    /// @description						Creates a finite state machine (FSM) associated with the instance constructing it. Manages named states, callbacks, transitions, timers, and state history.
    /// @param {String} _name				Optional name identifying the state machine. Defaults to an empty string.
    function StateMachine(_name="") constructor {

        self.__target_id = other.id;
        self.__state_id = 0;
        self.__state_machine_name = _name;
        self.__states = {};
        self.__transitions = [];
        self.__current_state_name = "";
        self.__state_name_history = [];
        self.__max_state_name_history = 4; // Default

        /// @function						get_state_timer()
        /// @description					Gets the number of frames elapsed in the current state
        /// @returns {Real}					The current state's timer value
        static get_state_timer = function() {
            return self.__states[$ self.__current_state_name].timer;
        }

        /// @function						set_max_state_name_history(_num_states)
        /// @description					Sets the maximum number of state names retained in the history array. The minimum allowed value is 2.
        /// @param {Real} _num_states		Maximum number of state names to retain. Defaults to a minimum of 2 if a smaller value is provided.
        static set_max_state_name_history = function(_num_states) {
            self.__max_state_name_history = max(2, _num_states);
        }

        /// @function						get_state_history()
        /// @description					Gets the internal array of recorded state names, ordered from oldest to newest. Returns the original array, not a copy.
        /// @returns {Array<String>}		The state name history array.
        static get_state_history = function() {
            return self.__state_name_history;
        }

        /// @function						get_current_state_name()
        /// @description					Gets the name of the currently active state. Returns an empty string if no state has been initialized or triggered.
        /// @returns {String}				The current state's name, or an empty string if none is active.
        static get_current_state_name = function() {
            return self.__current_state_name;
        }

        /// @function						get_previous_state_name()
        /// @description					Gets the most recently recorded state name from the history array. Returns an empty string if the history is empty.
        /// @returns {String}				The last recorded state name, or an empty string if no history exists.
        static get_previous_state_name = function() {
            var _n = array_length(self.__state_name_history);
            return _n > 0 ? self.__state_name_history[_n-1] : "";
        }

        /// @function						exists(_state_name)
        /// @description					Checks whether a state with the specified name has been registered in this state machine.
        /// @param {String} _				state_name Name of the state to check.
        /// @returns {Bool}					True if the state exists, otherwise false.
        static exists = function(_state_name) {
            return variable_struct_exists(self.__states, _state_name);
        }

        /// @function						init(_state_name)
        /// @description					Initializes the state machine with the specified state. Records its name in history, makes it the current state, and executes its enter callback. Throws an error if the state does not exist.
        /// @param {String} _state_name		Name of the registered state to initialize.
        static init = function(_state_name) {
            if (!self.exists(_state_name)) throw($"[State Machine] Cannot initialize state machine with state {_state_name} - state does not exist");

            array_push(self.__state_name_history, _state_name);
            self.__current_state_name = _state_name;
            self.__states[$ _state_name].functions.enter(); // Execute enter state for initial state

        }



        /// @function							add(_state_name, _state_functions)
        /// @description						Registers a new named state with its callbacks. Supports enter, step, leave, and additional custom functions. All callbacks are bound to the instance associated with the state machine. Missing standard callbacks are replaced with empty functions. Throws an error if the state already exists.
        /// @param {String}	_state_name			Unique name of the state to register.
        /// @param {Struct} [_state_functions]	Optional struct containing state callbacks. Supported standard keys are enter, step, and leave, each holding a function. Additional keys define custom state functions. Defaults to empty callbacks.
        static add = function(_state_name, _state_functions = { "enter": method(self.__target_id, function() {}), "step": method(self.__target_id, function() {}), "leave": method(self.__target_id, function() {})}) {
            if (self.exists(_state_name)) throw($"[State Machine] Cannot add state {_state_name} - state already exists");

            variable_struct_set(self.__states, _state_name, {});
            variable_struct_set(self.__states[$ _state_name], "functions", {});

            // Assign specified state functions
            var _state_function_names = variable_struct_get_names(_state_functions);
            for (var _i=0, _n=array_length(_state_function_names); _i<_n; _i++) {
                variable_struct_set(self.__states[$ _state_name].functions, _state_function_names[_i], method(self.__target_id, _state_functions[$ _state_function_names[_i]]));
            }

            // Assign default state functions
            if (!variable_struct_exists(self.__states[$ _state_name].functions, "enter"))     variable_struct_set(self.__states[$ _state_name].functions, "enter", method(self.__target_id, function() {}));
            if (!variable_struct_exists(self.__states[$ _state_name].functions, "step"))      variable_struct_set(self.__states[$ _state_name].functions, "step", method(self.__target_id, function() {}));
            if (!variable_struct_exists(self.__states[$ _state_name].functions, "leave"))     variable_struct_set(self.__states[$ _state_name].functions, "leave", method(self.__target_id, function() {}));

            self.__states[$ _state_name].timer = 0;
            self.__states[$ _state_name].state_id = ++self.__state_id;

        }

        /// @function											add_transition(_from_states, _to_state, _condition, _priority, _exclude_to_state_in_from, _condition_param_struct)
        /// @description										Registers a conditional transition between states. The condition is bound to the associated instance and receives the parameter struct as its argument. Lower numeric priorities take precedence. When priorities match, transitions targeting more recently added states take precedence. All referenced states must already exist.
        /// @param {String or Array<String>} _from_states		Source state name or array of source state names. An empty array selects all currently registered states.
        /// @param {String} _to_state							Name of the destination state.
        /// @param {Function} _condition						Callback that receives _condition_param_struct and should return true when the transition is permitted.
        /// @param {Real} [_priority]							Optional numeric priority. Lower values take precedence. Defaults to 0.
        /// @param {Bool} [_exclude_to_state_in_from]			Optional flag indicating whether to exclude the destination state from the source states. Defaults to true.
        /// @param {Struct} [_condition_param_struct]			Optional struct passed to the condition callback when transitions are evaluated. Defaults to an empty struct.
        static add_transition = function(_from_states, _to_state, _condition, _priority = 0, _exclude_to_state_in_from = true, _condition_param_struct = {}) {
            if (!is_callable(_condition))             throw($"[State Machine] Cannot add transition - condition is not callable, {_condition}");
            if (!is_numeric(_priority))               throw($"[State Machine] Cannot add transition - priority is not numeric, {_priority}");
            if (!is_struct(_condition_param_struct))  throw($"[State Machine] Cannot add transition - param struct is not a struct, {_condition_param_struct}");

            var _arr = [];
            var _state_names = variable_struct_get_names(self.__states);
            if (is_array(_from_states) && array_length(_from_states) == 0) {
                _arr = _state_names;
            }
            else if (is_array(_from_states)) {
                _arr = _from_states;
            }
            else {
                _arr = [_from_states];
            }

            if (_exclude_to_state_in_from) {
                var _idx = array_find_index(_arr, method({to_state: _to_state}, function(_elem) {
                    return _elem == to_state;
                }));
                if (_idx >= 0) array_delete(_arr, _idx, 1);
            }

            if (!self.exists(_to_state)) throw($"[State Machine] Cannot add transition to state {_to_state} - state does not exist");

            for (var _i=0, _n=array_length(_arr); _i<_n; _i++) {
                if (!self.exists(_arr[_i])) throw($"[State Machine] Cannot add transition from state {_arr[_i]} - state does not exist");
            }

            array_push(self.__transitions, { from: _arr, to: _to_state, condition: method(self.__target_id, _condition), priority: _priority, condition_param_struct: _condition_param_struct });
        }

        /// @function		step()
        /// @description	Advances the current state's timer by one and executes its step callback. Should typically be called once per game step. Throws an error if the current state does not exist. Does not evaluate transitions automatically.
        static step = function() {
            if (!self.exists(self.__current_state_name)) throw($"[State Machine] Cannot perform step() function of state {self.__current_state_name} - state does not exist");

            self.__states[$ self.__current_state_name].timer++;
            self.__states[$ self.__current_state_name].functions[$ "step"]();
        }


        /// @function						trigger(_state_name)
        /// @description					Immediately switches to the specified state without evaluating transition conditions. If a valid current state exists, resets its timer and executes its leave callback. Then records the outgoing state name, activates the destination state, executes its enter callback, and trims state history to the configured limit.
        /// @param {String} _state_name		Name of the registered destination state. Throws an error if the state does not exist.
        static trigger = function(_state_name) {
            if (!self.exists(_state_name)) throw($"[State Machine] Cannot trigger state {_state_name} - state does not exist");

            // Leave current state
            if (self.exists(self.__current_state_name)) {
                self.__states[$ self.__current_state_name].timer = 0;
                self.__states[$ self.__current_state_name].functions[$ "leave"]();
            }
            // Push current
            array_push(self.__state_name_history, self.__current_state_name);
            // Set and enter new state
            self.__current_state_name = _state_name;
            self.__states[$ self.__current_state_name].functions[$ "enter"]();

            // Trim state history
            if (array_length(self.__state_name_history) > self.__max_state_name_history) array_resize_from_end(self.__state_name_history, self.__max_state_name_history);
        }

        /// @function			transition()
        /// @description		Evaluates registered transition conditions and finds transitions whose source list contains the current state. If applicable transitions exist, selects the lowest numeric priority, breaking ties in favor of the most recently registered destination state, and triggers it. Only one transition is triggered per call.
        static transition = function() {
            // Search for applicable transitions
            var _applicable_transitions = [];
            var _n = array_length(self.__transitions);
            for (var _i=0; _i<_n; _i++) {
                var _trx = self.__transitions[_i];
                if (array_find_index(self.__transitions[_i].from, method({state_name: self.__current_state_name}, function(_elem) {
                        return _elem == state_name;
                })) != -1 && _trx.condition(_trx.condition_param_struct)) {
                    array_push(_applicable_transitions, _trx);
                }
            }

            if (array_length(_applicable_transitions) > 0) {
                // Sort by priority and then by newest state
                array_sort(_applicable_transitions, function(_e1, _e2) {
                    if (_e1.priority == _e2.priority) {
                        return self.__states[$ _e2.to].state_id - self.__states[$ _e1.to].state_id;
                    }
                    else {
                        return _e1.priority - _e2.priority;
                    }
                });

                // Trigger the transition
                var _transition = _applicable_transitions[0];
                trigger(_transition.to);
            }

        }

        /// @function					state_machine_function_exists(_function)
        /// @description				Checks whether the current state has a callback or custom function registered under the specified name. Requires a valid current state.
        /// @param {String} _function	Name of the state function to check.
        /// @returns {Bool}				True if the function exists in the current state, otherwise false.
        static state_machine_function_exists = function(_function) {
            return variable_struct_exists(self.__states[$ self.__current_state_name].functions, _function);
        }

        /// @function call(_function, _param_array)
        /// @description Executes a named function belonging to the current state. Passes _param_array as one argument to the function, without unpacking array elements. Throws an error if the current state or specified function does not exist.
        /// @param {String} _function Name of the state function to execute, including custom functions or standard callbacks.
        /// @param {Any} _param_array Optional argument passed directly to the state function. Can contain an array or another value. Defaults to undefined.
        static call = function(_function, _param_array = undefined) {
            if (!self.exists(self.__current_state_name)) throw($"[State Machine] Cannot call the requested function of state {self.__current_state_name} - state does not exist");
            if (!variable_struct_exists(self.__states[$ self.__current_state_name].functions, _function)) throw($"[State Machine] Cannot call the requested function of state {self.__current_state_name} - function {_function} does not exist");

            self.__states[$ self.__current_state_name].functions[$ _function](_param_array);
        }

        /// @function						array_resize_from_end(_array, _new_size)
        /// @description					Shrinks an array while retaining its last _new_size elements in their original order. Removes elements from the beginning of the array. If the requested size is greater than or equal to the current length, the array is left unchanged.
        /// @param {Array} _array			Array to resize.
        /// @param {Real} _new_size			Non-negative integer specifying the maximum number of elements to retain.
        static array_resize_from_end = function(_array, _new_size) {
            var _n = array_length(_array);
            if (_new_size < _n) {
                for (var _i=0; _i<_new_size; _i++) {
                    // removed the array accessor @ since it's no longer on by default in GM
                    _array[_i] = _array[_i+_n-_new_size];
                }
                array_resize(_array, _new_size);
            }
        }

    }

#endregion
