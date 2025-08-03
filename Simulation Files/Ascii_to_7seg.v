// ascii_to_7seg.v
// This module decodes a single ASCII character (numeric, uppercase, lowercase)
// to 7-segment patterns for a Common Anode display.
module ascii_to_7seg (
    input  wire [7:0] ascii_char,    // Input ASCII character (e.g., 8'h30 for '0', 8'h41 for 'A')
    output reg  [6:0] seg,          // 7-segment outputs (active LOW for common anode)
    output wire [7:0]an            
    // Removed 'an' output as it should be handled by a higher-level multiplexer
);

    // Segment Mapping (Common Anode: 0 = ON, 1 = OFF)
    //   ---a---
    //  |       |
    //  f       b
    //  |       |
    //   ---g---
    //  |       |
    //  e       c
    //  |       |
    //   ---d---
    // Segment order: {a, b, c, d, e, f, g}

    always @(*) begin
        // Default: All segments off (blank) for unsupported characters
        seg = 7'b111_1111;

        case (ascii_char)
            // --- Numerics (ASCII '0' to '9') ---
            8'h30: seg = 7'b000_0001; // '0' (a,b,c,d,e,f ON, g OFF)
            8'h31: seg = 7'b100_1111; // '1' (b,c ON)
            8'h32: seg = 7'b001_0010; // '2' (a,b,d,e,g ON)
            8'h33: seg = 7'b000_0110; // '3' (a,b,c,d,g ON)
            8'h34: seg = 7'b100_1100; // '4' (b,c,f,g ON)
            8'h35: seg = 7'b010_0100; // '5' (a,c,d,f,g ON)
            8'h36: seg = 7'b010_0000; // '6' (a,c,d,e,f,g ON)
            8'h37: seg = 7'b000_1111; // '7' (a,b,c ON)
            8'h38: seg = 7'b000_0000; // '8' (all segments ON)
            8'h39: seg = 7'b000_0100; // '9' (a,b,c,d,f,g ON)

            // --- Uppercase Letters (ASCII 'A' to 'Z') ---
            // These are common approximations for 7-segment display.
            // Some letters are impossible or look poor. Adjust as desired.
            8'h41: seg = 7'b000_1000; // 'A' (a,b,c,e,f,g)
            8'h42: seg = 7'b110_0000; // 'B' (looks like lowercase 'b')
            8'h43: seg = 7'b011_0001; // 'C' (a,d,e,f)
            8'h44: seg = 7'b100_0010; // 'D' (looks like lowercase 'd')
            8'h45: seg = 7'b011_0000; // 'E' (a,d,e,f,g)
            8'h46: seg = 7'b011_1000; // 'F' (a,e,f,g)
            8'h47: seg = 7'b000_0100; // 'G' (like 9, but with bottom left segment)
            8'h48: seg = 7'b100_1000; // 'H' (b,c,e,f,g)
            8'h49: seg = 7'b111_1001; // 'I' (like 1, or center bar + top/bottom horizontal)
            8'h4A: seg = 7'b100_0011; // 'J' (b,c,d,e,f)
            // K is very hard
            8'h4C: seg = 7'b111_0001; // 'L' (d,e,f)
            // M is very hard
            8'h4E: seg = 7'b110_1010; // 'N' (looks like lowercase 'n')
            8'h4F: seg = 7'b000_0001; // 'O' (same as '0')
            8'h50: seg = 7'b001_1000; // 'P' (a,b,e,f,g)
            8'h51: seg = 7'b000_1100; // 'Q' (a,b,c,f,g)
            8'h52: seg = 7'b111_1010; // 'R' (looks like lowercase 'r')
            8'h53: seg = 7'b010_0100; // 'S' (same as '5')
            8'h54: seg = 7'b111_0000; // 'T' (looks like lowercase 't')
            8'h55: seg = 7'b100_0001; // 'U' (b,c,d,e,f)
            // V, W, X are very hard
            8'h59: seg = 7'b100_0100; // 'Y' (b,c,d,f,g, looks like lowercase 'y')
            8'h5A: seg = 7'b001_0010; // 'Z' (same as '2')

            // --- Lowercase Letters (ASCII 'a' to 'z') ---
            // Often use approximations or share patterns with uppercase/other lowercase.
            8'h61: seg = 7'b000_1000; // 'a' (same as A)
            8'h62: seg = 7'b110_0000; // 'b' (standard lowercase b: c,d,e,f,g)
            8'h63: seg = 7'b011_0001; // 'c' (standard lowercase c: d,e,g)
            8'h64: seg = 7'b100_0010; // 'd' (standard lowercase d: b,c,d,e,g)
            8'h65: seg = 7'b011_0000; // 'e' (same as E)
            8'h66: seg = 7'b011_1000; // 'f' (same as F)
            8'h67: seg = 7'b000_0100; // 'g' (similar to 9)
            8'h68: seg = 7'b100_1000; // 'h' (same as H)
            8'h69: seg = 7'b111_1001; // 'i' (e.g., just 'c')
            8'h6A: seg = 7'b100_0011; // 'j' (same as J)
            // k is hard
            8'h6C: seg = 7'b111_0001; // 'l' (same as L)
            // m is hard
            8'h6E: seg = 7'b110_1010; // 'n' (standard lowercase n: c,e,g)
            8'h6F: seg = 7'b000_0001; // 'o' (often just c,d,e,g)
            8'h70: seg = 7'b001_1000; // 'p' (same as P)
            // q is hard
            8'h72: seg = 7'b111_1010; // 'r' (standard lowercase r: e,g)
            8'h73: seg = 7'b010_0100; // 's' (same as S or 5)
            8'h74: seg = 7'b111_0000; // 't' (standard lowercase t: d,e,f,g)
            8'h75: seg = 7'b100_0001; // 'u' (same as U)
            // v, w, x are hard
            8'h79: seg = 7'b100_0100; // 'y' (same as Y)
            8'h7A: seg = 7'b001_0010; // 'z' (same as Z or 2)


            // --- Other common characters / special symbols ---
            8'h20: seg = 7'b111_1111; // Space (blank)
            8'h2D: seg = 7'b011_1111; // Dash '-' (only 'g' segment on)
            8'h2E: seg = 7'b011_1111; // Period '.' (Decimal point, typically a separate segment output)
                                      // Note: The Nexys A7 has a separate DP anode.
                                      // This assumes DP is part of your 'seg' output,
                                      // but it's usually `seg[7]` or a separate `dp` output.

            default: seg = 7'b111_1111; // Fallback: Display 'E' for unsupported/error characters
                                        // or 7'b111_1111; for blank.
        endcase
        end
    assign an=8'b1111_1110;
endmodule
