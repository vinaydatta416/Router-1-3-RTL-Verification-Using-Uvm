class router_dst_driver extends uvm_driver#(router_dst_xtn);

	`uvm_component_utils(router_dst_driver)

	virtual router_dst_intf.DST_DRV_MP vif;

	router_dst_config m_cfg;

	extern function new(string name="router_dst_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(router_dst_xtn xtn);

endclass: router_dst_driver

// CLASS CONSTRUCTOR
function router_dst_driver::new(string name="router_dst_driver", uvm_component parent);
	super.new(name, parent);
endfunction: new

// BUILD PHASE METHOD
function void router_dst_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(router_dst_config)::get(this, "", "router_dst_config", m_cfg))
		`uvm_fatal(get_full_name(), "FAILED TO GET THE CONFIG")
endfunction: build_phase

// CONNECT PHASE METHOD
function void router_dst_driver::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	this.vif = m_cfg.vif;
endfunction: connect_phase

// RUN PHASE METHOD
task router_dst_driver::run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(req);
		send_to_dut(req);
		seq_item_port.item_done();
	end
endtask: run_phase

// TASK TO SEND THE PACKET TO DUT
task router_dst_driver::send_to_dut(router_dst_xtn xtn);
	
	// Waiting for the valid_out to HIGH
	wait(vif.dst_drv_cb.valid_out == 1'b1);
	`uvm_info(get_full_name(), "\n\nDUT asserted valid_out\n", UVM_LOW)

	// Adding the delay before asserting the read_en
	`uvm_info(get_full_name(), $sformatf("\n\nRead delay generated = %0d\n", xtn.delay), UVM_LOW)
	repeat (xtn.delay) 
		@(vif.dst_drv_cb);

	// Asserting read_enb
	vif.dst_drv_cb.read_enb <= 1'b1;
	`uvm_info(get_full_name(), "\n\nAsserted read_enb\n", UVM_LOW)
	
	// Waiting for the valid_out to LOW
	wait(vif.dst_drv_cb.valid_out == 1'b0);
	`uvm_info(get_full_name(), "\n\nDUT de-asserted valid_out\n", UVM_LOW)

	// De-asserting read_enb one clock edge after valid_out goes LOW
	@(vif.dst_drv_cb);
	vif.dst_drv_cb.read_enb	<= 1'b0;
	`uvm_info(get_full_name(), "\n\nDe-asserted read_enb\n", UVM_LOW)
	
endtask: send_to_dut
