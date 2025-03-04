module router_sync (

    input   clock,
            resetn,

            detect_add,
            write_enb_reg,

            read_enb_0,
            read_enb_1,
            read_enb_2,

            empty_0,
            empty_1,
            empty_2,

            full_0,
            full_1,
            full_2,

    input [1:0] data_in,

    output  vld_out_0,
            vld_out_1,
            vld_out_2,

    output reg  soft_reset_0,
                soft_reset_1,
                soft_reset_2,

                fifo_full,

    output reg [2:0] write_enb

);

    reg [1:0]   fifo_addr; // intermediate register for storing destination address

    reg [5:0]   sft_rst_count_0,
                sft_rst_count_1,
                sft_rst_count_2; // to count for 30 clock cycles

    // Logic for storing destination address
    always @(posedge clock) begin

        if(~resetn)
            fifo_addr <= 2'bxx;

        else begin

            if (detect_add)
                fifo_addr <= data_in;

            else
                fifo_addr <= fifo_addr;

        end

    end

    // One hot encoding for write enable to the FIFOs
    always @(*) begin

        if (write_enb_reg) begin

            case (fifo_addr)

                 2'b00: write_enb = 3'b001;

                 2'b01: write_enb = 3'b010;

                 2'b10: write_enb = 3'b100;

                 default: write_enb = 3'b000;

            endcase

        end

        else
            write_enb = 3'bxxx;

    end

    // fifo_full signal logic
    always @(posedge clock) begin

        case (fifo_addr)

            2'b00: fifo_full <= full_0;

            2'b10: fifo_full <= full_1;

            2'b10: fifo_full <= full_2;

            default: fifo_full <= 0;

        endcase

    end

    // vld_out_x logic to destination indicating that the fifo is not empty
    // and ready to be read
    assign vld_out_0 = ~empty_0;

    assign vld_out_1 = ~empty_1;

    assign vld_out_2 = ~empty_2;

    // Soft reset logic to reset the FIFOs when the destination hasn't send
    // any read signal within the first 30 clock cycles
    always @(posedge clock) begin

        if (~resetn) begin

             soft_reset_0       <= 0;
             sft_rst_count_0    <= 0;

        end

        else if (~vld_out_0) begin

             soft_reset_0       <= 0;
             sft_rst_count_0    <= 0;

        end

        else if (read_enb_0) begin

             soft_reset_0       <= 0;
             sft_rst_count_0    <= 0;

        end

        else if (sft_rst_count_0 < 30) begin

            soft_reset_0    <= 0;
            sft_rst_count_0 <= sft_rst_count_0 + 1'b1;

        end

        else begin

            soft_reset_0 <= 1;

        end

    end

    always @(posedge clock) begin

        if (~resetn) begin

             soft_reset_1       <= 0;
             sft_rst_count_1    <= 0;

        end

        else if (~vld_out_1) begin

             soft_reset_1       <= 0;
             sft_rst_count_1    <= 0;

        end

        else if (read_enb_1) begin

             soft_reset_1       <= 0;
             sft_rst_count_1    <= 0;

        end

        else if (sft_rst_count_1 < 30) begin

            soft_reset_1    <= 0;
            sft_rst_count_1 <= sft_rst_count_1 + 1'b1;

        end

        else begin

            soft_reset_1 <= 1;

        end

    end

    always @(posedge clock) begin

        if (~resetn) begin

             soft_reset_2       <= 0;
             sft_rst_count_2    <= 0;

        end

        else if (~vld_out_2) begin

             soft_reset_2       <= 0;
             sft_rst_count_2    <= 0;

        end

        else if (read_enb_2) begin

             soft_reset_2       <= 0;
             sft_rst_count_2    <= 0;

        end

        else if (sft_rst_count_2 < 30) begin

            soft_reset_2    <= 0;
            sft_rst_count_2 <= sft_rst_count_2 + 1'b1;

        end

        else begin

            soft_reset_2 <= 1;

        end

    end

endmodule
