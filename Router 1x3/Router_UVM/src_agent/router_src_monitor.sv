// When running source side only test uncomment below line
// to delay end of test
//`define ADD_PHASE_DELAY

class router_src_monitor extends uvm_monitor;

	`uvm_component_utils(router_src_monitor)

	virtual router_src_intf.SRC_MON_MP vif;

	router_src_config m_cfg;

	uvm_analysis_port#(router_src_xtn) monitor_port;
	
	`ifdef ADD_PHASE_DELAY
		int busy = 1;
		int ending;
	`endif

	extern function new(string name="router_src_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
	//extern function void report_phase(uvm_phase phase);

	`ifdef ADD_PHASE_DELAY
		extern function void phase_ready_to_end(uvm_phase phase);
	`endif

endclass: router_src_monitor


// MONITOR CONSTRUCTOR
function router_src_monitor::new(string name="router_src_monitor", uvm_component parent);
	super.new(name, parent);

	monitor_port = new("monitor_port", this);
endfunction: new


// MONITOR BUILD PHASE
function void router_src_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(router_src_config)::get(this, "", "router_src_config", m_cfg))
		`uvm_fatal(get_type_name(), "UNABLE TO OBTAIN SOURCE CONFIG")
endfunction: build_phase


// MONITOR CONNECT PHASE
function void router_src_monitor::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	vif = m_cfg.vif;
endfunction: connect_phase


// MONITOR RUN PHASE
task router_src_monitor::run_phase(uvm_phase phase);
	forever begin
		collect_data();
		`ifdef ADD_PHASE_DELAY
			if(ending) begin
				busy = 0;
				phase.drop_objection(this);
			end
		`endif
	end
endtask: run_phase

// PHASE READY TO END
`ifdef ADD_PHASE_DELAY
	function void router_src_monitor::phase_ready_to_end(uvm_phase phase);
		if(phase.get_name == "run") begin
			ending = 1;
			if(busy)
				phase.raise_objection(this, "not ready to end the phase");
		end
	endfunction: phase_ready_to_end
`endif


// Task to collect data
task router_src_monitor::collect_data();
	
	router_src_xtn xtn;
	xtn = router_src_xtn::type_id::create("xtn");

	// SAMPLING THE HEADER
	wait(vif.src_mon_cb.busy == 1'b0 && vif.src_mon_cb.pkt_valid == 1'b1);
	@(vif.src_mon_cb);
	xtn.header = vif.src_mon_cb.data_in;

	// SAMPLING THE PAYLOAD
	xtn.payload = new[xtn.header[7:2]];
	@(vif.src_mon_cb);
	foreach(xtn.payload[i]) begin
		while(vif.src_mon_cb.busy == 1)
			@(vif.src_mon_cb);
		xtn.payload[i] = vif.src_mon_cb.data_in;
		@(vif.src_mon_cb);
	end

	// SAMPLING THE PARITY
	wait(vif.src_mon_cb.busy == 1'b0 && vif.src_mon_cb.pkt_valid == 1'b0);
	xtn.parity = vif.src_mon_cb.data_in;

	// SAMPLING THE ERROR
	repeat (3) @(vif.src_mon_cb);
	xtn.error = vif.src_mon_cb.error;

	m_cfg.mon_data_count++;
	`uvm_info(get_type_name(), $sformatf("\n\nTHE SOURCE MONITOR PACKET COUNT IS %0d\nTHE PACKET COLLECTED BY THE SOURCE MONITOR IS:", m_cfg.mon_data_count), UVM_LOW)
	xtn.print();

	// SENDING THE COLLECTED PACKET TO ANALYSIS_PORT
	monitor_port.write(xtn);

endtask: collect_data


// Monitor report phase
//function void router_src_monitor::report_phase(uvm_phase phase);
//	super.report_phase(phase);
//
//	// Displaying the transaction count
//	`uvm_info("REPORT", $sformatf("\n\nTHE SOURCE MONITOR PACKET COUNT IS %0d\n", m_cfg.mon_data_count), UVM_LOW)
//
//endfunction: report_phase
