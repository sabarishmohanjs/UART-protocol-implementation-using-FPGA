module uart_top_tb();

    // Define clock frequency and baud rate for the testbench
    parameter CLK_FREQ = 100_000_000; // 100 MHz clock
    parameter BAUD_RATE = 10_000_000;       // 9600 bps baud rate

    // Testbench signals declaration
    reg clk;           // Clock signal
    reg reset;         // Reset signal
    reg i_data_avail;  // Input to UART: data available for TX
    reg [7:0] i_data_byte; // Input to UART: data byte for TX
    wire o_tx;         // Output from UART: TX line
    wire o_tx_done;    // Output from UART: TX complete
    wire o_tx_active;  // Output from UART: TX active
    wire [7:0] o_rx_data_byte; // Output from UART: RX data byte
    wire o_rx_data_avail; // Output from UART: RX data available
    wire error;        // Output from UART: parity error

    // Instantiate the Unit Under Test (UART top module)
    uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .clk(clk),
        .reset(reset), // Connect the reset signal
        .i_data_avail(i_data_avail),
        .i_data_byte(i_data_byte),
        .o_tx(o_tx),
        .o_tx_done(o_tx_done),
        .o_tx_active(o_tx_active),
        .o_rx_data_byte(o_rx_data_byte),
        .o_rx_data_avail(o_rx_data_avail),
        .error(error)
    );

    // Clock generation: 10ns period (100MHz frequency)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Toggle clock every 5ns (period = 10ns)
    end

    // Simulation sequence
    initial begin
        // Display header for monitor output
        $display("Time\tTX_Active\tTX_Done\tTX\tRX_Byte\tRX_Data_Avail\tPARITY_ERROR");
        // Monitor key signals during simulation
        $monitor("%0t\t%b\t\t%b\t%b\t%h\t%b\t\t%b",
                 $time, o_tx_active, o_tx_done, o_tx, o_rx_data_byte, o_rx_data_avail, error);

        // Initial state of inputs
        i_data_avail = 0;
        i_data_byte = 8'h00;
        reset = 1; // Assert reset
        #50; // Hold reset for some initial clock cycles
        reset = 0; // De-assert reset
        #10; // Small delay after reset

        // --- First data transmission (0xA5) ---
        // Set data to be sent
        i_data_byte = 8'hA5;
        i_data_avail = 1;
        #10; // Hold i_data_avail high for one clock cycle
        i_data_avail = 0;

        // Wait for receiver to assert data available for the first byte
        @(posedge o_rx_data_avail);
        $display("[%0t ns] ? Received byte: %h, Error: %b", $time, o_rx_data_byte, error);
        #10; // Small delay to allow o_rx_data_avail to go low again

        // --- Second data transmission (0x3C) ---
        #100; // Wait for some time before sending the next byte

        // Set data for the second transmission
        i_data_byte = 8'h3C;
        i_data_avail = 1;
        #10;
        i_data_avail = 0;

        // Wait for receiver to assert data available for the second byte
        @(posedge o_rx_data_avail);
        $display("[%0t ns] ? Received byte: %h, Error: %b", $time, o_rx_data_byte, error);
        #10; // Small delay to allow o_rx_data_avail to go low again

        #100; // Final delay

        // --- Third data transmission (0xFF) ---
        // Set data to be sent
        i_data_byte = 8'hFF;
        i_data_avail = 1;
        #10; // Hold i_data_avail high for one clock cycle
        i_data_avail = 0;

        // Wait for receiver to assert data available for the third byte
        @(posedge o_rx_data_avail);
        $display("[%0t ns] ? Received byte: %h, Error: %b", $time, o_rx_data_byte, error);
        #10; // Small delay to allow o_rx_data_avail to go low again

        // --- Fourth data transmission (0xF0) ---
        #100; // Wait for some time before sending the next byte

        // Set data for the fourth transmission
        i_data_byte = 8'hF0;
        i_data_avail = 1;
        #10;
        i_data_avail = 0;

        // Wait for receiver to assert data available for the fourth byte
        @(posedge o_rx_data_avail);
        $display("[%0t ns] ? Received byte: %h, Error: %b", $time, o_rx_data_byte, error);
        #10; // Small delay to allow o_rx_data_avail to go low again

        #100; // Final delay

        $display("? Simulation completed.");
        $finish; // End simulation
    end

endmodule
