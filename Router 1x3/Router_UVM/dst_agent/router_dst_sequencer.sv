class router_dst_sequencer extends uvm_sequencer#(router_dst_xtn);

	`uvm_component_utils(router_dst_sequencer)

	function new(string name="router_dst_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(), "Inside build_phase", UVM_LOW)
	endfunction: build_phase

endclass: router_dst_sequencer
