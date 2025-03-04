class router_src_agent extends uvm_agent;

	`uvm_component_utils(router_src_agent)

	router_src_monitor 		monh;
	router_src_sequencer 	seqrh;
	router_src_driver 		drvh;

	router_src_config 		m_cfg;

	extern function new (string name="router_src_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);

endclass: router_src_agent

function router_src_agent::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction: new

function void router_src_agent::build_phase(uvm_phase phase);

	super.build_phase(phase);

	// Getting the agent configuration
	uvm_config_db#(router_src_config)::get(this, "", "router_src_config", m_cfg);

	monh = router_src_monitor::type_id::create("monh", this);

	if(m_cfg.is_active == UVM_ACTIVE) begin
		drvh 	= router_src_driver::type_id::create("drvh", this);
		seqrh 	= router_src_sequencer::type_id::create("seqrh", this);
	end

endfunction: build_phase

function void router_src_agent::connect_phase(uvm_phase phase);

	if(m_cfg.is_active == UVM_ACTIVE)
		drvh.seq_item_port.connect(seqrh.seq_item_export);

endfunction: connect_phase
