class router_src_config extends uvm_object;

	int drv_data_count = 0;
	int mon_data_count = 0;

	virtual router_src_intf vif;

	uvm_active_passive_enum is_active = UVM_ACTIVE;

	`uvm_object_utils(router_src_config)

	function new(string name = "router_src_config");
		super.new(name);
	endfunction: new

endclass: router_src_config 
