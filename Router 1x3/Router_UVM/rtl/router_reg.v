module router_reg (
    input   clock,
            resetn,
            pkt_valid,
            fifo_full,
            rst_int_reg,
            detect_add,
            ld_state,
            laf_state,
            full_state,
            lfd_state,

    input [7:0] data_in,

    output reg  parity_done,
                low_pkt_valid,
                err,

    output reg [7:0] dout
);

    reg [7:0] hold_header_byte, fifo_full_byte, internal_parity_byte, pkt_parity_byte;

    // dout logic
    always @(posedge clock) begin

        if(~resetn) begin
            hold_header_byte  <= 8'b0;
            fifo_full_byte    <= 8'b0;
            dout              <= 8'b0;
        end

        else begin

            if (detect_add && pkt_valid) begin

                hold_header_byte <= data_in;

            end

            else if (lfd_state) begin

                dout  <= hold_header_byte;

            end

            else if (ld_state && ~fifo_full) begin

                dout  <= data_in;

            end

            else if (ld_state && fifo_full) begin

                fifo_full_byte <= data_in;

            end

            else if (laf_state) begin

                dout  <= fifo_full_byte;

            end

        end

    end

    // Packet parity capture
    always @(posedge clock) begin

        if (~resetn) begin

            pkt_parity_byte <= 8'b0;

        end

        else if (~pkt_valid && ld_state) begin

            pkt_parity_byte <= data_in;

        end

    end

    // Internal parity calculation
    always @(posedge clock) begin

        if (~resetn) begin

            internal_parity_byte <= 8'b0;

        end

        else if (lfd_state) begin

            internal_parity_byte <= hold_header_byte;

        end

        else if (pkt_valid && ld_state && ~full_state) begin

            internal_parity_byte <= internal_parity_byte ^ data_in;

        end

        else begin

            if (detect_add) begin

                internal_parity_byte <= 8'b0;

            end

        end

    end

    // Generating error signal
    always @(posedge clock) begin

        if (~resetn) begin

            err <= 1'b0;

        end

        else begin

            if (~pkt_valid && parity_done) begin 

                if (internal_parity_byte != pkt_parity_byte) begin

                    err <= 1'b1;

                end

                else 
                    err <= 1'b0;

            end

        end

    end

    // parity_done output logic
    always @(posedge clock) begin

        if (~resetn) begin

            parity_done <= 1'b0;

        end

        else begin

            if (ld_state && ~fifo_full && ~pkt_valid) begin

                parity_done <= 1'b1;

            end

            else if (laf_state && ~pkt_valid) begin

                parity_done <= 1'b1;

            end

            else begin

                parity_done <= 1'b0;

            end

        end

    end

    // low_pkt_valid generation logic
    always @(posedge clock) begin

        if (~resetn) begin

            low_pkt_valid <= 1'b0;

        end

        else begin

            if (rst_int_reg) begin

                low_pkt_valid <= 1'b0;

            end

            if (ld_state && ~pkt_valid) begin

                low_pkt_valid <= 1'b1;

            end

        end

    end

endmodule
