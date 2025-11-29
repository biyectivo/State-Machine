/// @description 
draw_set_color(c_white);
draw_text(x, y, string("{0} {1}", self.fsm.get_current_state_name(), self.fsm.get_state_timer()));
