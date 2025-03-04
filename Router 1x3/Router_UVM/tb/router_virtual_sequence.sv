class router_virtual_sequence extends uvm_sequence#(uvm_sequence_item);

	`uvm_object_utils(router_virtual_sequence)

	// Handles for actual sequencers
	router_src_sequencer src_seqrh;
	router_dst_sequencer dst_seqrh[];

	// Handle for the virtual sequencer
	router_virtual_sequencer v_seqrh;

	// Handle for the environment configuration
	router_env_config m_cfg;

	// Standard UVM methods
	function new(string name="router_virtual_sequence");
		super.new(name);
	endfunction: new

	task body();

		if(!uvm_config_db#(router_env_config)::get(null, get_full_name(), "router_env_config", m_cfg))
			`uvm_fatal(get_type_name(), "Failed to get env_config")

		dst_seqrh = new[m_cfg.no_of_dst];

		// Casting m_sequencer on v_seqrh
		if(!$cast(v_seqrh, m_sequencer))
			`uvm_fatal(get_type_name(), "Failed to cast m_sequencer on v_seqrh")

		// Connecting sequencer handles
		src_seqrh = v_seqrh.src_seqrh;
		foreach(dst_seqrh[i])
			dst_seqrh[i] = v_seqrh.dst_seqrh[i];

	endtask: body

endclass: router_virtual_sequence


//-------- Virtual sequences -----------

// Small packet virtual sequence
class small_packet_vseq extends router_virtual_sequence;
	
	`uvm_object_utils(small_packet_vseq)

	// Sequence handles for small packet 
	small_packet_src_seq 	small_src_seq;
	no_delay_dst_seq		no_dst_seq;

	function new(string name="small_packet_vseq");
		super.new(name);
	endfunction: new

	task body();

		super.body();

		small_src_seq 	= small_packet_src_seq::type_id::create("small_src_seq");
		no_dst_seq		= no_delay_dst_seq::type_id::create("no_dst_seq");
		
		fork
			small_src_seq.start(src_seqrh);
			no_dst_seq.start(dst_seqrh[m_cfg.dst_addr]);
		join

	endtask: body

endclass: small_packet_vseq

// Medium packet virtual sequence
class medium_packet_vseq extends router_virtual_sequence;
	
	`uvm_object_utils(medium_packet_vseq)

	// Sequence handles for medium packet 
	medium_packet_src_seq 	medium_src_seq;
	no_delay_dst_seq		no_dst_seq;

	function new(string name="medium_packet_vseq");
		super.new(name);
	endfunction: new

	task body();

		super.body();

		medium_src_seq 	= medium_packet_src_seq::type_id::create("medium_src_seq");
		no_dst_seq		= no_delay_dst_seq::type_id::create("no_dst_seq");

		fork
			medium_src_seq.start(src_seqrh);
			no_dst_seq.start(dst_seqrh[m_cfg.dst_addr]);
		join

	endtask: body

endclass: medium_packet_vseq

// Big packet virtual sequence
class big_packet_vseq extends router_virtual_sequence;
	
	`uvm_object_utils(big_packet_vseq)

	// Sequence handles for big packet 
	big_packet_src_seq 	big_src_seq;
	no_delay_dst_seq		no_dst_seq;

	function new(string name="big_packet_vseq");
		super.new(name);
	endfunction: new

	task body();

		super.body();

		big_src_seq 	= big_packet_src_seq::type_id::create("big_src_seq");
		no_dst_seq		= no_delay_dst_seq::type_id::create("no_dst_seq");

		fork
			big_src_seq.start(src_seqrh);
			no_dst_seq.start(dst_seqrh[m_cfg.dst_addr]);
		join

	endtask: body

endclass: big_packet_vseq
