// Transmitter module
// This module takes a byte and transmits it serially over the UART TX line.
// It uses the CLKS_PER_BIT parameter to time each bit period.
module transmitter#(parameter CLKS_PER_BIT=10)(
    input i_data_avail,  // High when new data byte is available for transmission
    input [7:0] i_data_byte, // 8-bit data byte to transmit
    input clk,           // System clock
    input reset,         // System reset
    output reg o_active, // High when transmission is active
    output reg o_done,   // High for one clock cycle when transmission is complete
    output reg o_tx       // UART TX line output
);
    reg t_parity = 0;      // Parity bit for transmission
    reg [7:0] data_byte = 0; // Internal buffer for the data byte
    reg [2:0] state = 0;   // Current state of the FSM
    reg [2:0] index = 0;   // Bit index for sending data (0-7)
    reg [15:0] counter = 0; // Counter for timing each bit period

    // State definitions for the FSM
    localparam IDLE = 3'b000;       // Waiting for data to transmit
    localparam START = 3'b001;      // Sending start bit
    localparam SEND_BIT = 3'b010;   // Sending data bits
    localparam PARITY = 3'b011;     // Sending parity bit
    localparam STOP = 3'b100;       // Sending stop bit

    // Main always block for transmitter FSM
    always@(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all registers on system reset
            counter <= 0;
            index <= 0;
            o_done <= 0;
            o_active <= 0;
            o_tx <= 1'b1; // UART TX line is idle high
            state <= IDLE;
            data_byte <= 0;
            t_parity <= 0;
        end else begin
            // Default to clearing o_done unless set in IDLE
            o_done <= 0;

            case(state)
                IDLE: begin
                    counter <= 0; // Reset counter
                    index <= 0;   // Reset bit index
                    o_tx <= 1'b1; // Ensure TX is idle high
                    if (i_data_avail == 1'b1) begin
                        o_active <= 1'b1;     // Indicate transmission is active
                        data_byte <= i_data_byte; // Load data byte
                        t_parity = ^i_data_byte;  // Calculate parity for the loaded byte
                        state <= START;       // Move to START state
                    end else begin
                        state <= IDLE;        // Stay in IDLE
                    end
                end

                START: begin
                    o_tx <= 0; // Send start bit (low)
                    if (counter < CLKS_PER_BIT - 1) begin
                        counter <= counter + 1; // Increment counter
                    end else begin
                        counter <= 0;           // Reset counter
                        state <= SEND_BIT;      // Move to SEND_BIT state
                    end
                end

                SEND_BIT: begin
                    o_tx <= data_byte[index]; // Send current data bit (LSB first)
                    if (counter < CLKS_PER_BIT - 1) begin
                        counter <= counter + 1; // Increment counter
                    end else begin
                        counter <= 0;           // Reset counter
                        if (index < 7) begin
                            index <= index + 1; // Move to next data bit
                            state <= SEND_BIT;  // Stay in SEND_BIT state
                        end else begin
                            state <= PARITY;    // All data bits sent, move to PARITY state
                        end
                    end
                end

                PARITY: begin
                    o_tx <= t_parity; // Send parity bit
                    if (counter < CLKS_PER_BIT - 1) begin
                        counter <= counter + 1; // Increment counter
                    end else begin
                        counter <= 0;           // Reset counter
                        state <= STOP;          // Move to STOP state
                    end
                end

                STOP: begin
                    o_tx <= 1'b1; // Send stop bit (high)
                    if (counter < CLKS_PER_BIT - 1) begin
                        counter <= counter + 1; // Increment counter
                    end else begin
                        counter <= 0;           // Reset counter
                        o_active <= 0;          // Deactivate transmission
                        o_done <= 1;            // Indicate transmission is done
                        state <= IDLE;          // Return to IDLE state
                    end
                end

                default: state <= IDLE; // Default to IDLE state
            endcase
        end
    end

endmodule
