/// @description 
draw_set_color(c_white);
draw_text(x, y, string("{0} {1}", fsm.get_current_state_name(), fsm.get_state_timer()));
