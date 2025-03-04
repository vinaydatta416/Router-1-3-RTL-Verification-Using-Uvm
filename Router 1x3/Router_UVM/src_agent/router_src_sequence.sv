// Router base sequence

class router_src_seq extends uvm_sequence #(router_src_xtn);

	`uvm_object_utils(router_src_seq)

	bit [1:0] dst_addr;

	extern function new(string name="router_src_seq");
	extern task body();

endclass: router_src_seq

// BASE CONSTRUCTOR
function router_src_seq::new(string name="router_src_seq");
	super.new(name);
endfunction: new

// BASE BODY TASK
task router_src_seq::body();
	if(!uvm_config_db#(bit[1:0])::get(null, "uvm_test_top.envh.src_agnt_toph.v_seqrh.src_seqrh*", "dst_addr", dst_addr))
		`uvm_fatal(get_type_name(), "failed to get dst_addr from test")
endtask: body


// Small packet sequence
class small_packet_src_seq extends router_src_seq;

	`uvm_object_utils(small_packet_src_seq)

	function new(string name="small_packet_src_seq");
		super.new(name);
	endfunction: new

	task body();

		req = router_src_xtn::type_id::create("req");
		super.body();

		start_item(req);
		assert(req.randomize() with {header[1:0] == dst_addr; header[7:2] inside {[1:14]};});
		finish_item(req);

	endtask: body

endclass: small_packet_src_seq


// Medium packet sequence
class medium_packet_src_seq extends router_src_seq;

	`uvm_object_utils(medium_packet_src_seq)

	function new(string name="medium_packet_src_seq");
		super.new(name);
	endfunction: new

	task body();

		req = router_src_xtn::type_id::create("req");
		super.body();

		start_item(req);
		assert(req.randomize() with {header[1:0] == dst_addr; header[7:2] inside {[15:30]};});
		finish_item(req);

	endtask: body

endclass: medium_packet_src_seq


// Big packet sequence
class big_packet_src_seq extends router_src_seq;

	`uvm_object_utils(big_packet_src_seq)

	function new(string name="big_packet_src_seq");
		super.new(name);
	endfunction: new

	task body();

		super.body();

		req = router_src_xtn::type_id::create("req");

		start_item(req);
		assert(req.randomize() with {header[7:2] inside {[31:63]}; header[1:0] == dst_addr;});
		finish_item(req);

	endtask: body

endclass: big_packet_src_seq


// Bad packet sequence
class bad_packet_src_seq extends router_src_seq;

	`uvm_object_utils(bad_packet_src_seq)

	function new(string name="bad_packet_src_seq");
		super.new(name);
	endfunction: new

	task body();

		super.body();

		req = router_src_xtn::type_id::create("req");

		start_item(req);
		assert(req.randomize() with {header[1:0] == dst_addr;});
		req.parity++;
		finish_item(req);

	endtask: body

endclass: bad_packet_src_seq

