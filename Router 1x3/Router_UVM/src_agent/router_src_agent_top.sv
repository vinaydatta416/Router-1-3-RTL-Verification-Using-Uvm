class router_src_agent_top extends uvm_env;

	`uvm_component_utils(router_src_agent_top)

	router_src_agent agnth;
	router_env_config m_cfg;

	extern function new(string name="router_src_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);

endclass: router_src_agent_top

function router_src_agent_top::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction: new

function void router_src_agent_top::build_phase(uvm_phase phase);
	
	super.build_phase(phase);
	
	if(!uvm_config_db#(router_env_config)::get(this, "", "router_env_config", m_cfg))
		`uvm_fatal(get_type_name(), "FAILED TO GET FROM THE CONFIGURATION")

	uvm_config_db#(router_src_config)::set(this, "agnth*", "router_src_config", m_cfg.src_cfg);

	// BUILDING THE SOURCE AGENT
	agnth = router_src_agent::type_id::create("agnth", this);

endfunction: build_phase
