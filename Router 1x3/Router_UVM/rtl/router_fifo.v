module router_fifo (

    input   clock,
            resetn,
            write_enb,
            soft_reset,
            read_enb,
            lfd_state,
    input   [7:0] data_in,

    output  empty,
            full,

    output reg [7:0] data_out
    
);

    integer i;

    // FIFO memory 16x9
    reg [8:0] mem [15:0];

    // FIFO pointer variables
    reg [4:0] wr_ptr = 5'h00, rd_ptr = 5'h00;

    // FIFO count for counting the payload
    reg [5:0] fifo_count;

    // Empty and Full calculation
    assign full   = ((rd_ptr[4] != wr_ptr[4]) && (rd_ptr[3:0] == wr_ptr[3:0])) ? 1 : 0;
    assign empty  = (rd_ptr == wr_ptr) ? 1 : 0;

    // Logic for lfd_state delayed by one clock cycle for synchronizing with
    // register output
    reg lfd_state_s;

    always @(posedge clock) begin

        if(!resetn)
            lfd_state_s <= 1'b0;

        else
            lfd_state_s <= lfd_state;

    end

    // Read pointer and write pointer logic
    always @(posedge clock) begin

        if(!resetn) begin

            wr_ptr  <= 5'b0;
            rd_ptr  <= 5'b0;

        end

        else if (soft_reset) begin

            wr_ptr  <= 5'b0;
            rd_ptr  <= 5'b0;

        end

        else begin

            if(write_enb && !full)
                wr_ptr  <= wr_ptr + 1'b1;
            else
                wr_ptr  <= wr_ptr;

            if(read_enb && !empty)
                rd_ptr  <= rd_ptr + 1'b1;
            else 
                rd_ptr  <= rd_ptr;
        end

    end

    // Write and Read Logic
    always @(posedge clock) begin

        if (!resetn) begin

            for (i = 0; i < 16; i=i+1)
                mem[i] <= 9'b0;
            
            data_out <= 8'b0;

        end

        else if (soft_reset) begin

            for (i = 0; i < 16; i=i+1)
                mem[i] <= 9'b0;
            
            data_out <= 8'b0;

        end

        else begin
            
            // Write operation
            if (write_enb && !full)
                // mem[wr_ptr[3:0]] <= {lfd_state_s, data_in};
                mem[wr_ptr[3:0]] <= {data_in};
            
            // Read operation
            if (read_enb && !empty)
                data_out          <= mem[rd_ptr[3:0]];

        end

    end

    // FIFO count logic. Down counting the payload length
    always @(posedge clock) begin

        if (!resetn)
            fifo_count <= 6'b0;

        else if (soft_reset)
            fifo_count <= 6'b0;

        else if (read_enb && !empty) begin

            if (mem[rd_ptr[3:0]][8] == 1'b1)
                fifo_count <= mem[rd_ptr[3:0]][7:2] + 1; // Latching the payload length + 1 for parity bit
            
            else if (fifo_count != 0)
                fifo_count <= fifo_count - 1'b1;
                
        end

    end

endmodule
