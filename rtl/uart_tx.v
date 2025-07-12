module uart_tx (
    input       clk,
    input       rst,
    input       tx_valid,
    input [7:0] tx_byte,
    output reg  tx,
    output reg  busy
);

// UART Parameters
localparam BAUD_RATE = 9600;
localparam CLOCK_FREQ = 60000000;
localparam BIT_PERIOD = CLOCK_FREQ / BAUD_RATE;
// 10416 for 20MHz clk and 9600 baud

// State Encoding
localparam IDLE      = 4'd0;
localparam START_BIT = 4'd1;
localparam DATA_BITS = 4'd2;
localparam STOP_BIT  = 4'd3;
localparam WAIT      = 4'd4;

// Internal Registers
reg [3:0] state = IDLE;
reg [7:0] tx_data_reg = 8'd0;
reg [2:0] bit_counter = 3'd0;
reg [14:0] baud_counter = 15'd0;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        tx <= 1'b1;
        busy <= 1'b0;
        state <= IDLE;
        bit_counter <= 3'd0;
        baud_counter <= 15'd0;
    end else begin
        case (state)
            IDLE: begin
                tx <= 1'b1;
                busy <= 1'b0;
                bit_counter <= 3'd0;
                baud_counter <= 15'd0;

                if (tx_valid) begin
                    tx_data_reg <= tx_byte;
                    tx <= 1'b0;       
                    busy <= 1'b1;
                    state <= START_BIT;
                end
            end

            START_BIT: begin
                if (baud_counter < BIT_PERIOD - 1) begin
                    baud_counter <= baud_counter + 1;
                end else begin
                    baud_counter <= 0;
                    state <= DATA_BITS;
                end
            end

            DATA_BITS: begin
                tx <= tx_data_reg[bit_counter];

                if (baud_counter < BIT_PERIOD - 1) begin
                    baud_counter <= baud_counter + 1;
                end else begin
                    baud_counter <= 0;

                    if (bit_counter < 7) begin
                        bit_counter <= bit_counter + 1;
                    end else begin
                        bit_counter <= 0;
                        state <= STOP_BIT;
                    end
                end
            end

            STOP_BIT: begin
                tx <= 1'b1; // Stop bit

                if (baud_counter < BIT_PERIOD - 1) begin
                    baud_counter <= baud_counter + 1;
                end else begin
                    baud_counter <= 0;
                    state <= WAIT;
                end
            end

            WAIT: begin
                busy <= 1'b0;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
                busy <= 1'b0;
            end
        endcase
    end
end
endmodule