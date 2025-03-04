class router_dst_monitor extends uvm_monitor;

	`uvm_component_utils(router_dst_monitor)

	virtual router_dst_intf.DST_MON_MP vif;

	router_dst_config m_cfg;

	uvm_analysis_port#(router_dst_xtn) monitor_port;

	router_dst_xtn mon_data;

	extern function new(string name="router_dst_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();

endclass: router_dst_monitor

// CLASS CONSTRUCTOR
function router_dst_monitor::new(string name="router_dst_monitor", uvm_component parent);
	super.new(name, parent);

	monitor_port = new("monitor_port", this);
endfunction: new

// BUILD PHASE METHOD
function void router_dst_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(router_dst_config)::get(this, "", "router_dst_config", m_cfg))
		`uvm_fatal(get_full_name(), "FAILED TO GET THE CONFIG")
endfunction: build_phase

// CONNECT PHASE METHOD
function void router_dst_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	
	this.vif = m_cfg.vif;
endfunction: connect_phase

// RUN PHASE METHOD
task router_dst_monitor::run_phase(uvm_phase phase);
	forever begin
		collect_data();
		`ifdef ADD_PHASE_END
			phase.drop_objection(this); // Required if delaying test ending in source monitor
		`endif
	end
endtask: run_phase

// METHOD TO SAMPLE THE DUT OUTPUT
task router_dst_monitor::collect_data();

	mon_data = router_dst_xtn::type_id::create("mon_data");

	// Waiting till read_enb is asserted
	wait(vif.dst_mon_cb.read_enb == 1'b1);
	
	// Sampling the header
	@(vif.dst_mon_cb);
	@(vif.dst_mon_cb);
	mon_data.header = vif.dst_mon_cb.data_out;

	// Initializing payload size and sampling each payload
	mon_data.payload = new[mon_data.header[7:2]];
	@(vif.dst_mon_cb);
	foreach(mon_data.payload[i]) begin
		mon_data.payload[i] = vif.dst_mon_cb.data_out;
		@(vif.dst_mon_cb);
	end

	//Sampling the Parity
	mon_data.parity = vif.dst_mon_cb.data_out;

	// Incrementing the data received count
	m_cfg.mon_data_count++;

	// Sending the packet to the analysis_port
	monitor_port.write(mon_data);

	// Printing the packet
	`uvm_info(get_full_name(), $sformatf("\n\nTHE DESTINATION MONITOR PACKET COUNT IS %0d\nTHE PACKET COLLECTED BY THE DESTINATION MONITOR IS:", m_cfg.mon_data_count), UVM_LOW)
	mon_data.print();

endtask: collect_data

