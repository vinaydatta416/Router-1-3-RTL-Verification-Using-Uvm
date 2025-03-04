module router_fsm (
    input   clock,
            resetn,
            pkt_valid,
            parity_done,
            soft_reset_0,
            soft_reset_1,
            soft_reset_2,
            fifo_full,
            low_pkt_valid,
            fifo_empty_0,
            fifo_empty_1,
            fifo_empty_2,

    input [1:0] data_in,

    output reg  busy,
                detect_add,
                ld_state,
                laf_state,
                full_state,
                write_enb_reg,
                rst_int_reg,
                lfd_state
);

    reg [3:0] state, next_state;
    reg [1:0] addr;

    // parameters for states
    parameter   DECODE_ADDRESS        = 3'D0,
                WAIT_TILL_EMPTY       = 3'D1,
                LOAD_FIRST_DATA       = 3'D2,
                LOAD_DATA             = 3'D3,
                FIFO_FULL_STATE       = 3'D4,
                LOAD_AFTER_FULL       = 3'D5,
                LOAD_PARITY           = 3'D6,
                CHECK_PARITY_ERROR    = 3'D7;

    // present state assignment
    always @(posedge clock) begin

        if(~resetn) begin
            state   <= DECODE_ADDRESS;
            addr    <= 0;
        end

        else if(soft_reset_0 || soft_reset_1 || soft_reset_2) begin
            state   <= DECODE_ADDRESS;
            addr    <= 0;
        end

        else begin
            state   <= next_state;
            addr    <= data_in;
        end

    end

    always @(*) begin

        case (state)

            DECODE_ADDRESS  : begin

                if (
                    (pkt_valid && (data_in[1:0] == 2'b00) && fifo_empty_0) ||
                    (pkt_valid && (data_in[1:0] == 2'b01) && fifo_empty_1) ||
                    (pkt_valid && (data_in[1:0] == 2'b10) && fifo_empty_2)
                ) begin

                    next_state = LOAD_FIRST_DATA;

                end

                else if (
                    (pkt_valid && (data_in[1:0] == 2'b00) && ~fifo_empty_0) ||
                    (pkt_valid && (data_in[1:0] == 2'b01) && ~fifo_empty_1) ||
                    (pkt_valid && (data_in[1:0] == 2'b10) && ~fifo_empty_2)
                ) begin

                    next_state = WAIT_TILL_EMPTY;

                end

            end

            WAIT_TILL_EMPTY : begin

                if (
                    (fifo_empty_0 && (data_in[1:0] == 2'b00)) ||
                    (fifo_empty_1 && (data_in[1:0] == 2'b01)) ||
                    (fifo_empty_2 && (data_in[1:0] == 2'b10))
                ) begin

                    next_state = LOAD_FIRST_DATA;

                end

                else
                    next_state = WAIT_TILL_EMPTY;

            end

            LOAD_FIRST_DATA : next_state = LOAD_DATA;

            LOAD_DATA       : begin

                if (fifo_full)
                    next_state = FIFO_FULL_STATE;

                else if(~fifo_full && ~pkt_valid)
                    next_state = LOAD_PARITY;

                else
                    next_state = LOAD_DATA;

            end

            FIFO_FULL_STATE : next_state = fifo_full ? FIFO_FULL_STATE : LOAD_AFTER_FULL;

            LOAD_AFTER_FULL : begin

                if (~parity_done && ~low_pkt_valid)
                    next_state = LOAD_DATA;

                else if (parity_done)
                    next_state = DECODE_ADDRESS;

                else if (~parity_done && low_pkt_valid)
                    next_state = LOAD_PARITY;

            end

            LOAD_PARITY     : next_state = CHECK_PARITY_ERROR;

            CHECK_PARITY_ERROR  : begin

                if (fifo_full)
                    next_state = FIFO_FULL_STATE;

                else if (~fifo_full)
                    next_state = DECODE_ADDRESS;

            end

            default: next_state = DECODE_ADDRESS;

        endcase

    end

    // signal assertion logic block
    always @(*) begin

    detect_add    = 1'b0;
    busy          = 1'b0;
    ld_state      = 1'b0;
    laf_state     = 1'b0;
    full_state    = 1'b0;
    write_enb_reg = 1'b0;
    rst_int_reg   = 1'b0;
    lfd_state     = 1'b0;

        case (state)

            DECODE_ADDRESS  : begin

                detect_add    = 1'b1;

            end

            LOAD_FIRST_DATA : begin

                lfd_state     = 1'b1;
                busy          = 1'b1;

            end

            LOAD_DATA       : begin

                ld_state      = 1'b1;
                busy          = 1'b0;
                write_enb_reg = 1'b1;

            end

            LOAD_PARITY     : begin

                busy          = 1'b1;
                write_enb_reg = 1'b1;

            end

            FIFO_FULL_STATE : begin

                busy          = 1'b1;
                write_enb_reg = 1'b0;
                full_state    = 1'b1;

            end

            LOAD_AFTER_FULL : begin

                laf_state     = 1'b1;
                busy          = 1'b1;
                write_enb_reg = 1'b1;

            end

            WAIT_TILL_EMPTY : begin

                busy          = 1'b1;
                write_enb_reg = 1'b0;

            end

            CHECK_PARITY_ERROR : begin

                rst_int_reg   = 1'b1;
                busy          = 1'b1;

            end

            default : begin

                detect_add    = 1'b0;
                busy          = 1'b0;
                ld_state      = 1'b0;
                laf_state     = 1'b0;
                full_state    = 1'b0;
                write_enb_reg = 1'b0;
                rst_int_reg   = 1'b0;
                lfd_state     = 1'b0;

            end

        endcase

    end


endmodule
