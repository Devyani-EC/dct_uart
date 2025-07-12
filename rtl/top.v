module top (
    input  clk,
    input  uart_rx_pin,
    output uart_tx_pin
);

wire [7:0]      rx_byte;
wire [255:0]    out;
wire            valid;
wire            o_done;
wire            busy;

reg [255:0]    in_data = 0;
reg [255:0]    out_data = 0;
reg [7:0]      tx_byte = 0;
reg [1:0]      state = 0;
reg [5:0]      byte_count = 0;
reg [255:0]    rx_store = 0;
reg [5:0]      count = 0;
reg            i_call = 0;
reg            reset = 0;
reg            tx_valid = 0;


always @(posedge clk) begin
    if (count == 32) begin
        in_data <= rx_store;
        i_call <= 1;
        reset <= 0;
        count <= 0;
    end else begin
        i_call <= 0;

        if (valid) begin
            rx_store[255 - (count * 8) -: 8] <= rx_byte;
            count <= count + 1;
        end
    end
    
    case (state)
        0: begin
            if (o_done) begin
                out_data <= {out};
               state <= 1;
            end
        end

        1: begin 
            if(byte_count == 32) begin
                byte_count <= 0;
                tx_valid <= 0;
                state <= 0;
            end else begin 
                if (!busy) begin
                    tx_byte <= out_data[255 - (byte_count * 8) -: 8];
                    tx_valid <= 1;
                    state <= 2;
                end
            end
        end

        2: begin
           if (byte_count < 32) begin
                byte_count <= byte_count + 1;
                tx_valid <= 0;
                state <= 1;
            end 
        end
        
    endcase
end

// Module Instantiations
uart_rx rx_ (
    .clk        (clk),
    .reset      (reset),
    .rx         (uart_rx_pin),
    .valid      (valid),
    .rx_byte    (rx_byte)
);

uart_tx tx_ (
    .clk        (clk),
    .rst        (reset),
    .tx_byte    (tx_byte),
    .tx_valid   (tx_valid),
    .tx         (uart_tx_pin),
    .busy       (busy)
);

dct_core dct (
    .clk            (clk),
    .rst_n          (reset),
    .a1             (in_data),
    .start          (i_call),
    .final_output   (out),
    .done           (o_done)
);

endmodule