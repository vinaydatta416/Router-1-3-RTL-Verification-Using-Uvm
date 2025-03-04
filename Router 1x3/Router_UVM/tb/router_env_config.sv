class router_env_config extends uvm_object;

	`uvm_object_utils(router_env_config)

	router_src_config src_cfg;
	router_dst_config dst_cfg[];

	bit has_src_agent;
	bit has_dst_agent;
	bit has_scoreboard;
	int no_of_dst;
	bit [1:0] dst_addr;

	function new(string name = "router_env_config");
		super.new(name);
	endfunction: new

endclass: router_env_config
