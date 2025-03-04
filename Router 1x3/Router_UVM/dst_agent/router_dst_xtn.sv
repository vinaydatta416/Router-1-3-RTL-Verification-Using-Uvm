class router_dst_xtn extends uvm_sequence_item;

	`uvm_object_utils(router_dst_xtn)

	bit [7:0] header;
	bit [7:0] payload[];
	bit [7:0] parity;
	randc bit [5:0] delay; // delay for sending the read_enb in the driver

	extern function new(string name="router_dst_xtn");
	extern function void do_print(uvm_printer printer);

endclass: router_dst_xtn


// CLASS CONSTRUCTOR
function router_dst_xtn::new(string name);
	super.new(name);
endfunction: new


// DO PRINT METHOD
function void router_dst_xtn::do_print(uvm_printer printer);

	printer.print_field("Header[BIN]", 	this.header, 	8, UVM_BIN);
	printer.print_field("Header[DEC]", 	this.header, 	8, UVM_DEC);
	foreach(payload[i])
		printer.print_field($sformatf("Payload[%0d]",i), this.payload[i], 8, UVM_DEC);
	printer.print_field("Parity", 		this.parity, 	8, UVM_DEC);

endfunction: do_print
