module uart_rx (
    input            clk,
    input            reset,
    input            rx,
    output reg [7:0] rx_byte = 0,
    output reg       valid
);

// UART Parameters
localparam BAUD_RATE   = 9600;
localparam CLOCK_FREQ  = 60000000;
localparam BIT_PERIOD  = CLOCK_FREQ / BAUD_RATE;
// 10416 for 20MHz clk and 9600 baud

// State Encoding
localparam IDLE        = 0;
localparam START_BIT   = 1;
localparam DATA_BITS   = 2;
localparam STOP_BIT    = 3;
localparam WAIT        = 4;

// Internal Registers
reg [3:0] state = IDLE;
reg [3:0] bit_counter = 0;
reg [14:0] BIT_PERIOD_COUNTER = 0;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        valid <= 1'b0;
        rx_byte <= 8'b0;
        bit_counter <= 0;
        BIT_PERIOD_COUNTER <= 0;
    end else begin
        case (state)
            IDLE: begin
                valid <= 1'b0;

                if (rx == 1'b0) begin // Start bit detected
                    state <= START_BIT;
                    BIT_PERIOD_COUNTER <= 0;
                end
            end

            START_BIT: begin
                if (BIT_PERIOD_COUNTER < (BIT_PERIOD - 1) / 2) begin
                    BIT_PERIOD_COUNTER <= BIT_PERIOD_COUNTER + 1;
                end else begin
                    BIT_PERIOD_COUNTER <= 0;

                    if (rx == 1'b0)
                        state <= DATA_BITS;
                    else
                        state <= IDLE;
                end
            end

            DATA_BITS: begin
                if (bit_counter < 8) begin
                    rx_byte[bit_counter] <= rx;

                    if (BIT_PERIOD_COUNTER < BIT_PERIOD) begin
                        BIT_PERIOD_COUNTER <= BIT_PERIOD_COUNTER + 1;
                    end else begin
                        bit_counter <= bit_counter + 1;
                        BIT_PERIOD_COUNTER <= 0;
                    end
                end else begin
                    state <= STOP_BIT;
                    BIT_PERIOD_COUNTER <= 0;
                    bit_counter <= 0;
                end
            end

            STOP_BIT: begin
                if (BIT_PERIOD_COUNTER < BIT_PERIOD) begin
                    BIT_PERIOD_COUNTER <= BIT_PERIOD_COUNTER + 1;
                end else begin
                    BIT_PERIOD_COUNTER <= 0;
                    state <= WAIT;
                end
            end

            WAIT: begin
                state <= IDLE;
                valid <= 1'b1;
            end

            default: begin
                state <= IDLE;
                valid <= 1'b0;
            end
        endcase
    end
end
endmodule