// Receiver module
// This module receives serial data from the UART RX line and outputs a data byte.
// It uses the CLKS_PER_BIT parameter for timing and includes parity checking.
module receiver #(parameter CLKS_PER_BIT=10)(
    input clk,           // System clock
    input reset,         // System reset
    input i_rx,          // UART RX line input
    output o_data_avail, // High for one clock cycle when a new data byte is received
    output [7:0] o_data_byte, // Received 8-bit data byte
    output wire error    // High if a parity error is detected
);

    reg r_parity = 0;      // Received parity bit
    reg rx_buf = 0;        // Buffer for i_rx (for synchronization)
    reg rx = 0;            // Synchronized RX input
    reg data_avail = 0;    // Internal flag for data availability
    reg [7:0] data_byte = 0; // Internal buffer for received data byte
    reg [2:0] state = 0;   // Current state of the FSM
    reg [15:0] counter = 0; // Counter for timing each bit period
    reg [3:0] index = 0;   // Bit index for receiving data (0-7)

    // Assign internal registers to output ports
    assign o_data_avail = data_avail;
    assign o_data_byte = data_byte;

    // Declare error_check wire outside the always block
    wire [8:0] error_check;
    // Calculate error_check by concatenating received parity and data byte
    assign error_check = {r_parity, o_data_byte};
    // Parity error if XOR reduction of error_check is 1 (for odd parity)
    assign error = ^error_check;

    // Synchronize i_rx to the internal clock domain to prevent metastability issues
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            rx_buf <= 0;
            rx <= 0;
        end else begin
            rx_buf <= i_rx;
            rx <= rx_buf;
        end
    end

    // State definitions for the FSM
    localparam IDLE = 3'b000;       // Waiting for start bit
    localparam START = 3'b001;      // Detecting and validating start bit
    localparam GET_BIT = 3'b010;    // Receiving data bits
    localparam PARITY = 3'b011;     // Receiving parity bit
    localparam STOP = 3'b100;       // Receiving stop bit

    // Main always block for receiver FSM
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers on system reset
            counter <= 0;
            index <= 0;
            data_avail <= 0;
            data_byte <= 0;
            state <= IDLE;
            r_parity <= 0;
        end else begin
            // Default to clearing data_avail unless set in STOP state
            data_avail <= 0;

            case(state)
                IDLE: begin
                    counter <= 0; // Reset counter
                    index <= 0;   // Reset bit index
                    if (rx == 0) begin // Detect start bit (low)
                        state <= START; // Move to START state
                    end else begin
                        state <= IDLE;  // Stay in IDLE
                    end
                end

                START: begin
                    // Sample in the middle of the start bit period to confirm it's still low
                    if (counter == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx == 0) begin // Confirm start bit is still low
                            counter <= 0;   // Reset counter
                            state <= GET_BIT; // Move to GET_BIT state
                        end else begin
                            state <= IDLE;  // Spurious start bit, return to IDLE
                        end
                    end else begin
                        counter <= counter + 1; // Increment counter
                    end
                end

                GET_BIT: begin
                    if (counter < CLKS_PER_BIT - 1) begin
                        counter <= counter + 1; // Increment counter
                    end else begin
                        counter <= 0;           // Reset counter
                        data_byte[index] <= rx; // Sample and store data bit (LSB first)
                        if (index < 7) begin
                            index <= index + 1; // Move to next data bit
                            state <= GET_BIT;   // Stay in GET_BIT state
                        end else begin
                            state <= PARITY;    // All data bits received, move to PARITY state
                        end
                    end
                end

                PARITY: begin
                    if (counter < CLKS_PER_BIT - 1) begin
                        counter <= counter + 1; // Increment counter
                    end else begin
                        counter <= 0;           // Reset counter
                        r_parity <= rx;         // Sample and store parity bit
                        state <= STOP;          // Move to STOP state
                    end
                end

                STOP: begin
                    if (counter < CLKS_PER_BIT - 1) begin
                        counter <= counter + 1; // Increment counter
                    end else begin
                        counter <= 0;           // Reset counter
                        data_avail <= 1'b1;     // Indicate data is available
                        state <= IDLE;          // Return to IDLE state
                    end
                end

                default: state <= IDLE; // Default to IDLE state
            endcase
        end
    end

endmodule
