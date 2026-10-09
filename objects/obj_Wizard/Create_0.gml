self.walk_speed = 2;
self.run_speed = 8;
//self.jump_height = 16;
//self.gravity_force = 1;
//self.old_y = undefined;

self.fsm = new StateMachine();

self.fsm.add("Idle", {
	"enter": function() {
		self.sprite_index = spr_IDLE;
	},
	"step": function() {},
	"leave": function() {},
	"gui": function() {
		draw_set_color(c_white);
		draw_text(self.x, self.y-self.sprite_height, $"ZZZ");
	}
});

self.fsm.add("Walk", {
	"enter": function() {
		self.sprite_index = spr_WALK;
	},
	"step": function() {
		var _sign_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
		self.x += _sign_x * self.walk_speed;
		var _sign_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
		self.y += _sign_y * self.walk_speed;
		
		if (_sign_x != 0 && _sign_x != self.image_xscale) self.image_xscale = _sign_x;
		
		self.x = clamp(self.x, 0, room_width);
		self.y = clamp(self.y, 0, room_height);
	},
	"leave": function() {},
	"gui": function() {
		draw_set_color(c_white);
		draw_text(self.x, self.y-self.sprite_height, $"I'm walking");
	}
});

self.fsm.add("Run", {
	"enter": function() {
		self.sprite_index = spr_RUN;
	},
	"step": function() {
		var _sign_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
		self.x += _sign_x * self.run_speed;
		var _sign_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));
		self.y += _sign_y * self.run_speed;
		
		if (_sign_x != 0 && _sign_x != self.image_xscale) self.image_xscale = _sign_x;
		
		self.x = clamp(self.x, 0, room_width);
		self.y = clamp(self.y, self.sprite_height/2, room_height);
	},
	"leave": function() {},
	"gui": function() {
		draw_set_color(c_white);
		draw_text(self.x, self.y-self.sprite_height, $"RUUUUN!!!!!");
	}
});


self.fsm.add_transition(["Idle", "Run"], "Walk", function() {
	return	!keyboard_check(vk_shift) &&
			(
				keyboard_check(ord("W")) || 
				keyboard_check(ord("A")) ||
				keyboard_check(ord("S")) ||
				keyboard_check(ord("D"))
			)			
});

self.fsm.add_transition(["Idle", "Walk"], "Run", function() {
	return	keyboard_check(vk_shift) &&
			(
				keyboard_check(ord("W")) || 
				keyboard_check(ord("A")) ||
				keyboard_check(ord("S")) ||
				keyboard_check(ord("D"))
			)			
});

self.fsm.add_transition(["Walk", "Run"], "Idle", function() {	
	return	!(
				keyboard_check(ord("W")) || 
				keyboard_check(ord("A")) ||
				keyboard_check(ord("S")) ||
				keyboard_check(ord("D"))
			)			
});

self.fsm.init("Idle");
