class router_dst_agent extends uvm_agent;

	`uvm_component_utils(router_dst_agent)

	router_dst_monitor 		monh;
	router_dst_sequencer 	seqrh;
	router_dst_driver 		drvh;

	router_dst_config 		m_cfg;

	extern function new (string name="router_dst_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass: router_dst_agent

function router_dst_agent::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction: new

function void router_dst_agent::build_phase(uvm_phase phase);

	super.build_phase(phase);

	// Getting the agent configuration
	uvm_config_db#(router_dst_config)::get(this, "", "router_dst_config", m_cfg);

	monh = router_dst_monitor::type_id::create("monh", this);

	if(m_cfg.is_active == UVM_ACTIVE) begin
		drvh 	= router_dst_driver::type_id::create("drvh", this);
		seqrh 	= router_dst_sequencer::type_id::create("seqrh", this);
	end

endfunction: build_phase

function void router_dst_agent::connect_phase(uvm_phase phase);

	if(m_cfg.is_active == UVM_ACTIVE)
		drvh.seq_item_port.connect(seqrh.seq_item_export);

endfunction: connect_phase
