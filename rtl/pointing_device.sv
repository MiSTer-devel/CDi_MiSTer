module pointing_device (
    input clk,
    input wire [15:0] mister_joystick,
    input wire [15:0] mister_joystick_analog,
    input wire [24:0] mister_mouse,
    input rts,
    input overclock,
    input [2:0] speed_setting,
    bytestream.source serial_out
);

    localparam kDeadzoneSize = 14;

    function automatic signed [7:0] deadzone_calc(input signed [7:0] val);
        if (val > kDeadzoneSize) deadzone_calc = val - kDeadzoneSize;
        else if (val < -kDeadzoneSize) deadzone_calc = val + kDeadzoneSize;
        else deadzone_calc = 0;
    endfunction

    function automatic signed [7:0] mouse_saturate(input signed [12:0] acc);
        if (acc > 127) mouse_saturate = 127;
        else if (acc < -127) mouse_saturate = -127;
        else mouse_saturate = 8'(acc);
    endfunction


    // The baud rate of the spoon is 1200
    // A serial frame uses 1 start bit, 8 data bits and 1 stop bit
    // In truth according to the documentation these are 7 data bits and 2 stop bits
    // But I know that this is just wrong documentation.
    // 1200 baud is eqivalent to 120 byte/s
    // 30e6 / 120 is 250000
    // For overclocking: 30e6 / 50 Hz video / 3 = 200000
    wire [18:0] kTicksPerByte = overclock ? 200000 : 250000;

    typedef enum bit [2:0] {
        DEVICE_ID,  // Always start with this after RTS is asserted
        IDLE,
        BYTE0,  // 1 1 B1 B2 Y7 Y6 X7 X6
        BYTE1,  // 1 0 X5 X4 X3 X2 X1 X0
        BYTE2  // 1 0 Y5 Y4 Y3 Y2 Y1 Y0
    } e_state;

    typedef enum bit {
        MANEUVERING,  // e.g. Paddle Controller
        RELATIVE  // e.g. Mouse
    } e_device_type;

    // Currently active device
    e_device_type device_type;

    e_state state;
    bit [18:0] cnt;
    bit [7:0] frame[3];

    bit perform_transmit;

    bit b1;
    bit b2;

    bit b1_q, b2_q;

    bit signed [7:0] speed;

    bit signed [7:0] x_analog;
    bit signed [7:0] y_analog;

    bit signed [7:0] x;
    bit signed [7:0] y;

    bit signed [7:0] x_q;
    bit signed [7:0] y_q;
    bit [2:0] accel;

    bit mouse_event_q;
    wire mouse_event = mister_mouse[24];

    bit digital_movement;
    bit analog_movement;

    wire signed [8:0] x_mouse_inc = {mister_mouse[4], mister_mouse[15:8]};
    wire signed [8:0] y_mouse_inc = -{mister_mouse[5], mister_mouse[23:16]};
    // every edge transfers data
    wire mouse_inc_valid = mouse_event != mouse_event_q;

    wire significant_mouse_movement = (x_mouse_inc < -2) || (y_mouse_inc < -2) || (x_mouse_inc > 2) || (y_mouse_inc > 2);
    bit significant_mouse_movement_latch;

    // Accumulate movement from MiSTer framework
    bit signed [12:0] x_mouse_acc;
    bit signed [12:0] y_mouse_acc;

    bit signed [7:0] x_mouse;
    bit signed [7:0] y_mouse;

    // Speed settings of various pointing devices
    // thx to https://github.com/Stovent/ for measuring the 22ER9021:
    //   speed I only sends 1
    //   speed N sends 2 2 4 4 6 6 8 8 8 8...
    //   speed II sends 2 4 6 8 10 12 14 16 16 16...
    // RV 8701 (the spoon controller) with no speed setting
    //   2 2 2 2 2 2 8 8 8 8
    // verilog_format: off
    bit signed [7:0] speed_lut [4*8]='{
        2,  2,  4,  4,  6,  6,  8,  8, // 22ER9021 N
        2,  4,  6,  8, 10, 12, 14, 16, // 22ER9021 II
        2,  2,  2,  2,  2,  2,  8,  8, // RV 8701
        1,  1,  1,  1,  1,  1,  1,  1  // 22ER9021 I
    };
    // verilog_format: on

    always_comb begin
        x = 0;
        y = 0;

        // combine joystick and mouse buttons
        // The gamepad uses the layout of the 22ER9017
        // Front face buttons
        //         B1
        //  B1/B2      B2
        //         B1
        b1 = mister_joystick[6] | mister_joystick[4] | mister_joystick[7] | mister_mouse[0];
        b2 = mister_joystick[6] | mister_joystick[5] | mister_mouse[1];

        speed = speed_lut[{speed_setting[1:0], accel}];

        // handle d pad
        if (mister_joystick[0]) x = speed;
        if (mister_joystick[2]) y = speed;
        if (mister_joystick[1]) x = -speed;
        if (mister_joystick[3]) y = -speed;

        x_analog = mister_joystick_analog[7:0];
        y_analog = mister_joystick_analog[15:8];

        // map analog input to -18..+18 with a deadzone of 28x28
        x_analog = deadzone_calc(x_analog) / 6;
        y_analog = deadzone_calc(y_analog) / 6;

        // set mouse coordinates
        x_mouse = mouse_saturate(x_mouse_acc);
        y_mouse = mouse_saturate(y_mouse_acc);

        digital_movement = mister_joystick[3:0] != 0;
        analog_movement = (x_analog != 0) || (y_analog != 0);

        // prioritize analog > digital > mouse
        if (device_type == RELATIVE) begin
            x = x_mouse;
            y = y_mouse;
        end
        if (device_type == MANEUVERING && analog_movement) begin
            x = x_analog;
            y = y_analog;
        end

        // Only transmit when buttons have changed or when we are moving the cursor
        // Even so, the speed is not changed, we must transmit permanently.
        perform_transmit = (b1 != b1_q) || (b2 != b2_q) || (x != x_q) || 
                    (y != y_q) || (x !=0 ) || (y !=0 );
    end

    always_ff @(posedge clk) begin
        if (serial_out.write) $display("INPUT SERIAL %x", serial_out.data);
    end

    always_ff @(posedge clk) begin
        serial_out.write <= 0;
        mouse_event_q <= mouse_event;

        // Accumulation of mouse movement
        if (mouse_inc_valid && device_type == RELATIVE) begin
            x_mouse_acc <= x_mouse_acc + 13'(x_mouse_inc);
            y_mouse_acc <= y_mouse_acc + 13'(y_mouse_inc);
        end

        if (significant_mouse_movement) significant_mouse_movement_latch <= 1;

        if (rts) begin
            state <= DEVICE_ID;
            cnt   <= kTicksPerByte;
        end else if (cnt != 0) begin
            cnt <= cnt - 1;
        end else begin
            cnt <= kTicksPerByte;

            case (state)
                DEVICE_ID: begin
                    if (device_type == RELATIVE) begin
                        serial_out.data <= ("M" | (1 << 7));  // relative
                    end else begin
                        serial_out.data <= ("J" | (1 << 7));  // maneuvering
                    end

                    state <= IDLE;
                    serial_out.write <= 1;
                end
                IDLE: begin
                    // do nothing
                end
                BYTE0: begin
                    serial_out.data <= frame[0];
                    state <= BYTE1;
                    serial_out.write <= 1;
                end
                BYTE1: begin
                    serial_out.data <= frame[1];
                    state <= BYTE2;
                    serial_out.write <= 1;
                end
                BYTE2: begin
                    serial_out.data <= frame[2];
                    state <= IDLE;
                    serial_out.write <= 1;
                end
                default: ;
            endcase
        end


        // Change whole frame at the same time before transmitting the next
        if (cnt == 1 && state == IDLE) begin
            significant_mouse_movement_latch <= 0;

            // Setup transmission of pointing device data, send correct
            // device ID first if required.
            if (significant_mouse_movement_latch && !digital_movement && !analog_movement && (device_type != RELATIVE)) begin
                device_type <= RELATIVE;
                state <= DEVICE_ID;
            end else if ((digital_movement || analog_movement) && (device_type != MANEUVERING)) begin
                device_type <= MANEUVERING;
                state <= DEVICE_ID;
            end else if (perform_transmit) begin
                // Store for next comparison
                x_q <= x;
                y_q <= y;
                b1_q <= b1;
                b2_q <= b2;

                frame[0] <= {2'b11, b1, b2, y[7:6], x[7:6]};
                frame[1] <= {2'b10, x[5:0]};
                frame[2] <= {2'b10, y[5:0]};
                $display("INPUT FRAME Buttons:%d%d  X:%d  Y:%d", b1, b2, x, y);

                state <= BYTE0;

                // Consume only the relative movement stored in this packet.
                // Keep any saturated remainder for later packets and include
                // a same-clock increment, which was not part of this packet.
                // Joystick packets must not consume pending mouse movement.
                if (device_type == RELATIVE) begin
                    x_mouse_acc <= x_mouse_acc - 13'(x_mouse) +
                                   (mouse_inc_valid ? 13'(x_mouse_inc) : 13'sd0);
                    y_mouse_acc <= y_mouse_acc - 13'(y_mouse) +
                                   (mouse_inc_valid ? 13'(y_mouse_inc) : 13'sd0);
                end
            end

            // With every transmitted frame, when using the gamepad, the acceleration will increase
            if (mister_joystick[3:0] == 0) begin
                accel <= 0;
            end else if (mister_joystick[3:0] != 0 && accel < 7) begin
                accel <= accel + 1;
            end
        end
    end
endmodule

