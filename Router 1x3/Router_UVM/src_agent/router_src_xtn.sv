// Base source sequence item with constraints regarding the protocol

class router_src_xtn extends uvm_sequence_item;

	`uvm_object_utils_begin(router_src_xtn)
	// NOTE: Not regestering fields with the factory as it is causing the print() method to print the propertied twice. If required in the future for clone, compare etc. uncomment below lines
//		`uvm_field_int(header, UVM_ALL_ON)
//		`uvm_field_int(parity, UVM_ALL_ON)
//		`uvm_field_int(error, UVM_ALL_ON)
//		`uvm_field_int(busy, UVM_ALL_ON)
//		`uvm_field_array_int(payload, UVM_ALL_ON)
	`uvm_object_utils_end

	randc bit [7:0] header;
	randc bit [7:0] payload[];
	bit [7:0] parity;
	bit error;
	bit busy;

	//constraint valid_addr 			{header[1:0] != 2'b11;};
	constraint valid_payload_len 	{header[7:2] != 6'b0;};
	constraint valid_payload_size 	{payload.size() == header[7:2];};

	// Sequence item constructor
	function new(string name="router_src_xtn");
		super.new(name);
	endfunction: new

	// Overriding do_print to format the way xtn is printed
	virtual function void do_print(uvm_printer printer);
		
		printer.print_field("Header[BIN]", 	this.header, 	8, UVM_BIN);
		printer.print_field("Header[DEC]", 	this.header, 	8, UVM_DEC);
		foreach(payload[i])
			printer.print_field($sformatf("Payload[%0d]", i), this.payload[i], 8, UVM_DEC);
		printer.print_field("Parity", 	this.parity, 	8, UVM_DEC);
		printer.print_field("Busy", 	this.busy, 		1, UVM_DEC);
		printer.print_field("Error", 	this.error, 	1, UVM_DEC);

	endfunction: do_print

	// After each randomize the parity byte is calculated
	function void post_randomize();
		parity = header;
		foreach(payload[i])
			parity = parity ^ payload[i];
	endfunction: post_randomize

endclass:router_src_xtn 

