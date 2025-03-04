class router_dst_sequence extends uvm_sequence#(router_dst_xtn);

	`uvm_object_utils(router_dst_sequence)

	extern function new(string name="router_dst_sequence");

endclass: router_dst_sequence

// CLASS CONSTRUCTOR
function router_dst_sequence::new(string name);
	super.new(name);
endfunction: new



// NO DELAY SEQUENCE
class no_delay_dst_seq extends router_dst_sequence;

	`uvm_object_utils(no_delay_dst_seq)

	extern function new(string name="no_delay_dst_seq");
	extern task body();

endclass: no_delay_dst_seq

// CLASS CONSTRUCTOR
function no_delay_dst_seq::new(string name);
	super.new(name);
endfunction: new

// BODY METHOD
task no_delay_dst_seq::body();
	
	req = router_dst_xtn::type_id::create("req");

	start_item(req);
	assert(req.randomize() with {req.delay < 29;});
	finish_item(req);

endtask: body



// DELAY SEQUENCE
class with_delay_dst_seq extends router_dst_sequence;

	`uvm_object_utils(with_delay_dst_seq)

	extern function new(string name="with_delay_dst_seq");
	extern task body();

endclass: with_delay_dst_seq

// CLASS CONSTRUCTOR
function with_delay_dst_seq::new(string name);
	super.new(name);
endfunction: new

// BODY METHOD
task with_delay_dst_seq::body();

	req = router_dst_xtn::type_id::create("req");

	start_item(req);
	assert(req.randomize() with {req.delay > 29;});
	finish_item(req);

endtask: body
