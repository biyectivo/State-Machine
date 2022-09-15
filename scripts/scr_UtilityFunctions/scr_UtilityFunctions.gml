///@function			array_find(_array, _item)
///@description			searches an array for an item
///@param				{array}	_array	The array
///@param				{any}	_item	The item to search for
///@return				the position of _item within _array or -1 if not found
function array_find(_array, _item) {
	var _n = array_length(_array);
	var _i = 0;
	var _found = false;
	while (_i<_n && !_found) {
		if (_array[_i] == _item)	 _found = true;
		else	 _i++;
	}
	return _found ? _i : -1;
}

///@function			array_find_any(_things, _array)
///@description			looks for any of the things into the array
///@param	{array}		_array		target array to search things in 
///@param	{any}		_things		object/array of objects to search for
///@return	{real}		the index of the first occurrence of any of the things looked for in the target array or -1 if not found
function array_find_any(_array, _things) {
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

///@function			array_resize_from_end(_array, _new_size)
///@description			resizes the array starting from the end working left
///@param	{array}		_array		target array
///@param	{real}		_new_size	the new size of the array
function array_resize_from_end(_array, _new_size) {
	var _n = array_length(_array);
	if (_new_size < _n) {		
		for (var _i=0; _i<_new_size; _i++) {
			// removed the array accessor @ since it's no longer on by default in GM
			_array[_i] = _array[_i+_n-_new_size];
		}
		array_resize(_array, _new_size);
	}
}

///@function			backup_draw_settings
///@description			Backs up CPU draw_ settings in variables from the calling instance's
function backup_draw_settings() {
	self.__backup_color = draw_get_color();
	self.__backup_alpha = draw_get_alpha();
	self.__backup_halign = draw_get_halign();
	self.__backup_valign = draw_get_valign();
	self.__backup_font = draw_get_font();
}

///@function			restore_draw_settings
///@description			Restores CPU draw_ settings from variables stored with backup_draw_settings from the calling instance's
function restore_draw_settings() {
	try {
		 draw_set_color(self.__backup_color);
		 draw_set_alpha(self.__backup_alpha);
		 draw_set_halign(self.__backup_halign);
		 draw_set_valign(self.__backup_valign);
		 draw_set_font(self.__backup_font);
	}
}

///@function			string_split(_string, _delimiter)
///@description			splits a string with a given delimiter
///@param				{string}	_string		The string to split
///@param				{string}	_delimiter	The delimiter to use
///@return				{array}		An array of strings
function string_split(_string, _delimiter) {
	if (string_length(_string) == 0 || string_length(_delimiter) == 0 || string_pos(_delimiter, _string) == 0)	return _string;
	else {
		var _split = [];
		var _str = _string;
		var _n = string_length(_str);
		var _pos = string_pos(_delimiter, _str);
		while (_pos > 0) {
			array_push(_split, string_copy(_str, 1, _pos-1));
			_str = string_copy(_str, _pos+1, _n);
			var _n = string_length(_str);
			var _pos = string_pos(_delimiter, _str);
		}
		array_push(_split, _str);
		return _split;
	}
}

///@function		random_sample(_array, _sample_size _with_replacement)
///@description		samples n items from an array
///@param			{array}		_array				the array to sample from
///@param			{real}		_sample_size		sample size
///@param			{bool}		_with_replacement	whether to sample with replacement or not - default: false
///@return			{any}		the selected sample
function random_sample(_array, _sample_size, _with_replacement=false) {
	var _sample = [];
	if (_with_replacement) {
		var _arr = [];
		array_copy(_arr, 0, _array, 0, array_length(_array));
		var _n = array_length(_arr);
		repeat (_sample_size) {
			var _idx = irandom_range(0, _n-1);
			array_push(_sample, _arr[_idx]);
			array_delete(_arr, _idx, 1);
			_n = array_length(_arr);
		}
	}
	else {
		var _n = array_length(_array);
		repeat (_sample_size)	array_push(_sample, _array[irandom_range(0, _n-1)]);
	}
	return _sample;
}

///@function		array_create_numeric(_value_start, _value_end, _increment_or_size)
///@description		creates a numeric array with start, end and increment conditions
///@param			{real}	_value_start		starting value
///@param			{real}	_value_end			ending value
///@param			{real}	_increment_or_size	increment value - if start=end, represents size instead
///@return			the array
function array_create_numeric(_value_start, _value_end, _increment_or_size=1) {
	var _arr = [];
	if (_value_start == _value_end)		repeat(_increment_or_size)				array_push(_arr, _value_start);
	else for (var _i=_value_start; _i<=_value_end; _i += _increment_or_size)	array_push(_arr, _i);
	return _arr;
}

///@function	approach(start, end, shift)
///@description	gradually increments or decrements a value towards a target by a shift increment
///@param	{real}	_start	starting value
///@param	{real}	_end	ending value
///@param	{real}	_shift	absolute increment size
///@return	{real}	the value
function approach(_start, _end, _shift) {
	if (_start < _end)	return min(_start + _shift, _end); 
	else				return max(_start - _shift, _end);
}