class router_dst_agent_top extends uvm_env;

	`uvm_component_utils(router_dst_agent_top)

	router_dst_agent agnth[];

	router_env_config m_cfg;

	extern function new(string name="router_dst_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);

endclass: router_dst_agent_top

function router_dst_agent_top::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction: new

function void router_dst_agent_top::build_phase(uvm_phase phase);
	
	super.build_phase(phase);

	if(!uvm_config_db#(router_env_config)::get(this, "", "router_env_config", m_cfg))
		`uvm_fatal(get_type_name(), "FAILED TO GET FROM THE CONFIGURATION")

	agnth = new[m_cfg.no_of_dst];

	// BUILDING THE DESTINATION AGENTS
	foreach(agnth[i]) begin
		agnth[i] = router_dst_agent::type_id::create($sformatf("agnth%0d", i), this);
		uvm_config_db#(router_dst_config)::set(this, $sformatf("agnth%0d*", i), "router_dst_config", m_cfg.dst_cfg[i]);
	end

endfunction: build_phase
