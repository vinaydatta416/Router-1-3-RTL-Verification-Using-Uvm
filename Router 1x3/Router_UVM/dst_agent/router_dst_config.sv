class router_dst_config extends uvm_object;

	`uvm_object_utils(router_dst_config)

	int drv_data_count = 0;
	int mon_data_count = 0;

	virtual router_dst_intf vif;
	
	uvm_active_passive_enum is_active = UVM_ACTIVE;

	function new(string name="router_dst_config");
		super.new(name);
	endfunction: new

endclass: router_dst_config 
