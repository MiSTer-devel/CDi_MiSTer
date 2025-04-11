module fadd
  (input  a,
   input  b,
   input  cin,
   output s,
   output cout);
  wire n4170_o;
  wire n4171_o;
  wire n4172_o;
  wire n4173_o;
  wire n4174_o;
  wire n4175_o;
  wire n4176_o;
  assign s = n4171_o;
  assign cout = n4176_o;
  /* 6805.vhd:19:10  */
  assign n4170_o = a ^ b;
  /* 6805.vhd:19:16  */
  assign n4171_o = n4170_o ^ cin;
  /* 6805.vhd:20:14  */
  assign n4172_o = a & b;
  /* 6805.vhd:20:27  */
  assign n4173_o = a & cin;
  /* 6805.vhd:20:21  */
  assign n4174_o = n4172_o | n4173_o;
  /* 6805.vhd:20:42  */
  assign n4175_o = b & cin;
  /* 6805.vhd:20:36  */
  assign n4176_o = n4174_o | n4175_o;
endmodule

module add8
  (input  [7:0] a,
   input  [7:0] b,
   input  cin,
   output [7:0] sum,
   output cout);
  wire [6:0] c;
  wire n4095_o;
  wire n4096_o;
  wire a0_n4097;
  wire a0_n4098;
  wire a0_s;
  wire a0_cout;
  wire n4103_o;
  wire n4104_o;
  wire n4105_o;
  wire stage_n1_as_n4106;
  wire stage_n1_as_n4107;
  wire stage_n1_as_s;
  wire stage_n1_as_cout;
  wire n4112_o;
  wire n4113_o;
  wire n4114_o;
  wire stage_n2_as_n4115;
  wire stage_n2_as_n4116;
  wire stage_n2_as_s;
  wire stage_n2_as_cout;
  wire n4121_o;
  wire n4122_o;
  wire n4123_o;
  wire stage_n3_as_n4124;
  wire stage_n3_as_n4125;
  wire stage_n3_as_s;
  wire stage_n3_as_cout;
  wire n4130_o;
  wire n4131_o;
  wire n4132_o;
  wire stage_n4_as_n4133;
  wire stage_n4_as_n4134;
  wire stage_n4_as_s;
  wire stage_n4_as_cout;
  wire n4139_o;
  wire n4140_o;
  wire n4141_o;
  wire stage_n5_as_n4142;
  wire stage_n5_as_n4143;
  wire stage_n5_as_s;
  wire stage_n5_as_cout;
  wire n4148_o;
  wire n4149_o;
  wire n4150_o;
  wire stage_n6_as_n4151;
  wire stage_n6_as_n4152;
  wire stage_n6_as_s;
  wire stage_n6_as_cout;
  wire n4157_o;
  wire n4158_o;
  wire n4159_o;
  wire a31_n4160;
  wire a31_n4161;
  wire a31_s;
  wire a31_cout;
  wire [6:0] n4166_o;
  wire [7:0] n4167_o;
  assign sum = n4167_o;
  assign cout = a31_n4161;
  /* 6805.vhd:34:10  */
  assign c = n4166_o; // (signal)
  /* 6805.vhd:43:33  */
  assign n4095_o = a[0];
  /* 6805.vhd:43:39  */
  assign n4096_o = b[0];
  /* 6805.vhd:43:49  */
  assign a0_n4097 = a0_s; // (signal)
  /* 6805.vhd:43:57  */
  assign a0_n4098 = a0_cout; // (signal)
  /* 6805.vhd:43:3  */
  fadd a0 (
    .a(n4095_o),
    .b(n4096_o),
    .cin(cin),
    .s(a0_s),
    .cout(a0_cout));
  /* 6805.vhd:45:33  */
  assign n4103_o = a[1];
  /* 6805.vhd:45:39  */
  assign n4104_o = b[1];
  /* 6805.vhd:45:45  */
  assign n4105_o = c[6];
  /* 6805.vhd:45:53  */
  assign stage_n1_as_n4106 = stage_n1_as_s; // (signal)
  /* 6805.vhd:45:61  */
  assign stage_n1_as_n4107 = stage_n1_as_cout; // (signal)
  /* 6805.vhd:45:14  */
  fadd stage_n1_as (
    .a(n4103_o),
    .b(n4104_o),
    .cin(n4105_o),
    .s(stage_n1_as_s),
    .cout(stage_n1_as_cout));
  /* 6805.vhd:45:33  */
  assign n4112_o = a[2];
  /* 6805.vhd:45:39  */
  assign n4113_o = b[2];
  /* 6805.vhd:45:45  */
  assign n4114_o = c[5];
  /* 6805.vhd:45:53  */
  assign stage_n2_as_n4115 = stage_n2_as_s; // (signal)
  /* 6805.vhd:45:61  */
  assign stage_n2_as_n4116 = stage_n2_as_cout; // (signal)
  /* 6805.vhd:45:14  */
  fadd stage_n2_as (
    .a(n4112_o),
    .b(n4113_o),
    .cin(n4114_o),
    .s(stage_n2_as_s),
    .cout(stage_n2_as_cout));
  /* 6805.vhd:45:33  */
  assign n4121_o = a[3];
  /* 6805.vhd:45:39  */
  assign n4122_o = b[3];
  /* 6805.vhd:45:45  */
  assign n4123_o = c[4];
  /* 6805.vhd:45:53  */
  assign stage_n3_as_n4124 = stage_n3_as_s; // (signal)
  /* 6805.vhd:45:61  */
  assign stage_n3_as_n4125 = stage_n3_as_cout; // (signal)
  /* 6805.vhd:45:14  */
  fadd stage_n3_as (
    .a(n4121_o),
    .b(n4122_o),
    .cin(n4123_o),
    .s(stage_n3_as_s),
    .cout(stage_n3_as_cout));
  /* 6805.vhd:45:33  */
  assign n4130_o = a[4];
  /* 6805.vhd:45:39  */
  assign n4131_o = b[4];
  /* 6805.vhd:45:45  */
  assign n4132_o = c[3];
  /* 6805.vhd:45:53  */
  assign stage_n4_as_n4133 = stage_n4_as_s; // (signal)
  /* 6805.vhd:45:61  */
  assign stage_n4_as_n4134 = stage_n4_as_cout; // (signal)
  /* 6805.vhd:45:14  */
  fadd stage_n4_as (
    .a(n4130_o),
    .b(n4131_o),
    .cin(n4132_o),
    .s(stage_n4_as_s),
    .cout(stage_n4_as_cout));
  /* 6805.vhd:45:33  */
  assign n4139_o = a[5];
  /* 6805.vhd:45:39  */
  assign n4140_o = b[5];
  /* 6805.vhd:45:45  */
  assign n4141_o = c[2];
  /* 6805.vhd:45:53  */
  assign stage_n5_as_n4142 = stage_n5_as_s; // (signal)
  /* 6805.vhd:45:61  */
  assign stage_n5_as_n4143 = stage_n5_as_cout; // (signal)
  /* 6805.vhd:45:14  */
  fadd stage_n5_as (
    .a(n4139_o),
    .b(n4140_o),
    .cin(n4141_o),
    .s(stage_n5_as_s),
    .cout(stage_n5_as_cout));
  /* 6805.vhd:45:33  */
  assign n4148_o = a[6];
  /* 6805.vhd:45:39  */
  assign n4149_o = b[6];
  /* 6805.vhd:45:45  */
  assign n4150_o = c[1];
  /* 6805.vhd:45:53  */
  assign stage_n6_as_n4151 = stage_n6_as_s; // (signal)
  /* 6805.vhd:45:61  */
  assign stage_n6_as_n4152 = stage_n6_as_cout; // (signal)
  /* 6805.vhd:45:14  */
  fadd stage_n6_as (
    .a(n4148_o),
    .b(n4149_o),
    .cin(n4150_o),
    .s(stage_n6_as_s),
    .cout(stage_n6_as_cout));
  /* 6805.vhd:47:33  */
  assign n4157_o = a[7];
  /* 6805.vhd:47:39  */
  assign n4158_o = b[7];
  /* 6805.vhd:47:45  */
  assign n4159_o = c[0];
  /* 6805.vhd:47:51  */
  assign a31_n4160 = a31_s; // (signal)
  /* 6805.vhd:47:59  */
  assign a31_n4161 = a31_cout; // (signal)
  /* 6805.vhd:47:3  */
  fadd a31 (
    .a(n4157_o),
    .b(n4158_o),
    .cin(n4159_o),
    .s(a31_s),
    .cout(a31_cout));
  assign n4166_o = {a0_n4098, stage_n1_as_n4107, stage_n2_as_n4116, stage_n3_as_n4125, stage_n4_as_n4134, stage_n5_as_n4143, stage_n6_as_n4152};
  assign n4167_o = {a31_n4160, stage_n6_as_n4151, stage_n5_as_n4142, stage_n4_as_n4133, stage_n3_as_n4124, stage_n2_as_n4115, stage_n1_as_n4106, a0_n4097};
endmodule

module add8c
  (input  b,
   input  [7:0] a,
   input  [7:0] sum_in,
   input  [7:0] cin,
   output [7:0] sum_out,
   output [7:0] cout);
  reg [7:0] zero;
  reg [7:0] aa;
  wire [7:0] n4018_o;
  wire n4019_o;
  wire n4020_o;
  wire n4021_o;
  wire stage_n1_sta_n4022;
  wire stage_n1_sta_n4023;
  wire stage_n1_sta_s;
  wire stage_n1_sta_cout;
  wire n4028_o;
  wire n4029_o;
  wire n4030_o;
  wire stage_n2_sta_n4031;
  wire stage_n2_sta_n4032;
  wire stage_n2_sta_s;
  wire stage_n2_sta_cout;
  wire n4037_o;
  wire n4038_o;
  wire n4039_o;
  wire stage_n3_sta_n4040;
  wire stage_n3_sta_n4041;
  wire stage_n3_sta_s;
  wire stage_n3_sta_cout;
  wire n4046_o;
  wire n4047_o;
  wire n4048_o;
  wire stage_n4_sta_n4049;
  wire stage_n4_sta_n4050;
  wire stage_n4_sta_s;
  wire stage_n4_sta_cout;
  wire n4055_o;
  wire n4056_o;
  wire n4057_o;
  wire stage_n5_sta_n4058;
  wire stage_n5_sta_n4059;
  wire stage_n5_sta_s;
  wire stage_n5_sta_cout;
  wire n4064_o;
  wire n4065_o;
  wire n4066_o;
  wire stage_n6_sta_n4067;
  wire stage_n6_sta_n4068;
  wire stage_n6_sta_s;
  wire stage_n6_sta_cout;
  wire n4073_o;
  wire n4074_o;
  wire n4075_o;
  wire stage_n7_sta_n4076;
  wire stage_n7_sta_n4077;
  wire stage_n7_sta_s;
  wire stage_n7_sta_cout;
  wire n4082_o;
  wire n4083_o;
  wire n4084_o;
  wire stage_n8_sta_n4085;
  wire stage_n8_sta_n4086;
  wire stage_n8_sta_s;
  wire stage_n8_sta_cout;
  wire [7:0] n4091_o;
  wire [7:0] n4092_o;
  assign sum_out = n4091_o;
  assign cout = n4092_o;
  /* 6805.vhd:65:10  */
  always @*
    zero = 8'b00000000; // (isignal)
  initial
    zero = 8'b00000000;
  /* 6805.vhd:66:10  */
  always @*
    aa = n4018_o; // (isignal)
  initial
    aa = 8'b00000000;
  /* 6805.vhd:75:11  */
  assign n4018_o = b ? a : zero;
  /* 6805.vhd:77:26  */
  assign n4019_o = aa[0];
  /* 6805.vhd:77:37  */
  assign n4020_o = sum_in[0];
  /* 6805.vhd:77:45  */
  assign n4021_o = cin[0];
  /* 6805.vhd:77:51  */
  assign stage_n1_sta_n4022 = stage_n1_sta_s; // (signal)
  /* 6805.vhd:77:63  */
  assign stage_n1_sta_n4023 = stage_n1_sta_cout; // (signal)
  /* 6805.vhd:77:5  */
  fadd stage_n1_sta (
    .a(n4019_o),
    .b(n4020_o),
    .cin(n4021_o),
    .s(stage_n1_sta_s),
    .cout(stage_n1_sta_cout));
  /* 6805.vhd:77:26  */
  assign n4028_o = aa[1];
  /* 6805.vhd:77:37  */
  assign n4029_o = sum_in[1];
  /* 6805.vhd:77:45  */
  assign n4030_o = cin[1];
  /* 6805.vhd:77:51  */
  assign stage_n2_sta_n4031 = stage_n2_sta_s; // (signal)
  /* 6805.vhd:77:63  */
  assign stage_n2_sta_n4032 = stage_n2_sta_cout; // (signal)
  /* 6805.vhd:77:5  */
  fadd stage_n2_sta (
    .a(n4028_o),
    .b(n4029_o),
    .cin(n4030_o),
    .s(stage_n2_sta_s),
    .cout(stage_n2_sta_cout));
  /* 6805.vhd:77:26  */
  assign n4037_o = aa[2];
  /* 6805.vhd:77:37  */
  assign n4038_o = sum_in[2];
  /* 6805.vhd:77:45  */
  assign n4039_o = cin[2];
  /* 6805.vhd:77:51  */
  assign stage_n3_sta_n4040 = stage_n3_sta_s; // (signal)
  /* 6805.vhd:77:63  */
  assign stage_n3_sta_n4041 = stage_n3_sta_cout; // (signal)
  /* 6805.vhd:77:5  */
  fadd stage_n3_sta (
    .a(n4037_o),
    .b(n4038_o),
    .cin(n4039_o),
    .s(stage_n3_sta_s),
    .cout(stage_n3_sta_cout));
  /* 6805.vhd:77:26  */
  assign n4046_o = aa[3];
  /* 6805.vhd:77:37  */
  assign n4047_o = sum_in[3];
  /* 6805.vhd:77:45  */
  assign n4048_o = cin[3];
  /* 6805.vhd:77:51  */
  assign stage_n4_sta_n4049 = stage_n4_sta_s; // (signal)
  /* 6805.vhd:77:63  */
  assign stage_n4_sta_n4050 = stage_n4_sta_cout; // (signal)
  /* 6805.vhd:77:5  */
  fadd stage_n4_sta (
    .a(n4046_o),
    .b(n4047_o),
    .cin(n4048_o),
    .s(stage_n4_sta_s),
    .cout(stage_n4_sta_cout));
  /* 6805.vhd:77:26  */
  assign n4055_o = aa[4];
  /* 6805.vhd:77:37  */
  assign n4056_o = sum_in[4];
  /* 6805.vhd:77:45  */
  assign n4057_o = cin[4];
  /* 6805.vhd:77:51  */
  assign stage_n5_sta_n4058 = stage_n5_sta_s; // (signal)
  /* 6805.vhd:77:63  */
  assign stage_n5_sta_n4059 = stage_n5_sta_cout; // (signal)
  /* 6805.vhd:77:5  */
  fadd stage_n5_sta (
    .a(n4055_o),
    .b(n4056_o),
    .cin(n4057_o),
    .s(stage_n5_sta_s),
    .cout(stage_n5_sta_cout));
  /* 6805.vhd:77:26  */
  assign n4064_o = aa[5];
  /* 6805.vhd:77:37  */
  assign n4065_o = sum_in[5];
  /* 6805.vhd:77:45  */
  assign n4066_o = cin[5];
  /* 6805.vhd:77:51  */
  assign stage_n6_sta_n4067 = stage_n6_sta_s; // (signal)
  /* 6805.vhd:77:63  */
  assign stage_n6_sta_n4068 = stage_n6_sta_cout; // (signal)
  /* 6805.vhd:77:5  */
  fadd stage_n6_sta (
    .a(n4064_o),
    .b(n4065_o),
    .cin(n4066_o),
    .s(stage_n6_sta_s),
    .cout(stage_n6_sta_cout));
  /* 6805.vhd:77:26  */
  assign n4073_o = aa[6];
  /* 6805.vhd:77:37  */
  assign n4074_o = sum_in[6];
  /* 6805.vhd:77:45  */
  assign n4075_o = cin[6];
  /* 6805.vhd:77:51  */
  assign stage_n7_sta_n4076 = stage_n7_sta_s; // (signal)
  /* 6805.vhd:77:63  */
  assign stage_n7_sta_n4077 = stage_n7_sta_cout; // (signal)
  /* 6805.vhd:77:5  */
  fadd stage_n7_sta (
    .a(n4073_o),
    .b(n4074_o),
    .cin(n4075_o),
    .s(stage_n7_sta_s),
    .cout(stage_n7_sta_cout));
  /* 6805.vhd:77:26  */
  assign n4082_o = aa[7];
  /* 6805.vhd:77:37  */
  assign n4083_o = sum_in[7];
  /* 6805.vhd:77:45  */
  assign n4084_o = cin[7];
  /* 6805.vhd:77:51  */
  assign stage_n8_sta_n4085 = stage_n8_sta_s; // (signal)
  /* 6805.vhd:77:63  */
  assign stage_n8_sta_n4086 = stage_n8_sta_cout; // (signal)
  /* 6805.vhd:77:5  */
  fadd stage_n8_sta (
    .a(n4082_o),
    .b(n4083_o),
    .cin(n4084_o),
    .s(stage_n8_sta_s),
    .cout(stage_n8_sta_cout));
  assign n4091_o = {stage_n8_sta_n4085, stage_n7_sta_n4076, stage_n6_sta_n4067, stage_n5_sta_n4058, stage_n4_sta_n4049, stage_n3_sta_n4040, stage_n2_sta_n4031, stage_n1_sta_n4022};
  assign n4092_o = {stage_n8_sta_n4086, stage_n7_sta_n4077, stage_n6_sta_n4068, stage_n5_sta_n4059, stage_n4_sta_n4050, stage_n3_sta_n4041, stage_n2_sta_n4032, stage_n1_sta_n4023};
endmodule

module mul8
  (input  [7:0] a,
   input  [7:0] b,
   output [15:0] prod);
  reg [7:0] zero;
  wire [63:0] s;
  wire [63:0] c;
  wire [63:0] ss;
  wire n3899_o;
  wire [7:0] st0_n3900;
  wire [7:0] st0_n3901;
  wire [7:0] st0_sum_out;
  wire [7:0] st0_cout;
  wire [6:0] n3906_o;
  wire [7:0] n3908_o;
  wire n3909_o;
  wire n3910_o;
  wire [7:0] n3911_o;
  wire [7:0] n3912_o;
  wire [7:0] stage_n1_st_n3913;
  wire [7:0] stage_n1_st_n3914;
  wire [7:0] stage_n1_st_sum_out;
  wire [7:0] stage_n1_st_cout;
  wire [6:0] n3919_o;
  wire [7:0] n3921_o;
  wire n3922_o;
  wire n3923_o;
  wire [7:0] n3924_o;
  wire [7:0] n3925_o;
  wire [7:0] stage_n2_st_n3926;
  wire [7:0] stage_n2_st_n3927;
  wire [7:0] stage_n2_st_sum_out;
  wire [7:0] stage_n2_st_cout;
  wire [6:0] n3932_o;
  wire [7:0] n3934_o;
  wire n3935_o;
  wire n3936_o;
  wire [7:0] n3937_o;
  wire [7:0] n3938_o;
  wire [7:0] stage_n3_st_n3939;
  wire [7:0] stage_n3_st_n3940;
  wire [7:0] stage_n3_st_sum_out;
  wire [7:0] stage_n3_st_cout;
  wire [6:0] n3945_o;
  wire [7:0] n3947_o;
  wire n3948_o;
  wire n3949_o;
  wire [7:0] n3950_o;
  wire [7:0] n3951_o;
  wire [7:0] stage_n4_st_n3952;
  wire [7:0] stage_n4_st_n3953;
  wire [7:0] stage_n4_st_sum_out;
  wire [7:0] stage_n4_st_cout;
  wire [6:0] n3958_o;
  wire [7:0] n3960_o;
  wire n3961_o;
  wire n3962_o;
  wire [7:0] n3963_o;
  wire [7:0] n3964_o;
  wire [7:0] stage_n5_st_n3965;
  wire [7:0] stage_n5_st_n3966;
  wire [7:0] stage_n5_st_sum_out;
  wire [7:0] stage_n5_st_cout;
  wire [6:0] n3971_o;
  wire [7:0] n3973_o;
  wire n3974_o;
  wire n3975_o;
  wire [7:0] n3976_o;
  wire [7:0] n3977_o;
  wire [7:0] stage_n6_st_n3978;
  wire [7:0] stage_n6_st_n3979;
  wire [7:0] stage_n6_st_sum_out;
  wire [7:0] stage_n6_st_cout;
  wire [6:0] n3984_o;
  wire [7:0] n3986_o;
  wire n3987_o;
  wire n3988_o;
  wire [7:0] n3989_o;
  wire [7:0] n3990_o;
  wire [7:0] stage_n7_st_n3991;
  wire [7:0] stage_n7_st_n3992;
  wire [7:0] stage_n7_st_sum_out;
  wire [7:0] stage_n7_st_cout;
  wire [6:0] n3997_o;
  wire [7:0] n3999_o;
  wire n4000_o;
  wire [7:0] n4001_o;
  wire [7:0] n4002_o;
  localparam n4003_o = 1'b0;
  wire [7:0] add_n4004;
  wire [7:0] add_sum;
  wire add_cout;
  wire [63:0] n4010_o;
  wire [63:0] n4011_o;
  wire [63:0] n4012_o;
  wire [15:0] n4013_o;
  assign prod = n4013_o;
  /* 6805.vhd:92:10  */
  always @*
    zero = 8'b00000000; // (isignal)
  initial
    zero = 8'b00000000;
  /* 6805.vhd:95:10  */
  assign s = n4010_o; // (signal)
  /* 6805.vhd:96:10  */
  assign c = n4011_o; // (signal)
  /* 6805.vhd:97:10  */
  assign ss = n4012_o; // (signal)
  /* 6805.vhd:115:24  */
  assign n3899_o = b[0];
  /* 6805.vhd:115:45  */
  assign st0_n3900 = st0_sum_out; // (signal)
  /* 6805.vhd:115:51  */
  assign st0_n3901 = st0_cout; // (signal)
  /* 6805.vhd:115:3  */
  add8c st0 (
    .b(n3899_o),
    .a(a),
    .sum_in(zero),
    .cin(zero),
    .sum_out(st0_sum_out),
    .cout(st0_cout));
  /* 6805.vhd:116:22  */
  assign n3906_o = s[63:57];
  /* 6805.vhd:116:16  */
  assign n3908_o = {1'b0, n3906_o};
  /* 6805.vhd:117:18  */
  assign n3909_o = s[56];
  /* 6805.vhd:120:25  */
  assign n3910_o = b[1];
  /* 6805.vhd:120:35  */
  assign n3911_o = ss[63:56];
  /* 6805.vhd:120:44  */
  assign n3912_o = c[63:56];
  /* 6805.vhd:120:51  */
  assign stage_n1_st_n3913 = stage_n1_st_sum_out; // (signal)
  /* 6805.vhd:120:57  */
  assign stage_n1_st_n3914 = stage_n1_st_cout; // (signal)
  /* 6805.vhd:120:5  */
  add8c stage_n1_st (
    .b(n3910_o),
    .a(a),
    .sum_in(n3911_o),
    .cin(n3912_o),
    .sum_out(stage_n1_st_sum_out),
    .cout(stage_n1_st_cout));
  /* 6805.vhd:121:24  */
  assign n3919_o = s[55:49];
  /* 6805.vhd:121:18  */
  assign n3921_o = {1'b0, n3919_o};
  /* 6805.vhd:122:20  */
  assign n3922_o = s[48];
  /* 6805.vhd:120:25  */
  assign n3923_o = b[2];
  /* 6805.vhd:120:35  */
  assign n3924_o = ss[55:48];
  /* 6805.vhd:120:44  */
  assign n3925_o = c[55:48];
  /* 6805.vhd:120:51  */
  assign stage_n2_st_n3926 = stage_n2_st_sum_out; // (signal)
  /* 6805.vhd:120:57  */
  assign stage_n2_st_n3927 = stage_n2_st_cout; // (signal)
  /* 6805.vhd:120:5  */
  add8c stage_n2_st (
    .b(n3923_o),
    .a(a),
    .sum_in(n3924_o),
    .cin(n3925_o),
    .sum_out(stage_n2_st_sum_out),
    .cout(stage_n2_st_cout));
  /* 6805.vhd:121:24  */
  assign n3932_o = s[47:41];
  /* 6805.vhd:121:18  */
  assign n3934_o = {1'b0, n3932_o};
  /* 6805.vhd:122:20  */
  assign n3935_o = s[40];
  /* 6805.vhd:120:25  */
  assign n3936_o = b[3];
  /* 6805.vhd:120:35  */
  assign n3937_o = ss[47:40];
  /* 6805.vhd:120:44  */
  assign n3938_o = c[47:40];
  /* 6805.vhd:120:51  */
  assign stage_n3_st_n3939 = stage_n3_st_sum_out; // (signal)
  /* 6805.vhd:120:57  */
  assign stage_n3_st_n3940 = stage_n3_st_cout; // (signal)
  /* 6805.vhd:120:5  */
  add8c stage_n3_st (
    .b(n3936_o),
    .a(a),
    .sum_in(n3937_o),
    .cin(n3938_o),
    .sum_out(stage_n3_st_sum_out),
    .cout(stage_n3_st_cout));
  /* 6805.vhd:121:24  */
  assign n3945_o = s[39:33];
  /* 6805.vhd:121:18  */
  assign n3947_o = {1'b0, n3945_o};
  /* 6805.vhd:122:20  */
  assign n3948_o = s[32];
  /* 6805.vhd:120:25  */
  assign n3949_o = b[4];
  /* 6805.vhd:120:35  */
  assign n3950_o = ss[39:32];
  /* 6805.vhd:120:44  */
  assign n3951_o = c[39:32];
  /* 6805.vhd:120:51  */
  assign stage_n4_st_n3952 = stage_n4_st_sum_out; // (signal)
  /* 6805.vhd:120:57  */
  assign stage_n4_st_n3953 = stage_n4_st_cout; // (signal)
  /* 6805.vhd:120:5  */
  add8c stage_n4_st (
    .b(n3949_o),
    .a(a),
    .sum_in(n3950_o),
    .cin(n3951_o),
    .sum_out(stage_n4_st_sum_out),
    .cout(stage_n4_st_cout));
  /* 6805.vhd:121:24  */
  assign n3958_o = s[31:25];
  /* 6805.vhd:121:18  */
  assign n3960_o = {1'b0, n3958_o};
  /* 6805.vhd:122:20  */
  assign n3961_o = s[24];
  /* 6805.vhd:120:25  */
  assign n3962_o = b[5];
  /* 6805.vhd:120:35  */
  assign n3963_o = ss[31:24];
  /* 6805.vhd:120:44  */
  assign n3964_o = c[31:24];
  /* 6805.vhd:120:51  */
  assign stage_n5_st_n3965 = stage_n5_st_sum_out; // (signal)
  /* 6805.vhd:120:57  */
  assign stage_n5_st_n3966 = stage_n5_st_cout; // (signal)
  /* 6805.vhd:120:5  */
  add8c stage_n5_st (
    .b(n3962_o),
    .a(a),
    .sum_in(n3963_o),
    .cin(n3964_o),
    .sum_out(stage_n5_st_sum_out),
    .cout(stage_n5_st_cout));
  /* 6805.vhd:121:24  */
  assign n3971_o = s[23:17];
  /* 6805.vhd:121:18  */
  assign n3973_o = {1'b0, n3971_o};
  /* 6805.vhd:122:20  */
  assign n3974_o = s[16];
  /* 6805.vhd:120:25  */
  assign n3975_o = b[6];
  /* 6805.vhd:120:35  */
  assign n3976_o = ss[23:16];
  /* 6805.vhd:120:44  */
  assign n3977_o = c[23:16];
  /* 6805.vhd:120:51  */
  assign stage_n6_st_n3978 = stage_n6_st_sum_out; // (signal)
  /* 6805.vhd:120:57  */
  assign stage_n6_st_n3979 = stage_n6_st_cout; // (signal)
  /* 6805.vhd:120:5  */
  add8c stage_n6_st (
    .b(n3975_o),
    .a(a),
    .sum_in(n3976_o),
    .cin(n3977_o),
    .sum_out(stage_n6_st_sum_out),
    .cout(stage_n6_st_cout));
  /* 6805.vhd:121:24  */
  assign n3984_o = s[15:9];
  /* 6805.vhd:121:18  */
  assign n3986_o = {1'b0, n3984_o};
  /* 6805.vhd:122:20  */
  assign n3987_o = s[8];
  /* 6805.vhd:120:25  */
  assign n3988_o = b[7];
  /* 6805.vhd:120:35  */
  assign n3989_o = ss[15:8];
  /* 6805.vhd:120:44  */
  assign n3990_o = c[15:8];
  /* 6805.vhd:120:51  */
  assign stage_n7_st_n3991 = stage_n7_st_sum_out; // (signal)
  /* 6805.vhd:120:57  */
  assign stage_n7_st_n3992 = stage_n7_st_cout; // (signal)
  /* 6805.vhd:120:5  */
  add8c stage_n7_st (
    .b(n3988_o),
    .a(a),
    .sum_in(n3989_o),
    .cin(n3990_o),
    .sum_out(stage_n7_st_sum_out),
    .cout(stage_n7_st_cout));
  /* 6805.vhd:121:24  */
  assign n3997_o = s[7:1];
  /* 6805.vhd:121:18  */
  assign n3999_o = {1'b0, n3997_o};
  /* 6805.vhd:122:20  */
  assign n4000_o = s[0];
  /* 6805.vhd:125:24  */
  assign n4001_o = ss[7:0];
  /* 6805.vhd:125:30  */
  assign n4002_o = c[7:0];
  /* 6805.vhd:125:41  */
  assign add_n4004 = add_sum; // (signal)
  /* 6805.vhd:125:3  */
  add8 add (
    .a(n4001_o),
    .b(n4002_o),
    .cin(n4003_o),
    .sum(add_sum),
    .cout());
  assign n4010_o = {st0_n3900, stage_n1_st_n3913, stage_n2_st_n3926, stage_n3_st_n3939, stage_n4_st_n3952, stage_n5_st_n3965, stage_n6_st_n3978, stage_n7_st_n3991};
  assign n4011_o = {st0_n3901, stage_n1_st_n3914, stage_n2_st_n3927, stage_n3_st_n3940, stage_n4_st_n3953, stage_n5_st_n3966, stage_n6_st_n3979, stage_n7_st_n3992};
  assign n4012_o = {n3908_o, n3921_o, n3934_o, n3947_o, n3960_o, n3973_o, n3986_o, n3999_o};
  assign n4013_o = {add_n4004, n4000_o, n3987_o, n3974_o, n3961_o, n3948_o, n3935_o, n3922_o, n3909_o};
endmodule

module UR6805
  (input  clk,
   input  clken,
   input  rst,
   input  extirq,
   input  timerirq,
   input  sciirq,
   input  [7:0] datain,
   output [15:0] addr,
   output wr,
   output [3:0] state,
   output [7:0] dataout);
  wire [63:0] mask0;
  wire [63:0] mask1;
  wire [7:0] rega/*verilator public_flat_rd*/ ;
  wire [7:0] regx/*verilator public_flat_rd*/ ;
  wire [15:0] regsp;
  wire [15:0] regpc/*verilator public_flat_rd*/ ;
  wire flagh;
  wire flagi;
  wire flagn;
  wire flagz;
  wire flagc;
  wire [7:0] help;
  wire [15:0] temp;
  wire [3:0] mainfsm;
  wire [2:0] addrmux;
  wire [3:0] datamux;
  wire [7:0] opcode;
  wire [15:0] prod;
  wire extirq_d;
  wire timerirq_d;
  wire sciirq_d;
  wire extirqrequest;
  wire timerirqrequest;
  wire sciirqrequest;
  wire trace;
  wire trace_i;
  wire [7:0] traceopcode;
  wire [15:0] mul_n4;
  wire [15:0] mul_prod;
  wire n8_o;
  wire [15:0] n9_o;
  wire n11_o;
  wire [15:0] n12_o;
  wire [15:0] n14_o;
  wire n16_o;
  wire [15:0] n17_o;
  wire n19_o;
  wire [15:0] n20_o;
  wire [15:0] n22_o;
  wire [15:0] n23_o;
  wire n25_o;
  wire [15:0] n26_o;
  wire [15:0] n27_o;
  wire n29_o;
  wire [15:0] n30_o;
  wire [15:0] n32_o;
  wire [7:0] n33_o;
  wire [15:0] n35_o;
  wire [15:0] n36_o;
  wire n38_o;
  wire [15:0] n39_o;
  wire [7:0] n40_o;
  wire [15:0] n42_o;
  wire [15:0] n43_o;
  wire n45_o;
  wire [7:0] n46_o;
  wire n48_o;
  wire [7:0] n49_o;
  wire n51_o;
  wire [7:0] n52_o;
  wire [7:0] n53_o;
  wire n55_o;
  wire [7:0] n56_o;
  wire [7:0] n57_o;
  wire n59_o;
  wire [7:0] n60_o;
  wire [7:0] n61_o;
  wire n63_o;
  wire [7:0] n64_o;
  wire [7:0] n65_o;
  wire n67_o;
  wire [7:0] n68_o;
  wire [7:0] n69_o;
  wire n71_o;
  wire [7:0] n72_o;
  wire [7:0] n73_o;
  wire n75_o;
  wire [7:0] n76_o;
  wire n78_o;
  wire [7:0] n79_o;
  wire n100_o;
  wire n103_o;
  wire n104_o;
  wire n106_o;
  wire n108_o;
  wire n109_o;
  wire n111_o;
  wire n113_o;
  wire n114_o;
  wire n116_o;
  wire [15:0] n118_o;
  wire n120_o;
  wire n122_o;
  wire n123_o;
  wire n124_o;
  wire n125_o;
  wire n126_o;
  wire [15:0] n128_o;
  wire n130_o;
  wire [15:0] n132_o;
  wire n134_o;
  wire n136_o;
  wire n137_o;
  wire n139_o;
  wire n140_o;
  wire n142_o;
  wire n143_o;
  wire n145_o;
  wire n146_o;
  wire n148_o;
  wire n149_o;
  wire n151_o;
  wire n152_o;
  wire n154_o;
  wire n155_o;
  wire n157_o;
  wire n158_o;
  wire n160_o;
  wire n161_o;
  wire n163_o;
  wire n164_o;
  wire n166_o;
  wire n167_o;
  wire n169_o;
  wire n170_o;
  wire n172_o;
  wire n173_o;
  wire n175_o;
  wire n176_o;
  wire n178_o;
  wire n179_o;
  wire n181_o;
  wire n182_o;
  wire n184_o;
  wire n185_o;
  wire n187_o;
  wire n188_o;
  wire n190_o;
  wire n191_o;
  wire n193_o;
  wire n194_o;
  wire n196_o;
  wire n197_o;
  wire n199_o;
  wire n200_o;
  wire n202_o;
  wire n203_o;
  wire n205_o;
  wire n206_o;
  wire n208_o;
  wire n209_o;
  wire n211_o;
  wire n212_o;
  wire n214_o;
  wire n215_o;
  wire n217_o;
  wire n218_o;
  wire n220_o;
  wire n221_o;
  wire n223_o;
  wire n224_o;
  wire n226_o;
  wire n227_o;
  wire n229_o;
  wire n230_o;
  wire n232_o;
  wire n233_o;
  wire n235_o;
  wire n236_o;
  wire n238_o;
  wire n239_o;
  wire n241_o;
  wire n242_o;
  wire n244_o;
  wire n245_o;
  wire n247_o;
  wire n248_o;
  wire n250_o;
  wire n251_o;
  wire n253_o;
  wire n254_o;
  wire n256_o;
  wire n257_o;
  wire n259_o;
  wire n260_o;
  wire n262_o;
  wire n263_o;
  wire n265_o;
  wire n266_o;
  wire n268_o;
  wire n269_o;
  wire n271_o;
  wire n272_o;
  wire n274_o;
  wire n275_o;
  wire n277_o;
  wire n278_o;
  wire n280_o;
  wire n281_o;
  wire n283_o;
  wire n284_o;
  wire n286_o;
  wire n287_o;
  wire n289_o;
  wire n290_o;
  wire n292_o;
  wire n293_o;
  wire n295_o;
  wire n296_o;
  wire n298_o;
  wire n299_o;
  wire n301_o;
  wire n302_o;
  wire n304_o;
  wire n305_o;
  wire [15:0] n307_o;
  wire n309_o;
  wire n311_o;
  wire n312_o;
  wire n314_o;
  wire n315_o;
  wire n317_o;
  wire n318_o;
  wire n320_o;
  wire n321_o;
  wire n323_o;
  wire n324_o;
  wire n326_o;
  wire n327_o;
  wire n329_o;
  wire n330_o;
  wire n332_o;
  wire n333_o;
  wire n335_o;
  wire n336_o;
  wire n338_o;
  wire n339_o;
  wire n341_o;
  wire n342_o;
  wire n344_o;
  wire n345_o;
  wire n347_o;
  wire n348_o;
  wire n350_o;
  wire n351_o;
  wire n353_o;
  wire n354_o;
  wire n356_o;
  wire n357_o;
  wire n359_o;
  wire n360_o;
  wire n362_o;
  wire n363_o;
  wire n365_o;
  wire n366_o;
  wire n368_o;
  wire n369_o;
  wire n371_o;
  wire n372_o;
  wire n374_o;
  wire n375_o;
  wire n377_o;
  wire n378_o;
  wire n380_o;
  wire n381_o;
  wire n383_o;
  wire n384_o;
  wire n386_o;
  wire n387_o;
  wire n389_o;
  wire n390_o;
  wire n392_o;
  wire n393_o;
  wire n395_o;
  wire n396_o;
  wire n398_o;
  wire n399_o;
  wire n401_o;
  wire n402_o;
  wire n404_o;
  wire n405_o;
  wire n407_o;
  wire n408_o;
  wire n410_o;
  wire n411_o;
  wire n413_o;
  wire n414_o;
  wire n416_o;
  wire n417_o;
  wire n419_o;
  wire n420_o;
  wire n422_o;
  wire n423_o;
  wire n425_o;
  wire n426_o;
  wire n428_o;
  wire n429_o;
  wire n431_o;
  wire n432_o;
  wire n434_o;
  wire n435_o;
  wire n437_o;
  wire n438_o;
  wire n440_o;
  wire n441_o;
  wire n443_o;
  wire n444_o;
  wire [15:0] n446_o;
  wire n448_o;
  wire n450_o;
  wire n451_o;
  wire n453_o;
  wire n454_o;
  wire n456_o;
  wire n457_o;
  wire n459_o;
  wire n460_o;
  wire n462_o;
  wire n463_o;
  wire n465_o;
  wire n466_o;
  wire n468_o;
  wire n469_o;
  wire n471_o;
  wire n472_o;
  wire n474_o;
  wire n475_o;
  wire [15:0] n477_o;
  wire n479_o;
  wire n481_o;
  wire n482_o;
  wire n484_o;
  wire n485_o;
  wire n487_o;
  wire n488_o;
  wire n490_o;
  wire n491_o;
  wire n493_o;
  wire n494_o;
  wire n496_o;
  wire n497_o;
  wire n499_o;
  wire n500_o;
  wire n502_o;
  wire n503_o;
  wire n505_o;
  wire n506_o;
  wire n508_o;
  wire n509_o;
  wire n511_o;
  wire n512_o;
  wire [15:0] n514_o;
  wire n516_o;
  wire n518_o;
  wire n519_o;
  wire n521_o;
  wire n522_o;
  wire n524_o;
  wire n525_o;
  wire n527_o;
  wire n528_o;
  wire n530_o;
  wire n531_o;
  wire n533_o;
  wire n534_o;
  wire n536_o;
  wire n537_o;
  wire n539_o;
  wire n540_o;
  wire n542_o;
  wire n543_o;
  wire n545_o;
  wire n546_o;
  wire n548_o;
  wire n549_o;
  wire n551_o;
  wire n552_o;
  wire n554_o;
  wire n555_o;
  wire n557_o;
  wire n558_o;
  wire [15:0] n560_o;
  wire n562_o;
  wire n564_o;
  wire n565_o;
  wire n567_o;
  wire n568_o;
  wire n570_o;
  wire n571_o;
  wire n573_o;
  wire n574_o;
  wire n576_o;
  wire n577_o;
  wire n579_o;
  wire n580_o;
  wire n582_o;
  wire n583_o;
  wire n585_o;
  wire n586_o;
  wire n588_o;
  wire n589_o;
  wire n591_o;
  wire n592_o;
  wire n594_o;
  wire n595_o;
  wire [15:0] n597_o;
  wire n599_o;
  wire n600_o;
  wire n602_o;
  wire n605_o;
  wire [15:0] n607_o;
  wire n609_o;
  wire n610_o;
  wire n612_o;
  wire n615_o;
  wire [15:0] n617_o;
  wire n619_o;
  wire [7:0] n621_o;
  wire [7:0] n623_o;
  wire n624_o;
  wire n626_o;
  wire n629_o;
  wire n632_o;
  wire [15:0] n634_o;
  wire n636_o;
  wire [7:0] n637_o;
  wire [7:0] n638_o;
  wire [15:0] n640_o;
  wire n642_o;
  wire [7:0] n644_o;
  wire [7:0] n646_o;
  wire n647_o;
  wire n649_o;
  wire n652_o;
  wire [15:0] n654_o;
  wire n656_o;
  wire [6:0] n657_o;
  wire [7:0] n659_o;
  wire [6:0] n660_o;
  wire [7:0] n662_o;
  wire n663_o;
  wire n665_o;
  wire n668_o;
  wire [15:0] n670_o;
  wire n672_o;
  wire [6:0] n673_o;
  wire [7:0] n674_o;
  wire [6:0] n675_o;
  wire [7:0] n676_o;
  wire n677_o;
  wire n679_o;
  wire n682_o;
  wire [15:0] n684_o;
  wire n686_o;
  wire n687_o;
  wire [6:0] n688_o;
  wire [7:0] n689_o;
  wire n690_o;
  wire [6:0] n691_o;
  wire [7:0] n692_o;
  wire n693_o;
  wire n694_o;
  wire n696_o;
  wire n699_o;
  wire [15:0] n701_o;
  wire n703_o;
  wire [6:0] n704_o;
  wire [7:0] n706_o;
  wire [6:0] n707_o;
  wire [7:0] n709_o;
  wire n710_o;
  wire n711_o;
  wire n713_o;
  wire n716_o;
  wire [15:0] n718_o;
  wire n720_o;
  wire [6:0] n721_o;
  wire [7:0] n722_o;
  wire [6:0] n723_o;
  wire [7:0] n724_o;
  wire n725_o;
  wire n726_o;
  wire n728_o;
  wire n731_o;
  wire [15:0] n733_o;
  wire n735_o;
  wire [7:0] n737_o;
  wire [7:0] n739_o;
  wire n740_o;
  wire n742_o;
  wire n745_o;
  wire [15:0] n747_o;
  wire n749_o;
  wire [7:0] n751_o;
  wire [7:0] n753_o;
  wire n754_o;
  wire n756_o;
  wire n759_o;
  wire [15:0] n761_o;
  wire n763_o;
  wire n764_o;
  wire n766_o;
  wire n769_o;
  wire [15:0] n771_o;
  wire n773_o;
  wire [15:0] n775_o;
  wire n777_o;
  wire [7:0] n779_o;
  wire [7:0] n781_o;
  wire n782_o;
  wire n784_o;
  wire n787_o;
  wire n790_o;
  wire [15:0] n792_o;
  wire n794_o;
  wire [7:0] n796_o;
  wire [7:0] n798_o;
  wire n799_o;
  wire n801_o;
  wire n804_o;
  wire [15:0] n806_o;
  wire n808_o;
  wire [6:0] n809_o;
  wire [7:0] n811_o;
  wire [6:0] n812_o;
  wire [7:0] n814_o;
  wire n815_o;
  wire n817_o;
  wire n820_o;
  wire [15:0] n822_o;
  wire n824_o;
  wire [6:0] n825_o;
  wire [7:0] n826_o;
  wire [6:0] n827_o;
  wire [7:0] n828_o;
  wire n829_o;
  wire n831_o;
  wire n834_o;
  wire [15:0] n836_o;
  wire n838_o;
  wire n839_o;
  wire [6:0] n840_o;
  wire [7:0] n841_o;
  wire n842_o;
  wire [6:0] n843_o;
  wire [7:0] n844_o;
  wire n845_o;
  wire n846_o;
  wire n848_o;
  wire n851_o;
  wire [15:0] n853_o;
  wire n855_o;
  wire [6:0] n856_o;
  wire [7:0] n858_o;
  wire [6:0] n859_o;
  wire [7:0] n861_o;
  wire n862_o;
  wire n863_o;
  wire n865_o;
  wire n868_o;
  wire [15:0] n870_o;
  wire n872_o;
  wire [6:0] n873_o;
  wire [7:0] n874_o;
  wire [6:0] n875_o;
  wire [7:0] n876_o;
  wire n877_o;
  wire n878_o;
  wire n880_o;
  wire n883_o;
  wire [15:0] n885_o;
  wire n887_o;
  wire [7:0] n889_o;
  wire [7:0] n891_o;
  wire n892_o;
  wire n894_o;
  wire n897_o;
  wire [15:0] n899_o;
  wire n901_o;
  wire [7:0] n903_o;
  wire [7:0] n905_o;
  wire n906_o;
  wire n908_o;
  wire n911_o;
  wire [15:0] n913_o;
  wire n915_o;
  wire n916_o;
  wire n918_o;
  wire n921_o;
  wire [15:0] n923_o;
  wire n925_o;
  wire [15:0] n927_o;
  wire n929_o;
  wire [15:0] n931_o;
  wire [15:0] n933_o;
  wire n935_o;
  wire n937_o;
  wire n938_o;
  wire n940_o;
  wire n941_o;
  wire n943_o;
  wire n944_o;
  wire n946_o;
  wire n947_o;
  wire n949_o;
  wire n950_o;
  wire n952_o;
  wire n953_o;
  wire n955_o;
  wire n956_o;
  wire n958_o;
  wire n959_o;
  wire n961_o;
  wire n962_o;
  wire n964_o;
  wire n965_o;
  wire [15:0] n967_o;
  wire n969_o;
  wire [15:0] n971_o;
  wire n973_o;
  wire n975_o;
  wire n976_o;
  wire [15:0] n978_o;
  wire n980_o;
  wire [15:0] n982_o;
  wire n984_o;
  wire [15:0] n986_o;
  wire n988_o;
  wire [15:0] n990_o;
  wire n992_o;
  wire n993_o;
  wire [15:0] n995_o;
  wire n997_o;
  wire n999_o;
  wire n1000_o;
  wire n1001_o;
  wire [15:0] n1003_o;
  wire n1005_o;
  wire n1007_o;
  wire n1008_o;
  wire [15:0] n1010_o;
  wire n1012_o;
  wire [15:0] n1014_o;
  wire n1016_o;
  wire n1018_o;
  wire n1019_o;
  wire n1021_o;
  wire n1022_o;
  wire n1024_o;
  wire n1025_o;
  wire n1027_o;
  wire n1028_o;
  wire n1030_o;
  wire n1031_o;
  wire n1033_o;
  wire n1034_o;
  wire n1036_o;
  wire n1037_o;
  wire n1039_o;
  wire n1040_o;
  wire n1042_o;
  wire n1043_o;
  wire n1045_o;
  wire n1046_o;
  wire n1048_o;
  wire n1049_o;
  wire n1051_o;
  wire n1052_o;
  wire n1054_o;
  wire n1055_o;
  wire n1057_o;
  wire n1058_o;
  wire n1060_o;
  wire n1061_o;
  wire n1063_o;
  wire n1064_o;
  wire n1066_o;
  wire n1067_o;
  wire n1069_o;
  wire n1070_o;
  wire n1072_o;
  wire n1073_o;
  wire n1075_o;
  wire n1076_o;
  wire n1078_o;
  wire n1079_o;
  wire n1081_o;
  wire n1082_o;
  wire n1084_o;
  wire n1085_o;
  wire n1087_o;
  wire n1088_o;
  wire n1090_o;
  wire n1091_o;
  wire n1093_o;
  wire n1094_o;
  wire n1096_o;
  wire n1097_o;
  wire n1099_o;
  wire n1100_o;
  wire n1102_o;
  wire n1103_o;
  wire n1105_o;
  wire n1106_o;
  wire n1108_o;
  wire n1109_o;
  wire n1111_o;
  wire n1112_o;
  wire n1114_o;
  wire n1115_o;
  wire n1117_o;
  wire n1118_o;
  wire n1120_o;
  wire n1121_o;
  wire n1123_o;
  wire n1124_o;
  wire n1126_o;
  wire n1127_o;
  wire n1129_o;
  wire n1130_o;
  wire n1132_o;
  wire n1133_o;
  wire n1135_o;
  wire n1136_o;
  wire n1138_o;
  wire n1139_o;
  wire n1141_o;
  wire n1142_o;
  wire [15:0] n1144_o;
  wire n1146_o;
  wire [15:0] n1148_o;
  wire [15:0] n1150_o;
  wire n1152_o;
  wire n1154_o;
  wire n1155_o;
  wire n1157_o;
  wire n1158_o;
  wire [15:0] n1160_o;
  wire [15:0] n1162_o;
  wire n1164_o;
  wire n1166_o;
  wire n1167_o;
  wire [15:0] n1169_o;
  wire [15:0] n1171_o;
  wire n1173_o;
  wire [47:0] n1174_o;
  reg n1179_o;
  reg [7:0] n1181_o;
  reg [7:0] n1183_o;
  reg [15:0] n1185_o;
  reg [15:0] n1186_o;
  reg n1188_o;
  reg n1189_o;
  reg n1195_o;
  reg n1199_o;
  reg n1203_o;
  reg [7:0] n1205_o;
  reg [15:0] n1207_o;
  reg [3:0] n1257_o;
  reg [2:0] n1267_o;
  reg [3:0] n1272_o;
  reg n1274_o;
  wire n1276_o;
  wire [7:0] n1277_o;
  wire [7:0] n1278_o;
  wire [15:0] n1279_o;
  wire [15:0] n1280_o;
  wire n1281_o;
  wire n1282_o;
  wire n1283_o;
  wire n1284_o;
  wire n1285_o;
  wire [7:0] n1286_o;
  wire [15:0] n1287_o;
  wire [3:0] n1289_o;
  wire [2:0] n1291_o;
  wire [3:0] n1292_o;
  wire [7:0] n1294_o;
  wire n1295_o;
  wire n1297_o;
  wire [7:0] n1298_o;
  wire [7:0] n1299_o;
  wire [15:0] n1300_o;
  wire [15:0] n1301_o;
  wire n1302_o;
  wire n1303_o;
  wire n1304_o;
  wire n1305_o;
  wire n1306_o;
  wire [7:0] n1307_o;
  wire [15:0] n1308_o;
  wire [3:0] n1310_o;
  wire [2:0] n1312_o;
  wire [3:0] n1313_o;
  wire [7:0] n1315_o;
  wire n1316_o;
  wire [7:0] n1317_o;
  wire n1320_o;
  wire [15:0] n1322_o;
  wire n1324_o;
  wire n1326_o;
  wire n1327_o;
  wire n1329_o;
  wire n1330_o;
  wire n1332_o;
  wire n1333_o;
  wire n1335_o;
  wire n1336_o;
  wire n1338_o;
  wire n1339_o;
  wire n1341_o;
  wire n1342_o;
  wire n1344_o;
  wire n1345_o;
  wire n1347_o;
  wire n1348_o;
  wire n1350_o;
  wire n1351_o;
  wire n1353_o;
  wire n1354_o;
  wire n1356_o;
  wire n1357_o;
  wire n1359_o;
  wire n1360_o;
  wire n1362_o;
  wire n1363_o;
  wire n1365_o;
  wire n1366_o;
  wire n1368_o;
  wire n1369_o;
  wire n1371_o;
  wire n1372_o;
  wire n1374_o;
  wire n1375_o;
  wire n1377_o;
  wire n1378_o;
  wire n1380_o;
  wire n1381_o;
  wire n1383_o;
  wire n1384_o;
  wire n1386_o;
  wire n1387_o;
  wire n1389_o;
  wire n1390_o;
  wire n1392_o;
  wire n1393_o;
  wire n1395_o;
  wire n1396_o;
  wire n1398_o;
  wire n1399_o;
  wire n1401_o;
  wire n1402_o;
  wire n1404_o;
  wire n1405_o;
  wire n1407_o;
  wire n1408_o;
  wire n1410_o;
  wire n1411_o;
  wire n1413_o;
  wire n1414_o;
  wire n1416_o;
  wire n1417_o;
  wire n1419_o;
  wire n1420_o;
  wire n1422_o;
  wire n1423_o;
  wire n1425_o;
  wire n1426_o;
  wire n1428_o;
  wire n1429_o;
  wire n1431_o;
  wire n1432_o;
  wire n1434_o;
  wire n1435_o;
  wire n1437_o;
  wire n1438_o;
  wire n1440_o;
  wire n1441_o;
  wire n1443_o;
  wire n1444_o;
  wire n1446_o;
  wire n1447_o;
  wire [15:0] n1449_o;
  wire n1451_o;
  wire n1453_o;
  wire n1454_o;
  wire n1456_o;
  wire n1457_o;
  wire n1459_o;
  wire n1460_o;
  wire n1462_o;
  wire n1463_o;
  wire n1465_o;
  wire n1466_o;
  wire n1468_o;
  wire n1469_o;
  wire n1471_o;
  wire n1472_o;
  wire n1474_o;
  wire n1475_o;
  wire n1477_o;
  wire n1478_o;
  wire n1480_o;
  wire n1481_o;
  wire n1483_o;
  wire n1484_o;
  wire n1486_o;
  wire n1487_o;
  wire n1489_o;
  wire n1490_o;
  wire n1492_o;
  wire n1493_o;
  wire n1495_o;
  wire n1496_o;
  wire n1498_o;
  wire n1499_o;
  wire n1501_o;
  wire n1502_o;
  wire n1504_o;
  wire n1505_o;
  wire n1507_o;
  wire n1508_o;
  wire n1510_o;
  wire n1511_o;
  wire n1513_o;
  wire n1514_o;
  wire n1516_o;
  wire n1517_o;
  wire n1519_o;
  wire n1520_o;
  wire n1522_o;
  wire n1523_o;
  wire n1525_o;
  wire n1526_o;
  wire n1528_o;
  wire n1529_o;
  wire n1531_o;
  wire n1532_o;
  wire n1534_o;
  wire n1535_o;
  wire n1537_o;
  wire n1538_o;
  wire [15:0] n1540_o;
  wire n1542_o;
  wire [15:0] n1544_o;
  wire n1546_o;
  wire [15:0] n1548_o;
  wire n1550_o;
  wire n1552_o;
  wire n1553_o;
  wire n1555_o;
  wire n1556_o;
  wire n1558_o;
  wire n1559_o;
  wire n1561_o;
  wire n1562_o;
  wire n1564_o;
  wire n1565_o;
  wire n1567_o;
  wire n1568_o;
  wire n1570_o;
  wire n1571_o;
  wire n1573_o;
  wire n1574_o;
  wire n1576_o;
  wire n1577_o;
  wire n1579_o;
  wire n1580_o;
  wire n1582_o;
  wire n1583_o;
  wire n1584_o;
  wire n1585_o;
  wire [15:0] n1587_o;
  wire [15:0] n1588_o;
  wire [15:0] n1590_o;
  wire [15:0] n1592_o;
  wire [15:0] n1593_o;
  wire [15:0] n1595_o;
  wire [15:0] n1596_o;
  wire n1598_o;
  wire [15:0] n1600_o;
  wire n1602_o;
  wire n1603_o;
  wire n1604_o;
  wire n1605_o;
  wire n1606_o;
  wire n1607_o;
  wire [15:0] n1609_o;
  wire [15:0] n1610_o;
  wire [15:0] n1612_o;
  wire [15:0] n1614_o;
  wire [15:0] n1615_o;
  wire [15:0] n1617_o;
  wire [15:0] n1618_o;
  wire [15:0] n1620_o;
  wire [15:0] n1621_o;
  wire n1623_o;
  wire n1625_o;
  wire n1626_o;
  wire n1627_o;
  wire n1628_o;
  wire n1629_o;
  wire n1630_o;
  wire [15:0] n1632_o;
  wire [15:0] n1633_o;
  wire [15:0] n1635_o;
  wire [15:0] n1637_o;
  wire [15:0] n1638_o;
  wire [15:0] n1640_o;
  wire [15:0] n1641_o;
  wire [15:0] n1643_o;
  wire [15:0] n1644_o;
  wire n1646_o;
  wire n1648_o;
  wire n1649_o;
  wire n1650_o;
  wire n1651_o;
  wire n1652_o;
  wire n1653_o;
  wire [15:0] n1655_o;
  wire [15:0] n1656_o;
  wire [15:0] n1658_o;
  wire [15:0] n1660_o;
  wire [15:0] n1661_o;
  wire [15:0] n1663_o;
  wire [15:0] n1664_o;
  wire [15:0] n1666_o;
  wire [15:0] n1667_o;
  wire n1669_o;
  wire n1671_o;
  wire n1672_o;
  wire n1673_o;
  wire n1674_o;
  wire n1675_o;
  wire n1676_o;
  wire [15:0] n1678_o;
  wire [15:0] n1679_o;
  wire [15:0] n1681_o;
  wire [15:0] n1683_o;
  wire [15:0] n1684_o;
  wire [15:0] n1686_o;
  wire [15:0] n1687_o;
  wire [15:0] n1689_o;
  wire [15:0] n1690_o;
  wire n1692_o;
  wire n1694_o;
  wire n1695_o;
  wire n1696_o;
  wire n1697_o;
  wire n1698_o;
  wire n1699_o;
  wire [15:0] n1701_o;
  wire [15:0] n1702_o;
  wire [15:0] n1704_o;
  wire [15:0] n1706_o;
  wire [15:0] n1707_o;
  wire [15:0] n1709_o;
  wire [15:0] n1710_o;
  wire [15:0] n1712_o;
  wire [15:0] n1713_o;
  wire n1715_o;
  wire n1717_o;
  wire n1718_o;
  wire n1719_o;
  wire n1720_o;
  wire n1721_o;
  wire n1722_o;
  wire [15:0] n1724_o;
  wire [15:0] n1725_o;
  wire [15:0] n1727_o;
  wire [15:0] n1729_o;
  wire [15:0] n1730_o;
  wire [15:0] n1732_o;
  wire [15:0] n1733_o;
  wire [15:0] n1735_o;
  wire [15:0] n1736_o;
  wire n1738_o;
  wire n1740_o;
  wire n1741_o;
  wire n1742_o;
  wire n1743_o;
  wire n1744_o;
  wire n1745_o;
  wire [15:0] n1747_o;
  wire [15:0] n1748_o;
  wire [15:0] n1750_o;
  wire [15:0] n1752_o;
  wire [15:0] n1753_o;
  wire [15:0] n1755_o;
  wire [15:0] n1756_o;
  wire [15:0] n1758_o;
  wire [15:0] n1759_o;
  wire n1761_o;
  wire n1763_o;
  wire n1764_o;
  wire n1766_o;
  wire [15:0] n1768_o;
  wire [15:0] n1769_o;
  wire n1771_o;
  wire [1:0] n1772_o;
  wire [7:0] n1773_o;
  reg [7:0] n1775_o;
  wire [7:0] n1776_o;
  wire [7:0] n1778_o;
  reg [7:0] n1779_o;
  wire [15:0] n1781_o;
  wire n1783_o;
  wire n1785_o;
  wire n1786_o;
  wire [15:0] n1788_o;
  wire [15:0] n1789_o;
  wire [15:0] n1791_o;
  wire n1793_o;
  wire n1795_o;
  wire n1796_o;
  wire n1798_o;
  wire n1799_o;
  wire n1801_o;
  wire n1802_o;
  wire n1804_o;
  wire n1805_o;
  wire n1807_o;
  wire n1808_o;
  wire n1810_o;
  wire n1811_o;
  wire n1813_o;
  wire n1814_o;
  wire n1816_o;
  wire n1817_o;
  wire n1819_o;
  wire n1820_o;
  wire n1822_o;
  wire n1823_o;
  wire n1824_o;
  wire n1825_o;
  wire n1826_o;
  wire n1827_o;
  wire [15:0] n1829_o;
  wire n1831_o;
  wire n1833_o;
  wire n1834_o;
  wire [15:0] n1836_o;
  wire n1838_o;
  wire n1840_o;
  wire [15:0] n1842_o;
  wire n1844_o;
  wire n1846_o;
  wire n1847_o;
  wire n1849_o;
  wire n1850_o;
  wire [15:0] n1852_o;
  wire n1854_o;
  wire [15:0] n1856_o;
  wire n1858_o;
  wire n1860_o;
  wire n1861_o;
  wire [22:0] n1862_o;
  reg n1869_o;
  reg [15:0] n1870_o;
  wire [7:0] n1871_o;
  wire [7:0] n1872_o;
  wire [7:0] n1873_o;
  wire [7:0] n1874_o;
  wire [7:0] n1875_o;
  wire [7:0] n1876_o;
  wire [7:0] n1877_o;
  wire [7:0] n1878_o;
  wire [7:0] n1879_o;
  wire [7:0] n1880_o;
  wire [7:0] n1881_o;
  wire [7:0] n1882_o;
  wire [7:0] n1883_o;
  wire [7:0] n1884_o;
  wire [7:0] n1885_o;
  wire [7:0] n1886_o;
  wire [7:0] n1887_o;
  wire [7:0] n1888_o;
  wire [7:0] n1889_o;
  wire [7:0] n1890_o;
  reg [7:0] n1891_o;
  wire [7:0] n1892_o;
  wire [7:0] n1893_o;
  wire [7:0] n1894_o;
  wire [7:0] n1895_o;
  wire [7:0] n1896_o;
  wire [7:0] n1897_o;
  wire [7:0] n1898_o;
  wire [7:0] n1899_o;
  wire [7:0] n1900_o;
  wire [7:0] n1901_o;
  wire [7:0] n1902_o;
  wire [7:0] n1903_o;
  wire [7:0] n1904_o;
  wire [7:0] n1905_o;
  wire [7:0] n1906_o;
  wire [7:0] n1907_o;
  wire [7:0] n1908_o;
  wire [7:0] n1909_o;
  wire [7:0] n1910_o;
  wire [7:0] n1911_o;
  reg [7:0] n1912_o;
  reg n1913_o;
  reg n1914_o;
  reg n1916_o;
  reg n1918_o;
  reg n1919_o;
  reg [7:0] n1921_o;
  wire [7:0] n1922_o;
  wire [7:0] n1923_o;
  reg [7:0] n1924_o;
  wire [7:0] n1925_o;
  wire [7:0] n1926_o;
  reg [7:0] n1927_o;
  reg [3:0] n1952_o;
  reg [2:0] n1961_o;
  reg [3:0] n1967_o;
  wire n1969_o;
  wire [2:0] n1970_o;
  wire [2:0] n1973_o;
  wire [7:0] n1976_o;
  wire n1978_o;
  wire n1981_o;
  wire n1983_o;
  wire n1985_o;
  wire n1986_o;
  wire n1988_o;
  wire n1989_o;
  wire n1991_o;
  wire n1992_o;
  wire n1994_o;
  wire n1995_o;
  wire n1997_o;
  wire n1998_o;
  wire n2000_o;
  wire n2001_o;
  wire n2003_o;
  wire n2004_o;
  wire n2006_o;
  wire n2007_o;
  wire n2009_o;
  wire n2010_o;
  wire n2012_o;
  wire n2013_o;
  wire n2015_o;
  wire n2016_o;
  wire n2018_o;
  wire n2019_o;
  wire n2021_o;
  wire n2022_o;
  wire n2024_o;
  wire n2025_o;
  wire n2027_o;
  wire n2028_o;
  wire n2029_o;
  wire n2030_o;
  wire [2:0] n2031_o;
  wire [2:0] n2034_o;
  wire [7:0] n2037_o;
  wire [2:0] n2038_o;
  wire [2:0] n2041_o;
  wire [7:0] n2044_o;
  wire [7:0] n2045_o;
  wire n2047_o;
  wire n2049_o;
  wire n2050_o;
  wire n2052_o;
  wire n2053_o;
  wire n2055_o;
  wire n2056_o;
  wire n2058_o;
  wire n2059_o;
  wire n2061_o;
  wire n2062_o;
  wire n2064_o;
  wire n2065_o;
  wire n2067_o;
  wire n2068_o;
  wire n2070_o;
  wire n2071_o;
  wire n2073_o;
  wire n2074_o;
  wire n2076_o;
  wire n2077_o;
  wire n2079_o;
  wire n2080_o;
  wire n2082_o;
  wire n2083_o;
  wire n2085_o;
  wire n2086_o;
  wire n2088_o;
  wire n2089_o;
  wire n2091_o;
  wire n2092_o;
  wire [3:0] n2093_o;
  wire n2095_o;
  wire n2097_o;
  wire n2099_o;
  wire [2:0] n2100_o;
  reg [2:0] n2104_o;
  wire [15:0] n2106_o;
  wire n2108_o;
  wire n2110_o;
  wire n2111_o;
  wire n2113_o;
  wire n2114_o;
  wire n2116_o;
  wire n2117_o;
  wire n2119_o;
  wire n2120_o;
  wire n2122_o;
  wire n2123_o;
  wire n2125_o;
  wire n2126_o;
  wire n2128_o;
  wire n2129_o;
  wire n2131_o;
  wire n2132_o;
  wire n2134_o;
  wire n2135_o;
  wire n2137_o;
  wire n2138_o;
  wire n2140_o;
  wire n2141_o;
  wire n2143_o;
  wire n2144_o;
  wire n2146_o;
  wire n2147_o;
  wire n2149_o;
  wire n2150_o;
  wire n2152_o;
  wire n2153_o;
  wire n2155_o;
  wire n2156_o;
  wire n2158_o;
  wire n2159_o;
  wire n2161_o;
  wire n2162_o;
  wire n2164_o;
  wire n2165_o;
  wire n2167_o;
  wire n2168_o;
  wire n2170_o;
  wire n2171_o;
  wire n2173_o;
  wire n2174_o;
  wire n2176_o;
  wire n2177_o;
  wire n2179_o;
  wire n2180_o;
  wire n2182_o;
  wire n2183_o;
  wire n2185_o;
  wire n2186_o;
  wire n2188_o;
  wire n2189_o;
  wire n2191_o;
  wire n2192_o;
  wire n2194_o;
  wire n2195_o;
  wire n2197_o;
  wire n2198_o;
  wire n2200_o;
  wire n2201_o;
  wire n2203_o;
  wire n2204_o;
  wire n2206_o;
  wire n2207_o;
  wire n2209_o;
  wire n2210_o;
  wire n2212_o;
  wire n2213_o;
  wire [7:0] n2214_o;
  wire [15:0] n2215_o;
  wire n2217_o;
  wire [7:0] n2218_o;
  wire [15:0] n2219_o;
  wire [15:0] n2221_o;
  wire [15:0] n2222_o;
  wire n2224_o;
  wire [15:0] n2226_o;
  wire [15:0] n2228_o;
  wire [15:0] n2229_o;
  wire n2231_o;
  wire n2232_o;
  wire n2234_o;
  wire n2237_o;
  wire [15:0] n2239_o;
  wire n2241_o;
  wire n2242_o;
  wire n2244_o;
  wire n2247_o;
  wire [15:0] n2249_o;
  wire n2251_o;
  wire n2252_o;
  wire n2254_o;
  wire n2257_o;
  wire [15:0] n2259_o;
  wire n2261_o;
  wire n2262_o;
  wire n2264_o;
  wire n2267_o;
  wire [15:0] n2269_o;
  wire n2271_o;
  wire n2272_o;
  wire n2274_o;
  wire n2277_o;
  wire [15:0] n2279_o;
  wire n2281_o;
  wire n2282_o;
  wire n2284_o;
  wire n2287_o;
  wire [15:0] n2289_o;
  wire n2291_o;
  wire [7:0] n2293_o;
  wire [7:0] n2295_o;
  wire n2296_o;
  wire n2298_o;
  wire n2301_o;
  wire n2304_o;
  wire n2306_o;
  wire n2308_o;
  wire n2309_o;
  wire n2311_o;
  wire n2312_o;
  wire [7:0] n2314_o;
  wire [7:0] n2316_o;
  wire n2317_o;
  wire n2319_o;
  wire n2322_o;
  wire n2324_o;
  wire n2326_o;
  wire n2327_o;
  wire n2329_o;
  wire n2330_o;
  wire [6:0] n2331_o;
  wire [7:0] n2333_o;
  wire [6:0] n2334_o;
  wire [7:0] n2336_o;
  wire n2337_o;
  wire n2339_o;
  wire n2342_o;
  wire n2344_o;
  wire n2346_o;
  wire n2347_o;
  wire n2349_o;
  wire n2350_o;
  wire [6:0] n2351_o;
  wire [7:0] n2352_o;
  wire [6:0] n2353_o;
  wire [7:0] n2354_o;
  wire n2355_o;
  wire n2357_o;
  wire n2360_o;
  wire n2362_o;
  wire n2364_o;
  wire n2365_o;
  wire n2367_o;
  wire n2368_o;
  wire n2369_o;
  wire [6:0] n2370_o;
  wire [7:0] n2371_o;
  wire n2372_o;
  wire [6:0] n2373_o;
  wire [7:0] n2374_o;
  wire n2375_o;
  wire n2376_o;
  wire n2378_o;
  wire n2381_o;
  wire n2383_o;
  wire n2385_o;
  wire n2386_o;
  wire n2388_o;
  wire n2389_o;
  wire [6:0] n2390_o;
  wire [7:0] n2392_o;
  wire [6:0] n2393_o;
  wire [7:0] n2395_o;
  wire n2396_o;
  wire n2397_o;
  wire n2399_o;
  wire n2402_o;
  wire n2404_o;
  wire n2406_o;
  wire n2407_o;
  wire n2409_o;
  wire n2410_o;
  wire [6:0] n2411_o;
  wire [7:0] n2412_o;
  wire [6:0] n2413_o;
  wire [7:0] n2414_o;
  wire n2415_o;
  wire n2416_o;
  wire n2418_o;
  wire n2421_o;
  wire n2423_o;
  wire n2425_o;
  wire n2426_o;
  wire n2428_o;
  wire n2429_o;
  wire [7:0] n2431_o;
  wire [7:0] n2433_o;
  wire n2434_o;
  wire n2436_o;
  wire n2439_o;
  wire n2441_o;
  wire n2443_o;
  wire n2444_o;
  wire n2446_o;
  wire n2447_o;
  wire [7:0] n2449_o;
  wire [7:0] n2451_o;
  wire n2452_o;
  wire n2454_o;
  wire n2457_o;
  wire n2459_o;
  wire n2461_o;
  wire n2462_o;
  wire n2464_o;
  wire n2465_o;
  wire n2466_o;
  wire n2468_o;
  wire n2471_o;
  wire n2473_o;
  wire n2475_o;
  wire n2476_o;
  wire n2478_o;
  wire n2479_o;
  wire n2481_o;
  wire n2483_o;
  wire n2484_o;
  wire [15:0] n2486_o;
  wire n2488_o;
  wire n2490_o;
  wire n2491_o;
  wire n2493_o;
  wire [15:0] n2495_o;
  wire n2497_o;
  wire [15:0] n2499_o;
  wire n2501_o;
  wire n2503_o;
  wire n2504_o;
  wire n2506_o;
  wire n2507_o;
  wire [15:0] n2509_o;
  wire n2511_o;
  wire [15:0] n2513_o;
  wire n2515_o;
  wire n2517_o;
  wire n2518_o;
  wire [28:0] n2519_o;
  reg n2538_o;
  reg [7:0] n2539_o;
  reg [15:0] n2540_o;
  wire [7:0] n2541_o;
  wire [7:0] n2542_o;
  wire [7:0] n2543_o;
  wire [7:0] n2544_o;
  wire [7:0] n2545_o;
  wire [7:0] n2546_o;
  wire [7:0] n2547_o;
  wire [7:0] n2548_o;
  wire [7:0] n2549_o;
  wire [7:0] n2550_o;
  wire [7:0] n2551_o;
  wire [7:0] n2552_o;
  reg [7:0] n2553_o;
  wire [7:0] n2554_o;
  wire [7:0] n2555_o;
  wire [7:0] n2556_o;
  wire [7:0] n2557_o;
  wire [7:0] n2558_o;
  wire [7:0] n2559_o;
  wire [7:0] n2560_o;
  wire [7:0] n2561_o;
  wire [7:0] n2562_o;
  wire [7:0] n2563_o;
  wire [7:0] n2564_o;
  wire [7:0] n2565_o;
  reg [7:0] n2566_o;
  reg n2568_o;
  reg n2569_o;
  reg n2571_o;
  reg [7:0] n2572_o;
  wire [7:0] n2573_o;
  reg [7:0] n2574_o;
  reg [3:0] n2605_o;
  reg [2:0] n2617_o;
  reg [3:0] n2638_o;
  wire n2641_o;
  wire n2642_o;
  wire n2643_o;
  wire n2644_o;
  wire n2645_o;
  wire [15:0] n2647_o;
  wire [15:0] n2648_o;
  wire [15:0] n2650_o;
  wire [15:0] n2652_o;
  wire [15:0] n2653_o;
  wire [15:0] n2655_o;
  wire [15:0] n2656_o;
  wire [15:0] n2658_o;
  wire [15:0] n2659_o;
  wire n2661_o;
  wire n2663_o;
  wire n2664_o;
  wire n2666_o;
  wire n2667_o;
  wire n2669_o;
  wire n2670_o;
  wire n2672_o;
  wire n2673_o;
  wire n2675_o;
  wire n2676_o;
  wire n2678_o;
  wire n2679_o;
  wire n2681_o;
  wire n2682_o;
  wire n2684_o;
  wire n2685_o;
  wire n2687_o;
  wire n2688_o;
  wire n2690_o;
  wire n2691_o;
  wire n2693_o;
  wire n2694_o;
  wire n2696_o;
  wire n2697_o;
  wire n2699_o;
  wire n2700_o;
  wire n2702_o;
  wire n2703_o;
  wire n2705_o;
  wire n2706_o;
  wire n2708_o;
  wire n2710_o;
  wire n2711_o;
  wire n2713_o;
  wire n2714_o;
  wire n2716_o;
  wire n2717_o;
  wire n2719_o;
  wire n2720_o;
  wire n2722_o;
  wire n2723_o;
  wire n2725_o;
  wire n2726_o;
  wire n2728_o;
  wire n2729_o;
  wire n2731_o;
  wire n2732_o;
  wire n2734_o;
  wire n2735_o;
  wire n2737_o;
  wire n2738_o;
  wire n2740_o;
  wire n2741_o;
  wire n2743_o;
  wire n2744_o;
  wire n2746_o;
  wire n2747_o;
  wire n2749_o;
  wire n2750_o;
  wire n2752_o;
  wire n2753_o;
  wire n2755_o;
  wire n2756_o;
  wire n2758_o;
  wire n2759_o;
  wire n2761_o;
  wire n2762_o;
  wire n2764_o;
  wire n2765_o;
  wire n2767_o;
  wire n2768_o;
  wire n2770_o;
  wire n2771_o;
  wire n2773_o;
  wire n2774_o;
  wire n2776_o;
  wire n2777_o;
  wire n2779_o;
  wire n2780_o;
  wire n2782_o;
  wire n2783_o;
  wire n2785_o;
  wire n2786_o;
  wire n2788_o;
  wire n2789_o;
  wire n2791_o;
  wire n2792_o;
  wire n2794_o;
  wire n2795_o;
  wire n2797_o;
  wire n2798_o;
  wire n2800_o;
  wire n2801_o;
  wire n2803_o;
  wire n2804_o;
  wire n2806_o;
  wire n2807_o;
  wire n2809_o;
  wire n2810_o;
  wire n2812_o;
  wire n2813_o;
  wire n2815_o;
  wire n2816_o;
  wire n2818_o;
  wire n2819_o;
  wire n2821_o;
  wire n2822_o;
  wire n2824_o;
  wire n2825_o;
  wire n2827_o;
  wire n2828_o;
  wire n2830_o;
  wire n2831_o;
  wire n2833_o;
  wire n2834_o;
  wire n2836_o;
  wire n2837_o;
  wire n2839_o;
  wire n2840_o;
  wire n2842_o;
  wire n2843_o;
  wire n2845_o;
  wire n2846_o;
  wire n2848_o;
  wire n2849_o;
  wire n2851_o;
  wire n2852_o;
  wire n2854_o;
  wire n2855_o;
  wire n2857_o;
  wire n2858_o;
  wire n2860_o;
  wire n2861_o;
  wire n2863_o;
  wire n2864_o;
  wire [15:0] n2866_o;
  wire n2868_o;
  wire n2870_o;
  wire n2871_o;
  wire [15:0] n2873_o;
  wire n2878_o;
  wire [7:0] n2879_o;
  wire [7:0] n2880_o;
  wire n2881_o;
  wire n2883_o;
  wire n2886_o;
  wire n2887_o;
  wire n2888_o;
  wire n2889_o;
  wire n2890_o;
  wire n2891_o;
  wire n2892_o;
  wire n2893_o;
  wire n2894_o;
  wire n2895_o;
  wire n2896_o;
  wire n2897_o;
  wire n2898_o;
  wire n2899_o;
  wire n2901_o;
  wire [15:0] n2903_o;
  wire [15:0] n2904_o;
  wire n2906_o;
  wire n2908_o;
  wire n2909_o;
  wire n2911_o;
  wire n2912_o;
  wire n2914_o;
  wire n2915_o;
  wire n2917_o;
  wire n2918_o;
  wire n2920_o;
  wire n2921_o;
  wire [7:0] n2922_o;
  wire n2923_o;
  wire n2925_o;
  wire n2928_o;
  wire n2929_o;
  wire n2930_o;
  wire n2931_o;
  wire n2932_o;
  wire n2933_o;
  wire n2934_o;
  wire n2935_o;
  wire n2936_o;
  wire n2937_o;
  wire n2938_o;
  wire n2939_o;
  wire n2940_o;
  wire n2941_o;
  wire n2943_o;
  wire [15:0] n2945_o;
  wire [15:0] n2946_o;
  wire n2948_o;
  wire n2950_o;
  wire n2951_o;
  wire n2953_o;
  wire n2954_o;
  wire n2956_o;
  wire n2957_o;
  wire n2959_o;
  wire n2960_o;
  wire n2962_o;
  wire n2963_o;
  wire [7:0] n2964_o;
  wire [7:0] n2966_o;
  wire [7:0] n2967_o;
  wire [7:0] n2968_o;
  wire [7:0] n2970_o;
  wire [7:0] n2971_o;
  wire n2972_o;
  wire n2974_o;
  wire n2977_o;
  wire n2978_o;
  wire n2979_o;
  wire n2980_o;
  wire n2981_o;
  wire n2982_o;
  wire n2983_o;
  wire n2984_o;
  wire n2985_o;
  wire n2986_o;
  wire n2987_o;
  wire n2988_o;
  wire n2989_o;
  wire n2990_o;
  wire n2992_o;
  wire [15:0] n2994_o;
  wire [15:0] n2995_o;
  wire n2997_o;
  wire n2999_o;
  wire n3000_o;
  wire n3002_o;
  wire n3003_o;
  wire n3005_o;
  wire n3006_o;
  wire n3008_o;
  wire n3009_o;
  wire n3011_o;
  wire n3012_o;
  wire [7:0] n3013_o;
  wire n3014_o;
  wire n3016_o;
  wire n3019_o;
  wire n3020_o;
  wire n3021_o;
  wire n3022_o;
  wire n3023_o;
  wire n3024_o;
  wire n3025_o;
  wire n3026_o;
  wire n3027_o;
  wire n3028_o;
  wire n3029_o;
  wire n3030_o;
  wire n3031_o;
  wire n3032_o;
  wire n3034_o;
  wire [15:0] n3036_o;
  wire [15:0] n3037_o;
  wire n3039_o;
  wire n3041_o;
  wire n3042_o;
  wire n3044_o;
  wire n3045_o;
  wire n3047_o;
  wire n3048_o;
  wire n3050_o;
  wire n3051_o;
  wire n3053_o;
  wire n3054_o;
  wire [7:0] n3055_o;
  wire [7:0] n3056_o;
  wire n3057_o;
  wire n3059_o;
  wire n3062_o;
  wire n3064_o;
  wire [15:0] n3066_o;
  wire [15:0] n3067_o;
  wire n3069_o;
  wire n3071_o;
  wire n3072_o;
  wire n3074_o;
  wire n3075_o;
  wire n3077_o;
  wire n3078_o;
  wire n3080_o;
  wire n3081_o;
  wire n3083_o;
  wire n3084_o;
  wire [7:0] n3085_o;
  wire n3086_o;
  wire n3088_o;
  wire n3091_o;
  wire n3093_o;
  wire [15:0] n3095_o;
  wire [15:0] n3096_o;
  wire n3098_o;
  wire n3100_o;
  wire n3101_o;
  wire n3103_o;
  wire n3104_o;
  wire n3106_o;
  wire n3107_o;
  wire n3109_o;
  wire n3110_o;
  wire n3112_o;
  wire n3113_o;
  wire n3114_o;
  wire n3116_o;
  wire n3119_o;
  wire n3121_o;
  wire [15:0] n3123_o;
  wire [15:0] n3124_o;
  wire n3126_o;
  wire n3128_o;
  wire n3129_o;
  wire n3131_o;
  wire n3132_o;
  wire n3134_o;
  wire n3135_o;
  wire n3137_o;
  wire n3138_o;
  wire n3140_o;
  wire n3141_o;
  wire [7:0] n3142_o;
  wire [7:0] n3143_o;
  wire n3144_o;
  wire n3146_o;
  wire n3149_o;
  wire n3151_o;
  wire [15:0] n3153_o;
  wire [15:0] n3154_o;
  wire n3156_o;
  wire n3158_o;
  wire n3159_o;
  wire n3161_o;
  wire n3162_o;
  wire n3164_o;
  wire n3165_o;
  wire n3167_o;
  wire n3168_o;
  wire n3170_o;
  wire n3171_o;
  wire [7:0] n3172_o;
  wire [7:0] n3174_o;
  wire [7:0] n3175_o;
  wire [7:0] n3176_o;
  wire [7:0] n3178_o;
  wire [7:0] n3179_o;
  wire n3180_o;
  wire n3182_o;
  wire n3185_o;
  wire n3186_o;
  wire n3187_o;
  wire n3188_o;
  wire n3189_o;
  wire n3190_o;
  wire n3191_o;
  wire n3192_o;
  wire n3193_o;
  wire n3194_o;
  wire n3195_o;
  wire n3196_o;
  wire n3197_o;
  wire n3198_o;
  wire n3199_o;
  wire n3200_o;
  wire n3201_o;
  wire n3202_o;
  wire n3203_o;
  wire n3204_o;
  wire n3205_o;
  wire n3206_o;
  wire n3207_o;
  wire n3208_o;
  wire n3209_o;
  wire n3210_o;
  wire n3211_o;
  wire n3213_o;
  wire [15:0] n3215_o;
  wire [15:0] n3216_o;
  wire n3218_o;
  wire n3220_o;
  wire n3221_o;
  wire n3223_o;
  wire n3224_o;
  wire n3226_o;
  wire n3227_o;
  wire n3229_o;
  wire n3230_o;
  wire n3232_o;
  wire n3233_o;
  wire [7:0] n3234_o;
  wire [7:0] n3235_o;
  wire n3236_o;
  wire n3238_o;
  wire n3241_o;
  wire n3243_o;
  wire [15:0] n3245_o;
  wire [15:0] n3246_o;
  wire n3248_o;
  wire n3250_o;
  wire n3251_o;
  wire n3253_o;
  wire n3254_o;
  wire n3256_o;
  wire n3257_o;
  wire n3259_o;
  wire n3260_o;
  wire n3262_o;
  wire n3263_o;
  wire [7:0] n3264_o;
  wire [7:0] n3265_o;
  wire n3266_o;
  wire n3268_o;
  wire n3271_o;
  wire n3272_o;
  wire n3273_o;
  wire n3274_o;
  wire n3275_o;
  wire n3276_o;
  wire n3277_o;
  wire n3278_o;
  wire n3279_o;
  wire n3280_o;
  wire n3281_o;
  wire n3282_o;
  wire n3283_o;
  wire n3284_o;
  wire n3285_o;
  wire n3286_o;
  wire n3287_o;
  wire n3288_o;
  wire n3289_o;
  wire n3290_o;
  wire n3291_o;
  wire n3292_o;
  wire n3293_o;
  wire n3294_o;
  wire n3295_o;
  wire n3296_o;
  wire n3297_o;
  wire n3299_o;
  wire [15:0] n3301_o;
  wire [15:0] n3302_o;
  wire n3304_o;
  wire n3306_o;
  wire n3307_o;
  wire n3309_o;
  wire n3310_o;
  wire n3312_o;
  wire n3313_o;
  wire n3315_o;
  wire n3316_o;
  wire n3318_o;
  wire n3319_o;
  wire n3320_o;
  wire n3322_o;
  wire n3325_o;
  wire n3327_o;
  wire [15:0] n3329_o;
  wire [15:0] n3330_o;
  wire n3332_o;
  wire n3334_o;
  wire n3335_o;
  wire n3337_o;
  wire n3338_o;
  wire n3340_o;
  wire n3341_o;
  wire n3343_o;
  wire n3344_o;
  wire n3346_o;
  wire n3347_o;
  wire n3348_o;
  wire n3349_o;
  wire [15:0] n3351_o;
  wire [15:0] n3352_o;
  wire [15:0] n3354_o;
  wire [15:0] n3355_o;
  wire [15:0] n3356_o;
  wire [15:0] n3358_o;
  wire n3360_o;
  wire [15:0] n3362_o;
  wire [15:0] n3364_o;
  wire n3366_o;
  wire [15:0] n3368_o;
  wire n3370_o;
  wire n3372_o;
  wire n3373_o;
  wire [15:0] n3375_o;
  wire [15:0] n3377_o;
  wire [15:0] n3378_o;
  wire [15:0] n3380_o;
  wire n3382_o;
  wire [15:0] n3384_o;
  wire [15:0] n3386_o;
  wire n3388_o;
  wire [20:0] n3389_o;
  reg n3395_o;
  reg [7:0] n3396_o;
  reg [7:0] n3397_o;
  reg [15:0] n3398_o;
  reg [15:0] n3399_o;
  reg n3400_o;
  reg n3401_o;
  reg n3402_o;
  reg n3403_o;
  wire n3404_o;
  reg n3405_o;
  wire n3406_o;
  reg n3407_o;
  wire n3408_o;
  reg n3409_o;
  wire n3410_o;
  reg n3411_o;
  wire n3412_o;
  reg n3413_o;
  wire n3414_o;
  reg n3415_o;
  wire n3416_o;
  reg n3417_o;
  wire n3418_o;
  reg n3419_o;
  reg [3:0] n3442_o;
  reg [2:0] n3461_o;
  reg [3:0] n3464_o;
  wire n3467_o;
  wire [15:0] n3469_o;
  wire n3471_o;
  wire n3473_o;
  wire n3474_o;
  wire [15:0] n3476_o;
  wire n3478_o;
  wire [15:0] n3480_o;
  wire n3482_o;
  wire [15:0] n3484_o;
  wire [15:0] n3486_o;
  wire [15:0] n3487_o;
  wire n3489_o;
  wire [3:0] n3490_o;
  reg n3493_o;
  reg [15:0] n3494_o;
  wire [7:0] n3495_o;
  wire [7:0] n3496_o;
  wire [7:0] n3497_o;
  reg [7:0] n3498_o;
  wire [7:0] n3499_o;
  wire [7:0] n3500_o;
  wire [7:0] n3501_o;
  reg [7:0] n3502_o;
  reg [3:0] n3508_o;
  reg [2:0] n3511_o;
  reg [3:0] n3513_o;
  wire n3515_o;
  wire n3517_o;
  wire n3519_o;
  wire n3520_o;
  wire [15:0] n3522_o;
  wire n3523_o;
  wire [15:0] n3526_o;
  wire n3528_o;
  wire [15:0] n3530_o;
  wire n3532_o;
  wire n3533_o;
  wire [15:0] n3535_o;
  wire n3537_o;
  wire n3538_o;
  wire n3539_o;
  wire [15:0] n3541_o;
  wire [3:0] n3544_o;
  wire n3545_o;
  wire n3546_o;
  wire n3547_o;
  wire n3549_o;
  wire [1:0] n3550_o;
  reg [15:0] n3551_o;
  wire [7:0] n3552_o;
  reg [7:0] n3553_o;
  reg n3555_o;
  reg [15:0] n3556_o;
  reg [3:0] n3559_o;
  reg [2:0] n3561_o;
  reg [3:0] n3563_o;
  reg n3564_o;
  reg n3565_o;
  reg n3566_o;
  wire n3568_o;
  wire [15:0] n3570_o;
  wire n3572_o;
  reg n3574_o;
  reg [15:0] n3575_o;
  reg [3:0] n3578_o;
  reg [2:0] n3580_o;
  wire n3582_o;
  wire [15:0] n3584_o;
  wire n3586_o;
  wire [7:0] n3587_o;
  reg [7:0] n3588_o;
  reg [15:0] n3589_o;
  reg [3:0] n3592_o;
  wire n3594_o;
  wire n3596_o;
  wire [7:0] n3597_o;
  reg [7:0] n3598_o;
  reg [3:0] n3601_o;
  reg [2:0] n3603_o;
  wire n3605_o;
  wire [15:0] n3607_o;
  wire n3609_o;
  wire [11:0] n3610_o;
  reg n3611_o;
  reg [7:0] n3612_o;
  reg [7:0] n3613_o;
  reg [15:0] n3614_o;
  wire [7:0] n3615_o;
  wire [7:0] n3616_o;
  wire [7:0] n3617_o;
  reg [7:0] n3618_o;
  wire [7:0] n3619_o;
  wire [7:0] n3620_o;
  wire [7:0] n3621_o;
  reg [7:0] n3622_o;
  reg n3623_o;
  reg n3624_o;
  reg n3625_o;
  reg n3626_o;
  reg n3627_o;
  wire n3628_o;
  wire n3629_o;
  wire n3630_o;
  wire n3631_o;
  reg n3632_o;
  wire n3633_o;
  wire n3634_o;
  wire n3635_o;
  wire n3636_o;
  reg n3637_o;
  wire n3638_o;
  wire n3639_o;
  wire n3640_o;
  wire n3641_o;
  reg n3642_o;
  wire n3643_o;
  wire n3644_o;
  wire n3645_o;
  wire n3646_o;
  reg n3647_o;
  wire n3648_o;
  wire n3649_o;
  wire n3650_o;
  wire n3651_o;
  reg n3652_o;
  wire n3653_o;
  wire n3654_o;
  wire n3655_o;
  wire n3656_o;
  reg n3657_o;
  wire n3658_o;
  wire n3659_o;
  wire n3660_o;
  wire n3661_o;
  reg n3662_o;
  wire n3663_o;
  wire n3664_o;
  wire n3665_o;
  wire n3666_o;
  reg n3667_o;
  wire [7:0] n3668_o;
  wire [7:0] n3669_o;
  wire [7:0] n3670_o;
  wire [7:0] n3671_o;
  wire [7:0] n3672_o;
  reg [7:0] n3673_o;
  wire [7:0] n3674_o;
  wire [7:0] n3675_o;
  wire [7:0] n3676_o;
  wire [7:0] n3677_o;
  wire [7:0] n3678_o;
  reg [7:0] n3679_o;
  reg [3:0] n3684_o;
  reg [2:0] n3686_o;
  reg [3:0] n3688_o;
  reg [7:0] n3689_o;
  reg n3690_o;
  reg n3691_o;
  reg n3692_o;
  reg n3694_o;
  reg n3696_o;
  reg [7:0] n3697_o;
  wire [15:0] n3703_o;
  wire [7:0] n3710_o;
  wire [15:0] n3712_o;
  wire n3718_o;
  wire n3719_o;
  wire n3720_o;
  wire [63:0] n3805_o;
  wire [63:0] n3806_o;
  wire [7:0] n3807_o;
  reg [7:0] n3808_q;
  wire [7:0] n3809_o;
  reg [7:0] n3810_q;
  wire [15:0] n3811_o;
  reg [15:0] n3812_q;
  wire [15:0] n3813_o;
  reg [15:0] n3814_q;
  wire n3815_o;
  reg n3816_q;
  wire n3817_o;
  reg n3818_q;
  wire n3819_o;
  reg n3820_q;
  wire n3821_o;
  reg n3822_q;
  wire n3823_o;
  reg n3824_q;
  wire [7:0] n3825_o;
  reg [7:0] n3826_q;
  wire [15:0] n3827_o;
  reg [15:0] n3828_q;
  wire [3:0] n3829_o;
  reg [3:0] n3830_q;
  wire [2:0] n3831_o;
  reg [2:0] n3832_q;
  wire [3:0] n3833_o;
  reg [3:0] n3834_q;
  wire n3835_o;
  wire n3836_o;
  wire [7:0] n3837_o;
  reg [7:0] n3838_q;
  reg n3839_q;
  reg n3840_q;
  reg n3841_q;
  reg n3842_q;
  reg n3843_q;
  reg n3844_q;
  wire n3845_o;
  reg n3846_q;
  wire n3847_o;
  reg n3848_q;
  wire n3849_o;
  wire n3850_o;
  wire [7:0] n3851_o;
  reg [7:0] n3852_q;
  wire n3853_o;
  reg n3854_q;
  wire [7:0] n3855_o;
  wire [7:0] n3856_o;
  wire [7:0] n3857_o;
  wire [7:0] n3858_o;
  wire [7:0] n3859_o;
  wire [7:0] n3860_o;
  wire [7:0] n3861_o;
  wire [7:0] n3862_o;
  wire [1:0] n3863_o;
  reg [7:0] n3864_o;
  wire [1:0] n3865_o;
  reg [7:0] n3866_o;
  wire n3867_o;
  wire [7:0] n3868_o;
  wire [7:0] n3869_o;
  wire [7:0] n3870_o;
  wire [7:0] n3871_o;
  wire [7:0] n3872_o;
  wire [7:0] n3873_o;
  wire [7:0] n3874_o;
  wire [7:0] n3875_o;
  wire [7:0] n3876_o;
  wire [1:0] n3877_o;
  reg [7:0] n3878_o;
  wire [1:0] n3879_o;
  reg [7:0] n3880_o;
  wire n3881_o;
  wire [7:0] n3882_o;
  wire [7:0] n3883_o;
  wire [7:0] n3884_o;
  wire [7:0] n3885_o;
  wire [7:0] n3886_o;
  wire [7:0] n3887_o;
  wire [7:0] n3888_o;
  wire [7:0] n3889_o;
  wire [7:0] n3890_o;
  wire [1:0] n3891_o;
  reg [7:0] n3892_o;
  wire [1:0] n3893_o;
  reg [7:0] n3894_o;
  wire n3895_o;
  wire [7:0] n3896_o;
  assign addr = n9_o;
  assign wr = n3854_q;
  assign state = mainfsm;
  assign dataout = n46_o;
  /* 6805.vhd:182:10  */
  assign mask0 = n3805_o; // (signal)
  /* 6805.vhd:183:10  */
  assign mask1 = n3806_o; // (signal)
  /* 6805.vhd:184:10  */
  assign rega = n3808_q; // (signal)
  /* 6805.vhd:185:10  */
  assign regx = n3810_q; // (signal)
  /* 6805.vhd:186:10  */
  assign regsp = n3812_q; // (signal)
  /* 6805.vhd:187:10  */
  assign regpc = n3814_q; // (signal)
  /* 6805.vhd:188:10  */
  assign flagh = n3816_q; // (signal)
  /* 6805.vhd:189:10  */
  assign flagi = n3818_q; // (signal)
  /* 6805.vhd:190:10  */
  assign flagn = n3820_q; // (signal)
  /* 6805.vhd:191:10  */
  assign flagz = n3822_q; // (signal)
  /* 6805.vhd:192:10  */
  assign flagc = n3824_q; // (signal)
  /* 6805.vhd:193:10  */
  assign help = n3826_q; // (signal)
  /* 6805.vhd:194:10  */
  assign temp = n3828_q; // (signal)
  /* 6805.vhd:195:10  */
  assign mainfsm = n3830_q; // (signal)
  /* 6805.vhd:196:10  */
  assign addrmux = n3832_q; // (signal)
  /* 6805.vhd:197:10  */
  assign datamux = n3834_q; // (signal)
  /* 6805.vhd:198:10  */
  assign opcode = n3838_q; // (signal)
  /* 6805.vhd:199:10  */
  assign prod = mul_n4; // (signal)
  /* 6805.vhd:200:10  */
  assign extirq_d = n3839_q; // (signal)
  /* 6805.vhd:201:10  */
  assign timerirq_d = n3840_q; // (signal)
  /* 6805.vhd:202:10  */
  assign sciirq_d = n3841_q; // (signal)
  /* 6805.vhd:203:10  */
  assign extirqrequest = n3842_q; // (signal)
  /* 6805.vhd:204:10  */
  assign timerirqrequest = n3843_q; // (signal)
  /* 6805.vhd:205:10  */
  assign sciirqrequest = n3844_q; // (signal)
  /* 6805.vhd:208:10  */
  assign trace = n3846_q; // (signal)
  /* 6805.vhd:209:10  */
  assign trace_i = n3848_q; // (signal)
  /* 6805.vhd:210:10  */
  assign traceopcode = n3852_q; // (signal)
  /* 6805.vhd:217:13  */
  assign mul_n4 = mul_prod; // (signal)
  /* 6805.vhd:214:3  */
  mul8 mul (
    .a(rega),
    .b(regx),
    .prod(mul_prod));
  /* 6805.vhd:220:39  */
  assign n8_o = addrmux == 3'b000;
  /* 6805.vhd:220:26  */
  assign n9_o = n8_o ? regpc : n12_o;
  /* 6805.vhd:221:39  */
  assign n11_o = addrmux == 3'b001;
  /* 6805.vhd:220:48  */
  assign n12_o = n11_o ? regsp : n17_o;
  /* 6805.vhd:222:17  */
  assign n14_o = {8'b00000000, regx};
  /* 6805.vhd:222:39  */
  assign n16_o = addrmux == 3'b010;
  /* 6805.vhd:221:48  */
  assign n17_o = n16_o ? n14_o : n20_o;
  /* 6805.vhd:223:39  */
  assign n19_o = addrmux == 3'b011;
  /* 6805.vhd:222:48  */
  assign n20_o = n19_o ? temp : n26_o;
  /* 6805.vhd:224:19  */
  assign n22_o = {8'b00000000, regx};
  /* 6805.vhd:224:27  */
  assign n23_o = n22_o + temp;
  /* 6805.vhd:224:48  */
  assign n25_o = addrmux == 3'b100;
  /* 6805.vhd:223:48  */
  assign n26_o = n25_o ? n23_o : n30_o;
  /* 6805.vhd:225:18  */
  assign n27_o = regsp + temp;
  /* 6805.vhd:225:39  */
  assign n29_o = addrmux == 3'b101;
  /* 6805.vhd:224:57  */
  assign n30_o = n29_o ? n27_o : n39_o;
  /* 6805.vhd:226:19  */
  assign n32_o = {8'b00000000, regx};
  /* 6805.vhd:226:42  */
  assign n33_o = temp[7:0];
  /* 6805.vhd:226:36  */
  assign n35_o = {8'b00000000, n33_o};
  /* 6805.vhd:226:27  */
  assign n36_o = n32_o + n35_o;
  /* 6805.vhd:226:70  */
  assign n38_o = addrmux == 3'b110;
  /* 6805.vhd:225:48  */
  assign n39_o = n38_o ? n36_o : n43_o;
  /* 6805.vhd:227:33  */
  assign n40_o = temp[7:0];
  /* 6805.vhd:227:27  */
  assign n42_o = {8'b00000000, n40_o};
  /* 6805.vhd:227:18  */
  assign n43_o = regsp + n42_o;
  /* 6805.vhd:228:46  */
  assign n45_o = datamux == 4'b0000;
  /* 6805.vhd:228:33  */
  assign n46_o = n45_o ? rega : n49_o;
  /* 6805.vhd:229:46  */
  assign n48_o = datamux == 4'b0001;
  /* 6805.vhd:228:53  */
  assign n49_o = n48_o ? regx : n52_o;
  /* 6805.vhd:230:46  */
  assign n51_o = datamux == 4'b0010;
  /* 6805.vhd:229:53  */
  assign n52_o = n51_o ? regx : n56_o;
  /* 6805.vhd:231:19  */
  assign n53_o = regsp[7:0];
  /* 6805.vhd:231:46  */
  assign n55_o = datamux == 4'b0011;
  /* 6805.vhd:230:53  */
  assign n56_o = n55_o ? n53_o : n60_o;
  /* 6805.vhd:232:19  */
  assign n57_o = regsp[15:8];
  /* 6805.vhd:232:46  */
  assign n59_o = datamux == 4'b0100;
  /* 6805.vhd:231:55  */
  assign n60_o = n59_o ? n57_o : n64_o;
  /* 6805.vhd:233:19  */
  assign n61_o = regpc[7:0];
  /* 6805.vhd:233:46  */
  assign n63_o = datamux == 4'b0101;
  /* 6805.vhd:232:55  */
  assign n64_o = n63_o ? n61_o : n68_o;
  /* 6805.vhd:234:19  */
  assign n65_o = regpc[15:8];
  /* 6805.vhd:234:46  */
  assign n67_o = datamux == 4'b0110;
  /* 6805.vhd:233:55  */
  assign n68_o = n67_o ? n65_o : n72_o;
  /* 6805.vhd:235:19  */
  assign n69_o = temp[7:0];
  /* 6805.vhd:235:46  */
  assign n71_o = datamux == 4'b0111;
  /* 6805.vhd:234:55  */
  assign n72_o = n71_o ? n69_o : n76_o;
  /* 6805.vhd:236:19  */
  assign n73_o = temp[15:8];
  /* 6805.vhd:236:46  */
  assign n75_o = datamux == 4'b1000;
  /* 6805.vhd:235:55  */
  assign n76_o = n75_o ? n73_o : n79_o;
  /* 6805.vhd:237:46  */
  assign n78_o = datamux == 4'b1001;
  /* 6805.vhd:236:55  */
  assign n79_o = n78_o ? help : traceopcode;
  /* 6805.vhd:264:12  */
  assign n100_o = ~rst;
  /* 6805.vhd:295:20  */
  assign n103_o = $unsigned(extirq) <= $unsigned(1'b0);
  /* 6805.vhd:295:28  */
  assign n104_o = extirq_d & n103_o;
  /* 6805.vhd:295:9  */
  assign n106_o = n104_o ? 1'b1 : extirqrequest;
  /* 6805.vhd:299:22  */
  assign n108_o = $unsigned(timerirq) <= $unsigned(1'b0);
  /* 6805.vhd:299:30  */
  assign n109_o = timerirq_d & n108_o;
  /* 6805.vhd:299:9  */
  assign n111_o = n109_o ? 1'b1 : timerirqrequest;
  /* 6805.vhd:303:20  */
  assign n113_o = $unsigned(sciirq) <= $unsigned(1'b0);
  /* 6805.vhd:303:28  */
  assign n114_o = sciirq_d & n113_o;
  /* 6805.vhd:303:9  */
  assign n116_o = n114_o ? 1'b1 : sciirqrequest;
  /* 6805.vhd:311:29  */
  assign n118_o = temp + 16'b0000000000000001;
  /* 6805.vhd:309:11  */
  assign n120_o = mainfsm == 4'b0000;
  /* 6805.vhd:313:11  */
  assign n122_o = mainfsm == 4'b0001;
  /* 6805.vhd:325:40  */
  assign n123_o = extirqrequest | timerirqrequest;
  /* 6805.vhd:325:66  */
  assign n124_o = n123_o | sciirqrequest;
  /* 6805.vhd:325:101  */
  assign n125_o = ~flagi;
  /* 6805.vhd:325:90  */
  assign n126_o = n125_o & n124_o;
  /* 6805.vhd:334:36  */
  assign n128_o = regsp + 16'b0000000000000001;
  /* 6805.vhd:332:17  */
  assign n130_o = datain == 8'b10000010;
  /* 6805.vhd:350:36  */
  assign n132_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:337:17  */
  assign n134_o = datain == 8'b00000000;
  /* 6805.vhd:337:28  */
  assign n136_o = datain == 8'b00000010;
  /* 6805.vhd:337:28  */
  assign n137_o = n134_o | n136_o;
  /* 6805.vhd:337:36  */
  assign n139_o = datain == 8'b00000100;
  /* 6805.vhd:337:36  */
  assign n140_o = n137_o | n139_o;
  /* 6805.vhd:337:44  */
  assign n142_o = datain == 8'b00000110;
  /* 6805.vhd:337:44  */
  assign n143_o = n140_o | n142_o;
  /* 6805.vhd:337:52  */
  assign n145_o = datain == 8'b00001000;
  /* 6805.vhd:337:52  */
  assign n146_o = n143_o | n145_o;
  /* 6805.vhd:337:60  */
  assign n148_o = datain == 8'b00001010;
  /* 6805.vhd:337:60  */
  assign n149_o = n146_o | n148_o;
  /* 6805.vhd:337:68  */
  assign n151_o = datain == 8'b00001100;
  /* 6805.vhd:337:68  */
  assign n152_o = n149_o | n151_o;
  /* 6805.vhd:337:76  */
  assign n154_o = datain == 8'b00001110;
  /* 6805.vhd:337:76  */
  assign n155_o = n152_o | n154_o;
  /* 6805.vhd:337:84  */
  assign n157_o = datain == 8'b00000001;
  /* 6805.vhd:337:84  */
  assign n158_o = n155_o | n157_o;
  /* 6805.vhd:338:28  */
  assign n160_o = datain == 8'b00000011;
  /* 6805.vhd:338:28  */
  assign n161_o = n158_o | n160_o;
  /* 6805.vhd:338:36  */
  assign n163_o = datain == 8'b00000101;
  /* 6805.vhd:338:36  */
  assign n164_o = n161_o | n163_o;
  /* 6805.vhd:338:44  */
  assign n166_o = datain == 8'b00000111;
  /* 6805.vhd:338:44  */
  assign n167_o = n164_o | n166_o;
  /* 6805.vhd:338:52  */
  assign n169_o = datain == 8'b00001001;
  /* 6805.vhd:338:52  */
  assign n170_o = n167_o | n169_o;
  /* 6805.vhd:338:60  */
  assign n172_o = datain == 8'b00001011;
  /* 6805.vhd:338:60  */
  assign n173_o = n170_o | n172_o;
  /* 6805.vhd:338:68  */
  assign n175_o = datain == 8'b00001101;
  /* 6805.vhd:338:68  */
  assign n176_o = n173_o | n175_o;
  /* 6805.vhd:338:76  */
  assign n178_o = datain == 8'b00001111;
  /* 6805.vhd:338:76  */
  assign n179_o = n176_o | n178_o;
  /* 6805.vhd:338:84  */
  assign n181_o = datain == 8'b00010000;
  /* 6805.vhd:338:84  */
  assign n182_o = n179_o | n181_o;
  /* 6805.vhd:339:28  */
  assign n184_o = datain == 8'b00010010;
  /* 6805.vhd:339:28  */
  assign n185_o = n182_o | n184_o;
  /* 6805.vhd:339:36  */
  assign n187_o = datain == 8'b00010100;
  /* 6805.vhd:339:36  */
  assign n188_o = n185_o | n187_o;
  /* 6805.vhd:339:44  */
  assign n190_o = datain == 8'b00010110;
  /* 6805.vhd:339:44  */
  assign n191_o = n188_o | n190_o;
  /* 6805.vhd:339:52  */
  assign n193_o = datain == 8'b00011000;
  /* 6805.vhd:339:52  */
  assign n194_o = n191_o | n193_o;
  /* 6805.vhd:339:60  */
  assign n196_o = datain == 8'b00011010;
  /* 6805.vhd:339:60  */
  assign n197_o = n194_o | n196_o;
  /* 6805.vhd:339:68  */
  assign n199_o = datain == 8'b00011100;
  /* 6805.vhd:339:68  */
  assign n200_o = n197_o | n199_o;
  /* 6805.vhd:339:76  */
  assign n202_o = datain == 8'b00011110;
  /* 6805.vhd:339:76  */
  assign n203_o = n200_o | n202_o;
  /* 6805.vhd:339:84  */
  assign n205_o = datain == 8'b00010001;
  /* 6805.vhd:339:84  */
  assign n206_o = n203_o | n205_o;
  /* 6805.vhd:340:28  */
  assign n208_o = datain == 8'b00010011;
  /* 6805.vhd:340:28  */
  assign n209_o = n206_o | n208_o;
  /* 6805.vhd:340:36  */
  assign n211_o = datain == 8'b00010101;
  /* 6805.vhd:340:36  */
  assign n212_o = n209_o | n211_o;
  /* 6805.vhd:340:44  */
  assign n214_o = datain == 8'b00010111;
  /* 6805.vhd:340:44  */
  assign n215_o = n212_o | n214_o;
  /* 6805.vhd:340:52  */
  assign n217_o = datain == 8'b00011001;
  /* 6805.vhd:340:52  */
  assign n218_o = n215_o | n217_o;
  /* 6805.vhd:340:60  */
  assign n220_o = datain == 8'b00011011;
  /* 6805.vhd:340:60  */
  assign n221_o = n218_o | n220_o;
  /* 6805.vhd:340:68  */
  assign n223_o = datain == 8'b00011101;
  /* 6805.vhd:340:68  */
  assign n224_o = n221_o | n223_o;
  /* 6805.vhd:340:76  */
  assign n226_o = datain == 8'b00011111;
  /* 6805.vhd:340:76  */
  assign n227_o = n224_o | n226_o;
  /* 6805.vhd:340:84  */
  assign n229_o = datain == 8'b00110000;
  /* 6805.vhd:340:84  */
  assign n230_o = n227_o | n229_o;
  /* 6805.vhd:341:28  */
  assign n232_o = datain == 8'b00110011;
  /* 6805.vhd:341:28  */
  assign n233_o = n230_o | n232_o;
  /* 6805.vhd:341:36  */
  assign n235_o = datain == 8'b00110100;
  /* 6805.vhd:341:36  */
  assign n236_o = n233_o | n235_o;
  /* 6805.vhd:341:44  */
  assign n238_o = datain == 8'b00110110;
  /* 6805.vhd:341:44  */
  assign n239_o = n236_o | n238_o;
  /* 6805.vhd:342:28  */
  assign n241_o = datain == 8'b00110111;
  /* 6805.vhd:342:28  */
  assign n242_o = n239_o | n241_o;
  /* 6805.vhd:342:36  */
  assign n244_o = datain == 8'b00111000;
  /* 6805.vhd:342:36  */
  assign n245_o = n242_o | n244_o;
  /* 6805.vhd:342:44  */
  assign n247_o = datain == 8'b00111001;
  /* 6805.vhd:342:44  */
  assign n248_o = n245_o | n247_o;
  /* 6805.vhd:343:28  */
  assign n250_o = datain == 8'b00111010;
  /* 6805.vhd:343:28  */
  assign n251_o = n248_o | n250_o;
  /* 6805.vhd:343:36  */
  assign n253_o = datain == 8'b00111100;
  /* 6805.vhd:343:36  */
  assign n254_o = n251_o | n253_o;
  /* 6805.vhd:343:44  */
  assign n256_o = datain == 8'b00111101;
  /* 6805.vhd:343:44  */
  assign n257_o = n254_o | n256_o;
  /* 6805.vhd:344:28  */
  assign n259_o = datain == 8'b00111111;
  /* 6805.vhd:344:28  */
  assign n260_o = n257_o | n259_o;
  /* 6805.vhd:344:36  */
  assign n262_o = datain == 8'b10110000;
  /* 6805.vhd:344:36  */
  assign n263_o = n260_o | n262_o;
  /* 6805.vhd:345:28  */
  assign n265_o = datain == 8'b10110001;
  /* 6805.vhd:345:28  */
  assign n266_o = n263_o | n265_o;
  /* 6805.vhd:345:36  */
  assign n268_o = datain == 8'b10110010;
  /* 6805.vhd:345:36  */
  assign n269_o = n266_o | n268_o;
  /* 6805.vhd:345:44  */
  assign n271_o = datain == 8'b10110011;
  /* 6805.vhd:345:44  */
  assign n272_o = n269_o | n271_o;
  /* 6805.vhd:345:52  */
  assign n274_o = datain == 8'b10110100;
  /* 6805.vhd:345:52  */
  assign n275_o = n272_o | n274_o;
  /* 6805.vhd:346:28  */
  assign n277_o = datain == 8'b10110101;
  /* 6805.vhd:346:28  */
  assign n278_o = n275_o | n277_o;
  /* 6805.vhd:346:36  */
  assign n280_o = datain == 8'b10110110;
  /* 6805.vhd:346:36  */
  assign n281_o = n278_o | n280_o;
  /* 6805.vhd:346:44  */
  assign n283_o = datain == 8'b10110111;
  /* 6805.vhd:346:44  */
  assign n284_o = n281_o | n283_o;
  /* 6805.vhd:346:52  */
  assign n286_o = datain == 8'b10111000;
  /* 6805.vhd:346:52  */
  assign n287_o = n284_o | n286_o;
  /* 6805.vhd:347:28  */
  assign n289_o = datain == 8'b10111001;
  /* 6805.vhd:347:28  */
  assign n290_o = n287_o | n289_o;
  /* 6805.vhd:347:36  */
  assign n292_o = datain == 8'b10111010;
  /* 6805.vhd:347:36  */
  assign n293_o = n290_o | n292_o;
  /* 6805.vhd:347:44  */
  assign n295_o = datain == 8'b10111011;
  /* 6805.vhd:347:44  */
  assign n296_o = n293_o | n295_o;
  /* 6805.vhd:347:52  */
  assign n298_o = datain == 8'b10111100;
  /* 6805.vhd:347:52  */
  assign n299_o = n296_o | n298_o;
  /* 6805.vhd:348:28  */
  assign n301_o = datain == 8'b10111110;
  /* 6805.vhd:348:28  */
  assign n302_o = n299_o | n301_o;
  /* 6805.vhd:348:36  */
  assign n304_o = datain == 8'b10111111;
  /* 6805.vhd:348:36  */
  assign n305_o = n302_o | n304_o;
  /* 6805.vhd:362:34  */
  assign n307_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:352:17  */
  assign n309_o = datain == 8'b00100000;
  /* 6805.vhd:352:28  */
  assign n311_o = datain == 8'b00100001;
  /* 6805.vhd:352:28  */
  assign n312_o = n309_o | n311_o;
  /* 6805.vhd:352:36  */
  assign n314_o = datain == 8'b00100010;
  /* 6805.vhd:352:36  */
  assign n315_o = n312_o | n314_o;
  /* 6805.vhd:352:44  */
  assign n317_o = datain == 8'b00100011;
  /* 6805.vhd:352:44  */
  assign n318_o = n315_o | n317_o;
  /* 6805.vhd:352:52  */
  assign n320_o = datain == 8'b00100100;
  /* 6805.vhd:352:52  */
  assign n321_o = n318_o | n320_o;
  /* 6805.vhd:352:60  */
  assign n323_o = datain == 8'b00100101;
  /* 6805.vhd:352:60  */
  assign n324_o = n321_o | n323_o;
  /* 6805.vhd:352:68  */
  assign n326_o = datain == 8'b00100110;
  /* 6805.vhd:352:68  */
  assign n327_o = n324_o | n326_o;
  /* 6805.vhd:352:76  */
  assign n329_o = datain == 8'b00100111;
  /* 6805.vhd:352:76  */
  assign n330_o = n327_o | n329_o;
  /* 6805.vhd:352:84  */
  assign n332_o = datain == 8'b00101000;
  /* 6805.vhd:352:84  */
  assign n333_o = n330_o | n332_o;
  /* 6805.vhd:353:28  */
  assign n335_o = datain == 8'b00101001;
  /* 6805.vhd:353:28  */
  assign n336_o = n333_o | n335_o;
  /* 6805.vhd:353:36  */
  assign n338_o = datain == 8'b00101010;
  /* 6805.vhd:353:36  */
  assign n339_o = n336_o | n338_o;
  /* 6805.vhd:353:44  */
  assign n341_o = datain == 8'b00101011;
  /* 6805.vhd:353:44  */
  assign n342_o = n339_o | n341_o;
  /* 6805.vhd:353:52  */
  assign n344_o = datain == 8'b00101100;
  /* 6805.vhd:353:52  */
  assign n345_o = n342_o | n344_o;
  /* 6805.vhd:353:60  */
  assign n347_o = datain == 8'b00101101;
  /* 6805.vhd:353:60  */
  assign n348_o = n345_o | n347_o;
  /* 6805.vhd:353:68  */
  assign n350_o = datain == 8'b00101110;
  /* 6805.vhd:353:68  */
  assign n351_o = n348_o | n350_o;
  /* 6805.vhd:353:76  */
  assign n353_o = datain == 8'b00101111;
  /* 6805.vhd:353:76  */
  assign n354_o = n351_o | n353_o;
  /* 6805.vhd:353:84  */
  assign n356_o = datain == 8'b11000000;
  /* 6805.vhd:353:84  */
  assign n357_o = n354_o | n356_o;
  /* 6805.vhd:354:28  */
  assign n359_o = datain == 8'b11000001;
  /* 6805.vhd:354:28  */
  assign n360_o = n357_o | n359_o;
  /* 6805.vhd:354:36  */
  assign n362_o = datain == 8'b11000010;
  /* 6805.vhd:354:36  */
  assign n363_o = n360_o | n362_o;
  /* 6805.vhd:354:44  */
  assign n365_o = datain == 8'b11000011;
  /* 6805.vhd:354:44  */
  assign n366_o = n363_o | n365_o;
  /* 6805.vhd:354:52  */
  assign n368_o = datain == 8'b11000100;
  /* 6805.vhd:354:52  */
  assign n369_o = n366_o | n368_o;
  /* 6805.vhd:355:28  */
  assign n371_o = datain == 8'b11000101;
  /* 6805.vhd:355:28  */
  assign n372_o = n369_o | n371_o;
  /* 6805.vhd:355:36  */
  assign n374_o = datain == 8'b11000110;
  /* 6805.vhd:355:36  */
  assign n375_o = n372_o | n374_o;
  /* 6805.vhd:355:44  */
  assign n377_o = datain == 8'b11000111;
  /* 6805.vhd:355:44  */
  assign n378_o = n375_o | n377_o;
  /* 6805.vhd:355:52  */
  assign n380_o = datain == 8'b11001000;
  /* 6805.vhd:355:52  */
  assign n381_o = n378_o | n380_o;
  /* 6805.vhd:356:28  */
  assign n383_o = datain == 8'b11001001;
  /* 6805.vhd:356:28  */
  assign n384_o = n381_o | n383_o;
  /* 6805.vhd:356:36  */
  assign n386_o = datain == 8'b11001010;
  /* 6805.vhd:356:36  */
  assign n387_o = n384_o | n386_o;
  /* 6805.vhd:356:44  */
  assign n389_o = datain == 8'b11001011;
  /* 6805.vhd:356:44  */
  assign n390_o = n387_o | n389_o;
  /* 6805.vhd:356:52  */
  assign n392_o = datain == 8'b11001100;
  /* 6805.vhd:356:52  */
  assign n393_o = n390_o | n392_o;
  /* 6805.vhd:357:28  */
  assign n395_o = datain == 8'b11001110;
  /* 6805.vhd:357:28  */
  assign n396_o = n393_o | n395_o;
  /* 6805.vhd:357:36  */
  assign n398_o = datain == 8'b11001111;
  /* 6805.vhd:357:36  */
  assign n399_o = n396_o | n398_o;
  /* 6805.vhd:357:44  */
  assign n401_o = datain == 8'b11010000;
  /* 6805.vhd:357:44  */
  assign n402_o = n399_o | n401_o;
  /* 6805.vhd:358:28  */
  assign n404_o = datain == 8'b11010001;
  /* 6805.vhd:358:28  */
  assign n405_o = n402_o | n404_o;
  /* 6805.vhd:358:36  */
  assign n407_o = datain == 8'b11010010;
  /* 6805.vhd:358:36  */
  assign n408_o = n405_o | n407_o;
  /* 6805.vhd:358:44  */
  assign n410_o = datain == 8'b11010011;
  /* 6805.vhd:358:44  */
  assign n411_o = n408_o | n410_o;
  /* 6805.vhd:358:52  */
  assign n413_o = datain == 8'b11010100;
  /* 6805.vhd:358:52  */
  assign n414_o = n411_o | n413_o;
  /* 6805.vhd:359:28  */
  assign n416_o = datain == 8'b11010101;
  /* 6805.vhd:359:28  */
  assign n417_o = n414_o | n416_o;
  /* 6805.vhd:359:36  */
  assign n419_o = datain == 8'b11010110;
  /* 6805.vhd:359:36  */
  assign n420_o = n417_o | n419_o;
  /* 6805.vhd:359:44  */
  assign n422_o = datain == 8'b11010111;
  /* 6805.vhd:359:44  */
  assign n423_o = n420_o | n422_o;
  /* 6805.vhd:359:52  */
  assign n425_o = datain == 8'b11011000;
  /* 6805.vhd:359:52  */
  assign n426_o = n423_o | n425_o;
  /* 6805.vhd:360:28  */
  assign n428_o = datain == 8'b11011001;
  /* 6805.vhd:360:28  */
  assign n429_o = n426_o | n428_o;
  /* 6805.vhd:360:36  */
  assign n431_o = datain == 8'b11011010;
  /* 6805.vhd:360:36  */
  assign n432_o = n429_o | n431_o;
  /* 6805.vhd:360:44  */
  assign n434_o = datain == 8'b11011011;
  /* 6805.vhd:360:44  */
  assign n435_o = n432_o | n434_o;
  /* 6805.vhd:360:52  */
  assign n437_o = datain == 8'b11011100;
  /* 6805.vhd:360:52  */
  assign n438_o = n435_o | n437_o;
  /* 6805.vhd:361:28  */
  assign n440_o = datain == 8'b11011110;
  /* 6805.vhd:361:28  */
  assign n441_o = n438_o | n440_o;
  /* 6805.vhd:361:36  */
  assign n443_o = datain == 8'b11011111;
  /* 6805.vhd:361:36  */
  assign n444_o = n441_o | n443_o;
  /* 6805.vhd:367:36  */
  assign n446_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:364:17  */
  assign n448_o = datain == 8'b01110000;
  /* 6805.vhd:364:28  */
  assign n450_o = datain == 8'b01110011;
  /* 6805.vhd:364:28  */
  assign n451_o = n448_o | n450_o;
  /* 6805.vhd:364:36  */
  assign n453_o = datain == 8'b01110100;
  /* 6805.vhd:364:36  */
  assign n454_o = n451_o | n453_o;
  /* 6805.vhd:364:44  */
  assign n456_o = datain == 8'b01110110;
  /* 6805.vhd:364:44  */
  assign n457_o = n454_o | n456_o;
  /* 6805.vhd:364:52  */
  assign n459_o = datain == 8'b01110111;
  /* 6805.vhd:364:52  */
  assign n460_o = n457_o | n459_o;
  /* 6805.vhd:364:60  */
  assign n462_o = datain == 8'b01111000;
  /* 6805.vhd:364:60  */
  assign n463_o = n460_o | n462_o;
  /* 6805.vhd:365:28  */
  assign n465_o = datain == 8'b01111001;
  /* 6805.vhd:365:28  */
  assign n466_o = n463_o | n465_o;
  /* 6805.vhd:365:36  */
  assign n468_o = datain == 8'b01111010;
  /* 6805.vhd:365:36  */
  assign n469_o = n466_o | n468_o;
  /* 6805.vhd:365:44  */
  assign n471_o = datain == 8'b01111100;
  /* 6805.vhd:365:44  */
  assign n472_o = n469_o | n471_o;
  /* 6805.vhd:365:52  */
  assign n474_o = datain == 8'b01111101;
  /* 6805.vhd:365:52  */
  assign n475_o = n472_o | n474_o;
  /* 6805.vhd:373:34  */
  assign n477_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:369:17  */
  assign n479_o = datain == 8'b10100000;
  /* 6805.vhd:369:28  */
  assign n481_o = datain == 8'b10100001;
  /* 6805.vhd:369:28  */
  assign n482_o = n479_o | n481_o;
  /* 6805.vhd:369:36  */
  assign n484_o = datain == 8'b10100010;
  /* 6805.vhd:369:36  */
  assign n485_o = n482_o | n484_o;
  /* 6805.vhd:369:44  */
  assign n487_o = datain == 8'b10100011;
  /* 6805.vhd:369:44  */
  assign n488_o = n485_o | n487_o;
  /* 6805.vhd:369:52  */
  assign n490_o = datain == 8'b10100100;
  /* 6805.vhd:369:52  */
  assign n491_o = n488_o | n490_o;
  /* 6805.vhd:370:28  */
  assign n493_o = datain == 8'b10100101;
  /* 6805.vhd:370:28  */
  assign n494_o = n491_o | n493_o;
  /* 6805.vhd:370:36  */
  assign n496_o = datain == 8'b10100110;
  /* 6805.vhd:370:36  */
  assign n497_o = n494_o | n496_o;
  /* 6805.vhd:370:44  */
  assign n499_o = datain == 8'b10101000;
  /* 6805.vhd:370:44  */
  assign n500_o = n497_o | n499_o;
  /* 6805.vhd:371:28  */
  assign n502_o = datain == 8'b10101001;
  /* 6805.vhd:371:28  */
  assign n503_o = n500_o | n502_o;
  /* 6805.vhd:371:36  */
  assign n505_o = datain == 8'b10101010;
  /* 6805.vhd:371:36  */
  assign n506_o = n503_o | n505_o;
  /* 6805.vhd:371:44  */
  assign n508_o = datain == 8'b10101011;
  /* 6805.vhd:371:44  */
  assign n509_o = n506_o | n508_o;
  /* 6805.vhd:371:52  */
  assign n511_o = datain == 8'b10101110;
  /* 6805.vhd:371:52  */
  assign n512_o = n509_o | n511_o;
  /* 6805.vhd:379:34  */
  assign n514_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:375:17  */
  assign n516_o = datain == 8'b11100000;
  /* 6805.vhd:375:28  */
  assign n518_o = datain == 8'b11100001;
  /* 6805.vhd:375:28  */
  assign n519_o = n516_o | n518_o;
  /* 6805.vhd:375:36  */
  assign n521_o = datain == 8'b11100010;
  /* 6805.vhd:375:36  */
  assign n522_o = n519_o | n521_o;
  /* 6805.vhd:375:44  */
  assign n524_o = datain == 8'b11100011;
  /* 6805.vhd:375:44  */
  assign n525_o = n522_o | n524_o;
  /* 6805.vhd:375:52  */
  assign n527_o = datain == 8'b11100100;
  /* 6805.vhd:375:52  */
  assign n528_o = n525_o | n527_o;
  /* 6805.vhd:376:28  */
  assign n530_o = datain == 8'b11100101;
  /* 6805.vhd:376:28  */
  assign n531_o = n528_o | n530_o;
  /* 6805.vhd:376:36  */
  assign n533_o = datain == 8'b11100110;
  /* 6805.vhd:376:36  */
  assign n534_o = n531_o | n533_o;
  /* 6805.vhd:376:44  */
  assign n536_o = datain == 8'b11100111;
  /* 6805.vhd:376:44  */
  assign n537_o = n534_o | n536_o;
  /* 6805.vhd:376:52  */
  assign n539_o = datain == 8'b11101000;
  /* 6805.vhd:376:52  */
  assign n540_o = n537_o | n539_o;
  /* 6805.vhd:377:28  */
  assign n542_o = datain == 8'b11101001;
  /* 6805.vhd:377:28  */
  assign n543_o = n540_o | n542_o;
  /* 6805.vhd:377:36  */
  assign n545_o = datain == 8'b11101010;
  /* 6805.vhd:377:36  */
  assign n546_o = n543_o | n545_o;
  /* 6805.vhd:377:44  */
  assign n548_o = datain == 8'b11101011;
  /* 6805.vhd:377:44  */
  assign n549_o = n546_o | n548_o;
  /* 6805.vhd:377:52  */
  assign n551_o = datain == 8'b11101100;
  /* 6805.vhd:377:52  */
  assign n552_o = n549_o | n551_o;
  /* 6805.vhd:378:28  */
  assign n554_o = datain == 8'b11101110;
  /* 6805.vhd:378:28  */
  assign n555_o = n552_o | n554_o;
  /* 6805.vhd:378:36  */
  assign n557_o = datain == 8'b11101111;
  /* 6805.vhd:378:36  */
  assign n558_o = n555_o | n557_o;
  /* 6805.vhd:386:36  */
  assign n560_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:381:17  */
  assign n562_o = datain == 8'b11110000;
  /* 6805.vhd:381:28  */
  assign n564_o = datain == 8'b11110001;
  /* 6805.vhd:381:28  */
  assign n565_o = n562_o | n564_o;
  /* 6805.vhd:381:36  */
  assign n567_o = datain == 8'b11110010;
  /* 6805.vhd:381:36  */
  assign n568_o = n565_o | n567_o;
  /* 6805.vhd:381:44  */
  assign n570_o = datain == 8'b11110011;
  /* 6805.vhd:381:44  */
  assign n571_o = n568_o | n570_o;
  /* 6805.vhd:381:52  */
  assign n573_o = datain == 8'b11110100;
  /* 6805.vhd:381:52  */
  assign n574_o = n571_o | n573_o;
  /* 6805.vhd:382:28  */
  assign n576_o = datain == 8'b11110101;
  /* 6805.vhd:382:28  */
  assign n577_o = n574_o | n576_o;
  /* 6805.vhd:382:36  */
  assign n579_o = datain == 8'b11110110;
  /* 6805.vhd:382:36  */
  assign n580_o = n577_o | n579_o;
  /* 6805.vhd:382:44  */
  assign n582_o = datain == 8'b11111000;
  /* 6805.vhd:382:44  */
  assign n583_o = n580_o | n582_o;
  /* 6805.vhd:383:28  */
  assign n585_o = datain == 8'b11111001;
  /* 6805.vhd:383:28  */
  assign n586_o = n583_o | n585_o;
  /* 6805.vhd:383:36  */
  assign n588_o = datain == 8'b11111010;
  /* 6805.vhd:383:36  */
  assign n589_o = n586_o | n588_o;
  /* 6805.vhd:383:44  */
  assign n591_o = datain == 8'b11111011;
  /* 6805.vhd:383:44  */
  assign n592_o = n589_o | n591_o;
  /* 6805.vhd:383:52  */
  assign n594_o = datain == 8'b11111110;
  /* 6805.vhd:383:52  */
  assign n595_o = n592_o | n594_o;
  /* 6805.vhd:389:34  */
  assign n597_o = {8'b00000000, regx};
  /* 6805.vhd:388:17  */
  assign n599_o = datain == 8'b11111100;
  /* 6805.vhd:393:32  */
  assign n600_o = rega[7];
  /* 6805.vhd:394:27  */
  assign n602_o = rega == 8'b00000000;
  /* 6805.vhd:394:19  */
  assign n605_o = n602_o ? 1'b1 : 1'b0;
  /* 6805.vhd:401:34  */
  assign n607_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:391:17  */
  assign n609_o = datain == 8'b11110111;
  /* 6805.vhd:405:32  */
  assign n610_o = regx[7];
  /* 6805.vhd:406:27  */
  assign n612_o = regx == 8'b00000000;
  /* 6805.vhd:406:19  */
  assign n615_o = n612_o ? 1'b1 : 1'b0;
  /* 6805.vhd:413:34  */
  assign n617_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:403:17  */
  assign n619_o = datain == 8'b11111111;
  /* 6805.vhd:416:36  */
  assign n621_o = 8'b00000000 - rega;
  /* 6805.vhd:417:36  */
  assign n623_o = 8'b00000000 - rega;
  /* 6805.vhd:418:34  */
  assign n624_o = n623_o[7];
  /* 6805.vhd:419:27  */
  assign n626_o = n623_o == 8'b00000000;
  /* 6805.vhd:419:19  */
  assign n629_o = n626_o ? 1'b1 : 1'b0;
  /* 6805.vhd:419:19  */
  assign n632_o = n626_o ? 1'b0 : 1'b1;
  /* 6805.vhd:426:34  */
  assign n634_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:415:17  */
  assign n636_o = datain == 8'b01000000;
  /* 6805.vhd:431:32  */
  assign n637_o = prod[7:0];
  /* 6805.vhd:432:32  */
  assign n638_o = prod[15:8];
  /* 6805.vhd:433:34  */
  assign n640_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:428:17  */
  assign n642_o = datain == 8'b01000010;
  /* 6805.vhd:436:35  */
  assign n644_o = rega ^ 8'b11111111;
  /* 6805.vhd:437:35  */
  assign n646_o = rega ^ 8'b11111111;
  /* 6805.vhd:439:34  */
  assign n647_o = n646_o[7];
  /* 6805.vhd:440:27  */
  assign n649_o = n646_o == 8'b00000000;
  /* 6805.vhd:440:19  */
  assign n652_o = n649_o ? 1'b1 : 1'b0;
  /* 6805.vhd:445:34  */
  assign n654_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:435:17  */
  assign n656_o = datain == 8'b01000011;
  /* 6805.vhd:448:40  */
  assign n657_o = rega[7:1];
  /* 6805.vhd:448:34  */
  assign n659_o = {1'b0, n657_o};
  /* 6805.vhd:449:40  */
  assign n660_o = rega[7:1];
  /* 6805.vhd:449:34  */
  assign n662_o = {1'b0, n660_o};
  /* 6805.vhd:451:34  */
  assign n663_o = rega[0];
  /* 6805.vhd:452:27  */
  assign n665_o = n662_o == 8'b00000000;
  /* 6805.vhd:452:19  */
  assign n668_o = n665_o ? 1'b1 : 1'b0;
  /* 6805.vhd:457:34  */
  assign n670_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:447:17  */
  assign n672_o = datain == 8'b01000100;
  /* 6805.vhd:460:42  */
  assign n673_o = rega[7:1];
  /* 6805.vhd:460:36  */
  assign n674_o = {flagc, n673_o};
  /* 6805.vhd:461:42  */
  assign n675_o = rega[7:1];
  /* 6805.vhd:461:36  */
  assign n676_o = {flagc, n675_o};
  /* 6805.vhd:463:34  */
  assign n677_o = rega[0];
  /* 6805.vhd:464:27  */
  assign n679_o = n676_o == 8'b00000000;
  /* 6805.vhd:464:19  */
  assign n682_o = n679_o ? 1'b1 : 1'b0;
  /* 6805.vhd:469:34  */
  assign n684_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:459:17  */
  assign n686_o = datain == 8'b01000110;
  /* 6805.vhd:472:34  */
  assign n687_o = rega[7];
  /* 6805.vhd:472:44  */
  assign n688_o = rega[7:1];
  /* 6805.vhd:472:38  */
  assign n689_o = {n687_o, n688_o};
  /* 6805.vhd:473:34  */
  assign n690_o = rega[7];
  /* 6805.vhd:473:44  */
  assign n691_o = rega[7:1];
  /* 6805.vhd:473:38  */
  assign n692_o = {n690_o, n691_o};
  /* 6805.vhd:474:34  */
  assign n693_o = rega[7];
  /* 6805.vhd:475:34  */
  assign n694_o = rega[0];
  /* 6805.vhd:476:27  */
  assign n696_o = n692_o == 8'b00000000;
  /* 6805.vhd:476:19  */
  assign n699_o = n696_o ? 1'b1 : 1'b0;
  /* 6805.vhd:481:34  */
  assign n701_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:471:17  */
  assign n703_o = datain == 8'b01000111;
  /* 6805.vhd:484:34  */
  assign n704_o = rega[6:0];
  /* 6805.vhd:484:47  */
  assign n706_o = {n704_o, 1'b0};
  /* 6805.vhd:485:34  */
  assign n707_o = rega[6:0];
  /* 6805.vhd:485:47  */
  assign n709_o = {n707_o, 1'b0};
  /* 6805.vhd:486:34  */
  assign n710_o = rega[6];
  /* 6805.vhd:487:34  */
  assign n711_o = rega[7];
  /* 6805.vhd:488:27  */
  assign n713_o = n709_o == 8'b00000000;
  /* 6805.vhd:488:19  */
  assign n716_o = n713_o ? 1'b1 : 1'b0;
  /* 6805.vhd:493:34  */
  assign n718_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:483:17  */
  assign n720_o = datain == 8'b01001000;
  /* 6805.vhd:496:34  */
  assign n721_o = rega[6:0];
  /* 6805.vhd:496:47  */
  assign n722_o = {n721_o, flagc};
  /* 6805.vhd:497:34  */
  assign n723_o = rega[6:0];
  /* 6805.vhd:497:47  */
  assign n724_o = {n723_o, flagc};
  /* 6805.vhd:498:34  */
  assign n725_o = rega[6];
  /* 6805.vhd:499:34  */
  assign n726_o = rega[7];
  /* 6805.vhd:500:27  */
  assign n728_o = n724_o == 8'b00000000;
  /* 6805.vhd:500:19  */
  assign n731_o = n728_o ? 1'b1 : 1'b0;
  /* 6805.vhd:505:34  */
  assign n733_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:495:17  */
  assign n735_o = datain == 8'b01001001;
  /* 6805.vhd:508:35  */
  assign n737_o = rega - 8'b00000001;
  /* 6805.vhd:509:35  */
  assign n739_o = rega - 8'b00000001;
  /* 6805.vhd:510:34  */
  assign n740_o = n739_o[7];
  /* 6805.vhd:511:27  */
  assign n742_o = n739_o == 8'b00000000;
  /* 6805.vhd:511:19  */
  assign n745_o = n742_o ? 1'b1 : 1'b0;
  /* 6805.vhd:516:34  */
  assign n747_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:507:17  */
  assign n749_o = datain == 8'b01001010;
  /* 6805.vhd:519:35  */
  assign n751_o = rega + 8'b00000001;
  /* 6805.vhd:520:35  */
  assign n753_o = rega + 8'b00000001;
  /* 6805.vhd:521:34  */
  assign n754_o = n753_o[7];
  /* 6805.vhd:522:27  */
  assign n756_o = n753_o == 8'b00000000;
  /* 6805.vhd:522:19  */
  assign n759_o = n756_o ? 1'b1 : 1'b0;
  /* 6805.vhd:527:34  */
  assign n761_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:518:17  */
  assign n763_o = datain == 8'b01001100;
  /* 6805.vhd:530:34  */
  assign n764_o = rega[7];
  /* 6805.vhd:531:27  */
  assign n766_o = rega == 8'b00000000;
  /* 6805.vhd:531:19  */
  assign n769_o = n766_o ? 1'b1 : 1'b0;
  /* 6805.vhd:536:34  */
  assign n771_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:529:17  */
  assign n773_o = datain == 8'b01001101;
  /* 6805.vhd:542:34  */
  assign n775_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:538:17  */
  assign n777_o = datain == 8'b01001111;
  /* 6805.vhd:545:33  */
  assign n779_o = 8'b00000000 - regx;
  /* 6805.vhd:546:33  */
  assign n781_o = 8'b00000000 - regx;
  /* 6805.vhd:547:34  */
  assign n782_o = n781_o[7];
  /* 6805.vhd:548:27  */
  assign n784_o = n781_o == 8'b00000000;
  /* 6805.vhd:548:19  */
  assign n787_o = n784_o ? 1'b1 : 1'b0;
  /* 6805.vhd:548:19  */
  assign n790_o = n784_o ? 1'b0 : 1'b1;
  /* 6805.vhd:555:34  */
  assign n792_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:544:17  */
  assign n794_o = datain == 8'b01010000;
  /* 6805.vhd:558:32  */
  assign n796_o = regx ^ 8'b11111111;
  /* 6805.vhd:559:32  */
  assign n798_o = regx ^ 8'b11111111;
  /* 6805.vhd:561:34  */
  assign n799_o = n798_o[7];
  /* 6805.vhd:562:27  */
  assign n801_o = n798_o == 8'b00000000;
  /* 6805.vhd:562:19  */
  assign n804_o = n801_o ? 1'b1 : 1'b0;
  /* 6805.vhd:567:34  */
  assign n806_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:557:17  */
  assign n808_o = datain == 8'b01010011;
  /* 6805.vhd:570:37  */
  assign n809_o = regx[7:1];
  /* 6805.vhd:570:31  */
  assign n811_o = {1'b0, n809_o};
  /* 6805.vhd:571:37  */
  assign n812_o = regx[7:1];
  /* 6805.vhd:571:31  */
  assign n814_o = {1'b0, n812_o};
  /* 6805.vhd:573:34  */
  assign n815_o = regx[0];
  /* 6805.vhd:574:27  */
  assign n817_o = n814_o == 8'b00000000;
  /* 6805.vhd:574:19  */
  assign n820_o = n817_o ? 1'b1 : 1'b0;
  /* 6805.vhd:579:34  */
  assign n822_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:569:17  */
  assign n824_o = datain == 8'b01010100;
  /* 6805.vhd:582:39  */
  assign n825_o = regx[7:1];
  /* 6805.vhd:582:33  */
  assign n826_o = {flagc, n825_o};
  /* 6805.vhd:583:39  */
  assign n827_o = regx[7:1];
  /* 6805.vhd:583:33  */
  assign n828_o = {flagc, n827_o};
  /* 6805.vhd:585:34  */
  assign n829_o = regx[0];
  /* 6805.vhd:586:27  */
  assign n831_o = n828_o == 8'b00000000;
  /* 6805.vhd:586:19  */
  assign n834_o = n831_o ? 1'b1 : 1'b0;
  /* 6805.vhd:591:34  */
  assign n836_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:581:17  */
  assign n838_o = datain == 8'b01010110;
  /* 6805.vhd:594:31  */
  assign n839_o = regx[7];
  /* 6805.vhd:594:41  */
  assign n840_o = regx[7:1];
  /* 6805.vhd:594:35  */
  assign n841_o = {n839_o, n840_o};
  /* 6805.vhd:595:31  */
  assign n842_o = regx[7];
  /* 6805.vhd:595:41  */
  assign n843_o = regx[7:1];
  /* 6805.vhd:595:35  */
  assign n844_o = {n842_o, n843_o};
  /* 6805.vhd:596:34  */
  assign n845_o = regx[7];
  /* 6805.vhd:597:34  */
  assign n846_o = regx[0];
  /* 6805.vhd:598:27  */
  assign n848_o = n844_o == 8'b00000000;
  /* 6805.vhd:598:19  */
  assign n851_o = n848_o ? 1'b1 : 1'b0;
  /* 6805.vhd:603:34  */
  assign n853_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:593:17  */
  assign n855_o = datain == 8'b01010111;
  /* 6805.vhd:606:31  */
  assign n856_o = regx[6:0];
  /* 6805.vhd:606:44  */
  assign n858_o = {n856_o, 1'b0};
  /* 6805.vhd:607:31  */
  assign n859_o = regx[6:0];
  /* 6805.vhd:607:44  */
  assign n861_o = {n859_o, 1'b0};
  /* 6805.vhd:608:34  */
  assign n862_o = regx[6];
  /* 6805.vhd:609:34  */
  assign n863_o = regx[7];
  /* 6805.vhd:610:27  */
  assign n865_o = n861_o == 8'b00000000;
  /* 6805.vhd:610:19  */
  assign n868_o = n865_o ? 1'b1 : 1'b0;
  /* 6805.vhd:615:34  */
  assign n870_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:605:17  */
  assign n872_o = datain == 8'b01011000;
  /* 6805.vhd:618:31  */
  assign n873_o = regx[6:0];
  /* 6805.vhd:618:44  */
  assign n874_o = {n873_o, flagc};
  /* 6805.vhd:619:31  */
  assign n875_o = regx[6:0];
  /* 6805.vhd:619:44  */
  assign n876_o = {n875_o, flagc};
  /* 6805.vhd:620:34  */
  assign n877_o = regx[6];
  /* 6805.vhd:621:34  */
  assign n878_o = regx[7];
  /* 6805.vhd:622:27  */
  assign n880_o = n876_o == 8'b00000000;
  /* 6805.vhd:622:19  */
  assign n883_o = n880_o ? 1'b1 : 1'b0;
  /* 6805.vhd:627:34  */
  assign n885_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:617:17  */
  assign n887_o = datain == 8'b01011001;
  /* 6805.vhd:630:44  */
  assign n889_o = regx - 8'b00000001;
  /* 6805.vhd:631:44  */
  assign n891_o = regx - 8'b00000001;
  /* 6805.vhd:632:34  */
  assign n892_o = n891_o[7];
  /* 6805.vhd:633:27  */
  assign n894_o = n891_o == 8'b00000000;
  /* 6805.vhd:633:19  */
  assign n897_o = n894_o ? 1'b1 : 1'b0;
  /* 6805.vhd:638:34  */
  assign n899_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:629:17  */
  assign n901_o = datain == 8'b01011010;
  /* 6805.vhd:641:44  */
  assign n903_o = regx + 8'b00000001;
  /* 6805.vhd:642:44  */
  assign n905_o = regx + 8'b00000001;
  /* 6805.vhd:643:34  */
  assign n906_o = n905_o[7];
  /* 6805.vhd:644:27  */
  assign n908_o = n905_o == 8'b00000000;
  /* 6805.vhd:644:19  */
  assign n911_o = n908_o ? 1'b1 : 1'b0;
  /* 6805.vhd:649:34  */
  assign n913_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:640:17  */
  assign n915_o = datain == 8'b01011100;
  /* 6805.vhd:652:34  */
  assign n916_o = regx[7];
  /* 6805.vhd:653:27  */
  assign n918_o = regx == 8'b00000000;
  /* 6805.vhd:653:19  */
  assign n921_o = n918_o ? 1'b1 : 1'b0;
  /* 6805.vhd:658:34  */
  assign n923_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:651:17  */
  assign n925_o = datain == 8'b01011101;
  /* 6805.vhd:664:34  */
  assign n927_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:660:17  */
  assign n929_o = datain == 8'b01011111;
  /* 6805.vhd:669:33  */
  assign n931_o = {8'b00000000, regx};
  /* 6805.vhd:670:36  */
  assign n933_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:666:17  */
  assign n935_o = datain == 8'b01100000;
  /* 6805.vhd:666:28  */
  assign n937_o = datain == 8'b01100011;
  /* 6805.vhd:666:28  */
  assign n938_o = n935_o | n937_o;
  /* 6805.vhd:666:36  */
  assign n940_o = datain == 8'b01100100;
  /* 6805.vhd:666:36  */
  assign n941_o = n938_o | n940_o;
  /* 6805.vhd:666:44  */
  assign n943_o = datain == 8'b01100110;
  /* 6805.vhd:666:44  */
  assign n944_o = n941_o | n943_o;
  /* 6805.vhd:666:52  */
  assign n946_o = datain == 8'b01100111;
  /* 6805.vhd:666:52  */
  assign n947_o = n944_o | n946_o;
  /* 6805.vhd:667:28  */
  assign n949_o = datain == 8'b01101000;
  /* 6805.vhd:667:28  */
  assign n950_o = n947_o | n949_o;
  /* 6805.vhd:667:36  */
  assign n952_o = datain == 8'b01101001;
  /* 6805.vhd:667:36  */
  assign n953_o = n950_o | n952_o;
  /* 6805.vhd:667:44  */
  assign n955_o = datain == 8'b01101010;
  /* 6805.vhd:667:44  */
  assign n956_o = n953_o | n955_o;
  /* 6805.vhd:667:52  */
  assign n958_o = datain == 8'b01101100;
  /* 6805.vhd:667:52  */
  assign n959_o = n956_o | n958_o;
  /* 6805.vhd:668:28  */
  assign n961_o = datain == 8'b01101101;
  /* 6805.vhd:668:28  */
  assign n962_o = n959_o | n961_o;
  /* 6805.vhd:668:36  */
  assign n964_o = datain == 8'b01101111;
  /* 6805.vhd:668:36  */
  assign n965_o = n962_o | n964_o;
  /* 6805.vhd:679:34  */
  assign n967_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:672:17  */
  assign n969_o = datain == 8'b01111111;
  /* 6805.vhd:682:36  */
  assign n971_o = regsp + 16'b0000000000000001;
  /* 6805.vhd:681:17  */
  assign n973_o = datain == 8'b10000000;
  /* 6805.vhd:681:28  */
  assign n975_o = datain == 8'b10000001;
  /* 6805.vhd:681:28  */
  assign n976_o = n973_o | n975_o;
  /* 6805.vhd:686:36  */
  assign n978_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:685:17  */
  assign n980_o = datain == 8'b10000011;
  /* 6805.vhd:690:36  */
  assign n982_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:689:17  */
  assign n984_o = datain == 8'b10001110;
  /* 6805.vhd:693:36  */
  assign n986_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:692:17  */
  assign n988_o = datain == 8'b10001111;
  /* 6805.vhd:697:36  */
  assign n990_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:695:17  */
  assign n992_o = datain == 8'b10010111;
  /* 6805.vhd:700:34  */
  assign n993_o = datain[0];
  /* 6805.vhd:701:36  */
  assign n995_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:699:17  */
  assign n997_o = datain == 8'b10011000;
  /* 6805.vhd:699:28  */
  assign n999_o = datain == 8'b10011001;
  /* 6805.vhd:699:28  */
  assign n1000_o = n997_o | n999_o;
  /* 6805.vhd:704:34  */
  assign n1001_o = datain[0];
  /* 6805.vhd:705:36  */
  assign n1003_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:703:17  */
  assign n1005_o = datain == 8'b10011010;
  /* 6805.vhd:703:28  */
  assign n1007_o = datain == 8'b10011011;
  /* 6805.vhd:703:28  */
  assign n1008_o = n1005_o | n1007_o;
  /* 6805.vhd:709:36  */
  assign n1010_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:707:17  */
  assign n1012_o = datain == 8'b10011100;
  /* 6805.vhd:719:36  */
  assign n1014_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:711:17  */
  assign n1016_o = datain == 8'b00110001;
  /* 6805.vhd:711:28  */
  assign n1018_o = datain == 8'b01000001;
  /* 6805.vhd:711:28  */
  assign n1019_o = n1016_o | n1018_o;
  /* 6805.vhd:711:36  */
  assign n1021_o = datain == 8'b00110101;
  /* 6805.vhd:711:36  */
  assign n1022_o = n1019_o | n1021_o;
  /* 6805.vhd:711:44  */
  assign n1024_o = datain == 8'b00111011;
  /* 6805.vhd:711:44  */
  assign n1025_o = n1022_o | n1024_o;
  /* 6805.vhd:711:52  */
  assign n1027_o = datain == 8'b01000101;
  /* 6805.vhd:711:52  */
  assign n1028_o = n1025_o | n1027_o;
  /* 6805.vhd:711:60  */
  assign n1030_o = datain == 8'b01001011;
  /* 6805.vhd:711:60  */
  assign n1031_o = n1028_o | n1030_o;
  /* 6805.vhd:712:28  */
  assign n1033_o = datain == 8'b01001110;
  /* 6805.vhd:712:28  */
  assign n1034_o = n1031_o | n1033_o;
  /* 6805.vhd:712:36  */
  assign n1036_o = datain == 8'b01010001;
  /* 6805.vhd:712:36  */
  assign n1037_o = n1034_o | n1036_o;
  /* 6805.vhd:712:44  */
  assign n1039_o = datain == 8'b01010010;
  /* 6805.vhd:712:44  */
  assign n1040_o = n1037_o | n1039_o;
  /* 6805.vhd:712:52  */
  assign n1042_o = datain == 8'b01010101;
  /* 6805.vhd:712:52  */
  assign n1043_o = n1040_o | n1042_o;
  /* 6805.vhd:712:60  */
  assign n1045_o = datain == 8'b01011011;
  /* 6805.vhd:712:60  */
  assign n1046_o = n1043_o | n1045_o;
  /* 6805.vhd:713:28  */
  assign n1048_o = datain == 8'b01011110;
  /* 6805.vhd:713:28  */
  assign n1049_o = n1046_o | n1048_o;
  /* 6805.vhd:713:36  */
  assign n1051_o = datain == 8'b01100001;
  /* 6805.vhd:713:36  */
  assign n1052_o = n1049_o | n1051_o;
  /* 6805.vhd:713:44  */
  assign n1054_o = datain == 8'b01100010;
  /* 6805.vhd:713:44  */
  assign n1055_o = n1052_o | n1054_o;
  /* 6805.vhd:713:52  */
  assign n1057_o = datain == 8'b01100101;
  /* 6805.vhd:713:52  */
  assign n1058_o = n1055_o | n1057_o;
  /* 6805.vhd:713:60  */
  assign n1060_o = datain == 8'b01101011;
  /* 6805.vhd:713:60  */
  assign n1061_o = n1058_o | n1060_o;
  /* 6805.vhd:714:28  */
  assign n1063_o = datain == 8'b01101110;
  /* 6805.vhd:714:28  */
  assign n1064_o = n1061_o | n1063_o;
  /* 6805.vhd:714:36  */
  assign n1066_o = datain == 8'b01110001;
  /* 6805.vhd:714:36  */
  assign n1067_o = n1064_o | n1066_o;
  /* 6805.vhd:714:44  */
  assign n1069_o = datain == 8'b01110010;
  /* 6805.vhd:714:44  */
  assign n1070_o = n1067_o | n1069_o;
  /* 6805.vhd:714:52  */
  assign n1072_o = datain == 8'b01110101;
  /* 6805.vhd:714:52  */
  assign n1073_o = n1070_o | n1072_o;
  /* 6805.vhd:714:60  */
  assign n1075_o = datain == 8'b01111011;
  /* 6805.vhd:714:60  */
  assign n1076_o = n1073_o | n1075_o;
  /* 6805.vhd:714:68  */
  assign n1078_o = datain == 8'b01111110;
  /* 6805.vhd:714:68  */
  assign n1079_o = n1076_o | n1078_o;
  /* 6805.vhd:714:76  */
  assign n1081_o = datain == 8'b10000100;
  /* 6805.vhd:714:76  */
  assign n1082_o = n1079_o | n1081_o;
  /* 6805.vhd:715:28  */
  assign n1084_o = datain == 8'b10000101;
  /* 6805.vhd:715:28  */
  assign n1085_o = n1082_o | n1084_o;
  /* 6805.vhd:715:36  */
  assign n1087_o = datain == 8'b10000110;
  /* 6805.vhd:715:36  */
  assign n1088_o = n1085_o | n1087_o;
  /* 6805.vhd:715:44  */
  assign n1090_o = datain == 8'b10000111;
  /* 6805.vhd:715:44  */
  assign n1091_o = n1088_o | n1090_o;
  /* 6805.vhd:715:52  */
  assign n1093_o = datain == 8'b10001000;
  /* 6805.vhd:715:52  */
  assign n1094_o = n1091_o | n1093_o;
  /* 6805.vhd:715:60  */
  assign n1096_o = datain == 8'b10001001;
  /* 6805.vhd:715:60  */
  assign n1097_o = n1094_o | n1096_o;
  /* 6805.vhd:716:28  */
  assign n1099_o = datain == 8'b10001010;
  /* 6805.vhd:716:28  */
  assign n1100_o = n1097_o | n1099_o;
  /* 6805.vhd:716:36  */
  assign n1102_o = datain == 8'b10001011;
  /* 6805.vhd:716:36  */
  assign n1103_o = n1100_o | n1102_o;
  /* 6805.vhd:716:44  */
  assign n1105_o = datain == 8'b10001100;
  /* 6805.vhd:716:44  */
  assign n1106_o = n1103_o | n1105_o;
  /* 6805.vhd:716:52  */
  assign n1108_o = datain == 8'b10001101;
  /* 6805.vhd:716:52  */
  assign n1109_o = n1106_o | n1108_o;
  /* 6805.vhd:716:60  */
  assign n1111_o = datain == 8'b10010000;
  /* 6805.vhd:716:60  */
  assign n1112_o = n1109_o | n1111_o;
  /* 6805.vhd:717:28  */
  assign n1114_o = datain == 8'b10010001;
  /* 6805.vhd:717:28  */
  assign n1115_o = n1112_o | n1114_o;
  /* 6805.vhd:717:36  */
  assign n1117_o = datain == 8'b10010010;
  /* 6805.vhd:717:36  */
  assign n1118_o = n1115_o | n1117_o;
  /* 6805.vhd:717:44  */
  assign n1120_o = datain == 8'b10010011;
  /* 6805.vhd:717:44  */
  assign n1121_o = n1118_o | n1120_o;
  /* 6805.vhd:717:52  */
  assign n1123_o = datain == 8'b10010100;
  /* 6805.vhd:717:52  */
  assign n1124_o = n1121_o | n1123_o;
  /* 6805.vhd:717:60  */
  assign n1126_o = datain == 8'b10010101;
  /* 6805.vhd:717:60  */
  assign n1127_o = n1124_o | n1126_o;
  /* 6805.vhd:717:68  */
  assign n1129_o = datain == 8'b10011101;
  /* 6805.vhd:717:68  */
  assign n1130_o = n1127_o | n1129_o;
  /* 6805.vhd:717:76  */
  assign n1132_o = datain == 8'b10011110;
  /* 6805.vhd:717:76  */
  assign n1133_o = n1130_o | n1132_o;
  /* 6805.vhd:717:84  */
  assign n1135_o = datain == 8'b10100111;
  /* 6805.vhd:717:84  */
  assign n1136_o = n1133_o | n1135_o;
  /* 6805.vhd:718:28  */
  assign n1138_o = datain == 8'b10101100;
  /* 6805.vhd:718:28  */
  assign n1139_o = n1136_o | n1138_o;
  /* 6805.vhd:718:36  */
  assign n1141_o = datain == 8'b10101111;
  /* 6805.vhd:718:36  */
  assign n1142_o = n1139_o | n1141_o;
  /* 6805.vhd:723:36  */
  assign n1144_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:721:17  */
  assign n1146_o = datain == 8'b10011111;
  /* 6805.vhd:726:36  */
  assign n1148_o = regpc + 16'b0000000000000010;
  /* 6805.vhd:727:36  */
  assign n1150_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:725:17  */
  assign n1152_o = datain == 8'b10101101;
  /* 6805.vhd:725:28  */
  assign n1154_o = datain == 8'b10111101;
  /* 6805.vhd:725:28  */
  assign n1155_o = n1152_o | n1154_o;
  /* 6805.vhd:725:36  */
  assign n1157_o = datain == 8'b11101101;
  /* 6805.vhd:725:36  */
  assign n1158_o = n1155_o | n1157_o;
  /* 6805.vhd:730:36  */
  assign n1160_o = regpc + 16'b0000000000000011;
  /* 6805.vhd:731:36  */
  assign n1162_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:729:17  */
  assign n1164_o = datain == 8'b11001101;
  /* 6805.vhd:729:28  */
  assign n1166_o = datain == 8'b11011101;
  /* 6805.vhd:729:28  */
  assign n1167_o = n1164_o | n1166_o;
  /* 6805.vhd:734:36  */
  assign n1169_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:738:36  */
  assign n1171_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:733:17  */
  assign n1173_o = datain == 8'b11111101;
  assign n1174_o = {n1173_o, n1167_o, n1158_o, n1146_o, n1142_o, n1012_o, n1008_o, n1000_o, n992_o, n988_o, n984_o, n980_o, n976_o, n969_o, n965_o, n929_o, n925_o, n915_o, n901_o, n887_o, n872_o, n855_o, n838_o, n824_o, n808_o, n794_o, n777_o, n773_o, n763_o, n749_o, n735_o, n720_o, n703_o, n686_o, n672_o, n656_o, n642_o, n636_o, n619_o, n609_o, n599_o, n595_o, n558_o, n512_o, n475_o, n444_o, n305_o, n130_o};
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1179_o = 1'b0;
      48'b010000000000000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b001000000000000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000100000000000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000010000000000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000001000000000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000100000000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000010000000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000001000000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000100000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000010000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000001000000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000100000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000010000000000000000000000000000000000: n1179_o = 1'b0;
      48'b000000000000001000000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000100000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000010000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000001000000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000100000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000010000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000001000000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000100000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000010000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000001000000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000100000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000010000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000001000000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000100000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000010000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000001000000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000100000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000010000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000001000000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000100000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000010000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000001000000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000100000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000010000000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000001000000000: n1179_o = 1'b0;
      48'b000000000000000000000000000000000000000100000000: n1179_o = 1'b0;
      48'b000000000000000000000000000000000000000010000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000000001000000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000000000100000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000000000010000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000000000001000: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000000000000100: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000000000000010: n1179_o = n3854_q;
      48'b000000000000000000000000000000000000000000000001: n1179_o = n3854_q;
      default: n1179_o = n3854_q;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1181_o = rega;
      48'b010000000000000000000000000000000000000000000000: n1181_o = rega;
      48'b001000000000000000000000000000000000000000000000: n1181_o = rega;
      48'b000100000000000000000000000000000000000000000000: n1181_o = regx;
      48'b000010000000000000000000000000000000000000000000: n1181_o = rega;
      48'b000001000000000000000000000000000000000000000000: n1181_o = rega;
      48'b000000100000000000000000000000000000000000000000: n1181_o = rega;
      48'b000000010000000000000000000000000000000000000000: n1181_o = rega;
      48'b000000001000000000000000000000000000000000000000: n1181_o = rega;
      48'b000000000100000000000000000000000000000000000000: n1181_o = rega;
      48'b000000000010000000000000000000000000000000000000: n1181_o = rega;
      48'b000000000001000000000000000000000000000000000000: n1181_o = rega;
      48'b000000000000100000000000000000000000000000000000: n1181_o = rega;
      48'b000000000000010000000000000000000000000000000000: n1181_o = rega;
      48'b000000000000001000000000000000000000000000000000: n1181_o = rega;
      48'b000000000000000100000000000000000000000000000000: n1181_o = rega;
      48'b000000000000000010000000000000000000000000000000: n1181_o = rega;
      48'b000000000000000001000000000000000000000000000000: n1181_o = rega;
      48'b000000000000000000100000000000000000000000000000: n1181_o = rega;
      48'b000000000000000000010000000000000000000000000000: n1181_o = rega;
      48'b000000000000000000001000000000000000000000000000: n1181_o = rega;
      48'b000000000000000000000100000000000000000000000000: n1181_o = rega;
      48'b000000000000000000000010000000000000000000000000: n1181_o = rega;
      48'b000000000000000000000001000000000000000000000000: n1181_o = rega;
      48'b000000000000000000000000100000000000000000000000: n1181_o = rega;
      48'b000000000000000000000000010000000000000000000000: n1181_o = rega;
      48'b000000000000000000000000001000000000000000000000: n1181_o = 8'b00000000;
      48'b000000000000000000000000000100000000000000000000: n1181_o = rega;
      48'b000000000000000000000000000010000000000000000000: n1181_o = n751_o;
      48'b000000000000000000000000000001000000000000000000: n1181_o = n737_o;
      48'b000000000000000000000000000000100000000000000000: n1181_o = n722_o;
      48'b000000000000000000000000000000010000000000000000: n1181_o = n706_o;
      48'b000000000000000000000000000000001000000000000000: n1181_o = n689_o;
      48'b000000000000000000000000000000000100000000000000: n1181_o = n674_o;
      48'b000000000000000000000000000000000010000000000000: n1181_o = n659_o;
      48'b000000000000000000000000000000000001000000000000: n1181_o = n644_o;
      48'b000000000000000000000000000000000000100000000000: n1181_o = n637_o;
      48'b000000000000000000000000000000000000010000000000: n1181_o = n621_o;
      48'b000000000000000000000000000000000000001000000000: n1181_o = rega;
      48'b000000000000000000000000000000000000000100000000: n1181_o = rega;
      48'b000000000000000000000000000000000000000010000000: n1181_o = rega;
      48'b000000000000000000000000000000000000000001000000: n1181_o = rega;
      48'b000000000000000000000000000000000000000000100000: n1181_o = rega;
      48'b000000000000000000000000000000000000000000010000: n1181_o = rega;
      48'b000000000000000000000000000000000000000000001000: n1181_o = rega;
      48'b000000000000000000000000000000000000000000000100: n1181_o = rega;
      48'b000000000000000000000000000000000000000000000010: n1181_o = rega;
      48'b000000000000000000000000000000000000000000000001: n1181_o = rega;
      default: n1181_o = rega;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1183_o = regx;
      48'b010000000000000000000000000000000000000000000000: n1183_o = regx;
      48'b001000000000000000000000000000000000000000000000: n1183_o = regx;
      48'b000100000000000000000000000000000000000000000000: n1183_o = regx;
      48'b000010000000000000000000000000000000000000000000: n1183_o = regx;
      48'b000001000000000000000000000000000000000000000000: n1183_o = regx;
      48'b000000100000000000000000000000000000000000000000: n1183_o = regx;
      48'b000000010000000000000000000000000000000000000000: n1183_o = regx;
      48'b000000001000000000000000000000000000000000000000: n1183_o = rega;
      48'b000000000100000000000000000000000000000000000000: n1183_o = regx;
      48'b000000000010000000000000000000000000000000000000: n1183_o = regx;
      48'b000000000001000000000000000000000000000000000000: n1183_o = regx;
      48'b000000000000100000000000000000000000000000000000: n1183_o = regx;
      48'b000000000000010000000000000000000000000000000000: n1183_o = regx;
      48'b000000000000001000000000000000000000000000000000: n1183_o = regx;
      48'b000000000000000100000000000000000000000000000000: n1183_o = 8'b00000000;
      48'b000000000000000010000000000000000000000000000000: n1183_o = regx;
      48'b000000000000000001000000000000000000000000000000: n1183_o = n903_o;
      48'b000000000000000000100000000000000000000000000000: n1183_o = n889_o;
      48'b000000000000000000010000000000000000000000000000: n1183_o = n874_o;
      48'b000000000000000000001000000000000000000000000000: n1183_o = n858_o;
      48'b000000000000000000000100000000000000000000000000: n1183_o = n841_o;
      48'b000000000000000000000010000000000000000000000000: n1183_o = n826_o;
      48'b000000000000000000000001000000000000000000000000: n1183_o = n811_o;
      48'b000000000000000000000000100000000000000000000000: n1183_o = n796_o;
      48'b000000000000000000000000010000000000000000000000: n1183_o = n779_o;
      48'b000000000000000000000000001000000000000000000000: n1183_o = regx;
      48'b000000000000000000000000000100000000000000000000: n1183_o = regx;
      48'b000000000000000000000000000010000000000000000000: n1183_o = regx;
      48'b000000000000000000000000000001000000000000000000: n1183_o = regx;
      48'b000000000000000000000000000000100000000000000000: n1183_o = regx;
      48'b000000000000000000000000000000010000000000000000: n1183_o = regx;
      48'b000000000000000000000000000000001000000000000000: n1183_o = regx;
      48'b000000000000000000000000000000000100000000000000: n1183_o = regx;
      48'b000000000000000000000000000000000010000000000000: n1183_o = regx;
      48'b000000000000000000000000000000000001000000000000: n1183_o = regx;
      48'b000000000000000000000000000000000000100000000000: n1183_o = n638_o;
      48'b000000000000000000000000000000000000010000000000: n1183_o = regx;
      48'b000000000000000000000000000000000000001000000000: n1183_o = regx;
      48'b000000000000000000000000000000000000000100000000: n1183_o = regx;
      48'b000000000000000000000000000000000000000010000000: n1183_o = regx;
      48'b000000000000000000000000000000000000000001000000: n1183_o = regx;
      48'b000000000000000000000000000000000000000000100000: n1183_o = regx;
      48'b000000000000000000000000000000000000000000010000: n1183_o = regx;
      48'b000000000000000000000000000000000000000000001000: n1183_o = regx;
      48'b000000000000000000000000000000000000000000000100: n1183_o = regx;
      48'b000000000000000000000000000000000000000000000010: n1183_o = regx;
      48'b000000000000000000000000000000000000000000000001: n1183_o = regx;
      default: n1183_o = regx;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1185_o = regsp;
      48'b010000000000000000000000000000000000000000000000: n1185_o = regsp;
      48'b001000000000000000000000000000000000000000000000: n1185_o = regsp;
      48'b000100000000000000000000000000000000000000000000: n1185_o = regsp;
      48'b000010000000000000000000000000000000000000000000: n1185_o = regsp;
      48'b000001000000000000000000000000000000000000000000: n1185_o = 16'b0000000011111111;
      48'b000000100000000000000000000000000000000000000000: n1185_o = regsp;
      48'b000000010000000000000000000000000000000000000000: n1185_o = regsp;
      48'b000000001000000000000000000000000000000000000000: n1185_o = regsp;
      48'b000000000100000000000000000000000000000000000000: n1185_o = regsp;
      48'b000000000010000000000000000000000000000000000000: n1185_o = regsp;
      48'b000000000001000000000000000000000000000000000000: n1185_o = regsp;
      48'b000000000000100000000000000000000000000000000000: n1185_o = n971_o;
      48'b000000000000010000000000000000000000000000000000: n1185_o = regsp;
      48'b000000000000001000000000000000000000000000000000: n1185_o = regsp;
      48'b000000000000000100000000000000000000000000000000: n1185_o = regsp;
      48'b000000000000000010000000000000000000000000000000: n1185_o = regsp;
      48'b000000000000000001000000000000000000000000000000: n1185_o = regsp;
      48'b000000000000000000100000000000000000000000000000: n1185_o = regsp;
      48'b000000000000000000010000000000000000000000000000: n1185_o = regsp;
      48'b000000000000000000001000000000000000000000000000: n1185_o = regsp;
      48'b000000000000000000000100000000000000000000000000: n1185_o = regsp;
      48'b000000000000000000000010000000000000000000000000: n1185_o = regsp;
      48'b000000000000000000000001000000000000000000000000: n1185_o = regsp;
      48'b000000000000000000000000100000000000000000000000: n1185_o = regsp;
      48'b000000000000000000000000010000000000000000000000: n1185_o = regsp;
      48'b000000000000000000000000001000000000000000000000: n1185_o = regsp;
      48'b000000000000000000000000000100000000000000000000: n1185_o = regsp;
      48'b000000000000000000000000000010000000000000000000: n1185_o = regsp;
      48'b000000000000000000000000000001000000000000000000: n1185_o = regsp;
      48'b000000000000000000000000000000100000000000000000: n1185_o = regsp;
      48'b000000000000000000000000000000010000000000000000: n1185_o = regsp;
      48'b000000000000000000000000000000001000000000000000: n1185_o = regsp;
      48'b000000000000000000000000000000000100000000000000: n1185_o = regsp;
      48'b000000000000000000000000000000000010000000000000: n1185_o = regsp;
      48'b000000000000000000000000000000000001000000000000: n1185_o = regsp;
      48'b000000000000000000000000000000000000100000000000: n1185_o = regsp;
      48'b000000000000000000000000000000000000010000000000: n1185_o = regsp;
      48'b000000000000000000000000000000000000001000000000: n1185_o = regsp;
      48'b000000000000000000000000000000000000000100000000: n1185_o = regsp;
      48'b000000000000000000000000000000000000000010000000: n1185_o = regsp;
      48'b000000000000000000000000000000000000000001000000: n1185_o = regsp;
      48'b000000000000000000000000000000000000000000100000: n1185_o = regsp;
      48'b000000000000000000000000000000000000000000010000: n1185_o = regsp;
      48'b000000000000000000000000000000000000000000001000: n1185_o = regsp;
      48'b000000000000000000000000000000000000000000000100: n1185_o = regsp;
      48'b000000000000000000000000000000000000000000000010: n1185_o = regsp;
      48'b000000000000000000000000000000000000000000000001: n1185_o = n128_o;
      default: n1185_o = regsp;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1186_o = n1171_o;
      48'b010000000000000000000000000000000000000000000000: n1186_o = n1162_o;
      48'b001000000000000000000000000000000000000000000000: n1186_o = n1150_o;
      48'b000100000000000000000000000000000000000000000000: n1186_o = n1144_o;
      48'b000010000000000000000000000000000000000000000000: n1186_o = n1014_o;
      48'b000001000000000000000000000000000000000000000000: n1186_o = n1010_o;
      48'b000000100000000000000000000000000000000000000000: n1186_o = n1003_o;
      48'b000000010000000000000000000000000000000000000000: n1186_o = n995_o;
      48'b000000001000000000000000000000000000000000000000: n1186_o = n990_o;
      48'b000000000100000000000000000000000000000000000000: n1186_o = n986_o;
      48'b000000000010000000000000000000000000000000000000: n1186_o = n982_o;
      48'b000000000001000000000000000000000000000000000000: n1186_o = n978_o;
      48'b000000000000100000000000000000000000000000000000: n1186_o = regpc;
      48'b000000000000010000000000000000000000000000000000: n1186_o = n967_o;
      48'b000000000000001000000000000000000000000000000000: n1186_o = n933_o;
      48'b000000000000000100000000000000000000000000000000: n1186_o = n927_o;
      48'b000000000000000010000000000000000000000000000000: n1186_o = n923_o;
      48'b000000000000000001000000000000000000000000000000: n1186_o = n913_o;
      48'b000000000000000000100000000000000000000000000000: n1186_o = n899_o;
      48'b000000000000000000010000000000000000000000000000: n1186_o = n885_o;
      48'b000000000000000000001000000000000000000000000000: n1186_o = n870_o;
      48'b000000000000000000000100000000000000000000000000: n1186_o = n853_o;
      48'b000000000000000000000010000000000000000000000000: n1186_o = n836_o;
      48'b000000000000000000000001000000000000000000000000: n1186_o = n822_o;
      48'b000000000000000000000000100000000000000000000000: n1186_o = n806_o;
      48'b000000000000000000000000010000000000000000000000: n1186_o = n792_o;
      48'b000000000000000000000000001000000000000000000000: n1186_o = n775_o;
      48'b000000000000000000000000000100000000000000000000: n1186_o = n771_o;
      48'b000000000000000000000000000010000000000000000000: n1186_o = n761_o;
      48'b000000000000000000000000000001000000000000000000: n1186_o = n747_o;
      48'b000000000000000000000000000000100000000000000000: n1186_o = n733_o;
      48'b000000000000000000000000000000010000000000000000: n1186_o = n718_o;
      48'b000000000000000000000000000000001000000000000000: n1186_o = n701_o;
      48'b000000000000000000000000000000000100000000000000: n1186_o = n684_o;
      48'b000000000000000000000000000000000010000000000000: n1186_o = n670_o;
      48'b000000000000000000000000000000000001000000000000: n1186_o = n654_o;
      48'b000000000000000000000000000000000000100000000000: n1186_o = n640_o;
      48'b000000000000000000000000000000000000010000000000: n1186_o = n634_o;
      48'b000000000000000000000000000000000000001000000000: n1186_o = n617_o;
      48'b000000000000000000000000000000000000000100000000: n1186_o = n607_o;
      48'b000000000000000000000000000000000000000010000000: n1186_o = n597_o;
      48'b000000000000000000000000000000000000000001000000: n1186_o = n560_o;
      48'b000000000000000000000000000000000000000000100000: n1186_o = n514_o;
      48'b000000000000000000000000000000000000000000010000: n1186_o = n477_o;
      48'b000000000000000000000000000000000000000000001000: n1186_o = n446_o;
      48'b000000000000000000000000000000000000000000000100: n1186_o = n307_o;
      48'b000000000000000000000000000000000000000000000010: n1186_o = n132_o;
      48'b000000000000000000000000000000000000000000000001: n1186_o = regpc;
      default: n1186_o = regpc;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1188_o = flagh;
      48'b010000000000000000000000000000000000000000000000: n1188_o = flagh;
      48'b001000000000000000000000000000000000000000000000: n1188_o = flagh;
      48'b000100000000000000000000000000000000000000000000: n1188_o = flagh;
      48'b000010000000000000000000000000000000000000000000: n1188_o = flagh;
      48'b000001000000000000000000000000000000000000000000: n1188_o = flagh;
      48'b000000100000000000000000000000000000000000000000: n1188_o = flagh;
      48'b000000010000000000000000000000000000000000000000: n1188_o = flagh;
      48'b000000001000000000000000000000000000000000000000: n1188_o = flagh;
      48'b000000000100000000000000000000000000000000000000: n1188_o = flagh;
      48'b000000000010000000000000000000000000000000000000: n1188_o = flagh;
      48'b000000000001000000000000000000000000000000000000: n1188_o = flagh;
      48'b000000000000100000000000000000000000000000000000: n1188_o = flagh;
      48'b000000000000010000000000000000000000000000000000: n1188_o = flagh;
      48'b000000000000001000000000000000000000000000000000: n1188_o = flagh;
      48'b000000000000000100000000000000000000000000000000: n1188_o = flagh;
      48'b000000000000000010000000000000000000000000000000: n1188_o = flagh;
      48'b000000000000000001000000000000000000000000000000: n1188_o = flagh;
      48'b000000000000000000100000000000000000000000000000: n1188_o = flagh;
      48'b000000000000000000010000000000000000000000000000: n1188_o = flagh;
      48'b000000000000000000001000000000000000000000000000: n1188_o = flagh;
      48'b000000000000000000000100000000000000000000000000: n1188_o = flagh;
      48'b000000000000000000000010000000000000000000000000: n1188_o = flagh;
      48'b000000000000000000000001000000000000000000000000: n1188_o = flagh;
      48'b000000000000000000000000100000000000000000000000: n1188_o = flagh;
      48'b000000000000000000000000010000000000000000000000: n1188_o = flagh;
      48'b000000000000000000000000001000000000000000000000: n1188_o = flagh;
      48'b000000000000000000000000000100000000000000000000: n1188_o = flagh;
      48'b000000000000000000000000000010000000000000000000: n1188_o = flagh;
      48'b000000000000000000000000000001000000000000000000: n1188_o = flagh;
      48'b000000000000000000000000000000100000000000000000: n1188_o = flagh;
      48'b000000000000000000000000000000010000000000000000: n1188_o = flagh;
      48'b000000000000000000000000000000001000000000000000: n1188_o = flagh;
      48'b000000000000000000000000000000000100000000000000: n1188_o = flagh;
      48'b000000000000000000000000000000000010000000000000: n1188_o = flagh;
      48'b000000000000000000000000000000000001000000000000: n1188_o = flagh;
      48'b000000000000000000000000000000000000100000000000: n1188_o = 1'b0;
      48'b000000000000000000000000000000000000010000000000: n1188_o = flagh;
      48'b000000000000000000000000000000000000001000000000: n1188_o = flagh;
      48'b000000000000000000000000000000000000000100000000: n1188_o = flagh;
      48'b000000000000000000000000000000000000000010000000: n1188_o = flagh;
      48'b000000000000000000000000000000000000000001000000: n1188_o = flagh;
      48'b000000000000000000000000000000000000000000100000: n1188_o = flagh;
      48'b000000000000000000000000000000000000000000010000: n1188_o = flagh;
      48'b000000000000000000000000000000000000000000001000: n1188_o = flagh;
      48'b000000000000000000000000000000000000000000000100: n1188_o = flagh;
      48'b000000000000000000000000000000000000000000000010: n1188_o = flagh;
      48'b000000000000000000000000000000000000000000000001: n1188_o = flagh;
      default: n1188_o = flagh;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1189_o = flagi;
      48'b010000000000000000000000000000000000000000000000: n1189_o = flagi;
      48'b001000000000000000000000000000000000000000000000: n1189_o = flagi;
      48'b000100000000000000000000000000000000000000000000: n1189_o = flagi;
      48'b000010000000000000000000000000000000000000000000: n1189_o = flagi;
      48'b000001000000000000000000000000000000000000000000: n1189_o = flagi;
      48'b000000100000000000000000000000000000000000000000: n1189_o = n1001_o;
      48'b000000010000000000000000000000000000000000000000: n1189_o = flagi;
      48'b000000001000000000000000000000000000000000000000: n1189_o = flagi;
      48'b000000000100000000000000000000000000000000000000: n1189_o = flagi;
      48'b000000000010000000000000000000000000000000000000: n1189_o = flagi;
      48'b000000000001000000000000000000000000000000000000: n1189_o = flagi;
      48'b000000000000100000000000000000000000000000000000: n1189_o = flagi;
      48'b000000000000010000000000000000000000000000000000: n1189_o = flagi;
      48'b000000000000001000000000000000000000000000000000: n1189_o = flagi;
      48'b000000000000000100000000000000000000000000000000: n1189_o = flagi;
      48'b000000000000000010000000000000000000000000000000: n1189_o = flagi;
      48'b000000000000000001000000000000000000000000000000: n1189_o = flagi;
      48'b000000000000000000100000000000000000000000000000: n1189_o = flagi;
      48'b000000000000000000010000000000000000000000000000: n1189_o = flagi;
      48'b000000000000000000001000000000000000000000000000: n1189_o = flagi;
      48'b000000000000000000000100000000000000000000000000: n1189_o = flagi;
      48'b000000000000000000000010000000000000000000000000: n1189_o = flagi;
      48'b000000000000000000000001000000000000000000000000: n1189_o = flagi;
      48'b000000000000000000000000100000000000000000000000: n1189_o = flagi;
      48'b000000000000000000000000010000000000000000000000: n1189_o = flagi;
      48'b000000000000000000000000001000000000000000000000: n1189_o = flagi;
      48'b000000000000000000000000000100000000000000000000: n1189_o = flagi;
      48'b000000000000000000000000000010000000000000000000: n1189_o = flagi;
      48'b000000000000000000000000000001000000000000000000: n1189_o = flagi;
      48'b000000000000000000000000000000100000000000000000: n1189_o = flagi;
      48'b000000000000000000000000000000010000000000000000: n1189_o = flagi;
      48'b000000000000000000000000000000001000000000000000: n1189_o = flagi;
      48'b000000000000000000000000000000000100000000000000: n1189_o = flagi;
      48'b000000000000000000000000000000000010000000000000: n1189_o = flagi;
      48'b000000000000000000000000000000000001000000000000: n1189_o = flagi;
      48'b000000000000000000000000000000000000100000000000: n1189_o = flagi;
      48'b000000000000000000000000000000000000010000000000: n1189_o = flagi;
      48'b000000000000000000000000000000000000001000000000: n1189_o = flagi;
      48'b000000000000000000000000000000000000000100000000: n1189_o = flagi;
      48'b000000000000000000000000000000000000000010000000: n1189_o = flagi;
      48'b000000000000000000000000000000000000000001000000: n1189_o = flagi;
      48'b000000000000000000000000000000000000000000100000: n1189_o = flagi;
      48'b000000000000000000000000000000000000000000010000: n1189_o = flagi;
      48'b000000000000000000000000000000000000000000001000: n1189_o = flagi;
      48'b000000000000000000000000000000000000000000000100: n1189_o = flagi;
      48'b000000000000000000000000000000000000000000000010: n1189_o = flagi;
      48'b000000000000000000000000000000000000000000000001: n1189_o = flagi;
      default: n1189_o = flagi;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1195_o = flagn;
      48'b010000000000000000000000000000000000000000000000: n1195_o = flagn;
      48'b001000000000000000000000000000000000000000000000: n1195_o = flagn;
      48'b000100000000000000000000000000000000000000000000: n1195_o = flagn;
      48'b000010000000000000000000000000000000000000000000: n1195_o = flagn;
      48'b000001000000000000000000000000000000000000000000: n1195_o = flagn;
      48'b000000100000000000000000000000000000000000000000: n1195_o = flagn;
      48'b000000010000000000000000000000000000000000000000: n1195_o = flagn;
      48'b000000001000000000000000000000000000000000000000: n1195_o = flagn;
      48'b000000000100000000000000000000000000000000000000: n1195_o = flagn;
      48'b000000000010000000000000000000000000000000000000: n1195_o = flagn;
      48'b000000000001000000000000000000000000000000000000: n1195_o = flagn;
      48'b000000000000100000000000000000000000000000000000: n1195_o = flagn;
      48'b000000000000010000000000000000000000000000000000: n1195_o = 1'b0;
      48'b000000000000001000000000000000000000000000000000: n1195_o = flagn;
      48'b000000000000000100000000000000000000000000000000: n1195_o = 1'b0;
      48'b000000000000000010000000000000000000000000000000: n1195_o = n916_o;
      48'b000000000000000001000000000000000000000000000000: n1195_o = n906_o;
      48'b000000000000000000100000000000000000000000000000: n1195_o = n892_o;
      48'b000000000000000000010000000000000000000000000000: n1195_o = n877_o;
      48'b000000000000000000001000000000000000000000000000: n1195_o = n862_o;
      48'b000000000000000000000100000000000000000000000000: n1195_o = n845_o;
      48'b000000000000000000000010000000000000000000000000: n1195_o = flagc;
      48'b000000000000000000000001000000000000000000000000: n1195_o = 1'b0;
      48'b000000000000000000000000100000000000000000000000: n1195_o = n799_o;
      48'b000000000000000000000000010000000000000000000000: n1195_o = n782_o;
      48'b000000000000000000000000001000000000000000000000: n1195_o = 1'b0;
      48'b000000000000000000000000000100000000000000000000: n1195_o = n764_o;
      48'b000000000000000000000000000010000000000000000000: n1195_o = n754_o;
      48'b000000000000000000000000000001000000000000000000: n1195_o = n740_o;
      48'b000000000000000000000000000000100000000000000000: n1195_o = n725_o;
      48'b000000000000000000000000000000010000000000000000: n1195_o = n710_o;
      48'b000000000000000000000000000000001000000000000000: n1195_o = n693_o;
      48'b000000000000000000000000000000000100000000000000: n1195_o = flagc;
      48'b000000000000000000000000000000000010000000000000: n1195_o = 1'b0;
      48'b000000000000000000000000000000000001000000000000: n1195_o = n647_o;
      48'b000000000000000000000000000000000000100000000000: n1195_o = flagn;
      48'b000000000000000000000000000000000000010000000000: n1195_o = n624_o;
      48'b000000000000000000000000000000000000001000000000: n1195_o = n610_o;
      48'b000000000000000000000000000000000000000100000000: n1195_o = n600_o;
      48'b000000000000000000000000000000000000000010000000: n1195_o = flagn;
      48'b000000000000000000000000000000000000000001000000: n1195_o = flagn;
      48'b000000000000000000000000000000000000000000100000: n1195_o = flagn;
      48'b000000000000000000000000000000000000000000010000: n1195_o = flagn;
      48'b000000000000000000000000000000000000000000001000: n1195_o = flagn;
      48'b000000000000000000000000000000000000000000000100: n1195_o = flagn;
      48'b000000000000000000000000000000000000000000000010: n1195_o = flagn;
      48'b000000000000000000000000000000000000000000000001: n1195_o = flagn;
      default: n1195_o = flagn;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1199_o = flagz;
      48'b010000000000000000000000000000000000000000000000: n1199_o = flagz;
      48'b001000000000000000000000000000000000000000000000: n1199_o = flagz;
      48'b000100000000000000000000000000000000000000000000: n1199_o = flagz;
      48'b000010000000000000000000000000000000000000000000: n1199_o = flagz;
      48'b000001000000000000000000000000000000000000000000: n1199_o = flagz;
      48'b000000100000000000000000000000000000000000000000: n1199_o = flagz;
      48'b000000010000000000000000000000000000000000000000: n1199_o = flagz;
      48'b000000001000000000000000000000000000000000000000: n1199_o = flagz;
      48'b000000000100000000000000000000000000000000000000: n1199_o = flagz;
      48'b000000000010000000000000000000000000000000000000: n1199_o = flagz;
      48'b000000000001000000000000000000000000000000000000: n1199_o = flagz;
      48'b000000000000100000000000000000000000000000000000: n1199_o = flagz;
      48'b000000000000010000000000000000000000000000000000: n1199_o = 1'b1;
      48'b000000000000001000000000000000000000000000000000: n1199_o = flagz;
      48'b000000000000000100000000000000000000000000000000: n1199_o = 1'b1;
      48'b000000000000000010000000000000000000000000000000: n1199_o = n921_o;
      48'b000000000000000001000000000000000000000000000000: n1199_o = n911_o;
      48'b000000000000000000100000000000000000000000000000: n1199_o = n897_o;
      48'b000000000000000000010000000000000000000000000000: n1199_o = n883_o;
      48'b000000000000000000001000000000000000000000000000: n1199_o = n868_o;
      48'b000000000000000000000100000000000000000000000000: n1199_o = n851_o;
      48'b000000000000000000000010000000000000000000000000: n1199_o = n834_o;
      48'b000000000000000000000001000000000000000000000000: n1199_o = n820_o;
      48'b000000000000000000000000100000000000000000000000: n1199_o = n804_o;
      48'b000000000000000000000000010000000000000000000000: n1199_o = n787_o;
      48'b000000000000000000000000001000000000000000000000: n1199_o = 1'b1;
      48'b000000000000000000000000000100000000000000000000: n1199_o = n769_o;
      48'b000000000000000000000000000010000000000000000000: n1199_o = n759_o;
      48'b000000000000000000000000000001000000000000000000: n1199_o = n745_o;
      48'b000000000000000000000000000000100000000000000000: n1199_o = n731_o;
      48'b000000000000000000000000000000010000000000000000: n1199_o = n716_o;
      48'b000000000000000000000000000000001000000000000000: n1199_o = n699_o;
      48'b000000000000000000000000000000000100000000000000: n1199_o = n682_o;
      48'b000000000000000000000000000000000010000000000000: n1199_o = n668_o;
      48'b000000000000000000000000000000000001000000000000: n1199_o = n652_o;
      48'b000000000000000000000000000000000000100000000000: n1199_o = flagz;
      48'b000000000000000000000000000000000000010000000000: n1199_o = n629_o;
      48'b000000000000000000000000000000000000001000000000: n1199_o = n615_o;
      48'b000000000000000000000000000000000000000100000000: n1199_o = n605_o;
      48'b000000000000000000000000000000000000000010000000: n1199_o = flagz;
      48'b000000000000000000000000000000000000000001000000: n1199_o = flagz;
      48'b000000000000000000000000000000000000000000100000: n1199_o = flagz;
      48'b000000000000000000000000000000000000000000010000: n1199_o = flagz;
      48'b000000000000000000000000000000000000000000001000: n1199_o = flagz;
      48'b000000000000000000000000000000000000000000000100: n1199_o = flagz;
      48'b000000000000000000000000000000000000000000000010: n1199_o = flagz;
      48'b000000000000000000000000000000000000000000000001: n1199_o = flagz;
      default: n1199_o = flagz;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1203_o = flagc;
      48'b010000000000000000000000000000000000000000000000: n1203_o = flagc;
      48'b001000000000000000000000000000000000000000000000: n1203_o = flagc;
      48'b000100000000000000000000000000000000000000000000: n1203_o = flagc;
      48'b000010000000000000000000000000000000000000000000: n1203_o = flagc;
      48'b000001000000000000000000000000000000000000000000: n1203_o = flagc;
      48'b000000100000000000000000000000000000000000000000: n1203_o = flagc;
      48'b000000010000000000000000000000000000000000000000: n1203_o = n993_o;
      48'b000000001000000000000000000000000000000000000000: n1203_o = flagc;
      48'b000000000100000000000000000000000000000000000000: n1203_o = flagc;
      48'b000000000010000000000000000000000000000000000000: n1203_o = flagc;
      48'b000000000001000000000000000000000000000000000000: n1203_o = flagc;
      48'b000000000000100000000000000000000000000000000000: n1203_o = flagc;
      48'b000000000000010000000000000000000000000000000000: n1203_o = flagc;
      48'b000000000000001000000000000000000000000000000000: n1203_o = flagc;
      48'b000000000000000100000000000000000000000000000000: n1203_o = flagc;
      48'b000000000000000010000000000000000000000000000000: n1203_o = flagc;
      48'b000000000000000001000000000000000000000000000000: n1203_o = flagc;
      48'b000000000000000000100000000000000000000000000000: n1203_o = flagc;
      48'b000000000000000000010000000000000000000000000000: n1203_o = n878_o;
      48'b000000000000000000001000000000000000000000000000: n1203_o = n863_o;
      48'b000000000000000000000100000000000000000000000000: n1203_o = n846_o;
      48'b000000000000000000000010000000000000000000000000: n1203_o = n829_o;
      48'b000000000000000000000001000000000000000000000000: n1203_o = n815_o;
      48'b000000000000000000000000100000000000000000000000: n1203_o = 1'b1;
      48'b000000000000000000000000010000000000000000000000: n1203_o = n790_o;
      48'b000000000000000000000000001000000000000000000000: n1203_o = flagc;
      48'b000000000000000000000000000100000000000000000000: n1203_o = flagc;
      48'b000000000000000000000000000010000000000000000000: n1203_o = flagc;
      48'b000000000000000000000000000001000000000000000000: n1203_o = flagc;
      48'b000000000000000000000000000000100000000000000000: n1203_o = n726_o;
      48'b000000000000000000000000000000010000000000000000: n1203_o = n711_o;
      48'b000000000000000000000000000000001000000000000000: n1203_o = n694_o;
      48'b000000000000000000000000000000000100000000000000: n1203_o = n677_o;
      48'b000000000000000000000000000000000010000000000000: n1203_o = n663_o;
      48'b000000000000000000000000000000000001000000000000: n1203_o = 1'b1;
      48'b000000000000000000000000000000000000100000000000: n1203_o = 1'b0;
      48'b000000000000000000000000000000000000010000000000: n1203_o = n632_o;
      48'b000000000000000000000000000000000000001000000000: n1203_o = flagc;
      48'b000000000000000000000000000000000000000100000000: n1203_o = flagc;
      48'b000000000000000000000000000000000000000010000000: n1203_o = flagc;
      48'b000000000000000000000000000000000000000001000000: n1203_o = flagc;
      48'b000000000000000000000000000000000000000000100000: n1203_o = flagc;
      48'b000000000000000000000000000000000000000000010000: n1203_o = flagc;
      48'b000000000000000000000000000000000000000000001000: n1203_o = flagc;
      48'b000000000000000000000000000000000000000000000100: n1203_o = flagc;
      48'b000000000000000000000000000000000000000000000010: n1203_o = flagc;
      48'b000000000000000000000000000000000000000000000001: n1203_o = flagc;
      default: n1203_o = flagc;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1205_o = help;
      48'b010000000000000000000000000000000000000000000000: n1205_o = help;
      48'b001000000000000000000000000000000000000000000000: n1205_o = help;
      48'b000100000000000000000000000000000000000000000000: n1205_o = help;
      48'b000010000000000000000000000000000000000000000000: n1205_o = help;
      48'b000001000000000000000000000000000000000000000000: n1205_o = help;
      48'b000000100000000000000000000000000000000000000000: n1205_o = help;
      48'b000000010000000000000000000000000000000000000000: n1205_o = help;
      48'b000000001000000000000000000000000000000000000000: n1205_o = help;
      48'b000000000100000000000000000000000000000000000000: n1205_o = help;
      48'b000000000010000000000000000000000000000000000000: n1205_o = help;
      48'b000000000001000000000000000000000000000000000000: n1205_o = help;
      48'b000000000000100000000000000000000000000000000000: n1205_o = help;
      48'b000000000000010000000000000000000000000000000000: n1205_o = 8'b00000000;
      48'b000000000000001000000000000000000000000000000000: n1205_o = help;
      48'b000000000000000100000000000000000000000000000000: n1205_o = help;
      48'b000000000000000010000000000000000000000000000000: n1205_o = help;
      48'b000000000000000001000000000000000000000000000000: n1205_o = help;
      48'b000000000000000000100000000000000000000000000000: n1205_o = help;
      48'b000000000000000000010000000000000000000000000000: n1205_o = help;
      48'b000000000000000000001000000000000000000000000000: n1205_o = help;
      48'b000000000000000000000100000000000000000000000000: n1205_o = help;
      48'b000000000000000000000010000000000000000000000000: n1205_o = help;
      48'b000000000000000000000001000000000000000000000000: n1205_o = help;
      48'b000000000000000000000000100000000000000000000000: n1205_o = help;
      48'b000000000000000000000000010000000000000000000000: n1205_o = help;
      48'b000000000000000000000000001000000000000000000000: n1205_o = help;
      48'b000000000000000000000000000100000000000000000000: n1205_o = help;
      48'b000000000000000000000000000010000000000000000000: n1205_o = help;
      48'b000000000000000000000000000001000000000000000000: n1205_o = help;
      48'b000000000000000000000000000000100000000000000000: n1205_o = help;
      48'b000000000000000000000000000000010000000000000000: n1205_o = help;
      48'b000000000000000000000000000000001000000000000000: n1205_o = help;
      48'b000000000000000000000000000000000100000000000000: n1205_o = help;
      48'b000000000000000000000000000000000010000000000000: n1205_o = help;
      48'b000000000000000000000000000000000001000000000000: n1205_o = help;
      48'b000000000000000000000000000000000000100000000000: n1205_o = help;
      48'b000000000000000000000000000000000000010000000000: n1205_o = help;
      48'b000000000000000000000000000000000000001000000000: n1205_o = help;
      48'b000000000000000000000000000000000000000100000000: n1205_o = help;
      48'b000000000000000000000000000000000000000010000000: n1205_o = help;
      48'b000000000000000000000000000000000000000001000000: n1205_o = help;
      48'b000000000000000000000000000000000000000000100000: n1205_o = help;
      48'b000000000000000000000000000000000000000000010000: n1205_o = help;
      48'b000000000000000000000000000000000000000000001000: n1205_o = help;
      48'b000000000000000000000000000000000000000000000100: n1205_o = help;
      48'b000000000000000000000000000000000000000000000010: n1205_o = help;
      48'b000000000000000000000000000000000000000000000001: n1205_o = help;
      default: n1205_o = help;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1207_o = n1169_o;
      48'b010000000000000000000000000000000000000000000000: n1207_o = n1160_o;
      48'b001000000000000000000000000000000000000000000000: n1207_o = n1148_o;
      48'b000100000000000000000000000000000000000000000000: n1207_o = temp;
      48'b000010000000000000000000000000000000000000000000: n1207_o = temp;
      48'b000001000000000000000000000000000000000000000000: n1207_o = temp;
      48'b000000100000000000000000000000000000000000000000: n1207_o = temp;
      48'b000000010000000000000000000000000000000000000000: n1207_o = temp;
      48'b000000001000000000000000000000000000000000000000: n1207_o = temp;
      48'b000000000100000000000000000000000000000000000000: n1207_o = temp;
      48'b000000000010000000000000000000000000000000000000: n1207_o = temp;
      48'b000000000001000000000000000000000000000000000000: n1207_o = temp;
      48'b000000000000100000000000000000000000000000000000: n1207_o = temp;
      48'b000000000000010000000000000000000000000000000000: n1207_o = temp;
      48'b000000000000001000000000000000000000000000000000: n1207_o = n931_o;
      48'b000000000000000100000000000000000000000000000000: n1207_o = temp;
      48'b000000000000000010000000000000000000000000000000: n1207_o = temp;
      48'b000000000000000001000000000000000000000000000000: n1207_o = temp;
      48'b000000000000000000100000000000000000000000000000: n1207_o = temp;
      48'b000000000000000000010000000000000000000000000000: n1207_o = temp;
      48'b000000000000000000001000000000000000000000000000: n1207_o = temp;
      48'b000000000000000000000100000000000000000000000000: n1207_o = temp;
      48'b000000000000000000000010000000000000000000000000: n1207_o = temp;
      48'b000000000000000000000001000000000000000000000000: n1207_o = temp;
      48'b000000000000000000000000100000000000000000000000: n1207_o = temp;
      48'b000000000000000000000000010000000000000000000000: n1207_o = temp;
      48'b000000000000000000000000001000000000000000000000: n1207_o = temp;
      48'b000000000000000000000000000100000000000000000000: n1207_o = temp;
      48'b000000000000000000000000000010000000000000000000: n1207_o = temp;
      48'b000000000000000000000000000001000000000000000000: n1207_o = temp;
      48'b000000000000000000000000000000100000000000000000: n1207_o = temp;
      48'b000000000000000000000000000000010000000000000000: n1207_o = temp;
      48'b000000000000000000000000000000001000000000000000: n1207_o = temp;
      48'b000000000000000000000000000000000100000000000000: n1207_o = temp;
      48'b000000000000000000000000000000000010000000000000: n1207_o = temp;
      48'b000000000000000000000000000000000001000000000000: n1207_o = temp;
      48'b000000000000000000000000000000000000100000000000: n1207_o = temp;
      48'b000000000000000000000000000000000000010000000000: n1207_o = temp;
      48'b000000000000000000000000000000000000001000000000: n1207_o = temp;
      48'b000000000000000000000000000000000000000100000000: n1207_o = temp;
      48'b000000000000000000000000000000000000000010000000: n1207_o = temp;
      48'b000000000000000000000000000000000000000001000000: n1207_o = temp;
      48'b000000000000000000000000000000000000000000100000: n1207_o = temp;
      48'b000000000000000000000000000000000000000000010000: n1207_o = temp;
      48'b000000000000000000000000000000000000000000001000: n1207_o = temp;
      48'b000000000000000000000000000000000000000000000100: n1207_o = temp;
      48'b000000000000000000000000000000000000000000000010: n1207_o = 16'b0000000000000000;
      48'b000000000000000000000000000000000000000000000001: n1207_o = temp;
      default: n1207_o = temp;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1257_o = 4'b0100;
      48'b010000000000000000000000000000000000000000000000: n1257_o = 4'b0011;
      48'b001000000000000000000000000000000000000000000000: n1257_o = 4'b0011;
      48'b000100000000000000000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000010000000000000000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000001000000000000000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000100000000000000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000010000000000000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000001000000000000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000100000000000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000010000000000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000001000000000000000000000000000000000000: n1257_o = 4'b0011;
      48'b000000000000100000000000000000000000000000000000: n1257_o = 4'b0011;
      48'b000000000000010000000000000000000000000000000000: n1257_o = 4'b0011;
      48'b000000000000001000000000000000000000000000000000: n1257_o = 4'b0011;
      48'b000000000000000100000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000010000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000001000000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000100000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000010000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000001000000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000100000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000010000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000001000000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000100000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000010000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000001000000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000100000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000010000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000001000000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000100000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000010000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000001000000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000000100000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000000010000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000000001000000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000000000100000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000000000010000000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000000000001000000000: n1257_o = 4'b0101;
      48'b000000000000000000000000000000000000000100000000: n1257_o = 4'b0101;
      48'b000000000000000000000000000000000000000010000000: n1257_o = 4'b0010;
      48'b000000000000000000000000000000000000000001000000: n1257_o = 4'b0101;
      48'b000000000000000000000000000000000000000000100000: n1257_o = 4'b0100;
      48'b000000000000000000000000000000000000000000010000: n1257_o = 4'b0101;
      48'b000000000000000000000000000000000000000000001000: n1257_o = 4'b0100;
      48'b000000000000000000000000000000000000000000000100: n1257_o = 4'b0011;
      48'b000000000000000000000000000000000000000000000010: n1257_o = 4'b0011;
      48'b000000000000000000000000000000000000000000000001: n1257_o = 4'b0011;
      default: n1257_o = 4'b0000;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1267_o = 3'b001;
      48'b010000000000000000000000000000000000000000000000: n1267_o = addrmux;
      48'b001000000000000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000100000000000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000010000000000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000001000000000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000000100000000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000000010000000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000000001000000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000000000100000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000000000010000000000000000000000000000000000000: n1267_o = addrmux;
      48'b000000000001000000000000000000000000000000000000: n1267_o = 3'b001;
      48'b000000000000100000000000000000000000000000000000: n1267_o = 3'b001;
      48'b000000000000010000000000000000000000000000000000: n1267_o = 3'b010;
      48'b000000000000001000000000000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000100000000000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000010000000000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000001000000000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000100000000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000010000000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000001000000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000100000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000010000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000001000000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000100000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000010000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000001000000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000100000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000010000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000001000000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000100000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000010000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000001000000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000000100000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000000010000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000000001000000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000000000100000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000000000010000000000: n1267_o = addrmux;
      48'b000000000000000000000000000000000000001000000000: n1267_o = 3'b010;
      48'b000000000000000000000000000000000000000100000000: n1267_o = 3'b010;
      48'b000000000000000000000000000000000000000010000000: n1267_o = addrmux;
      48'b000000000000000000000000000000000000000001000000: n1267_o = 3'b010;
      48'b000000000000000000000000000000000000000000100000: n1267_o = addrmux;
      48'b000000000000000000000000000000000000000000010000: n1267_o = addrmux;
      48'b000000000000000000000000000000000000000000001000: n1267_o = 3'b010;
      48'b000000000000000000000000000000000000000000000100: n1267_o = addrmux;
      48'b000000000000000000000000000000000000000000000010: n1267_o = addrmux;
      48'b000000000000000000000000000000000000000000000001: n1267_o = 3'b001;
      default: n1267_o = addrmux;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1272_o = 4'b0111;
      48'b010000000000000000000000000000000000000000000000: n1272_o = datamux;
      48'b001000000000000000000000000000000000000000000000: n1272_o = datamux;
      48'b000100000000000000000000000000000000000000000000: n1272_o = datamux;
      48'b000010000000000000000000000000000000000000000000: n1272_o = datamux;
      48'b000001000000000000000000000000000000000000000000: n1272_o = datamux;
      48'b000000100000000000000000000000000000000000000000: n1272_o = datamux;
      48'b000000010000000000000000000000000000000000000000: n1272_o = datamux;
      48'b000000001000000000000000000000000000000000000000: n1272_o = datamux;
      48'b000000000100000000000000000000000000000000000000: n1272_o = datamux;
      48'b000000000010000000000000000000000000000000000000: n1272_o = datamux;
      48'b000000000001000000000000000000000000000000000000: n1272_o = datamux;
      48'b000000000000100000000000000000000000000000000000: n1272_o = datamux;
      48'b000000000000010000000000000000000000000000000000: n1272_o = 4'b1001;
      48'b000000000000001000000000000000000000000000000000: n1272_o = datamux;
      48'b000000000000000100000000000000000000000000000000: n1272_o = datamux;
      48'b000000000000000010000000000000000000000000000000: n1272_o = datamux;
      48'b000000000000000001000000000000000000000000000000: n1272_o = datamux;
      48'b000000000000000000100000000000000000000000000000: n1272_o = datamux;
      48'b000000000000000000010000000000000000000000000000: n1272_o = datamux;
      48'b000000000000000000001000000000000000000000000000: n1272_o = datamux;
      48'b000000000000000000000100000000000000000000000000: n1272_o = datamux;
      48'b000000000000000000000010000000000000000000000000: n1272_o = datamux;
      48'b000000000000000000000001000000000000000000000000: n1272_o = datamux;
      48'b000000000000000000000000100000000000000000000000: n1272_o = datamux;
      48'b000000000000000000000000010000000000000000000000: n1272_o = datamux;
      48'b000000000000000000000000001000000000000000000000: n1272_o = datamux;
      48'b000000000000000000000000000100000000000000000000: n1272_o = datamux;
      48'b000000000000000000000000000010000000000000000000: n1272_o = datamux;
      48'b000000000000000000000000000001000000000000000000: n1272_o = datamux;
      48'b000000000000000000000000000000100000000000000000: n1272_o = datamux;
      48'b000000000000000000000000000000010000000000000000: n1272_o = datamux;
      48'b000000000000000000000000000000001000000000000000: n1272_o = datamux;
      48'b000000000000000000000000000000000100000000000000: n1272_o = datamux;
      48'b000000000000000000000000000000000010000000000000: n1272_o = datamux;
      48'b000000000000000000000000000000000001000000000000: n1272_o = datamux;
      48'b000000000000000000000000000000000000100000000000: n1272_o = datamux;
      48'b000000000000000000000000000000000000010000000000: n1272_o = datamux;
      48'b000000000000000000000000000000000000001000000000: n1272_o = 4'b0010;
      48'b000000000000000000000000000000000000000100000000: n1272_o = 4'b0000;
      48'b000000000000000000000000000000000000000010000000: n1272_o = datamux;
      48'b000000000000000000000000000000000000000001000000: n1272_o = datamux;
      48'b000000000000000000000000000000000000000000100000: n1272_o = datamux;
      48'b000000000000000000000000000000000000000000010000: n1272_o = datamux;
      48'b000000000000000000000000000000000000000000001000: n1272_o = datamux;
      48'b000000000000000000000000000000000000000000000100: n1272_o = datamux;
      48'b000000000000000000000000000000000000000000000010: n1272_o = datamux;
      48'b000000000000000000000000000000000000000000000001: n1272_o = datamux;
      default: n1272_o = datamux;
    endcase
  /* 6805.vhd:331:15  */
  always @*
    case (n1174_o)
      48'b100000000000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b010000000000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b001000000000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000100000000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000010000000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000001000000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000100000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000010000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000001000000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000100000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000010000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000001000000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000100000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000010000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000001000000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000100000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000010000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000001000000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000100000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000010000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000001000000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000100000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000010000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000001000000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000100000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000010000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000001000000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000100000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000010000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000001000000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000100000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000010000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000001000000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000100000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000010000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000001000000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000100000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000010000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000001000000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000100000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000010000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000001000000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000000100000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000000010000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000000001000: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000000000100: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000000000010: n1274_o = trace_i;
      48'b000000000000000000000000000000000000000000000001: n1274_o = 1'b1;
      default: n1274_o = trace_i;
    endcase
  /* 6805.vhd:325:13  */
  assign n1276_o = n126_o ? n3854_q : n1179_o;
  /* 6805.vhd:325:13  */
  assign n1277_o = n126_o ? rega : n1181_o;
  /* 6805.vhd:325:13  */
  assign n1278_o = n126_o ? regx : n1183_o;
  /* 6805.vhd:325:13  */
  assign n1279_o = n126_o ? regsp : n1185_o;
  /* 6805.vhd:325:13  */
  assign n1280_o = n126_o ? regpc : n1186_o;
  /* 6805.vhd:325:13  */
  assign n1281_o = n126_o ? flagh : n1188_o;
  /* 6805.vhd:325:13  */
  assign n1282_o = n126_o ? flagi : n1189_o;
  /* 6805.vhd:325:13  */
  assign n1283_o = n126_o ? flagn : n1195_o;
  /* 6805.vhd:325:13  */
  assign n1284_o = n126_o ? flagz : n1199_o;
  /* 6805.vhd:325:13  */
  assign n1285_o = n126_o ? flagc : n1203_o;
  /* 6805.vhd:325:13  */
  assign n1286_o = n126_o ? help : n1205_o;
  /* 6805.vhd:325:13  */
  assign n1287_o = n126_o ? temp : n1207_o;
  /* 6805.vhd:325:13  */
  assign n1289_o = n126_o ? 4'b0011 : n1257_o;
  /* 6805.vhd:325:13  */
  assign n1291_o = n126_o ? 3'b001 : n1267_o;
  /* 6805.vhd:325:13  */
  assign n1292_o = n126_o ? datamux : n1272_o;
  /* 6805.vhd:325:13  */
  assign n1294_o = n126_o ? 8'b10000011 : datain;
  /* 6805.vhd:325:13  */
  assign n1295_o = n126_o ? trace_i : n1274_o;
  /* 6805.vhd:320:13  */
  assign n1297_o = trace ? n3854_q : n1276_o;
  /* 6805.vhd:320:13  */
  assign n1298_o = trace ? rega : n1277_o;
  /* 6805.vhd:320:13  */
  assign n1299_o = trace ? regx : n1278_o;
  /* 6805.vhd:320:13  */
  assign n1300_o = trace ? regsp : n1279_o;
  /* 6805.vhd:320:13  */
  assign n1301_o = trace ? regpc : n1280_o;
  /* 6805.vhd:320:13  */
  assign n1302_o = trace ? flagh : n1281_o;
  /* 6805.vhd:320:13  */
  assign n1303_o = trace ? flagi : n1282_o;
  /* 6805.vhd:320:13  */
  assign n1304_o = trace ? flagn : n1283_o;
  /* 6805.vhd:320:13  */
  assign n1305_o = trace ? flagz : n1284_o;
  /* 6805.vhd:320:13  */
  assign n1306_o = trace ? flagc : n1285_o;
  /* 6805.vhd:320:13  */
  assign n1307_o = trace ? help : n1286_o;
  /* 6805.vhd:320:13  */
  assign n1308_o = trace ? temp : n1287_o;
  /* 6805.vhd:320:13  */
  assign n1310_o = trace ? 4'b0011 : n1289_o;
  /* 6805.vhd:320:13  */
  assign n1312_o = trace ? 3'b001 : n1291_o;
  /* 6805.vhd:320:13  */
  assign n1313_o = trace ? datamux : n1292_o;
  /* 6805.vhd:320:13  */
  assign n1315_o = trace ? 8'b10000011 : n1294_o;
  /* 6805.vhd:320:13  */
  assign n1316_o = trace ? trace_i : n1295_o;
  /* 6805.vhd:320:13  */
  assign n1317_o = trace ? datain : traceopcode;
  /* 6805.vhd:318:11  */
  assign n1320_o = mainfsm == 4'b0010;
  /* 6805.vhd:758:32  */
  assign n1322_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:749:15  */
  assign n1324_o = opcode == 8'b00000000;
  /* 6805.vhd:749:26  */
  assign n1326_o = opcode == 8'b00000010;
  /* 6805.vhd:749:26  */
  assign n1327_o = n1324_o | n1326_o;
  /* 6805.vhd:749:34  */
  assign n1329_o = opcode == 8'b00000100;
  /* 6805.vhd:749:34  */
  assign n1330_o = n1327_o | n1329_o;
  /* 6805.vhd:749:42  */
  assign n1332_o = opcode == 8'b00000110;
  /* 6805.vhd:749:42  */
  assign n1333_o = n1330_o | n1332_o;
  /* 6805.vhd:749:50  */
  assign n1335_o = opcode == 8'b00001000;
  /* 6805.vhd:749:50  */
  assign n1336_o = n1333_o | n1335_o;
  /* 6805.vhd:749:58  */
  assign n1338_o = opcode == 8'b00001010;
  /* 6805.vhd:749:58  */
  assign n1339_o = n1336_o | n1338_o;
  /* 6805.vhd:749:66  */
  assign n1341_o = opcode == 8'b00001100;
  /* 6805.vhd:749:66  */
  assign n1342_o = n1339_o | n1341_o;
  /* 6805.vhd:749:74  */
  assign n1344_o = opcode == 8'b00001110;
  /* 6805.vhd:749:74  */
  assign n1345_o = n1342_o | n1344_o;
  /* 6805.vhd:749:82  */
  assign n1347_o = opcode == 8'b00000001;
  /* 6805.vhd:749:82  */
  assign n1348_o = n1345_o | n1347_o;
  /* 6805.vhd:750:26  */
  assign n1350_o = opcode == 8'b00000011;
  /* 6805.vhd:750:26  */
  assign n1351_o = n1348_o | n1350_o;
  /* 6805.vhd:750:34  */
  assign n1353_o = opcode == 8'b00000101;
  /* 6805.vhd:750:34  */
  assign n1354_o = n1351_o | n1353_o;
  /* 6805.vhd:750:42  */
  assign n1356_o = opcode == 8'b00000111;
  /* 6805.vhd:750:42  */
  assign n1357_o = n1354_o | n1356_o;
  /* 6805.vhd:750:50  */
  assign n1359_o = opcode == 8'b00001001;
  /* 6805.vhd:750:50  */
  assign n1360_o = n1357_o | n1359_o;
  /* 6805.vhd:750:58  */
  assign n1362_o = opcode == 8'b00001011;
  /* 6805.vhd:750:58  */
  assign n1363_o = n1360_o | n1362_o;
  /* 6805.vhd:750:66  */
  assign n1365_o = opcode == 8'b00001101;
  /* 6805.vhd:750:66  */
  assign n1366_o = n1363_o | n1365_o;
  /* 6805.vhd:750:74  */
  assign n1368_o = opcode == 8'b00001111;
  /* 6805.vhd:750:74  */
  assign n1369_o = n1366_o | n1368_o;
  /* 6805.vhd:750:82  */
  assign n1371_o = opcode == 8'b00010000;
  /* 6805.vhd:750:82  */
  assign n1372_o = n1369_o | n1371_o;
  /* 6805.vhd:751:26  */
  assign n1374_o = opcode == 8'b00010010;
  /* 6805.vhd:751:26  */
  assign n1375_o = n1372_o | n1374_o;
  /* 6805.vhd:751:34  */
  assign n1377_o = opcode == 8'b00010100;
  /* 6805.vhd:751:34  */
  assign n1378_o = n1375_o | n1377_o;
  /* 6805.vhd:751:42  */
  assign n1380_o = opcode == 8'b00010110;
  /* 6805.vhd:751:42  */
  assign n1381_o = n1378_o | n1380_o;
  /* 6805.vhd:751:50  */
  assign n1383_o = opcode == 8'b00011000;
  /* 6805.vhd:751:50  */
  assign n1384_o = n1381_o | n1383_o;
  /* 6805.vhd:751:58  */
  assign n1386_o = opcode == 8'b00011010;
  /* 6805.vhd:751:58  */
  assign n1387_o = n1384_o | n1386_o;
  /* 6805.vhd:751:66  */
  assign n1389_o = opcode == 8'b00011100;
  /* 6805.vhd:751:66  */
  assign n1390_o = n1387_o | n1389_o;
  /* 6805.vhd:751:74  */
  assign n1392_o = opcode == 8'b00011110;
  /* 6805.vhd:751:74  */
  assign n1393_o = n1390_o | n1392_o;
  /* 6805.vhd:751:82  */
  assign n1395_o = opcode == 8'b00010001;
  /* 6805.vhd:751:82  */
  assign n1396_o = n1393_o | n1395_o;
  /* 6805.vhd:752:26  */
  assign n1398_o = opcode == 8'b00010011;
  /* 6805.vhd:752:26  */
  assign n1399_o = n1396_o | n1398_o;
  /* 6805.vhd:752:34  */
  assign n1401_o = opcode == 8'b00010101;
  /* 6805.vhd:752:34  */
  assign n1402_o = n1399_o | n1401_o;
  /* 6805.vhd:752:42  */
  assign n1404_o = opcode == 8'b00010111;
  /* 6805.vhd:752:42  */
  assign n1405_o = n1402_o | n1404_o;
  /* 6805.vhd:752:50  */
  assign n1407_o = opcode == 8'b00011001;
  /* 6805.vhd:752:50  */
  assign n1408_o = n1405_o | n1407_o;
  /* 6805.vhd:752:58  */
  assign n1410_o = opcode == 8'b00011011;
  /* 6805.vhd:752:58  */
  assign n1411_o = n1408_o | n1410_o;
  /* 6805.vhd:752:66  */
  assign n1413_o = opcode == 8'b00011101;
  /* 6805.vhd:752:66  */
  assign n1414_o = n1411_o | n1413_o;
  /* 6805.vhd:752:74  */
  assign n1416_o = opcode == 8'b00011111;
  /* 6805.vhd:752:74  */
  assign n1417_o = n1414_o | n1416_o;
  /* 6805.vhd:752:82  */
  assign n1419_o = opcode == 8'b00110000;
  /* 6805.vhd:752:82  */
  assign n1420_o = n1417_o | n1419_o;
  /* 6805.vhd:753:26  */
  assign n1422_o = opcode == 8'b00110011;
  /* 6805.vhd:753:26  */
  assign n1423_o = n1420_o | n1422_o;
  /* 6805.vhd:753:34  */
  assign n1425_o = opcode == 8'b00110100;
  /* 6805.vhd:753:34  */
  assign n1426_o = n1423_o | n1425_o;
  /* 6805.vhd:753:42  */
  assign n1428_o = opcode == 8'b00110110;
  /* 6805.vhd:753:42  */
  assign n1429_o = n1426_o | n1428_o;
  /* 6805.vhd:753:50  */
  assign n1431_o = opcode == 8'b00110111;
  /* 6805.vhd:753:50  */
  assign n1432_o = n1429_o | n1431_o;
  /* 6805.vhd:754:26  */
  assign n1434_o = opcode == 8'b00111000;
  /* 6805.vhd:754:26  */
  assign n1435_o = n1432_o | n1434_o;
  /* 6805.vhd:754:34  */
  assign n1437_o = opcode == 8'b00111001;
  /* 6805.vhd:754:34  */
  assign n1438_o = n1435_o | n1437_o;
  /* 6805.vhd:754:42  */
  assign n1440_o = opcode == 8'b00111010;
  /* 6805.vhd:754:42  */
  assign n1441_o = n1438_o | n1440_o;
  /* 6805.vhd:754:50  */
  assign n1443_o = opcode == 8'b00111100;
  /* 6805.vhd:754:50  */
  assign n1444_o = n1441_o | n1443_o;
  /* 6805.vhd:754:58  */
  assign n1446_o = opcode == 8'b00111101;
  /* 6805.vhd:754:58  */
  assign n1447_o = n1444_o | n1446_o;
  /* 6805.vhd:769:32  */
  assign n1449_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:760:15  */
  assign n1451_o = opcode == 8'b11000000;
  /* 6805.vhd:760:26  */
  assign n1453_o = opcode == 8'b11000001;
  /* 6805.vhd:760:26  */
  assign n1454_o = n1451_o | n1453_o;
  /* 6805.vhd:760:34  */
  assign n1456_o = opcode == 8'b11000010;
  /* 6805.vhd:760:34  */
  assign n1457_o = n1454_o | n1456_o;
  /* 6805.vhd:760:42  */
  assign n1459_o = opcode == 8'b11000011;
  /* 6805.vhd:760:42  */
  assign n1460_o = n1457_o | n1459_o;
  /* 6805.vhd:760:50  */
  assign n1462_o = opcode == 8'b11000100;
  /* 6805.vhd:760:50  */
  assign n1463_o = n1460_o | n1462_o;
  /* 6805.vhd:761:26  */
  assign n1465_o = opcode == 8'b11000101;
  /* 6805.vhd:761:26  */
  assign n1466_o = n1463_o | n1465_o;
  /* 6805.vhd:761:34  */
  assign n1468_o = opcode == 8'b11000110;
  /* 6805.vhd:761:34  */
  assign n1469_o = n1466_o | n1468_o;
  /* 6805.vhd:761:42  */
  assign n1471_o = opcode == 8'b11000111;
  /* 6805.vhd:761:42  */
  assign n1472_o = n1469_o | n1471_o;
  /* 6805.vhd:761:50  */
  assign n1474_o = opcode == 8'b11001000;
  /* 6805.vhd:761:50  */
  assign n1475_o = n1472_o | n1474_o;
  /* 6805.vhd:762:26  */
  assign n1477_o = opcode == 8'b11001001;
  /* 6805.vhd:762:26  */
  assign n1478_o = n1475_o | n1477_o;
  /* 6805.vhd:762:34  */
  assign n1480_o = opcode == 8'b11001010;
  /* 6805.vhd:762:34  */
  assign n1481_o = n1478_o | n1480_o;
  /* 6805.vhd:762:42  */
  assign n1483_o = opcode == 8'b11001011;
  /* 6805.vhd:762:42  */
  assign n1484_o = n1481_o | n1483_o;
  /* 6805.vhd:762:50  */
  assign n1486_o = opcode == 8'b11001100;
  /* 6805.vhd:762:50  */
  assign n1487_o = n1484_o | n1486_o;
  /* 6805.vhd:763:26  */
  assign n1489_o = opcode == 8'b11001110;
  /* 6805.vhd:763:26  */
  assign n1490_o = n1487_o | n1489_o;
  /* 6805.vhd:763:34  */
  assign n1492_o = opcode == 8'b11001111;
  /* 6805.vhd:763:34  */
  assign n1493_o = n1490_o | n1492_o;
  /* 6805.vhd:763:42  */
  assign n1495_o = opcode == 8'b11010000;
  /* 6805.vhd:763:42  */
  assign n1496_o = n1493_o | n1495_o;
  /* 6805.vhd:764:26  */
  assign n1498_o = opcode == 8'b11010001;
  /* 6805.vhd:764:26  */
  assign n1499_o = n1496_o | n1498_o;
  /* 6805.vhd:764:34  */
  assign n1501_o = opcode == 8'b11010010;
  /* 6805.vhd:764:34  */
  assign n1502_o = n1499_o | n1501_o;
  /* 6805.vhd:764:42  */
  assign n1504_o = opcode == 8'b11010011;
  /* 6805.vhd:764:42  */
  assign n1505_o = n1502_o | n1504_o;
  /* 6805.vhd:764:50  */
  assign n1507_o = opcode == 8'b11010100;
  /* 6805.vhd:764:50  */
  assign n1508_o = n1505_o | n1507_o;
  /* 6805.vhd:765:26  */
  assign n1510_o = opcode == 8'b11010101;
  /* 6805.vhd:765:26  */
  assign n1511_o = n1508_o | n1510_o;
  /* 6805.vhd:765:34  */
  assign n1513_o = opcode == 8'b11010110;
  /* 6805.vhd:765:34  */
  assign n1514_o = n1511_o | n1513_o;
  /* 6805.vhd:765:42  */
  assign n1516_o = opcode == 8'b11010111;
  /* 6805.vhd:765:42  */
  assign n1517_o = n1514_o | n1516_o;
  /* 6805.vhd:765:50  */
  assign n1519_o = opcode == 8'b11011000;
  /* 6805.vhd:765:50  */
  assign n1520_o = n1517_o | n1519_o;
  /* 6805.vhd:766:26  */
  assign n1522_o = opcode == 8'b11011001;
  /* 6805.vhd:766:26  */
  assign n1523_o = n1520_o | n1522_o;
  /* 6805.vhd:766:34  */
  assign n1525_o = opcode == 8'b11011010;
  /* 6805.vhd:766:34  */
  assign n1526_o = n1523_o | n1525_o;
  /* 6805.vhd:766:42  */
  assign n1528_o = opcode == 8'b11011011;
  /* 6805.vhd:766:42  */
  assign n1529_o = n1526_o | n1528_o;
  /* 6805.vhd:766:50  */
  assign n1531_o = opcode == 8'b11011100;
  /* 6805.vhd:766:50  */
  assign n1532_o = n1529_o | n1531_o;
  /* 6805.vhd:767:26  */
  assign n1534_o = opcode == 8'b11011110;
  /* 6805.vhd:767:26  */
  assign n1535_o = n1532_o | n1534_o;
  /* 6805.vhd:767:34  */
  assign n1537_o = opcode == 8'b11011111;
  /* 6805.vhd:767:34  */
  assign n1538_o = n1535_o | n1537_o;
  /* 6805.vhd:776:32  */
  assign n1540_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:771:15  */
  assign n1542_o = opcode == 8'b10110111;
  /* 6805.vhd:783:32  */
  assign n1544_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:778:15  */
  assign n1546_o = opcode == 8'b10111111;
  /* 6805.vhd:791:32  */
  assign n1548_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:785:15  */
  assign n1550_o = opcode == 8'b10110000;
  /* 6805.vhd:785:26  */
  assign n1552_o = opcode == 8'b10110001;
  /* 6805.vhd:785:26  */
  assign n1553_o = n1550_o | n1552_o;
  /* 6805.vhd:785:34  */
  assign n1555_o = opcode == 8'b10110010;
  /* 6805.vhd:785:34  */
  assign n1556_o = n1553_o | n1555_o;
  /* 6805.vhd:785:42  */
  assign n1558_o = opcode == 8'b10110011;
  /* 6805.vhd:785:42  */
  assign n1559_o = n1556_o | n1558_o;
  /* 6805.vhd:785:50  */
  assign n1561_o = opcode == 8'b10110100;
  /* 6805.vhd:785:50  */
  assign n1562_o = n1559_o | n1561_o;
  /* 6805.vhd:786:26  */
  assign n1564_o = opcode == 8'b10110101;
  /* 6805.vhd:786:26  */
  assign n1565_o = n1562_o | n1564_o;
  /* 6805.vhd:786:34  */
  assign n1567_o = opcode == 8'b10110110;
  /* 6805.vhd:786:34  */
  assign n1568_o = n1565_o | n1567_o;
  /* 6805.vhd:786:42  */
  assign n1570_o = opcode == 8'b10111000;
  /* 6805.vhd:786:42  */
  assign n1571_o = n1568_o | n1570_o;
  /* 6805.vhd:787:26  */
  assign n1573_o = opcode == 8'b10111001;
  /* 6805.vhd:787:26  */
  assign n1574_o = n1571_o | n1573_o;
  /* 6805.vhd:787:34  */
  assign n1576_o = opcode == 8'b10111010;
  /* 6805.vhd:787:34  */
  assign n1577_o = n1574_o | n1576_o;
  /* 6805.vhd:787:42  */
  assign n1579_o = opcode == 8'b10111011;
  /* 6805.vhd:787:42  */
  assign n1580_o = n1577_o | n1579_o;
  /* 6805.vhd:787:50  */
  assign n1582_o = opcode == 8'b10111110;
  /* 6805.vhd:787:50  */
  assign n1583_o = n1580_o | n1582_o;
  /* 6805.vhd:795:26  */
  assign n1584_o = datain[7];
  /* 6805.vhd:795:30  */
  assign n1585_o = ~n1584_o;
  /* 6805.vhd:796:43  */
  assign n1587_o = {8'b00000000, datain};
  /* 6805.vhd:796:34  */
  assign n1588_o = regpc + n1587_o;
  /* 6805.vhd:796:53  */
  assign n1590_o = n1588_o + 16'b0000000000000001;
  /* 6805.vhd:798:43  */
  assign n1592_o = {8'b11111111, datain};
  /* 6805.vhd:798:34  */
  assign n1593_o = regpc + n1592_o;
  /* 6805.vhd:798:53  */
  assign n1595_o = n1593_o + 16'b0000000000000001;
  /* 6805.vhd:795:17  */
  assign n1596_o = n1585_o ? n1590_o : n1595_o;
  /* 6805.vhd:794:15  */
  assign n1598_o = opcode == 8'b00100000;
  /* 6805.vhd:802:32  */
  assign n1600_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:801:15  */
  assign n1602_o = opcode == 8'b00100001;
  /* 6805.vhd:805:27  */
  assign n1603_o = flagc | flagz;
  /* 6805.vhd:805:45  */
  assign n1604_o = opcode[0];
  /* 6805.vhd:805:37  */
  assign n1605_o = n1603_o == n1604_o;
  /* 6805.vhd:806:28  */
  assign n1606_o = datain[7];
  /* 6805.vhd:806:32  */
  assign n1607_o = ~n1606_o;
  /* 6805.vhd:807:45  */
  assign n1609_o = {8'b00000000, datain};
  /* 6805.vhd:807:36  */
  assign n1610_o = regpc + n1609_o;
  /* 6805.vhd:807:55  */
  assign n1612_o = n1610_o + 16'b0000000000000001;
  /* 6805.vhd:809:45  */
  assign n1614_o = {8'b11111111, datain};
  /* 6805.vhd:809:36  */
  assign n1615_o = regpc + n1614_o;
  /* 6805.vhd:809:55  */
  assign n1617_o = n1615_o + 16'b0000000000000001;
  /* 6805.vhd:806:19  */
  assign n1618_o = n1607_o ? n1612_o : n1617_o;
  /* 6805.vhd:812:34  */
  assign n1620_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:805:17  */
  assign n1621_o = n1605_o ? n1618_o : n1620_o;
  /* 6805.vhd:804:15  */
  assign n1623_o = opcode == 8'b00100010;
  /* 6805.vhd:804:26  */
  assign n1625_o = opcode == 8'b00100011;
  /* 6805.vhd:804:26  */
  assign n1626_o = n1623_o | n1625_o;
  /* 6805.vhd:816:35  */
  assign n1627_o = opcode[0];
  /* 6805.vhd:816:27  */
  assign n1628_o = flagc == n1627_o;
  /* 6805.vhd:817:28  */
  assign n1629_o = datain[7];
  /* 6805.vhd:817:32  */
  assign n1630_o = ~n1629_o;
  /* 6805.vhd:818:45  */
  assign n1632_o = {8'b00000000, datain};
  /* 6805.vhd:818:36  */
  assign n1633_o = regpc + n1632_o;
  /* 6805.vhd:818:55  */
  assign n1635_o = n1633_o + 16'b0000000000000001;
  /* 6805.vhd:820:45  */
  assign n1637_o = {8'b11111111, datain};
  /* 6805.vhd:820:36  */
  assign n1638_o = regpc + n1637_o;
  /* 6805.vhd:820:55  */
  assign n1640_o = n1638_o + 16'b0000000000000001;
  /* 6805.vhd:817:19  */
  assign n1641_o = n1630_o ? n1635_o : n1640_o;
  /* 6805.vhd:823:34  */
  assign n1643_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:816:17  */
  assign n1644_o = n1628_o ? n1641_o : n1643_o;
  /* 6805.vhd:815:15  */
  assign n1646_o = opcode == 8'b00100100;
  /* 6805.vhd:815:26  */
  assign n1648_o = opcode == 8'b00100101;
  /* 6805.vhd:815:26  */
  assign n1649_o = n1646_o | n1648_o;
  /* 6805.vhd:827:35  */
  assign n1650_o = opcode[0];
  /* 6805.vhd:827:27  */
  assign n1651_o = flagz == n1650_o;
  /* 6805.vhd:828:28  */
  assign n1652_o = datain[7];
  /* 6805.vhd:828:32  */
  assign n1653_o = ~n1652_o;
  /* 6805.vhd:829:45  */
  assign n1655_o = {8'b00000000, datain};
  /* 6805.vhd:829:36  */
  assign n1656_o = regpc + n1655_o;
  /* 6805.vhd:829:55  */
  assign n1658_o = n1656_o + 16'b0000000000000001;
  /* 6805.vhd:831:45  */
  assign n1660_o = {8'b11111111, datain};
  /* 6805.vhd:831:36  */
  assign n1661_o = regpc + n1660_o;
  /* 6805.vhd:831:55  */
  assign n1663_o = n1661_o + 16'b0000000000000001;
  /* 6805.vhd:828:19  */
  assign n1664_o = n1653_o ? n1658_o : n1663_o;
  /* 6805.vhd:834:34  */
  assign n1666_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:827:17  */
  assign n1667_o = n1651_o ? n1664_o : n1666_o;
  /* 6805.vhd:826:15  */
  assign n1669_o = opcode == 8'b00100110;
  /* 6805.vhd:826:26  */
  assign n1671_o = opcode == 8'b00100111;
  /* 6805.vhd:826:26  */
  assign n1672_o = n1669_o | n1671_o;
  /* 6805.vhd:838:35  */
  assign n1673_o = opcode[0];
  /* 6805.vhd:838:27  */
  assign n1674_o = flagh == n1673_o;
  /* 6805.vhd:839:28  */
  assign n1675_o = datain[7];
  /* 6805.vhd:839:32  */
  assign n1676_o = ~n1675_o;
  /* 6805.vhd:840:45  */
  assign n1678_o = {8'b00000000, datain};
  /* 6805.vhd:840:36  */
  assign n1679_o = regpc + n1678_o;
  /* 6805.vhd:840:55  */
  assign n1681_o = n1679_o + 16'b0000000000000001;
  /* 6805.vhd:842:45  */
  assign n1683_o = {8'b11111111, datain};
  /* 6805.vhd:842:36  */
  assign n1684_o = regpc + n1683_o;
  /* 6805.vhd:842:55  */
  assign n1686_o = n1684_o + 16'b0000000000000001;
  /* 6805.vhd:839:19  */
  assign n1687_o = n1676_o ? n1681_o : n1686_o;
  /* 6805.vhd:845:34  */
  assign n1689_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:838:17  */
  assign n1690_o = n1674_o ? n1687_o : n1689_o;
  /* 6805.vhd:837:15  */
  assign n1692_o = opcode == 8'b00101000;
  /* 6805.vhd:837:26  */
  assign n1694_o = opcode == 8'b00101001;
  /* 6805.vhd:837:26  */
  assign n1695_o = n1692_o | n1694_o;
  /* 6805.vhd:849:35  */
  assign n1696_o = opcode[0];
  /* 6805.vhd:849:27  */
  assign n1697_o = flagn == n1696_o;
  /* 6805.vhd:850:28  */
  assign n1698_o = datain[7];
  /* 6805.vhd:850:32  */
  assign n1699_o = ~n1698_o;
  /* 6805.vhd:851:45  */
  assign n1701_o = {8'b00000000, datain};
  /* 6805.vhd:851:36  */
  assign n1702_o = regpc + n1701_o;
  /* 6805.vhd:851:55  */
  assign n1704_o = n1702_o + 16'b0000000000000001;
  /* 6805.vhd:853:45  */
  assign n1706_o = {8'b11111111, datain};
  /* 6805.vhd:853:36  */
  assign n1707_o = regpc + n1706_o;
  /* 6805.vhd:853:55  */
  assign n1709_o = n1707_o + 16'b0000000000000001;
  /* 6805.vhd:850:19  */
  assign n1710_o = n1699_o ? n1704_o : n1709_o;
  /* 6805.vhd:856:34  */
  assign n1712_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:849:17  */
  assign n1713_o = n1697_o ? n1710_o : n1712_o;
  /* 6805.vhd:848:15  */
  assign n1715_o = opcode == 8'b00101010;
  /* 6805.vhd:848:26  */
  assign n1717_o = opcode == 8'b00101011;
  /* 6805.vhd:848:26  */
  assign n1718_o = n1715_o | n1717_o;
  /* 6805.vhd:860:35  */
  assign n1719_o = opcode[0];
  /* 6805.vhd:860:27  */
  assign n1720_o = flagi == n1719_o;
  /* 6805.vhd:861:28  */
  assign n1721_o = datain[7];
  /* 6805.vhd:861:32  */
  assign n1722_o = ~n1721_o;
  /* 6805.vhd:862:45  */
  assign n1724_o = {8'b00000000, datain};
  /* 6805.vhd:862:36  */
  assign n1725_o = regpc + n1724_o;
  /* 6805.vhd:862:55  */
  assign n1727_o = n1725_o + 16'b0000000000000001;
  /* 6805.vhd:864:45  */
  assign n1729_o = {8'b11111111, datain};
  /* 6805.vhd:864:36  */
  assign n1730_o = regpc + n1729_o;
  /* 6805.vhd:864:55  */
  assign n1732_o = n1730_o + 16'b0000000000000001;
  /* 6805.vhd:861:19  */
  assign n1733_o = n1722_o ? n1727_o : n1732_o;
  /* 6805.vhd:867:34  */
  assign n1735_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:860:17  */
  assign n1736_o = n1720_o ? n1733_o : n1735_o;
  /* 6805.vhd:859:15  */
  assign n1738_o = opcode == 8'b00101100;
  /* 6805.vhd:859:26  */
  assign n1740_o = opcode == 8'b00101101;
  /* 6805.vhd:859:26  */
  assign n1741_o = n1738_o | n1740_o;
  /* 6805.vhd:871:36  */
  assign n1742_o = opcode[0];
  /* 6805.vhd:871:28  */
  assign n1743_o = extirq == n1742_o;
  /* 6805.vhd:872:28  */
  assign n1744_o = datain[7];
  /* 6805.vhd:872:32  */
  assign n1745_o = ~n1744_o;
  /* 6805.vhd:873:45  */
  assign n1747_o = {8'b00000000, datain};
  /* 6805.vhd:873:36  */
  assign n1748_o = regpc + n1747_o;
  /* 6805.vhd:873:55  */
  assign n1750_o = n1748_o + 16'b0000000000000001;
  /* 6805.vhd:875:45  */
  assign n1752_o = {8'b11111111, datain};
  /* 6805.vhd:875:36  */
  assign n1753_o = regpc + n1752_o;
  /* 6805.vhd:875:55  */
  assign n1755_o = n1753_o + 16'b0000000000000001;
  /* 6805.vhd:872:19  */
  assign n1756_o = n1745_o ? n1750_o : n1755_o;
  /* 6805.vhd:878:34  */
  assign n1758_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:871:17  */
  assign n1759_o = n1743_o ? n1756_o : n1758_o;
  /* 6805.vhd:870:15  */
  assign n1761_o = opcode == 8'b00101110;
  /* 6805.vhd:870:26  */
  assign n1763_o = opcode == 8'b00101111;
  /* 6805.vhd:870:26  */
  assign n1764_o = n1761_o | n1763_o;
  /* 6805.vhd:884:19  */
  assign n1766_o = opcode == 8'b00111111;
  /* 6805.vhd:887:46  */
  assign n1768_o = {8'b00000000, datain};
  /* 6805.vhd:887:37  */
  assign n1769_o = temp + n1768_o;
  /* 6805.vhd:886:19  */
  assign n1771_o = opcode == 8'b01101111;
  assign n1772_o = {n1771_o, n1766_o};
  assign n1773_o = n1769_o[7:0];
  /* 6805.vhd:883:17  */
  always @*
    case (n1772_o)
      2'b10: n1775_o = n1773_o;
      2'b01: n1775_o = datain;
      default: n1775_o = 8'b00000000;
    endcase
  assign n1776_o = n1769_o[15:8];
  assign n1778_o = temp[15:8];
  /* 6805.vhd:883:17  */
  always @*
    case (n1772_o)
      2'b10: n1779_o = n1776_o;
      2'b01: n1779_o = n1778_o;
      default: n1779_o = 8'b00000000;
    endcase
  /* 6805.vhd:896:34  */
  assign n1781_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:881:15  */
  assign n1783_o = opcode == 8'b00111111;
  /* 6805.vhd:881:26  */
  assign n1785_o = opcode == 8'b01101111;
  /* 6805.vhd:881:26  */
  assign n1786_o = n1783_o | n1785_o;
  /* 6805.vhd:901:42  */
  assign n1788_o = {8'b00000000, datain};
  /* 6805.vhd:901:33  */
  assign n1789_o = temp + n1788_o;
  /* 6805.vhd:902:34  */
  assign n1791_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:898:15  */
  assign n1793_o = opcode == 8'b01100000;
  /* 6805.vhd:898:26  */
  assign n1795_o = opcode == 8'b01100011;
  /* 6805.vhd:898:26  */
  assign n1796_o = n1793_o | n1795_o;
  /* 6805.vhd:898:34  */
  assign n1798_o = opcode == 8'b01100100;
  /* 6805.vhd:898:34  */
  assign n1799_o = n1796_o | n1798_o;
  /* 6805.vhd:898:42  */
  assign n1801_o = opcode == 8'b01100110;
  /* 6805.vhd:898:42  */
  assign n1802_o = n1799_o | n1801_o;
  /* 6805.vhd:898:50  */
  assign n1804_o = opcode == 8'b01100111;
  /* 6805.vhd:898:50  */
  assign n1805_o = n1802_o | n1804_o;
  /* 6805.vhd:899:26  */
  assign n1807_o = opcode == 8'b01101000;
  /* 6805.vhd:899:26  */
  assign n1808_o = n1805_o | n1807_o;
  /* 6805.vhd:899:34  */
  assign n1810_o = opcode == 8'b01101001;
  /* 6805.vhd:899:34  */
  assign n1811_o = n1808_o | n1810_o;
  /* 6805.vhd:899:42  */
  assign n1813_o = opcode == 8'b01101010;
  /* 6805.vhd:899:42  */
  assign n1814_o = n1811_o | n1813_o;
  /* 6805.vhd:899:50  */
  assign n1816_o = opcode == 8'b01101100;
  /* 6805.vhd:899:50  */
  assign n1817_o = n1814_o | n1816_o;
  /* 6805.vhd:900:26  */
  assign n1819_o = opcode == 8'b01101101;
  /* 6805.vhd:900:26  */
  assign n1820_o = n1817_o | n1819_o;
  /* 6805.vhd:905:15  */
  assign n1822_o = opcode == 8'b01111111;
  /* 6805.vhd:910:32  */
  assign n1823_o = datain[4];
  /* 6805.vhd:911:32  */
  assign n1824_o = datain[3];
  /* 6805.vhd:912:32  */
  assign n1825_o = datain[2];
  /* 6805.vhd:913:32  */
  assign n1826_o = datain[1];
  /* 6805.vhd:914:32  */
  assign n1827_o = datain[0];
  /* 6805.vhd:915:32  */
  assign n1829_o = regsp + 16'b0000000000000001;
  /* 6805.vhd:909:15  */
  assign n1831_o = opcode == 8'b10000000;
  /* 6805.vhd:909:26  */
  assign n1833_o = opcode == 8'b10000010;
  /* 6805.vhd:909:26  */
  assign n1834_o = n1831_o | n1833_o;
  /* 6805.vhd:919:32  */
  assign n1836_o = regsp + 16'b0000000000000001;
  /* 6805.vhd:917:15  */
  assign n1838_o = opcode == 8'b10000001;
  /* 6805.vhd:921:15  */
  assign n1840_o = opcode == 8'b10000011;
  /* 6805.vhd:926:32  */
  assign n1842_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:925:15  */
  assign n1844_o = opcode == 8'b10101101;
  /* 6805.vhd:925:26  */
  assign n1846_o = opcode == 8'b10111101;
  /* 6805.vhd:925:26  */
  assign n1847_o = n1844_o | n1846_o;
  /* 6805.vhd:925:34  */
  assign n1849_o = opcode == 8'b11101101;
  /* 6805.vhd:925:34  */
  assign n1850_o = n1847_o | n1849_o;
  /* 6805.vhd:933:33  */
  assign n1852_o = {8'b00000000, datain};
  /* 6805.vhd:932:15  */
  assign n1854_o = opcode == 8'b10111100;
  /* 6805.vhd:937:32  */
  assign n1856_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:935:15  */
  assign n1858_o = opcode == 8'b11001101;
  /* 6805.vhd:935:26  */
  assign n1860_o = opcode == 8'b11011101;
  /* 6805.vhd:935:26  */
  assign n1861_o = n1858_o | n1860_o;
  assign n1862_o = {n1861_o, n1854_o, n1850_o, n1840_o, n1838_o, n1834_o, n1822_o, n1820_o, n1786_o, n1764_o, n1741_o, n1718_o, n1695_o, n1672_o, n1649_o, n1626_o, n1602_o, n1598_o, n1583_o, n1546_o, n1542_o, n1538_o, n1447_o};
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1869_o = n3854_q;
      23'b01000000000000000000000: n1869_o = n3854_q;
      23'b00100000000000000000000: n1869_o = 1'b0;
      23'b00010000000000000000000: n1869_o = 1'b0;
      23'b00001000000000000000000: n1869_o = n3854_q;
      23'b00000100000000000000000: n1869_o = n3854_q;
      23'b00000010000000000000000: n1869_o = 1'b1;
      23'b00000001000000000000000: n1869_o = n3854_q;
      23'b00000000100000000000000: n1869_o = 1'b0;
      23'b00000000010000000000000: n1869_o = n3854_q;
      23'b00000000001000000000000: n1869_o = n3854_q;
      23'b00000000000100000000000: n1869_o = n3854_q;
      23'b00000000000010000000000: n1869_o = n3854_q;
      23'b00000000000001000000000: n1869_o = n3854_q;
      23'b00000000000000100000000: n1869_o = n3854_q;
      23'b00000000000000010000000: n1869_o = n3854_q;
      23'b00000000000000001000000: n1869_o = n3854_q;
      23'b00000000000000000100000: n1869_o = n3854_q;
      23'b00000000000000000010000: n1869_o = n3854_q;
      23'b00000000000000000001000: n1869_o = 1'b0;
      23'b00000000000000000000100: n1869_o = 1'b0;
      23'b00000000000000000000010: n1869_o = n3854_q;
      23'b00000000000000000000001: n1869_o = n3854_q;
      default: n1869_o = n3854_q;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1870_o = regsp;
      23'b01000000000000000000000: n1870_o = regsp;
      23'b00100000000000000000000: n1870_o = regsp;
      23'b00010000000000000000000: n1870_o = regsp;
      23'b00001000000000000000000: n1870_o = n1836_o;
      23'b00000100000000000000000: n1870_o = n1829_o;
      23'b00000010000000000000000: n1870_o = regsp;
      23'b00000001000000000000000: n1870_o = regsp;
      23'b00000000100000000000000: n1870_o = regsp;
      23'b00000000010000000000000: n1870_o = regsp;
      23'b00000000001000000000000: n1870_o = regsp;
      23'b00000000000100000000000: n1870_o = regsp;
      23'b00000000000010000000000: n1870_o = regsp;
      23'b00000000000001000000000: n1870_o = regsp;
      23'b00000000000000100000000: n1870_o = regsp;
      23'b00000000000000010000000: n1870_o = regsp;
      23'b00000000000000001000000: n1870_o = regsp;
      23'b00000000000000000100000: n1870_o = regsp;
      23'b00000000000000000010000: n1870_o = regsp;
      23'b00000000000000000001000: n1870_o = regsp;
      23'b00000000000000000000100: n1870_o = regsp;
      23'b00000000000000000000010: n1870_o = regsp;
      23'b00000000000000000000001: n1870_o = regsp;
      default: n1870_o = regsp;
    endcase
  assign n1871_o = n1322_o[7:0];
  assign n1872_o = n1449_o[7:0];
  assign n1873_o = n1540_o[7:0];
  assign n1874_o = n1544_o[7:0];
  assign n1875_o = n1548_o[7:0];
  assign n1876_o = n1596_o[7:0];
  assign n1877_o = n1600_o[7:0];
  assign n1878_o = n1621_o[7:0];
  assign n1879_o = n1644_o[7:0];
  assign n1880_o = n1667_o[7:0];
  assign n1881_o = n1690_o[7:0];
  assign n1882_o = n1713_o[7:0];
  assign n1883_o = n1736_o[7:0];
  assign n1884_o = n1759_o[7:0];
  assign n1885_o = n1781_o[7:0];
  assign n1886_o = n1791_o[7:0];
  assign n1887_o = n1842_o[7:0];
  assign n1888_o = n1852_o[7:0];
  assign n1889_o = n1856_o[7:0];
  assign n1890_o = regpc[7:0];
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1891_o = n1889_o;
      23'b01000000000000000000000: n1891_o = n1888_o;
      23'b00100000000000000000000: n1891_o = n1887_o;
      23'b00010000000000000000000: n1891_o = n1890_o;
      23'b00001000000000000000000: n1891_o = n1890_o;
      23'b00000100000000000000000: n1891_o = n1890_o;
      23'b00000010000000000000000: n1891_o = n1890_o;
      23'b00000001000000000000000: n1891_o = n1886_o;
      23'b00000000100000000000000: n1891_o = n1885_o;
      23'b00000000010000000000000: n1891_o = n1884_o;
      23'b00000000001000000000000: n1891_o = n1883_o;
      23'b00000000000100000000000: n1891_o = n1882_o;
      23'b00000000000010000000000: n1891_o = n1881_o;
      23'b00000000000001000000000: n1891_o = n1880_o;
      23'b00000000000000100000000: n1891_o = n1879_o;
      23'b00000000000000010000000: n1891_o = n1878_o;
      23'b00000000000000001000000: n1891_o = n1877_o;
      23'b00000000000000000100000: n1891_o = n1876_o;
      23'b00000000000000000010000: n1891_o = n1875_o;
      23'b00000000000000000001000: n1891_o = n1874_o;
      23'b00000000000000000000100: n1891_o = n1873_o;
      23'b00000000000000000000010: n1891_o = n1872_o;
      23'b00000000000000000000001: n1891_o = n1871_o;
      default: n1891_o = n1890_o;
    endcase
  assign n1892_o = n1322_o[15:8];
  assign n1893_o = n1449_o[15:8];
  assign n1894_o = n1540_o[15:8];
  assign n1895_o = n1544_o[15:8];
  assign n1896_o = n1548_o[15:8];
  assign n1897_o = n1596_o[15:8];
  assign n1898_o = n1600_o[15:8];
  assign n1899_o = n1621_o[15:8];
  assign n1900_o = n1644_o[15:8];
  assign n1901_o = n1667_o[15:8];
  assign n1902_o = n1690_o[15:8];
  assign n1903_o = n1713_o[15:8];
  assign n1904_o = n1736_o[15:8];
  assign n1905_o = n1759_o[15:8];
  assign n1906_o = n1781_o[15:8];
  assign n1907_o = n1791_o[15:8];
  assign n1908_o = n1842_o[15:8];
  assign n1909_o = n1852_o[15:8];
  assign n1910_o = n1856_o[15:8];
  assign n1911_o = regpc[15:8];
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1912_o = n1910_o;
      23'b01000000000000000000000: n1912_o = n1909_o;
      23'b00100000000000000000000: n1912_o = n1908_o;
      23'b00010000000000000000000: n1912_o = n1911_o;
      23'b00001000000000000000000: n1912_o = datain;
      23'b00000100000000000000000: n1912_o = n1911_o;
      23'b00000010000000000000000: n1912_o = n1911_o;
      23'b00000001000000000000000: n1912_o = n1907_o;
      23'b00000000100000000000000: n1912_o = n1906_o;
      23'b00000000010000000000000: n1912_o = n1905_o;
      23'b00000000001000000000000: n1912_o = n1904_o;
      23'b00000000000100000000000: n1912_o = n1903_o;
      23'b00000000000010000000000: n1912_o = n1902_o;
      23'b00000000000001000000000: n1912_o = n1901_o;
      23'b00000000000000100000000: n1912_o = n1900_o;
      23'b00000000000000010000000: n1912_o = n1899_o;
      23'b00000000000000001000000: n1912_o = n1898_o;
      23'b00000000000000000100000: n1912_o = n1897_o;
      23'b00000000000000000010000: n1912_o = n1896_o;
      23'b00000000000000000001000: n1912_o = n1895_o;
      23'b00000000000000000000100: n1912_o = n1894_o;
      23'b00000000000000000000010: n1912_o = n1893_o;
      23'b00000000000000000000001: n1912_o = n1892_o;
      default: n1912_o = n1911_o;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1913_o = flagh;
      23'b01000000000000000000000: n1913_o = flagh;
      23'b00100000000000000000000: n1913_o = flagh;
      23'b00010000000000000000000: n1913_o = flagh;
      23'b00001000000000000000000: n1913_o = flagh;
      23'b00000100000000000000000: n1913_o = n1823_o;
      23'b00000010000000000000000: n1913_o = flagh;
      23'b00000001000000000000000: n1913_o = flagh;
      23'b00000000100000000000000: n1913_o = flagh;
      23'b00000000010000000000000: n1913_o = flagh;
      23'b00000000001000000000000: n1913_o = flagh;
      23'b00000000000100000000000: n1913_o = flagh;
      23'b00000000000010000000000: n1913_o = flagh;
      23'b00000000000001000000000: n1913_o = flagh;
      23'b00000000000000100000000: n1913_o = flagh;
      23'b00000000000000010000000: n1913_o = flagh;
      23'b00000000000000001000000: n1913_o = flagh;
      23'b00000000000000000100000: n1913_o = flagh;
      23'b00000000000000000010000: n1913_o = flagh;
      23'b00000000000000000001000: n1913_o = flagh;
      23'b00000000000000000000100: n1913_o = flagh;
      23'b00000000000000000000010: n1913_o = flagh;
      23'b00000000000000000000001: n1913_o = flagh;
      default: n1913_o = flagh;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1914_o = flagi;
      23'b01000000000000000000000: n1914_o = flagi;
      23'b00100000000000000000000: n1914_o = flagi;
      23'b00010000000000000000000: n1914_o = flagi;
      23'b00001000000000000000000: n1914_o = flagi;
      23'b00000100000000000000000: n1914_o = n1824_o;
      23'b00000010000000000000000: n1914_o = flagi;
      23'b00000001000000000000000: n1914_o = flagi;
      23'b00000000100000000000000: n1914_o = flagi;
      23'b00000000010000000000000: n1914_o = flagi;
      23'b00000000001000000000000: n1914_o = flagi;
      23'b00000000000100000000000: n1914_o = flagi;
      23'b00000000000010000000000: n1914_o = flagi;
      23'b00000000000001000000000: n1914_o = flagi;
      23'b00000000000000100000000: n1914_o = flagi;
      23'b00000000000000010000000: n1914_o = flagi;
      23'b00000000000000001000000: n1914_o = flagi;
      23'b00000000000000000100000: n1914_o = flagi;
      23'b00000000000000000010000: n1914_o = flagi;
      23'b00000000000000000001000: n1914_o = flagi;
      23'b00000000000000000000100: n1914_o = flagi;
      23'b00000000000000000000010: n1914_o = flagi;
      23'b00000000000000000000001: n1914_o = flagi;
      default: n1914_o = flagi;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1916_o = flagn;
      23'b01000000000000000000000: n1916_o = flagn;
      23'b00100000000000000000000: n1916_o = flagn;
      23'b00010000000000000000000: n1916_o = flagn;
      23'b00001000000000000000000: n1916_o = flagn;
      23'b00000100000000000000000: n1916_o = n1825_o;
      23'b00000010000000000000000: n1916_o = flagn;
      23'b00000001000000000000000: n1916_o = flagn;
      23'b00000000100000000000000: n1916_o = 1'b0;
      23'b00000000010000000000000: n1916_o = flagn;
      23'b00000000001000000000000: n1916_o = flagn;
      23'b00000000000100000000000: n1916_o = flagn;
      23'b00000000000010000000000: n1916_o = flagn;
      23'b00000000000001000000000: n1916_o = flagn;
      23'b00000000000000100000000: n1916_o = flagn;
      23'b00000000000000010000000: n1916_o = flagn;
      23'b00000000000000001000000: n1916_o = flagn;
      23'b00000000000000000100000: n1916_o = flagn;
      23'b00000000000000000010000: n1916_o = flagn;
      23'b00000000000000000001000: n1916_o = flagn;
      23'b00000000000000000000100: n1916_o = flagn;
      23'b00000000000000000000010: n1916_o = flagn;
      23'b00000000000000000000001: n1916_o = flagn;
      default: n1916_o = flagn;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1918_o = flagz;
      23'b01000000000000000000000: n1918_o = flagz;
      23'b00100000000000000000000: n1918_o = flagz;
      23'b00010000000000000000000: n1918_o = flagz;
      23'b00001000000000000000000: n1918_o = flagz;
      23'b00000100000000000000000: n1918_o = n1826_o;
      23'b00000010000000000000000: n1918_o = flagz;
      23'b00000001000000000000000: n1918_o = flagz;
      23'b00000000100000000000000: n1918_o = 1'b1;
      23'b00000000010000000000000: n1918_o = flagz;
      23'b00000000001000000000000: n1918_o = flagz;
      23'b00000000000100000000000: n1918_o = flagz;
      23'b00000000000010000000000: n1918_o = flagz;
      23'b00000000000001000000000: n1918_o = flagz;
      23'b00000000000000100000000: n1918_o = flagz;
      23'b00000000000000010000000: n1918_o = flagz;
      23'b00000000000000001000000: n1918_o = flagz;
      23'b00000000000000000100000: n1918_o = flagz;
      23'b00000000000000000010000: n1918_o = flagz;
      23'b00000000000000000001000: n1918_o = flagz;
      23'b00000000000000000000100: n1918_o = flagz;
      23'b00000000000000000000010: n1918_o = flagz;
      23'b00000000000000000000001: n1918_o = flagz;
      default: n1918_o = flagz;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1919_o = flagc;
      23'b01000000000000000000000: n1919_o = flagc;
      23'b00100000000000000000000: n1919_o = flagc;
      23'b00010000000000000000000: n1919_o = flagc;
      23'b00001000000000000000000: n1919_o = flagc;
      23'b00000100000000000000000: n1919_o = n1827_o;
      23'b00000010000000000000000: n1919_o = flagc;
      23'b00000001000000000000000: n1919_o = flagc;
      23'b00000000100000000000000: n1919_o = flagc;
      23'b00000000010000000000000: n1919_o = flagc;
      23'b00000000001000000000000: n1919_o = flagc;
      23'b00000000000100000000000: n1919_o = flagc;
      23'b00000000000010000000000: n1919_o = flagc;
      23'b00000000000001000000000: n1919_o = flagc;
      23'b00000000000000100000000: n1919_o = flagc;
      23'b00000000000000010000000: n1919_o = flagc;
      23'b00000000000000001000000: n1919_o = flagc;
      23'b00000000000000000100000: n1919_o = flagc;
      23'b00000000000000000010000: n1919_o = flagc;
      23'b00000000000000000001000: n1919_o = flagc;
      23'b00000000000000000000100: n1919_o = flagc;
      23'b00000000000000000000010: n1919_o = flagc;
      23'b00000000000000000000001: n1919_o = flagc;
      default: n1919_o = flagc;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1921_o = help;
      23'b01000000000000000000000: n1921_o = help;
      23'b00100000000000000000000: n1921_o = datain;
      23'b00010000000000000000000: n1921_o = help;
      23'b00001000000000000000000: n1921_o = help;
      23'b00000100000000000000000: n1921_o = help;
      23'b00000010000000000000000: n1921_o = help;
      23'b00000001000000000000000: n1921_o = help;
      23'b00000000100000000000000: n1921_o = 8'b00000000;
      23'b00000000010000000000000: n1921_o = help;
      23'b00000000001000000000000: n1921_o = help;
      23'b00000000000100000000000: n1921_o = help;
      23'b00000000000010000000000: n1921_o = help;
      23'b00000000000001000000000: n1921_o = help;
      23'b00000000000000100000000: n1921_o = help;
      23'b00000000000000010000000: n1921_o = help;
      23'b00000000000000001000000: n1921_o = help;
      23'b00000000000000000100000: n1921_o = help;
      23'b00000000000000000010000: n1921_o = help;
      23'b00000000000000000001000: n1921_o = help;
      23'b00000000000000000000100: n1921_o = help;
      23'b00000000000000000000010: n1921_o = help;
      23'b00000000000000000000001: n1921_o = help;
      default: n1921_o = help;
    endcase
  assign n1922_o = n1789_o[7:0];
  assign n1923_o = temp[7:0];
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1924_o = n1923_o;
      23'b01000000000000000000000: n1924_o = n1923_o;
      23'b00100000000000000000000: n1924_o = n1923_o;
      23'b00010000000000000000000: n1924_o = n1923_o;
      23'b00001000000000000000000: n1924_o = n1923_o;
      23'b00000100000000000000000: n1924_o = n1923_o;
      23'b00000010000000000000000: n1924_o = n1923_o;
      23'b00000001000000000000000: n1924_o = n1922_o;
      23'b00000000100000000000000: n1924_o = n1775_o;
      23'b00000000010000000000000: n1924_o = n1923_o;
      23'b00000000001000000000000: n1924_o = n1923_o;
      23'b00000000000100000000000: n1924_o = n1923_o;
      23'b00000000000010000000000: n1924_o = n1923_o;
      23'b00000000000001000000000: n1924_o = n1923_o;
      23'b00000000000000100000000: n1924_o = n1923_o;
      23'b00000000000000010000000: n1924_o = n1923_o;
      23'b00000000000000001000000: n1924_o = n1923_o;
      23'b00000000000000000100000: n1924_o = n1923_o;
      23'b00000000000000000010000: n1924_o = datain;
      23'b00000000000000000001000: n1924_o = datain;
      23'b00000000000000000000100: n1924_o = datain;
      23'b00000000000000000000010: n1924_o = n1923_o;
      23'b00000000000000000000001: n1924_o = datain;
      default: n1924_o = n1923_o;
    endcase
  assign n1925_o = n1789_o[15:8];
  assign n1926_o = temp[15:8];
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1927_o = datain;
      23'b01000000000000000000000: n1927_o = n1926_o;
      23'b00100000000000000000000: n1927_o = n1926_o;
      23'b00010000000000000000000: n1927_o = n1926_o;
      23'b00001000000000000000000: n1927_o = n1926_o;
      23'b00000100000000000000000: n1927_o = n1926_o;
      23'b00000010000000000000000: n1927_o = n1926_o;
      23'b00000001000000000000000: n1927_o = n1925_o;
      23'b00000000100000000000000: n1927_o = n1779_o;
      23'b00000000010000000000000: n1927_o = n1926_o;
      23'b00000000001000000000000: n1927_o = n1926_o;
      23'b00000000000100000000000: n1927_o = n1926_o;
      23'b00000000000010000000000: n1927_o = n1926_o;
      23'b00000000000001000000000: n1927_o = n1926_o;
      23'b00000000000000100000000: n1927_o = n1926_o;
      23'b00000000000000010000000: n1927_o = n1926_o;
      23'b00000000000000001000000: n1927_o = n1926_o;
      23'b00000000000000000100000: n1927_o = n1926_o;
      23'b00000000000000000010000: n1927_o = n1926_o;
      23'b00000000000000000001000: n1927_o = n1926_o;
      23'b00000000000000000000100: n1927_o = n1926_o;
      23'b00000000000000000000010: n1927_o = datain;
      23'b00000000000000000000001: n1927_o = n1926_o;
      default: n1927_o = n1926_o;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1952_o = 4'b0100;
      23'b01000000000000000000000: n1952_o = 4'b0010;
      23'b00100000000000000000000: n1952_o = 4'b0100;
      23'b00010000000000000000000: n1952_o = 4'b0100;
      23'b00001000000000000000000: n1952_o = 4'b0100;
      23'b00000100000000000000000: n1952_o = 4'b0100;
      23'b00000010000000000000000: n1952_o = 4'b0010;
      23'b00000001000000000000000: n1952_o = 4'b0100;
      23'b00000000100000000000000: n1952_o = 4'b0100;
      23'b00000000010000000000000: n1952_o = 4'b0010;
      23'b00000000001000000000000: n1952_o = 4'b0010;
      23'b00000000000100000000000: n1952_o = 4'b0010;
      23'b00000000000010000000000: n1952_o = 4'b0010;
      23'b00000000000001000000000: n1952_o = 4'b0010;
      23'b00000000000000100000000: n1952_o = 4'b0010;
      23'b00000000000000010000000: n1952_o = 4'b0010;
      23'b00000000000000001000000: n1952_o = 4'b0010;
      23'b00000000000000000100000: n1952_o = 4'b0010;
      23'b00000000000000000010000: n1952_o = 4'b0101;
      23'b00000000000000000001000: n1952_o = 4'b0101;
      23'b00000000000000000000100: n1952_o = 4'b0101;
      23'b00000000000000000000010: n1952_o = 4'b0100;
      23'b00000000000000000000001: n1952_o = 4'b0100;
      default: n1952_o = 4'b0000;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1961_o = addrmux;
      23'b01000000000000000000000: n1961_o = addrmux;
      23'b00100000000000000000000: n1961_o = 3'b001;
      23'b00010000000000000000000: n1961_o = addrmux;
      23'b00001000000000000000000: n1961_o = addrmux;
      23'b00000100000000000000000: n1961_o = addrmux;
      23'b00000010000000000000000: n1961_o = 3'b000;
      23'b00000001000000000000000: n1961_o = 3'b011;
      23'b00000000100000000000000: n1961_o = 3'b011;
      23'b00000000010000000000000: n1961_o = addrmux;
      23'b00000000001000000000000: n1961_o = addrmux;
      23'b00000000000100000000000: n1961_o = addrmux;
      23'b00000000000010000000000: n1961_o = addrmux;
      23'b00000000000001000000000: n1961_o = addrmux;
      23'b00000000000000100000000: n1961_o = addrmux;
      23'b00000000000000010000000: n1961_o = addrmux;
      23'b00000000000000001000000: n1961_o = addrmux;
      23'b00000000000000000100000: n1961_o = addrmux;
      23'b00000000000000000010000: n1961_o = 3'b011;
      23'b00000000000000000001000: n1961_o = 3'b011;
      23'b00000000000000000000100: n1961_o = 3'b011;
      23'b00000000000000000000010: n1961_o = addrmux;
      23'b00000000000000000000001: n1961_o = 3'b011;
      default: n1961_o = addrmux;
    endcase
  /* 6805.vhd:748:13  */
  always @*
    case (n1862_o)
      23'b10000000000000000000000: n1967_o = datamux;
      23'b01000000000000000000000: n1967_o = datamux;
      23'b00100000000000000000000: n1967_o = 4'b0101;
      23'b00010000000000000000000: n1967_o = 4'b0101;
      23'b00001000000000000000000: n1967_o = datamux;
      23'b00000100000000000000000: n1967_o = datamux;
      23'b00000010000000000000000: n1967_o = datamux;
      23'b00000001000000000000000: n1967_o = datamux;
      23'b00000000100000000000000: n1967_o = 4'b1001;
      23'b00000000010000000000000: n1967_o = datamux;
      23'b00000000001000000000000: n1967_o = datamux;
      23'b00000000000100000000000: n1967_o = datamux;
      23'b00000000000010000000000: n1967_o = datamux;
      23'b00000000000001000000000: n1967_o = datamux;
      23'b00000000000000100000000: n1967_o = datamux;
      23'b00000000000000010000000: n1967_o = datamux;
      23'b00000000000000001000000: n1967_o = datamux;
      23'b00000000000000000100000: n1967_o = datamux;
      23'b00000000000000000010000: n1967_o = datamux;
      23'b00000000000000000001000: n1967_o = 4'b0010;
      23'b00000000000000000000100: n1967_o = 4'b0000;
      23'b00000000000000000000010: n1967_o = datamux;
      23'b00000000000000000000001: n1967_o = datamux;
      default: n1967_o = datamux;
    endcase
  /* 6805.vhd:747:11  */
  assign n1969_o = mainfsm == 4'b0011;
  /* 6805.vhd:948:57  */
  assign n1970_o = opcode[3:1];
  /* 6805.vhd:948:38  */
  assign n1973_o = 3'b111 - n1970_o;
  /* 6805.vhd:948:28  */
  assign n1976_o = datain & n3868_o;
  /* 6805.vhd:948:73  */
  assign n1978_o = n1976_o != 8'b00000000;
  /* 6805.vhd:948:17  */
  assign n1981_o = n1978_o ? 1'b1 : 1'b0;
  /* 6805.vhd:946:15  */
  assign n1983_o = opcode == 8'b00000000;
  /* 6805.vhd:946:26  */
  assign n1985_o = opcode == 8'b00000010;
  /* 6805.vhd:946:26  */
  assign n1986_o = n1983_o | n1985_o;
  /* 6805.vhd:946:34  */
  assign n1988_o = opcode == 8'b00000100;
  /* 6805.vhd:946:34  */
  assign n1989_o = n1986_o | n1988_o;
  /* 6805.vhd:946:42  */
  assign n1991_o = opcode == 8'b00000110;
  /* 6805.vhd:946:42  */
  assign n1992_o = n1989_o | n1991_o;
  /* 6805.vhd:946:50  */
  assign n1994_o = opcode == 8'b00001000;
  /* 6805.vhd:946:50  */
  assign n1995_o = n1992_o | n1994_o;
  /* 6805.vhd:946:58  */
  assign n1997_o = opcode == 8'b00001010;
  /* 6805.vhd:946:58  */
  assign n1998_o = n1995_o | n1997_o;
  /* 6805.vhd:946:66  */
  assign n2000_o = opcode == 8'b00001100;
  /* 6805.vhd:946:66  */
  assign n2001_o = n1998_o | n2000_o;
  /* 6805.vhd:946:74  */
  assign n2003_o = opcode == 8'b00001110;
  /* 6805.vhd:946:74  */
  assign n2004_o = n2001_o | n2003_o;
  /* 6805.vhd:946:82  */
  assign n2006_o = opcode == 8'b00000001;
  /* 6805.vhd:946:82  */
  assign n2007_o = n2004_o | n2006_o;
  /* 6805.vhd:947:26  */
  assign n2009_o = opcode == 8'b00000011;
  /* 6805.vhd:947:26  */
  assign n2010_o = n2007_o | n2009_o;
  /* 6805.vhd:947:34  */
  assign n2012_o = opcode == 8'b00000101;
  /* 6805.vhd:947:34  */
  assign n2013_o = n2010_o | n2012_o;
  /* 6805.vhd:947:42  */
  assign n2015_o = opcode == 8'b00000111;
  /* 6805.vhd:947:42  */
  assign n2016_o = n2013_o | n2015_o;
  /* 6805.vhd:947:50  */
  assign n2018_o = opcode == 8'b00001001;
  /* 6805.vhd:947:50  */
  assign n2019_o = n2016_o | n2018_o;
  /* 6805.vhd:947:58  */
  assign n2021_o = opcode == 8'b00001011;
  /* 6805.vhd:947:58  */
  assign n2022_o = n2019_o | n2021_o;
  /* 6805.vhd:947:66  */
  assign n2024_o = opcode == 8'b00001101;
  /* 6805.vhd:947:66  */
  assign n2025_o = n2022_o | n2024_o;
  /* 6805.vhd:947:74  */
  assign n2027_o = opcode == 8'b00001111;
  /* 6805.vhd:947:74  */
  assign n2028_o = n2025_o | n2027_o;
  /* 6805.vhd:959:26  */
  assign n2029_o = opcode[0];
  /* 6805.vhd:959:30  */
  assign n2030_o = ~n2029_o;
  /* 6805.vhd:960:63  */
  assign n2031_o = opcode[3:1];
  /* 6805.vhd:960:44  */
  assign n2034_o = 3'b111 - n2031_o;
  /* 6805.vhd:960:34  */
  assign n2037_o = datain | n3882_o;
  /* 6805.vhd:962:63  */
  assign n2038_o = opcode[3:1];
  /* 6805.vhd:962:44  */
  assign n2041_o = 3'b111 - n2038_o;
  /* 6805.vhd:962:34  */
  assign n2044_o = datain & n3896_o;
  /* 6805.vhd:959:17  */
  assign n2045_o = n2030_o ? n2037_o : n2044_o;
  /* 6805.vhd:955:15  */
  assign n2047_o = opcode == 8'b00010000;
  /* 6805.vhd:955:26  */
  assign n2049_o = opcode == 8'b00010010;
  /* 6805.vhd:955:26  */
  assign n2050_o = n2047_o | n2049_o;
  /* 6805.vhd:955:34  */
  assign n2052_o = opcode == 8'b00010100;
  /* 6805.vhd:955:34  */
  assign n2053_o = n2050_o | n2052_o;
  /* 6805.vhd:955:42  */
  assign n2055_o = opcode == 8'b00010110;
  /* 6805.vhd:955:42  */
  assign n2056_o = n2053_o | n2055_o;
  /* 6805.vhd:955:50  */
  assign n2058_o = opcode == 8'b00011000;
  /* 6805.vhd:955:50  */
  assign n2059_o = n2056_o | n2058_o;
  /* 6805.vhd:955:58  */
  assign n2061_o = opcode == 8'b00011010;
  /* 6805.vhd:955:58  */
  assign n2062_o = n2059_o | n2061_o;
  /* 6805.vhd:955:66  */
  assign n2064_o = opcode == 8'b00011100;
  /* 6805.vhd:955:66  */
  assign n2065_o = n2062_o | n2064_o;
  /* 6805.vhd:955:74  */
  assign n2067_o = opcode == 8'b00011110;
  /* 6805.vhd:955:74  */
  assign n2068_o = n2065_o | n2067_o;
  /* 6805.vhd:955:82  */
  assign n2070_o = opcode == 8'b00010001;
  /* 6805.vhd:955:82  */
  assign n2071_o = n2068_o | n2070_o;
  /* 6805.vhd:956:26  */
  assign n2073_o = opcode == 8'b00010011;
  /* 6805.vhd:956:26  */
  assign n2074_o = n2071_o | n2073_o;
  /* 6805.vhd:956:34  */
  assign n2076_o = opcode == 8'b00010101;
  /* 6805.vhd:956:34  */
  assign n2077_o = n2074_o | n2076_o;
  /* 6805.vhd:956:42  */
  assign n2079_o = opcode == 8'b00010111;
  /* 6805.vhd:956:42  */
  assign n2080_o = n2077_o | n2079_o;
  /* 6805.vhd:956:50  */
  assign n2082_o = opcode == 8'b00011001;
  /* 6805.vhd:956:50  */
  assign n2083_o = n2080_o | n2082_o;
  /* 6805.vhd:956:58  */
  assign n2085_o = opcode == 8'b00011011;
  /* 6805.vhd:956:58  */
  assign n2086_o = n2083_o | n2085_o;
  /* 6805.vhd:956:66  */
  assign n2088_o = opcode == 8'b00011101;
  /* 6805.vhd:956:66  */
  assign n2089_o = n2086_o | n2088_o;
  /* 6805.vhd:956:74  */
  assign n2091_o = opcode == 8'b00011111;
  /* 6805.vhd:956:74  */
  assign n2092_o = n2089_o | n2091_o;
  /* 6805.vhd:978:28  */
  assign n2093_o = opcode[7:4];
  /* 6805.vhd:979:19  */
  assign n2095_o = n2093_o == 4'b1100;
  /* 6805.vhd:981:19  */
  assign n2097_o = n2093_o == 4'b1101;
  /* 6805.vhd:983:19  */
  assign n2099_o = n2093_o == 4'b1110;
  assign n2100_o = {n2099_o, n2097_o, n2095_o};
  /* 6805.vhd:978:17  */
  always @*
    case (n2100_o)
      3'b100: n2104_o = 3'b110;
      3'b010: n2104_o = 3'b100;
      3'b001: n2104_o = 3'b011;
      default: n2104_o = addrmux;
    endcase
  /* 6805.vhd:988:32  */
  assign n2106_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:965:15  */
  assign n2108_o = opcode == 8'b11000000;
  /* 6805.vhd:965:26  */
  assign n2110_o = opcode == 8'b11000001;
  /* 6805.vhd:965:26  */
  assign n2111_o = n2108_o | n2110_o;
  /* 6805.vhd:965:34  */
  assign n2113_o = opcode == 8'b11000010;
  /* 6805.vhd:965:34  */
  assign n2114_o = n2111_o | n2113_o;
  /* 6805.vhd:965:42  */
  assign n2116_o = opcode == 8'b11000011;
  /* 6805.vhd:965:42  */
  assign n2117_o = n2114_o | n2116_o;
  /* 6805.vhd:965:50  */
  assign n2119_o = opcode == 8'b11000100;
  /* 6805.vhd:965:50  */
  assign n2120_o = n2117_o | n2119_o;
  /* 6805.vhd:966:26  */
  assign n2122_o = opcode == 8'b11000101;
  /* 6805.vhd:966:26  */
  assign n2123_o = n2120_o | n2122_o;
  /* 6805.vhd:966:34  */
  assign n2125_o = opcode == 8'b11000110;
  /* 6805.vhd:966:34  */
  assign n2126_o = n2123_o | n2125_o;
  /* 6805.vhd:966:42  */
  assign n2128_o = opcode == 8'b11001000;
  /* 6805.vhd:966:42  */
  assign n2129_o = n2126_o | n2128_o;
  /* 6805.vhd:967:26  */
  assign n2131_o = opcode == 8'b11001001;
  /* 6805.vhd:967:26  */
  assign n2132_o = n2129_o | n2131_o;
  /* 6805.vhd:967:34  */
  assign n2134_o = opcode == 8'b11001010;
  /* 6805.vhd:967:34  */
  assign n2135_o = n2132_o | n2134_o;
  /* 6805.vhd:967:42  */
  assign n2137_o = opcode == 8'b11001011;
  /* 6805.vhd:967:42  */
  assign n2138_o = n2135_o | n2137_o;
  /* 6805.vhd:967:50  */
  assign n2140_o = opcode == 8'b11001110;
  /* 6805.vhd:967:50  */
  assign n2141_o = n2138_o | n2140_o;
  /* 6805.vhd:968:26  */
  assign n2143_o = opcode == 8'b11010000;
  /* 6805.vhd:968:26  */
  assign n2144_o = n2141_o | n2143_o;
  /* 6805.vhd:969:26  */
  assign n2146_o = opcode == 8'b11010001;
  /* 6805.vhd:969:26  */
  assign n2147_o = n2144_o | n2146_o;
  /* 6805.vhd:969:34  */
  assign n2149_o = opcode == 8'b11010010;
  /* 6805.vhd:969:34  */
  assign n2150_o = n2147_o | n2149_o;
  /* 6805.vhd:969:42  */
  assign n2152_o = opcode == 8'b11010011;
  /* 6805.vhd:969:42  */
  assign n2153_o = n2150_o | n2152_o;
  /* 6805.vhd:969:50  */
  assign n2155_o = opcode == 8'b11010100;
  /* 6805.vhd:969:50  */
  assign n2156_o = n2153_o | n2155_o;
  /* 6805.vhd:970:26  */
  assign n2158_o = opcode == 8'b11010101;
  /* 6805.vhd:970:26  */
  assign n2159_o = n2156_o | n2158_o;
  /* 6805.vhd:970:34  */
  assign n2161_o = opcode == 8'b11010110;
  /* 6805.vhd:970:34  */
  assign n2162_o = n2159_o | n2161_o;
  /* 6805.vhd:970:42  */
  assign n2164_o = opcode == 8'b11011000;
  /* 6805.vhd:970:42  */
  assign n2165_o = n2162_o | n2164_o;
  /* 6805.vhd:971:26  */
  assign n2167_o = opcode == 8'b11011001;
  /* 6805.vhd:971:26  */
  assign n2168_o = n2165_o | n2167_o;
  /* 6805.vhd:971:34  */
  assign n2170_o = opcode == 8'b11011010;
  /* 6805.vhd:971:34  */
  assign n2171_o = n2168_o | n2170_o;
  /* 6805.vhd:971:42  */
  assign n2173_o = opcode == 8'b11011011;
  /* 6805.vhd:971:42  */
  assign n2174_o = n2171_o | n2173_o;
  /* 6805.vhd:971:50  */
  assign n2176_o = opcode == 8'b11011110;
  /* 6805.vhd:971:50  */
  assign n2177_o = n2174_o | n2176_o;
  /* 6805.vhd:972:26  */
  assign n2179_o = opcode == 8'b11100000;
  /* 6805.vhd:972:26  */
  assign n2180_o = n2177_o | n2179_o;
  /* 6805.vhd:973:26  */
  assign n2182_o = opcode == 8'b11100001;
  /* 6805.vhd:973:26  */
  assign n2183_o = n2180_o | n2182_o;
  /* 6805.vhd:973:34  */
  assign n2185_o = opcode == 8'b11100010;
  /* 6805.vhd:973:34  */
  assign n2186_o = n2183_o | n2185_o;
  /* 6805.vhd:973:42  */
  assign n2188_o = opcode == 8'b11100011;
  /* 6805.vhd:973:42  */
  assign n2189_o = n2186_o | n2188_o;
  /* 6805.vhd:973:50  */
  assign n2191_o = opcode == 8'b11100100;
  /* 6805.vhd:973:50  */
  assign n2192_o = n2189_o | n2191_o;
  /* 6805.vhd:974:26  */
  assign n2194_o = opcode == 8'b11100101;
  /* 6805.vhd:974:26  */
  assign n2195_o = n2192_o | n2194_o;
  /* 6805.vhd:974:34  */
  assign n2197_o = opcode == 8'b11100110;
  /* 6805.vhd:974:34  */
  assign n2198_o = n2195_o | n2197_o;
  /* 6805.vhd:974:42  */
  assign n2200_o = opcode == 8'b11101000;
  /* 6805.vhd:974:42  */
  assign n2201_o = n2198_o | n2200_o;
  /* 6805.vhd:975:26  */
  assign n2203_o = opcode == 8'b11101001;
  /* 6805.vhd:975:26  */
  assign n2204_o = n2201_o | n2203_o;
  /* 6805.vhd:975:34  */
  assign n2206_o = opcode == 8'b11101010;
  /* 6805.vhd:975:34  */
  assign n2207_o = n2204_o | n2206_o;
  /* 6805.vhd:975:42  */
  assign n2209_o = opcode == 8'b11101011;
  /* 6805.vhd:975:42  */
  assign n2210_o = n2207_o | n2209_o;
  /* 6805.vhd:975:50  */
  assign n2212_o = opcode == 8'b11101110;
  /* 6805.vhd:975:50  */
  assign n2213_o = n2210_o | n2212_o;
  /* 6805.vhd:991:30  */
  assign n2214_o = temp[15:8];
  /* 6805.vhd:991:44  */
  assign n2215_o = {n2214_o, datain};
  /* 6805.vhd:990:15  */
  assign n2217_o = opcode == 8'b11001100;
  /* 6805.vhd:994:31  */
  assign n2218_o = temp[15:8];
  /* 6805.vhd:994:45  */
  assign n2219_o = {n2218_o, datain};
  /* 6805.vhd:994:64  */
  assign n2221_o = {8'b00000000, regx};
  /* 6805.vhd:994:55  */
  assign n2222_o = n2219_o + n2221_o;
  /* 6805.vhd:993:15  */
  assign n2224_o = opcode == 8'b11011100;
  /* 6805.vhd:997:33  */
  assign n2226_o = {8'b00000000, datain};
  /* 6805.vhd:997:52  */
  assign n2228_o = {8'b00000000, regx};
  /* 6805.vhd:997:43  */
  assign n2229_o = n2226_o + n2228_o;
  /* 6805.vhd:996:15  */
  assign n2231_o = opcode == 8'b11101100;
  /* 6805.vhd:1001:30  */
  assign n2232_o = rega[7];
  /* 6805.vhd:1002:25  */
  assign n2234_o = rega == 8'b00000000;
  /* 6805.vhd:1002:17  */
  assign n2237_o = n2234_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1010:32  */
  assign n2239_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:999:15  */
  assign n2241_o = opcode == 8'b11000111;
  /* 6805.vhd:1014:30  */
  assign n2242_o = rega[7];
  /* 6805.vhd:1015:25  */
  assign n2244_o = rega == 8'b00000000;
  /* 6805.vhd:1015:17  */
  assign n2247_o = n2244_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1023:32  */
  assign n2249_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1012:15  */
  assign n2251_o = opcode == 8'b11010111;
  /* 6805.vhd:1027:30  */
  assign n2252_o = rega[7];
  /* 6805.vhd:1028:25  */
  assign n2254_o = rega == 8'b00000000;
  /* 6805.vhd:1028:17  */
  assign n2257_o = n2254_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1036:32  */
  assign n2259_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1025:15  */
  assign n2261_o = opcode == 8'b11100111;
  /* 6805.vhd:1040:30  */
  assign n2262_o = regx[7];
  /* 6805.vhd:1041:25  */
  assign n2264_o = regx == 8'b00000000;
  /* 6805.vhd:1041:17  */
  assign n2267_o = n2264_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1049:32  */
  assign n2269_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1038:15  */
  assign n2271_o = opcode == 8'b11001111;
  /* 6805.vhd:1053:30  */
  assign n2272_o = regx[7];
  /* 6805.vhd:1054:25  */
  assign n2274_o = regx == 8'b00000000;
  /* 6805.vhd:1054:17  */
  assign n2277_o = n2274_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1062:32  */
  assign n2279_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1051:15  */
  assign n2281_o = opcode == 8'b11011111;
  /* 6805.vhd:1066:30  */
  assign n2282_o = regx[7];
  /* 6805.vhd:1067:25  */
  assign n2284_o = regx == 8'b00000000;
  /* 6805.vhd:1067:17  */
  assign n2287_o = n2284_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1075:32  */
  assign n2289_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1064:15  */
  assign n2291_o = opcode == 8'b11101111;
  /* 6805.vhd:1080:34  */
  assign n2293_o = 8'b00000000 - datain;
  /* 6805.vhd:1081:34  */
  assign n2295_o = 8'b00000000 - datain;
  /* 6805.vhd:1082:32  */
  assign n2296_o = n2295_o[7];
  /* 6805.vhd:1083:25  */
  assign n2298_o = n2295_o == 8'b00000000;
  /* 6805.vhd:1083:17  */
  assign n2301_o = n2298_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1083:17  */
  assign n2304_o = n2298_o ? 1'b0 : 1'b1;
  /* 6805.vhd:1077:15  */
  assign n2306_o = opcode == 8'b00110000;
  /* 6805.vhd:1077:26  */
  assign n2308_o = opcode == 8'b01100000;
  /* 6805.vhd:1077:26  */
  assign n2309_o = n2306_o | n2308_o;
  /* 6805.vhd:1077:34  */
  assign n2311_o = opcode == 8'b01110000;
  /* 6805.vhd:1077:34  */
  assign n2312_o = n2309_o | n2311_o;
  /* 6805.vhd:1094:35  */
  assign n2314_o = datain ^ 8'b11111111;
  /* 6805.vhd:1095:35  */
  assign n2316_o = datain ^ 8'b11111111;
  /* 6805.vhd:1097:32  */
  assign n2317_o = n2316_o[7];
  /* 6805.vhd:1098:25  */
  assign n2319_o = n2316_o == 8'b00000000;
  /* 6805.vhd:1098:17  */
  assign n2322_o = n2319_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1091:15  */
  assign n2324_o = opcode == 8'b00110011;
  /* 6805.vhd:1091:26  */
  assign n2326_o = opcode == 8'b01100011;
  /* 6805.vhd:1091:26  */
  assign n2327_o = n2324_o | n2326_o;
  /* 6805.vhd:1091:34  */
  assign n2329_o = opcode == 8'b01110011;
  /* 6805.vhd:1091:34  */
  assign n2330_o = n2327_o | n2329_o;
  /* 6805.vhd:1107:40  */
  assign n2331_o = datain[7:1];
  /* 6805.vhd:1107:32  */
  assign n2333_o = {1'b0, n2331_o};
  /* 6805.vhd:1108:40  */
  assign n2334_o = datain[7:1];
  /* 6805.vhd:1108:32  */
  assign n2336_o = {1'b0, n2334_o};
  /* 6805.vhd:1110:34  */
  assign n2337_o = datain[0];
  /* 6805.vhd:1111:25  */
  assign n2339_o = n2336_o == 8'b00000000;
  /* 6805.vhd:1111:17  */
  assign n2342_o = n2339_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1104:15  */
  assign n2344_o = opcode == 8'b00110100;
  /* 6805.vhd:1104:26  */
  assign n2346_o = opcode == 8'b01100100;
  /* 6805.vhd:1104:26  */
  assign n2347_o = n2344_o | n2346_o;
  /* 6805.vhd:1104:34  */
  assign n2349_o = opcode == 8'b01110100;
  /* 6805.vhd:1104:34  */
  assign n2350_o = n2347_o | n2349_o;
  /* 6805.vhd:1120:42  */
  assign n2351_o = datain[7:1];
  /* 6805.vhd:1120:34  */
  assign n2352_o = {flagc, n2351_o};
  /* 6805.vhd:1121:42  */
  assign n2353_o = datain[7:1];
  /* 6805.vhd:1121:34  */
  assign n2354_o = {flagc, n2353_o};
  /* 6805.vhd:1123:34  */
  assign n2355_o = datain[0];
  /* 6805.vhd:1124:25  */
  assign n2357_o = n2354_o == 8'b00000000;
  /* 6805.vhd:1124:17  */
  assign n2360_o = n2357_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1117:15  */
  assign n2362_o = opcode == 8'b00110110;
  /* 6805.vhd:1117:26  */
  assign n2364_o = opcode == 8'b01100110;
  /* 6805.vhd:1117:26  */
  assign n2365_o = n2362_o | n2364_o;
  /* 6805.vhd:1117:34  */
  assign n2367_o = opcode == 8'b01110110;
  /* 6805.vhd:1117:34  */
  assign n2368_o = n2365_o | n2367_o;
  /* 6805.vhd:1133:34  */
  assign n2369_o = datain[7];
  /* 6805.vhd:1133:46  */
  assign n2370_o = datain[7:1];
  /* 6805.vhd:1133:38  */
  assign n2371_o = {n2369_o, n2370_o};
  /* 6805.vhd:1134:34  */
  assign n2372_o = datain[7];
  /* 6805.vhd:1134:46  */
  assign n2373_o = datain[7:1];
  /* 6805.vhd:1134:38  */
  assign n2374_o = {n2372_o, n2373_o};
  /* 6805.vhd:1135:34  */
  assign n2375_o = datain[7];
  /* 6805.vhd:1136:34  */
  assign n2376_o = datain[0];
  /* 6805.vhd:1137:25  */
  assign n2378_o = n2374_o == 8'b00000000;
  /* 6805.vhd:1137:17  */
  assign n2381_o = n2378_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1130:15  */
  assign n2383_o = opcode == 8'b00110111;
  /* 6805.vhd:1130:26  */
  assign n2385_o = opcode == 8'b01100111;
  /* 6805.vhd:1130:26  */
  assign n2386_o = n2383_o | n2385_o;
  /* 6805.vhd:1130:34  */
  assign n2388_o = opcode == 8'b01110111;
  /* 6805.vhd:1130:34  */
  assign n2389_o = n2386_o | n2388_o;
  /* 6805.vhd:1146:34  */
  assign n2390_o = datain[6:0];
  /* 6805.vhd:1146:47  */
  assign n2392_o = {n2390_o, 1'b0};
  /* 6805.vhd:1147:34  */
  assign n2393_o = datain[6:0];
  /* 6805.vhd:1147:47  */
  assign n2395_o = {n2393_o, 1'b0};
  /* 6805.vhd:1148:34  */
  assign n2396_o = datain[6];
  /* 6805.vhd:1149:34  */
  assign n2397_o = datain[7];
  /* 6805.vhd:1150:25  */
  assign n2399_o = n2395_o == 8'b00000000;
  /* 6805.vhd:1150:17  */
  assign n2402_o = n2399_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1143:15  */
  assign n2404_o = opcode == 8'b00111000;
  /* 6805.vhd:1143:26  */
  assign n2406_o = opcode == 8'b01101000;
  /* 6805.vhd:1143:26  */
  assign n2407_o = n2404_o | n2406_o;
  /* 6805.vhd:1143:34  */
  assign n2409_o = opcode == 8'b01111000;
  /* 6805.vhd:1143:34  */
  assign n2410_o = n2407_o | n2409_o;
  /* 6805.vhd:1159:34  */
  assign n2411_o = datain[6:0];
  /* 6805.vhd:1159:47  */
  assign n2412_o = {n2411_o, flagc};
  /* 6805.vhd:1160:34  */
  assign n2413_o = datain[6:0];
  /* 6805.vhd:1160:47  */
  assign n2414_o = {n2413_o, flagc};
  /* 6805.vhd:1161:34  */
  assign n2415_o = datain[6];
  /* 6805.vhd:1162:34  */
  assign n2416_o = datain[7];
  /* 6805.vhd:1163:25  */
  assign n2418_o = n2414_o == 8'b00000000;
  /* 6805.vhd:1163:17  */
  assign n2421_o = n2418_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1156:15  */
  assign n2423_o = opcode == 8'b00111001;
  /* 6805.vhd:1156:26  */
  assign n2425_o = opcode == 8'b01101001;
  /* 6805.vhd:1156:26  */
  assign n2426_o = n2423_o | n2425_o;
  /* 6805.vhd:1156:34  */
  assign n2428_o = opcode == 8'b01111001;
  /* 6805.vhd:1156:34  */
  assign n2429_o = n2426_o | n2428_o;
  /* 6805.vhd:1172:35  */
  assign n2431_o = datain - 8'b00000001;
  /* 6805.vhd:1173:35  */
  assign n2433_o = datain - 8'b00000001;
  /* 6805.vhd:1174:32  */
  assign n2434_o = n2433_o[7];
  /* 6805.vhd:1175:25  */
  assign n2436_o = n2433_o == 8'b00000000;
  /* 6805.vhd:1175:17  */
  assign n2439_o = n2436_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1169:15  */
  assign n2441_o = opcode == 8'b00111010;
  /* 6805.vhd:1169:26  */
  assign n2443_o = opcode == 8'b01101010;
  /* 6805.vhd:1169:26  */
  assign n2444_o = n2441_o | n2443_o;
  /* 6805.vhd:1169:34  */
  assign n2446_o = opcode == 8'b01111010;
  /* 6805.vhd:1169:34  */
  assign n2447_o = n2444_o | n2446_o;
  /* 6805.vhd:1184:35  */
  assign n2449_o = datain + 8'b00000001;
  /* 6805.vhd:1185:35  */
  assign n2451_o = datain + 8'b00000001;
  /* 6805.vhd:1186:32  */
  assign n2452_o = n2451_o[7];
  /* 6805.vhd:1187:25  */
  assign n2454_o = n2451_o == 8'b00000000;
  /* 6805.vhd:1187:17  */
  assign n2457_o = n2454_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1181:15  */
  assign n2459_o = opcode == 8'b00111100;
  /* 6805.vhd:1181:26  */
  assign n2461_o = opcode == 8'b01101100;
  /* 6805.vhd:1181:26  */
  assign n2462_o = n2459_o | n2461_o;
  /* 6805.vhd:1181:34  */
  assign n2464_o = opcode == 8'b01111100;
  /* 6805.vhd:1181:34  */
  assign n2465_o = n2462_o | n2464_o;
  /* 6805.vhd:1194:34  */
  assign n2466_o = datain[7];
  /* 6805.vhd:1195:27  */
  assign n2468_o = datain == 8'b00000000;
  /* 6805.vhd:1195:17  */
  assign n2471_o = n2468_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1193:15  */
  assign n2473_o = opcode == 8'b00111101;
  /* 6805.vhd:1193:26  */
  assign n2475_o = opcode == 8'b01101101;
  /* 6805.vhd:1193:26  */
  assign n2476_o = n2473_o | n2475_o;
  /* 6805.vhd:1193:34  */
  assign n2478_o = opcode == 8'b01111101;
  /* 6805.vhd:1193:34  */
  assign n2479_o = n2476_o | n2478_o;
  /* 6805.vhd:1202:15  */
  assign n2481_o = opcode == 8'b00111111;
  /* 6805.vhd:1202:26  */
  assign n2483_o = opcode == 8'b01101111;
  /* 6805.vhd:1202:26  */
  assign n2484_o = n2481_o | n2483_o;
  /* 6805.vhd:1208:32  */
  assign n2486_o = regsp + 16'b0000000000000001;
  /* 6805.vhd:1206:15  */
  assign n2488_o = opcode == 8'b10000000;
  /* 6805.vhd:1206:26  */
  assign n2490_o = opcode == 8'b10000010;
  /* 6805.vhd:1206:26  */
  assign n2491_o = n2488_o | n2490_o;
  /* 6805.vhd:1210:15  */
  assign n2493_o = opcode == 8'b10000001;
  /* 6805.vhd:1215:32  */
  assign n2495_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1214:15  */
  assign n2497_o = opcode == 8'b10000011;
  /* 6805.vhd:1219:32  */
  assign n2499_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1218:15  */
  assign n2501_o = opcode == 8'b10101101;
  /* 6805.vhd:1218:26  */
  assign n2503_o = opcode == 8'b10111101;
  /* 6805.vhd:1218:26  */
  assign n2504_o = n2501_o | n2503_o;
  /* 6805.vhd:1218:34  */
  assign n2506_o = opcode == 8'b11101101;
  /* 6805.vhd:1218:34  */
  assign n2507_o = n2504_o | n2506_o;
  /* 6805.vhd:1223:32  */
  assign n2509_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1222:15  */
  assign n2511_o = opcode == 8'b11111101;
  /* 6805.vhd:1229:34  */
  assign n2513_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1226:15  */
  assign n2515_o = opcode == 8'b11001101;
  /* 6805.vhd:1226:26  */
  assign n2517_o = opcode == 8'b11011101;
  /* 6805.vhd:1226:26  */
  assign n2518_o = n2515_o | n2517_o;
  assign n2519_o = {n2518_o, n2511_o, n2507_o, n2497_o, n2493_o, n2491_o, n2484_o, n2479_o, n2465_o, n2447_o, n2429_o, n2410_o, n2389_o, n2368_o, n2350_o, n2330_o, n2312_o, n2291_o, n2281_o, n2271_o, n2261_o, n2251_o, n2241_o, n2231_o, n2224_o, n2217_o, n2213_o, n2092_o, n2028_o};
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2538_o = 1'b0;
      29'b01000000000000000000000000000: n2538_o = n3854_q;
      29'b00100000000000000000000000000: n2538_o = n3854_q;
      29'b00010000000000000000000000000: n2538_o = n3854_q;
      29'b00001000000000000000000000000: n2538_o = n3854_q;
      29'b00000100000000000000000000000: n2538_o = n3854_q;
      29'b00000010000000000000000000000: n2538_o = 1'b1;
      29'b00000001000000000000000000000: n2538_o = n3854_q;
      29'b00000000100000000000000000000: n2538_o = 1'b0;
      29'b00000000010000000000000000000: n2538_o = 1'b0;
      29'b00000000001000000000000000000: n2538_o = 1'b0;
      29'b00000000000100000000000000000: n2538_o = 1'b0;
      29'b00000000000010000000000000000: n2538_o = 1'b0;
      29'b00000000000001000000000000000: n2538_o = 1'b0;
      29'b00000000000000100000000000000: n2538_o = 1'b0;
      29'b00000000000000010000000000000: n2538_o = 1'b0;
      29'b00000000000000001000000000000: n2538_o = 1'b0;
      29'b00000000000000000100000000000: n2538_o = 1'b0;
      29'b00000000000000000010000000000: n2538_o = 1'b0;
      29'b00000000000000000001000000000: n2538_o = 1'b0;
      29'b00000000000000000000100000000: n2538_o = 1'b0;
      29'b00000000000000000000010000000: n2538_o = 1'b0;
      29'b00000000000000000000001000000: n2538_o = 1'b0;
      29'b00000000000000000000000100000: n2538_o = n3854_q;
      29'b00000000000000000000000010000: n2538_o = n3854_q;
      29'b00000000000000000000000001000: n2538_o = n3854_q;
      29'b00000000000000000000000000100: n2538_o = n3854_q;
      29'b00000000000000000000000000010: n2538_o = 1'b0;
      29'b00000000000000000000000000001: n2538_o = n3854_q;
      default: n2538_o = n3854_q;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2539_o = rega;
      29'b01000000000000000000000000000: n2539_o = rega;
      29'b00100000000000000000000000000: n2539_o = rega;
      29'b00010000000000000000000000000: n2539_o = rega;
      29'b00001000000000000000000000000: n2539_o = rega;
      29'b00000100000000000000000000000: n2539_o = datain;
      29'b00000010000000000000000000000: n2539_o = rega;
      29'b00000001000000000000000000000: n2539_o = rega;
      29'b00000000100000000000000000000: n2539_o = rega;
      29'b00000000010000000000000000000: n2539_o = rega;
      29'b00000000001000000000000000000: n2539_o = rega;
      29'b00000000000100000000000000000: n2539_o = rega;
      29'b00000000000010000000000000000: n2539_o = rega;
      29'b00000000000001000000000000000: n2539_o = rega;
      29'b00000000000000100000000000000: n2539_o = rega;
      29'b00000000000000010000000000000: n2539_o = rega;
      29'b00000000000000001000000000000: n2539_o = rega;
      29'b00000000000000000100000000000: n2539_o = rega;
      29'b00000000000000000010000000000: n2539_o = rega;
      29'b00000000000000000001000000000: n2539_o = rega;
      29'b00000000000000000000100000000: n2539_o = rega;
      29'b00000000000000000000010000000: n2539_o = rega;
      29'b00000000000000000000001000000: n2539_o = rega;
      29'b00000000000000000000000100000: n2539_o = rega;
      29'b00000000000000000000000010000: n2539_o = rega;
      29'b00000000000000000000000001000: n2539_o = rega;
      29'b00000000000000000000000000100: n2539_o = rega;
      29'b00000000000000000000000000010: n2539_o = rega;
      29'b00000000000000000000000000001: n2539_o = rega;
      default: n2539_o = rega;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2540_o = regsp;
      29'b01000000000000000000000000000: n2540_o = n2509_o;
      29'b00100000000000000000000000000: n2540_o = n2499_o;
      29'b00010000000000000000000000000: n2540_o = n2495_o;
      29'b00001000000000000000000000000: n2540_o = regsp;
      29'b00000100000000000000000000000: n2540_o = n2486_o;
      29'b00000010000000000000000000000: n2540_o = regsp;
      29'b00000001000000000000000000000: n2540_o = regsp;
      29'b00000000100000000000000000000: n2540_o = regsp;
      29'b00000000010000000000000000000: n2540_o = regsp;
      29'b00000000001000000000000000000: n2540_o = regsp;
      29'b00000000000100000000000000000: n2540_o = regsp;
      29'b00000000000010000000000000000: n2540_o = regsp;
      29'b00000000000001000000000000000: n2540_o = regsp;
      29'b00000000000000100000000000000: n2540_o = regsp;
      29'b00000000000000010000000000000: n2540_o = regsp;
      29'b00000000000000001000000000000: n2540_o = regsp;
      29'b00000000000000000100000000000: n2540_o = regsp;
      29'b00000000000000000010000000000: n2540_o = regsp;
      29'b00000000000000000001000000000: n2540_o = regsp;
      29'b00000000000000000000100000000: n2540_o = regsp;
      29'b00000000000000000000010000000: n2540_o = regsp;
      29'b00000000000000000000001000000: n2540_o = regsp;
      29'b00000000000000000000000100000: n2540_o = regsp;
      29'b00000000000000000000000010000: n2540_o = regsp;
      29'b00000000000000000000000001000: n2540_o = regsp;
      29'b00000000000000000000000000100: n2540_o = regsp;
      29'b00000000000000000000000000010: n2540_o = regsp;
      29'b00000000000000000000000000001: n2540_o = regsp;
      default: n2540_o = regsp;
    endcase
  assign n2541_o = n2106_o[7:0];
  assign n2542_o = n2215_o[7:0];
  assign n2543_o = n2222_o[7:0];
  assign n2544_o = n2229_o[7:0];
  assign n2545_o = n2239_o[7:0];
  assign n2546_o = n2249_o[7:0];
  assign n2547_o = n2259_o[7:0];
  assign n2548_o = n2269_o[7:0];
  assign n2549_o = n2279_o[7:0];
  assign n2550_o = n2289_o[7:0];
  assign n2551_o = n2513_o[7:0];
  assign n2552_o = regpc[7:0];
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2553_o = n2551_o;
      29'b01000000000000000000000000000: n2553_o = n2552_o;
      29'b00100000000000000000000000000: n2553_o = n2552_o;
      29'b00010000000000000000000000000: n2553_o = n2552_o;
      29'b00001000000000000000000000000: n2553_o = datain;
      29'b00000100000000000000000000000: n2553_o = n2552_o;
      29'b00000010000000000000000000000: n2553_o = n2552_o;
      29'b00000001000000000000000000000: n2553_o = n2552_o;
      29'b00000000100000000000000000000: n2553_o = n2552_o;
      29'b00000000010000000000000000000: n2553_o = n2552_o;
      29'b00000000001000000000000000000: n2553_o = n2552_o;
      29'b00000000000100000000000000000: n2553_o = n2552_o;
      29'b00000000000010000000000000000: n2553_o = n2552_o;
      29'b00000000000001000000000000000: n2553_o = n2552_o;
      29'b00000000000000100000000000000: n2553_o = n2552_o;
      29'b00000000000000010000000000000: n2553_o = n2552_o;
      29'b00000000000000001000000000000: n2553_o = n2552_o;
      29'b00000000000000000100000000000: n2553_o = n2550_o;
      29'b00000000000000000010000000000: n2553_o = n2549_o;
      29'b00000000000000000001000000000: n2553_o = n2548_o;
      29'b00000000000000000000100000000: n2553_o = n2547_o;
      29'b00000000000000000000010000000: n2553_o = n2546_o;
      29'b00000000000000000000001000000: n2553_o = n2545_o;
      29'b00000000000000000000000100000: n2553_o = n2544_o;
      29'b00000000000000000000000010000: n2553_o = n2543_o;
      29'b00000000000000000000000001000: n2553_o = n2542_o;
      29'b00000000000000000000000000100: n2553_o = n2541_o;
      29'b00000000000000000000000000010: n2553_o = n2552_o;
      29'b00000000000000000000000000001: n2553_o = n2552_o;
      default: n2553_o = n2552_o;
    endcase
  assign n2554_o = n2106_o[15:8];
  assign n2555_o = n2215_o[15:8];
  assign n2556_o = n2222_o[15:8];
  assign n2557_o = n2229_o[15:8];
  assign n2558_o = n2239_o[15:8];
  assign n2559_o = n2249_o[15:8];
  assign n2560_o = n2259_o[15:8];
  assign n2561_o = n2269_o[15:8];
  assign n2562_o = n2279_o[15:8];
  assign n2563_o = n2289_o[15:8];
  assign n2564_o = n2513_o[15:8];
  assign n2565_o = regpc[15:8];
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2566_o = n2564_o;
      29'b01000000000000000000000000000: n2566_o = n2565_o;
      29'b00100000000000000000000000000: n2566_o = n2565_o;
      29'b00010000000000000000000000000: n2566_o = n2565_o;
      29'b00001000000000000000000000000: n2566_o = n2565_o;
      29'b00000100000000000000000000000: n2566_o = n2565_o;
      29'b00000010000000000000000000000: n2566_o = n2565_o;
      29'b00000001000000000000000000000: n2566_o = n2565_o;
      29'b00000000100000000000000000000: n2566_o = n2565_o;
      29'b00000000010000000000000000000: n2566_o = n2565_o;
      29'b00000000001000000000000000000: n2566_o = n2565_o;
      29'b00000000000100000000000000000: n2566_o = n2565_o;
      29'b00000000000010000000000000000: n2566_o = n2565_o;
      29'b00000000000001000000000000000: n2566_o = n2565_o;
      29'b00000000000000100000000000000: n2566_o = n2565_o;
      29'b00000000000000010000000000000: n2566_o = n2565_o;
      29'b00000000000000001000000000000: n2566_o = n2565_o;
      29'b00000000000000000100000000000: n2566_o = n2563_o;
      29'b00000000000000000010000000000: n2566_o = n2562_o;
      29'b00000000000000000001000000000: n2566_o = n2561_o;
      29'b00000000000000000000100000000: n2566_o = n2560_o;
      29'b00000000000000000000010000000: n2566_o = n2559_o;
      29'b00000000000000000000001000000: n2566_o = n2558_o;
      29'b00000000000000000000000100000: n2566_o = n2557_o;
      29'b00000000000000000000000010000: n2566_o = n2556_o;
      29'b00000000000000000000000001000: n2566_o = n2555_o;
      29'b00000000000000000000000000100: n2566_o = n2554_o;
      29'b00000000000000000000000000010: n2566_o = n2565_o;
      29'b00000000000000000000000000001: n2566_o = n2565_o;
      default: n2566_o = n2565_o;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2568_o = flagn;
      29'b01000000000000000000000000000: n2568_o = flagn;
      29'b00100000000000000000000000000: n2568_o = flagn;
      29'b00010000000000000000000000000: n2568_o = flagn;
      29'b00001000000000000000000000000: n2568_o = flagn;
      29'b00000100000000000000000000000: n2568_o = flagn;
      29'b00000010000000000000000000000: n2568_o = flagn;
      29'b00000001000000000000000000000: n2568_o = n2466_o;
      29'b00000000100000000000000000000: n2568_o = n2452_o;
      29'b00000000010000000000000000000: n2568_o = n2434_o;
      29'b00000000001000000000000000000: n2568_o = n2415_o;
      29'b00000000000100000000000000000: n2568_o = n2396_o;
      29'b00000000000010000000000000000: n2568_o = n2375_o;
      29'b00000000000001000000000000000: n2568_o = flagc;
      29'b00000000000000100000000000000: n2568_o = 1'b0;
      29'b00000000000000010000000000000: n2568_o = n2317_o;
      29'b00000000000000001000000000000: n2568_o = n2296_o;
      29'b00000000000000000100000000000: n2568_o = n2282_o;
      29'b00000000000000000010000000000: n2568_o = n2272_o;
      29'b00000000000000000001000000000: n2568_o = n2262_o;
      29'b00000000000000000000100000000: n2568_o = n2252_o;
      29'b00000000000000000000010000000: n2568_o = n2242_o;
      29'b00000000000000000000001000000: n2568_o = n2232_o;
      29'b00000000000000000000000100000: n2568_o = flagn;
      29'b00000000000000000000000010000: n2568_o = flagn;
      29'b00000000000000000000000001000: n2568_o = flagn;
      29'b00000000000000000000000000100: n2568_o = flagn;
      29'b00000000000000000000000000010: n2568_o = flagn;
      29'b00000000000000000000000000001: n2568_o = flagn;
      default: n2568_o = flagn;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2569_o = flagz;
      29'b01000000000000000000000000000: n2569_o = flagz;
      29'b00100000000000000000000000000: n2569_o = flagz;
      29'b00010000000000000000000000000: n2569_o = flagz;
      29'b00001000000000000000000000000: n2569_o = flagz;
      29'b00000100000000000000000000000: n2569_o = flagz;
      29'b00000010000000000000000000000: n2569_o = flagz;
      29'b00000001000000000000000000000: n2569_o = n2471_o;
      29'b00000000100000000000000000000: n2569_o = n2457_o;
      29'b00000000010000000000000000000: n2569_o = n2439_o;
      29'b00000000001000000000000000000: n2569_o = n2421_o;
      29'b00000000000100000000000000000: n2569_o = n2402_o;
      29'b00000000000010000000000000000: n2569_o = n2381_o;
      29'b00000000000001000000000000000: n2569_o = n2360_o;
      29'b00000000000000100000000000000: n2569_o = n2342_o;
      29'b00000000000000010000000000000: n2569_o = n2322_o;
      29'b00000000000000001000000000000: n2569_o = n2301_o;
      29'b00000000000000000100000000000: n2569_o = n2287_o;
      29'b00000000000000000010000000000: n2569_o = n2277_o;
      29'b00000000000000000001000000000: n2569_o = n2267_o;
      29'b00000000000000000000100000000: n2569_o = n2257_o;
      29'b00000000000000000000010000000: n2569_o = n2247_o;
      29'b00000000000000000000001000000: n2569_o = n2237_o;
      29'b00000000000000000000000100000: n2569_o = flagz;
      29'b00000000000000000000000010000: n2569_o = flagz;
      29'b00000000000000000000000001000: n2569_o = flagz;
      29'b00000000000000000000000000100: n2569_o = flagz;
      29'b00000000000000000000000000010: n2569_o = flagz;
      29'b00000000000000000000000000001: n2569_o = flagz;
      default: n2569_o = flagz;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2571_o = flagc;
      29'b01000000000000000000000000000: n2571_o = flagc;
      29'b00100000000000000000000000000: n2571_o = flagc;
      29'b00010000000000000000000000000: n2571_o = flagc;
      29'b00001000000000000000000000000: n2571_o = flagc;
      29'b00000100000000000000000000000: n2571_o = flagc;
      29'b00000010000000000000000000000: n2571_o = flagc;
      29'b00000001000000000000000000000: n2571_o = flagc;
      29'b00000000100000000000000000000: n2571_o = flagc;
      29'b00000000010000000000000000000: n2571_o = flagc;
      29'b00000000001000000000000000000: n2571_o = n2416_o;
      29'b00000000000100000000000000000: n2571_o = n2397_o;
      29'b00000000000010000000000000000: n2571_o = n2376_o;
      29'b00000000000001000000000000000: n2571_o = n2355_o;
      29'b00000000000000100000000000000: n2571_o = n2337_o;
      29'b00000000000000010000000000000: n2571_o = 1'b1;
      29'b00000000000000001000000000000: n2571_o = n2304_o;
      29'b00000000000000000100000000000: n2571_o = flagc;
      29'b00000000000000000010000000000: n2571_o = flagc;
      29'b00000000000000000001000000000: n2571_o = flagc;
      29'b00000000000000000000100000000: n2571_o = flagc;
      29'b00000000000000000000010000000: n2571_o = flagc;
      29'b00000000000000000000001000000: n2571_o = flagc;
      29'b00000000000000000000000100000: n2571_o = flagc;
      29'b00000000000000000000000010000: n2571_o = flagc;
      29'b00000000000000000000000001000: n2571_o = flagc;
      29'b00000000000000000000000000100: n2571_o = flagc;
      29'b00000000000000000000000000010: n2571_o = flagc;
      29'b00000000000000000000000000001: n2571_o = n1981_o;
      default: n2571_o = flagc;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2572_o = help;
      29'b01000000000000000000000000000: n2572_o = help;
      29'b00100000000000000000000000000: n2572_o = help;
      29'b00010000000000000000000000000: n2572_o = help;
      29'b00001000000000000000000000000: n2572_o = help;
      29'b00000100000000000000000000000: n2572_o = help;
      29'b00000010000000000000000000000: n2572_o = help;
      29'b00000001000000000000000000000: n2572_o = help;
      29'b00000000100000000000000000000: n2572_o = n2449_o;
      29'b00000000010000000000000000000: n2572_o = n2431_o;
      29'b00000000001000000000000000000: n2572_o = n2412_o;
      29'b00000000000100000000000000000: n2572_o = n2392_o;
      29'b00000000000010000000000000000: n2572_o = n2371_o;
      29'b00000000000001000000000000000: n2572_o = n2352_o;
      29'b00000000000000100000000000000: n2572_o = n2333_o;
      29'b00000000000000010000000000000: n2572_o = n2314_o;
      29'b00000000000000001000000000000: n2572_o = n2293_o;
      29'b00000000000000000100000000000: n2572_o = help;
      29'b00000000000000000010000000000: n2572_o = help;
      29'b00000000000000000001000000000: n2572_o = help;
      29'b00000000000000000000100000000: n2572_o = help;
      29'b00000000000000000000010000000: n2572_o = help;
      29'b00000000000000000000001000000: n2572_o = help;
      29'b00000000000000000000000100000: n2572_o = help;
      29'b00000000000000000000000010000: n2572_o = help;
      29'b00000000000000000000000001000: n2572_o = help;
      29'b00000000000000000000000000100: n2572_o = help;
      29'b00000000000000000000000000010: n2572_o = n2045_o;
      29'b00000000000000000000000000001: n2572_o = help;
      default: n2572_o = help;
    endcase
  assign n2573_o = temp[7:0];
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2574_o = datain;
      29'b01000000000000000000000000000: n2574_o = n2573_o;
      29'b00100000000000000000000000000: n2574_o = n2573_o;
      29'b00010000000000000000000000000: n2574_o = n2573_o;
      29'b00001000000000000000000000000: n2574_o = n2573_o;
      29'b00000100000000000000000000000: n2574_o = n2573_o;
      29'b00000010000000000000000000000: n2574_o = n2573_o;
      29'b00000001000000000000000000000: n2574_o = n2573_o;
      29'b00000000100000000000000000000: n2574_o = n2573_o;
      29'b00000000010000000000000000000: n2574_o = n2573_o;
      29'b00000000001000000000000000000: n2574_o = n2573_o;
      29'b00000000000100000000000000000: n2574_o = n2573_o;
      29'b00000000000010000000000000000: n2574_o = n2573_o;
      29'b00000000000001000000000000000: n2574_o = n2573_o;
      29'b00000000000000100000000000000: n2574_o = n2573_o;
      29'b00000000000000010000000000000: n2574_o = n2573_o;
      29'b00000000000000001000000000000: n2574_o = n2573_o;
      29'b00000000000000000100000000000: n2574_o = datain;
      29'b00000000000000000010000000000: n2574_o = datain;
      29'b00000000000000000001000000000: n2574_o = datain;
      29'b00000000000000000000100000000: n2574_o = datain;
      29'b00000000000000000000010000000: n2574_o = datain;
      29'b00000000000000000000001000000: n2574_o = datain;
      29'b00000000000000000000000100000: n2574_o = n2573_o;
      29'b00000000000000000000000010000: n2574_o = n2573_o;
      29'b00000000000000000000000001000: n2574_o = n2573_o;
      29'b00000000000000000000000000100: n2574_o = datain;
      29'b00000000000000000000000000010: n2574_o = n2573_o;
      29'b00000000000000000000000000001: n2574_o = n2573_o;
      default: n2574_o = n2573_o;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2605_o = 4'b0101;
      29'b01000000000000000000000000000: n2605_o = 4'b0101;
      29'b00100000000000000000000000000: n2605_o = 4'b0101;
      29'b00010000000000000000000000000: n2605_o = 4'b0101;
      29'b00001000000000000000000000000: n2605_o = 4'b0010;
      29'b00000100000000000000000000000: n2605_o = 4'b0101;
      29'b00000010000000000000000000000: n2605_o = 4'b0010;
      29'b00000001000000000000000000000: n2605_o = 4'b0010;
      29'b00000000100000000000000000000: n2605_o = 4'b0101;
      29'b00000000010000000000000000000: n2605_o = 4'b0101;
      29'b00000000001000000000000000000: n2605_o = 4'b0101;
      29'b00000000000100000000000000000: n2605_o = 4'b0101;
      29'b00000000000010000000000000000: n2605_o = 4'b0101;
      29'b00000000000001000000000000000: n2605_o = 4'b0101;
      29'b00000000000000100000000000000: n2605_o = 4'b0101;
      29'b00000000000000010000000000000: n2605_o = 4'b0101;
      29'b00000000000000001000000000000: n2605_o = 4'b0101;
      29'b00000000000000000100000000000: n2605_o = 4'b0101;
      29'b00000000000000000010000000000: n2605_o = 4'b0101;
      29'b00000000000000000001000000000: n2605_o = 4'b0101;
      29'b00000000000000000000100000000: n2605_o = 4'b0101;
      29'b00000000000000000000010000000: n2605_o = 4'b0101;
      29'b00000000000000000000001000000: n2605_o = 4'b0101;
      29'b00000000000000000000000100000: n2605_o = 4'b0010;
      29'b00000000000000000000000010000: n2605_o = 4'b0010;
      29'b00000000000000000000000001000: n2605_o = 4'b0010;
      29'b00000000000000000000000000100: n2605_o = 4'b0101;
      29'b00000000000000000000000000010: n2605_o = 4'b0101;
      29'b00000000000000000000000000001: n2605_o = 4'b0101;
      default: n2605_o = 4'b0000;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2617_o = 3'b001;
      29'b01000000000000000000000000000: n2617_o = addrmux;
      29'b00100000000000000000000000000: n2617_o = addrmux;
      29'b00010000000000000000000000000: n2617_o = addrmux;
      29'b00001000000000000000000000000: n2617_o = 3'b000;
      29'b00000100000000000000000000000: n2617_o = addrmux;
      29'b00000010000000000000000000000: n2617_o = 3'b000;
      29'b00000001000000000000000000000: n2617_o = 3'b000;
      29'b00000000100000000000000000000: n2617_o = addrmux;
      29'b00000000010000000000000000000: n2617_o = addrmux;
      29'b00000000001000000000000000000: n2617_o = addrmux;
      29'b00000000000100000000000000000: n2617_o = addrmux;
      29'b00000000000010000000000000000: n2617_o = addrmux;
      29'b00000000000001000000000000000: n2617_o = addrmux;
      29'b00000000000000100000000000000: n2617_o = addrmux;
      29'b00000000000000010000000000000: n2617_o = addrmux;
      29'b00000000000000001000000000000: n2617_o = addrmux;
      29'b00000000000000000100000000000: n2617_o = 3'b110;
      29'b00000000000000000010000000000: n2617_o = 3'b100;
      29'b00000000000000000001000000000: n2617_o = 3'b011;
      29'b00000000000000000000100000000: n2617_o = 3'b110;
      29'b00000000000000000000010000000: n2617_o = 3'b100;
      29'b00000000000000000000001000000: n2617_o = 3'b011;
      29'b00000000000000000000000100000: n2617_o = addrmux;
      29'b00000000000000000000000010000: n2617_o = addrmux;
      29'b00000000000000000000000001000: n2617_o = addrmux;
      29'b00000000000000000000000000100: n2617_o = n2104_o;
      29'b00000000000000000000000000010: n2617_o = addrmux;
      29'b00000000000000000000000000001: n2617_o = 3'b000;
      default: n2617_o = addrmux;
    endcase
  /* 6805.vhd:945:13  */
  always @*
    case (n2519_o)
      29'b10000000000000000000000000000: n2638_o = 4'b0101;
      29'b01000000000000000000000000000: n2638_o = 4'b1000;
      29'b00100000000000000000000000000: n2638_o = 4'b0110;
      29'b00010000000000000000000000000: n2638_o = 4'b0110;
      29'b00001000000000000000000000000: n2638_o = datamux;
      29'b00000100000000000000000000000: n2638_o = datamux;
      29'b00000010000000000000000000000: n2638_o = datamux;
      29'b00000001000000000000000000000: n2638_o = datamux;
      29'b00000000100000000000000000000: n2638_o = 4'b1001;
      29'b00000000010000000000000000000: n2638_o = 4'b1001;
      29'b00000000001000000000000000000: n2638_o = 4'b1001;
      29'b00000000000100000000000000000: n2638_o = 4'b1001;
      29'b00000000000010000000000000000: n2638_o = 4'b1001;
      29'b00000000000001000000000000000: n2638_o = 4'b1001;
      29'b00000000000000100000000000000: n2638_o = 4'b1001;
      29'b00000000000000010000000000000: n2638_o = 4'b1001;
      29'b00000000000000001000000000000: n2638_o = 4'b1001;
      29'b00000000000000000100000000000: n2638_o = 4'b0010;
      29'b00000000000000000010000000000: n2638_o = 4'b0010;
      29'b00000000000000000001000000000: n2638_o = 4'b0010;
      29'b00000000000000000000100000000: n2638_o = 4'b0000;
      29'b00000000000000000000010000000: n2638_o = 4'b0000;
      29'b00000000000000000000001000000: n2638_o = 4'b0000;
      29'b00000000000000000000000100000: n2638_o = datamux;
      29'b00000000000000000000000010000: n2638_o = datamux;
      29'b00000000000000000000000001000: n2638_o = datamux;
      29'b00000000000000000000000000100: n2638_o = datamux;
      29'b00000000000000000000000000010: n2638_o = 4'b1001;
      29'b00000000000000000000000000001: n2638_o = datamux;
      default: n2638_o = datamux;
    endcase
  /* 6805.vhd:944:11  */
  assign n2641_o = mainfsm == 4'b0100;
  /* 6805.vhd:1242:27  */
  assign n2642_o = opcode[0];
  /* 6805.vhd:1242:31  */
  assign n2643_o = n2642_o ^ flagc;
  /* 6805.vhd:1243:28  */
  assign n2644_o = datain[7];
  /* 6805.vhd:1243:32  */
  assign n2645_o = ~n2644_o;
  /* 6805.vhd:1244:45  */
  assign n2647_o = {8'b00000000, datain};
  /* 6805.vhd:1244:36  */
  assign n2648_o = regpc + n2647_o;
  /* 6805.vhd:1244:55  */
  assign n2650_o = n2648_o + 16'b0000000000000001;
  /* 6805.vhd:1246:45  */
  assign n2652_o = {8'b11111111, datain};
  /* 6805.vhd:1246:36  */
  assign n2653_o = regpc + n2652_o;
  /* 6805.vhd:1246:55  */
  assign n2655_o = n2653_o + 16'b0000000000000001;
  /* 6805.vhd:1243:19  */
  assign n2656_o = n2645_o ? n2650_o : n2655_o;
  /* 6805.vhd:1249:34  */
  assign n2658_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1242:17  */
  assign n2659_o = n2643_o ? n2656_o : n2658_o;
  /* 6805.vhd:1240:15  */
  assign n2661_o = opcode == 8'b00000000;
  /* 6805.vhd:1240:26  */
  assign n2663_o = opcode == 8'b00000010;
  /* 6805.vhd:1240:26  */
  assign n2664_o = n2661_o | n2663_o;
  /* 6805.vhd:1240:34  */
  assign n2666_o = opcode == 8'b00000100;
  /* 6805.vhd:1240:34  */
  assign n2667_o = n2664_o | n2666_o;
  /* 6805.vhd:1240:42  */
  assign n2669_o = opcode == 8'b00000110;
  /* 6805.vhd:1240:42  */
  assign n2670_o = n2667_o | n2669_o;
  /* 6805.vhd:1240:50  */
  assign n2672_o = opcode == 8'b00001000;
  /* 6805.vhd:1240:50  */
  assign n2673_o = n2670_o | n2672_o;
  /* 6805.vhd:1240:58  */
  assign n2675_o = opcode == 8'b00001010;
  /* 6805.vhd:1240:58  */
  assign n2676_o = n2673_o | n2675_o;
  /* 6805.vhd:1240:66  */
  assign n2678_o = opcode == 8'b00001100;
  /* 6805.vhd:1240:66  */
  assign n2679_o = n2676_o | n2678_o;
  /* 6805.vhd:1240:74  */
  assign n2681_o = opcode == 8'b00001110;
  /* 6805.vhd:1240:74  */
  assign n2682_o = n2679_o | n2681_o;
  /* 6805.vhd:1240:82  */
  assign n2684_o = opcode == 8'b00000001;
  /* 6805.vhd:1240:82  */
  assign n2685_o = n2682_o | n2684_o;
  /* 6805.vhd:1241:26  */
  assign n2687_o = opcode == 8'b00000011;
  /* 6805.vhd:1241:26  */
  assign n2688_o = n2685_o | n2687_o;
  /* 6805.vhd:1241:34  */
  assign n2690_o = opcode == 8'b00000101;
  /* 6805.vhd:1241:34  */
  assign n2691_o = n2688_o | n2690_o;
  /* 6805.vhd:1241:42  */
  assign n2693_o = opcode == 8'b00000111;
  /* 6805.vhd:1241:42  */
  assign n2694_o = n2691_o | n2693_o;
  /* 6805.vhd:1241:50  */
  assign n2696_o = opcode == 8'b00001001;
  /* 6805.vhd:1241:50  */
  assign n2697_o = n2694_o | n2696_o;
  /* 6805.vhd:1241:58  */
  assign n2699_o = opcode == 8'b00001011;
  /* 6805.vhd:1241:58  */
  assign n2700_o = n2697_o | n2699_o;
  /* 6805.vhd:1241:66  */
  assign n2702_o = opcode == 8'b00001101;
  /* 6805.vhd:1241:66  */
  assign n2703_o = n2700_o | n2702_o;
  /* 6805.vhd:1241:74  */
  assign n2705_o = opcode == 8'b00001111;
  /* 6805.vhd:1241:74  */
  assign n2706_o = n2703_o | n2705_o;
  /* 6805.vhd:1253:15  */
  assign n2708_o = opcode == 8'b00010000;
  /* 6805.vhd:1253:26  */
  assign n2710_o = opcode == 8'b00010010;
  /* 6805.vhd:1253:26  */
  assign n2711_o = n2708_o | n2710_o;
  /* 6805.vhd:1253:34  */
  assign n2713_o = opcode == 8'b00010100;
  /* 6805.vhd:1253:34  */
  assign n2714_o = n2711_o | n2713_o;
  /* 6805.vhd:1253:42  */
  assign n2716_o = opcode == 8'b00010110;
  /* 6805.vhd:1253:42  */
  assign n2717_o = n2714_o | n2716_o;
  /* 6805.vhd:1253:50  */
  assign n2719_o = opcode == 8'b00011000;
  /* 6805.vhd:1253:50  */
  assign n2720_o = n2717_o | n2719_o;
  /* 6805.vhd:1253:58  */
  assign n2722_o = opcode == 8'b00011010;
  /* 6805.vhd:1253:58  */
  assign n2723_o = n2720_o | n2722_o;
  /* 6805.vhd:1253:66  */
  assign n2725_o = opcode == 8'b00011100;
  /* 6805.vhd:1253:66  */
  assign n2726_o = n2723_o | n2725_o;
  /* 6805.vhd:1253:74  */
  assign n2728_o = opcode == 8'b00011110;
  /* 6805.vhd:1253:74  */
  assign n2729_o = n2726_o | n2728_o;
  /* 6805.vhd:1253:82  */
  assign n2731_o = opcode == 8'b00010001;
  /* 6805.vhd:1253:82  */
  assign n2732_o = n2729_o | n2731_o;
  /* 6805.vhd:1254:26  */
  assign n2734_o = opcode == 8'b00010011;
  /* 6805.vhd:1254:26  */
  assign n2735_o = n2732_o | n2734_o;
  /* 6805.vhd:1254:34  */
  assign n2737_o = opcode == 8'b00010101;
  /* 6805.vhd:1254:34  */
  assign n2738_o = n2735_o | n2737_o;
  /* 6805.vhd:1254:42  */
  assign n2740_o = opcode == 8'b00010111;
  /* 6805.vhd:1254:42  */
  assign n2741_o = n2738_o | n2740_o;
  /* 6805.vhd:1254:50  */
  assign n2743_o = opcode == 8'b00011001;
  /* 6805.vhd:1254:50  */
  assign n2744_o = n2741_o | n2743_o;
  /* 6805.vhd:1254:58  */
  assign n2746_o = opcode == 8'b00011011;
  /* 6805.vhd:1254:58  */
  assign n2747_o = n2744_o | n2746_o;
  /* 6805.vhd:1254:66  */
  assign n2749_o = opcode == 8'b00011101;
  /* 6805.vhd:1254:66  */
  assign n2750_o = n2747_o | n2749_o;
  /* 6805.vhd:1254:74  */
  assign n2752_o = opcode == 8'b00011111;
  /* 6805.vhd:1254:74  */
  assign n2753_o = n2750_o | n2752_o;
  /* 6805.vhd:1254:82  */
  assign n2755_o = opcode == 8'b00110000;
  /* 6805.vhd:1254:82  */
  assign n2756_o = n2753_o | n2755_o;
  /* 6805.vhd:1255:26  */
  assign n2758_o = opcode == 8'b00110011;
  /* 6805.vhd:1255:26  */
  assign n2759_o = n2756_o | n2758_o;
  /* 6805.vhd:1255:34  */
  assign n2761_o = opcode == 8'b00110100;
  /* 6805.vhd:1255:34  */
  assign n2762_o = n2759_o | n2761_o;
  /* 6805.vhd:1255:42  */
  assign n2764_o = opcode == 8'b00110110;
  /* 6805.vhd:1255:42  */
  assign n2765_o = n2762_o | n2764_o;
  /* 6805.vhd:1255:50  */
  assign n2767_o = opcode == 8'b00110111;
  /* 6805.vhd:1255:50  */
  assign n2768_o = n2765_o | n2767_o;
  /* 6805.vhd:1256:26  */
  assign n2770_o = opcode == 8'b00111000;
  /* 6805.vhd:1256:26  */
  assign n2771_o = n2768_o | n2770_o;
  /* 6805.vhd:1256:34  */
  assign n2773_o = opcode == 8'b00111001;
  /* 6805.vhd:1256:34  */
  assign n2774_o = n2771_o | n2773_o;
  /* 6805.vhd:1256:42  */
  assign n2776_o = opcode == 8'b00111010;
  /* 6805.vhd:1256:42  */
  assign n2777_o = n2774_o | n2776_o;
  /* 6805.vhd:1256:50  */
  assign n2779_o = opcode == 8'b00111100;
  /* 6805.vhd:1256:50  */
  assign n2780_o = n2777_o | n2779_o;
  /* 6805.vhd:1256:58  */
  assign n2782_o = opcode == 8'b01100000;
  /* 6805.vhd:1256:58  */
  assign n2783_o = n2780_o | n2782_o;
  /* 6805.vhd:1257:26  */
  assign n2785_o = opcode == 8'b01100011;
  /* 6805.vhd:1257:26  */
  assign n2786_o = n2783_o | n2785_o;
  /* 6805.vhd:1257:34  */
  assign n2788_o = opcode == 8'b01100100;
  /* 6805.vhd:1257:34  */
  assign n2789_o = n2786_o | n2788_o;
  /* 6805.vhd:1257:42  */
  assign n2791_o = opcode == 8'b01100110;
  /* 6805.vhd:1257:42  */
  assign n2792_o = n2789_o | n2791_o;
  /* 6805.vhd:1257:50  */
  assign n2794_o = opcode == 8'b01100111;
  /* 6805.vhd:1257:50  */
  assign n2795_o = n2792_o | n2794_o;
  /* 6805.vhd:1257:58  */
  assign n2797_o = opcode == 8'b01101000;
  /* 6805.vhd:1257:58  */
  assign n2798_o = n2795_o | n2797_o;
  /* 6805.vhd:1258:26  */
  assign n2800_o = opcode == 8'b01101001;
  /* 6805.vhd:1258:26  */
  assign n2801_o = n2798_o | n2800_o;
  /* 6805.vhd:1258:34  */
  assign n2803_o = opcode == 8'b01101010;
  /* 6805.vhd:1258:34  */
  assign n2804_o = n2801_o | n2803_o;
  /* 6805.vhd:1258:42  */
  assign n2806_o = opcode == 8'b01101100;
  /* 6805.vhd:1258:42  */
  assign n2807_o = n2804_o | n2806_o;
  /* 6805.vhd:1258:50  */
  assign n2809_o = opcode == 8'b01110000;
  /* 6805.vhd:1258:50  */
  assign n2810_o = n2807_o | n2809_o;
  /* 6805.vhd:1259:26  */
  assign n2812_o = opcode == 8'b01110011;
  /* 6805.vhd:1259:26  */
  assign n2813_o = n2810_o | n2812_o;
  /* 6805.vhd:1259:34  */
  assign n2815_o = opcode == 8'b01110100;
  /* 6805.vhd:1259:34  */
  assign n2816_o = n2813_o | n2815_o;
  /* 6805.vhd:1259:42  */
  assign n2818_o = opcode == 8'b01110110;
  /* 6805.vhd:1259:42  */
  assign n2819_o = n2816_o | n2818_o;
  /* 6805.vhd:1259:50  */
  assign n2821_o = opcode == 8'b01110111;
  /* 6805.vhd:1259:50  */
  assign n2822_o = n2819_o | n2821_o;
  /* 6805.vhd:1259:58  */
  assign n2824_o = opcode == 8'b01111000;
  /* 6805.vhd:1259:58  */
  assign n2825_o = n2822_o | n2824_o;
  /* 6805.vhd:1259:66  */
  assign n2827_o = opcode == 8'b01111001;
  /* 6805.vhd:1259:66  */
  assign n2828_o = n2825_o | n2827_o;
  /* 6805.vhd:1259:74  */
  assign n2830_o = opcode == 8'b01111010;
  /* 6805.vhd:1259:74  */
  assign n2831_o = n2828_o | n2830_o;
  /* 6805.vhd:1260:26  */
  assign n2833_o = opcode == 8'b01111100;
  /* 6805.vhd:1260:26  */
  assign n2834_o = n2831_o | n2833_o;
  /* 6805.vhd:1260:34  */
  assign n2836_o = opcode == 8'b10110111;
  /* 6805.vhd:1260:34  */
  assign n2837_o = n2834_o | n2836_o;
  /* 6805.vhd:1261:26  */
  assign n2839_o = opcode == 8'b10111111;
  /* 6805.vhd:1261:26  */
  assign n2840_o = n2837_o | n2839_o;
  /* 6805.vhd:1261:34  */
  assign n2842_o = opcode == 8'b11000111;
  /* 6805.vhd:1261:34  */
  assign n2843_o = n2840_o | n2842_o;
  /* 6805.vhd:1261:42  */
  assign n2845_o = opcode == 8'b11001111;
  /* 6805.vhd:1261:42  */
  assign n2846_o = n2843_o | n2845_o;
  /* 6805.vhd:1261:50  */
  assign n2848_o = opcode == 8'b11010111;
  /* 6805.vhd:1261:50  */
  assign n2849_o = n2846_o | n2848_o;
  /* 6805.vhd:1262:26  */
  assign n2851_o = opcode == 8'b11011111;
  /* 6805.vhd:1262:26  */
  assign n2852_o = n2849_o | n2851_o;
  /* 6805.vhd:1262:34  */
  assign n2854_o = opcode == 8'b11100111;
  /* 6805.vhd:1262:34  */
  assign n2855_o = n2852_o | n2854_o;
  /* 6805.vhd:1262:42  */
  assign n2857_o = opcode == 8'b11101111;
  /* 6805.vhd:1262:42  */
  assign n2858_o = n2855_o | n2857_o;
  /* 6805.vhd:1262:50  */
  assign n2860_o = opcode == 8'b11110111;
  /* 6805.vhd:1262:50  */
  assign n2861_o = n2858_o | n2860_o;
  /* 6805.vhd:1263:26  */
  assign n2863_o = opcode == 8'b11111111;
  /* 6805.vhd:1263:26  */
  assign n2864_o = n2861_o | n2863_o;
  /* 6805.vhd:1269:32  */
  assign n2866_o = regsp + 16'b0000000000000001;
  /* 6805.vhd:1267:15  */
  assign n2868_o = opcode == 8'b10000000;
  /* 6805.vhd:1267:26  */
  assign n2870_o = opcode == 8'b10000010;
  /* 6805.vhd:1267:26  */
  assign n2871_o = n2868_o | n2870_o;
  /* 6805.vhd:1272:32  */
  assign n2873_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1271:15  */
  assign n2878_o = opcode == 8'b10000011;
  /* 6805.vhd:1285:30  */
  assign n2879_o = rega - datain;
  /* 6805.vhd:1286:30  */
  assign n2880_o = rega - datain;
  /* 6805.vhd:1287:30  */
  assign n2881_o = n2880_o[7];
  /* 6805.vhd:1288:25  */
  assign n2883_o = n2880_o == 8'b00000000;
  /* 6805.vhd:1288:17  */
  assign n2886_o = n2883_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1293:36  */
  assign n2887_o = rega[7];
  /* 6805.vhd:1293:28  */
  assign n2888_o = ~n2887_o;
  /* 6805.vhd:1293:51  */
  assign n2889_o = datain[7];
  /* 6805.vhd:1293:41  */
  assign n2890_o = n2888_o & n2889_o;
  /* 6805.vhd:1294:33  */
  assign n2891_o = datain[7];
  /* 6805.vhd:1294:45  */
  assign n2892_o = n2880_o[7];
  /* 6805.vhd:1294:37  */
  assign n2893_o = n2891_o & n2892_o;
  /* 6805.vhd:1293:56  */
  assign n2894_o = n2890_o | n2893_o;
  /* 6805.vhd:1295:31  */
  assign n2895_o = n2880_o[7];
  /* 6805.vhd:1295:48  */
  assign n2896_o = rega[7];
  /* 6805.vhd:1295:40  */
  assign n2897_o = ~n2896_o;
  /* 6805.vhd:1295:35  */
  assign n2898_o = n2895_o & n2897_o;
  /* 6805.vhd:1294:50  */
  assign n2899_o = n2894_o | n2898_o;
  /* 6805.vhd:1296:27  */
  assign n2901_o = opcode == 8'b10100000;
  /* 6805.vhd:1297:34  */
  assign n2903_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1296:17  */
  assign n2904_o = n2901_o ? n2903_o : regpc;
  /* 6805.vhd:1283:15  */
  assign n2906_o = opcode == 8'b10100000;
  /* 6805.vhd:1283:26  */
  assign n2908_o = opcode == 8'b10110000;
  /* 6805.vhd:1283:26  */
  assign n2909_o = n2906_o | n2908_o;
  /* 6805.vhd:1283:34  */
  assign n2911_o = opcode == 8'b11000000;
  /* 6805.vhd:1283:34  */
  assign n2912_o = n2909_o | n2911_o;
  /* 6805.vhd:1283:42  */
  assign n2914_o = opcode == 8'b11010000;
  /* 6805.vhd:1283:42  */
  assign n2915_o = n2912_o | n2914_o;
  /* 6805.vhd:1283:50  */
  assign n2917_o = opcode == 8'b11100000;
  /* 6805.vhd:1283:50  */
  assign n2918_o = n2915_o | n2917_o;
  /* 6805.vhd:1283:58  */
  assign n2920_o = opcode == 8'b11110000;
  /* 6805.vhd:1283:58  */
  assign n2921_o = n2918_o | n2920_o;
  /* 6805.vhd:1302:30  */
  assign n2922_o = rega - datain;
  /* 6805.vhd:1303:30  */
  assign n2923_o = n2922_o[7];
  /* 6805.vhd:1304:25  */
  assign n2925_o = n2922_o == 8'b00000000;
  /* 6805.vhd:1304:17  */
  assign n2928_o = n2925_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1309:36  */
  assign n2929_o = rega[7];
  /* 6805.vhd:1309:28  */
  assign n2930_o = ~n2929_o;
  /* 6805.vhd:1309:51  */
  assign n2931_o = datain[7];
  /* 6805.vhd:1309:41  */
  assign n2932_o = n2930_o & n2931_o;
  /* 6805.vhd:1310:33  */
  assign n2933_o = datain[7];
  /* 6805.vhd:1310:45  */
  assign n2934_o = n2922_o[7];
  /* 6805.vhd:1310:37  */
  assign n2935_o = n2933_o & n2934_o;
  /* 6805.vhd:1309:56  */
  assign n2936_o = n2932_o | n2935_o;
  /* 6805.vhd:1311:31  */
  assign n2937_o = n2922_o[7];
  /* 6805.vhd:1311:48  */
  assign n2938_o = rega[7];
  /* 6805.vhd:1311:40  */
  assign n2939_o = ~n2938_o;
  /* 6805.vhd:1311:35  */
  assign n2940_o = n2937_o & n2939_o;
  /* 6805.vhd:1310:50  */
  assign n2941_o = n2936_o | n2940_o;
  /* 6805.vhd:1312:27  */
  assign n2943_o = opcode == 8'b10100001;
  /* 6805.vhd:1313:34  */
  assign n2945_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1312:17  */
  assign n2946_o = n2943_o ? n2945_o : regpc;
  /* 6805.vhd:1300:15  */
  assign n2948_o = opcode == 8'b10100001;
  /* 6805.vhd:1300:26  */
  assign n2950_o = opcode == 8'b10110001;
  /* 6805.vhd:1300:26  */
  assign n2951_o = n2948_o | n2950_o;
  /* 6805.vhd:1300:34  */
  assign n2953_o = opcode == 8'b11000001;
  /* 6805.vhd:1300:34  */
  assign n2954_o = n2951_o | n2953_o;
  /* 6805.vhd:1300:42  */
  assign n2956_o = opcode == 8'b11010001;
  /* 6805.vhd:1300:42  */
  assign n2957_o = n2954_o | n2956_o;
  /* 6805.vhd:1300:50  */
  assign n2959_o = opcode == 8'b11100001;
  /* 6805.vhd:1300:50  */
  assign n2960_o = n2957_o | n2959_o;
  /* 6805.vhd:1300:58  */
  assign n2962_o = opcode == 8'b11110001;
  /* 6805.vhd:1300:58  */
  assign n2963_o = n2960_o | n2962_o;
  /* 6805.vhd:1318:30  */
  assign n2964_o = rega - datain;
  /* 6805.vhd:1318:52  */
  assign n2966_o = {7'b0000000, flagc};
  /* 6805.vhd:1318:39  */
  assign n2967_o = n2964_o - n2966_o;
  /* 6805.vhd:1319:30  */
  assign n2968_o = rega - datain;
  /* 6805.vhd:1319:52  */
  assign n2970_o = {7'b0000000, flagc};
  /* 6805.vhd:1319:39  */
  assign n2971_o = n2968_o - n2970_o;
  /* 6805.vhd:1320:30  */
  assign n2972_o = n2971_o[7];
  /* 6805.vhd:1321:25  */
  assign n2974_o = n2971_o == 8'b00000000;
  /* 6805.vhd:1321:17  */
  assign n2977_o = n2974_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1326:36  */
  assign n2978_o = rega[7];
  /* 6805.vhd:1326:28  */
  assign n2979_o = ~n2978_o;
  /* 6805.vhd:1326:51  */
  assign n2980_o = datain[7];
  /* 6805.vhd:1326:41  */
  assign n2981_o = n2979_o & n2980_o;
  /* 6805.vhd:1327:33  */
  assign n2982_o = datain[7];
  /* 6805.vhd:1327:45  */
  assign n2983_o = n2971_o[7];
  /* 6805.vhd:1327:37  */
  assign n2984_o = n2982_o & n2983_o;
  /* 6805.vhd:1326:56  */
  assign n2985_o = n2981_o | n2984_o;
  /* 6805.vhd:1328:31  */
  assign n2986_o = n2971_o[7];
  /* 6805.vhd:1328:48  */
  assign n2987_o = rega[7];
  /* 6805.vhd:1328:40  */
  assign n2988_o = ~n2987_o;
  /* 6805.vhd:1328:35  */
  assign n2989_o = n2986_o & n2988_o;
  /* 6805.vhd:1327:50  */
  assign n2990_o = n2985_o | n2989_o;
  /* 6805.vhd:1329:27  */
  assign n2992_o = opcode == 8'b10100010;
  /* 6805.vhd:1330:34  */
  assign n2994_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1329:17  */
  assign n2995_o = n2992_o ? n2994_o : regpc;
  /* 6805.vhd:1316:15  */
  assign n2997_o = opcode == 8'b10100010;
  /* 6805.vhd:1316:26  */
  assign n2999_o = opcode == 8'b10110010;
  /* 6805.vhd:1316:26  */
  assign n3000_o = n2997_o | n2999_o;
  /* 6805.vhd:1316:34  */
  assign n3002_o = opcode == 8'b11000010;
  /* 6805.vhd:1316:34  */
  assign n3003_o = n3000_o | n3002_o;
  /* 6805.vhd:1316:42  */
  assign n3005_o = opcode == 8'b11010010;
  /* 6805.vhd:1316:42  */
  assign n3006_o = n3003_o | n3005_o;
  /* 6805.vhd:1316:50  */
  assign n3008_o = opcode == 8'b11100010;
  /* 6805.vhd:1316:50  */
  assign n3009_o = n3006_o | n3008_o;
  /* 6805.vhd:1316:58  */
  assign n3011_o = opcode == 8'b11110010;
  /* 6805.vhd:1316:58  */
  assign n3012_o = n3009_o | n3011_o;
  /* 6805.vhd:1335:30  */
  assign n3013_o = regx - datain;
  /* 6805.vhd:1336:30  */
  assign n3014_o = n3013_o[7];
  /* 6805.vhd:1337:25  */
  assign n3016_o = n3013_o == 8'b00000000;
  /* 6805.vhd:1337:17  */
  assign n3019_o = n3016_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1342:36  */
  assign n3020_o = regx[7];
  /* 6805.vhd:1342:28  */
  assign n3021_o = ~n3020_o;
  /* 6805.vhd:1342:51  */
  assign n3022_o = datain[7];
  /* 6805.vhd:1342:41  */
  assign n3023_o = n3021_o & n3022_o;
  /* 6805.vhd:1343:33  */
  assign n3024_o = datain[7];
  /* 6805.vhd:1343:45  */
  assign n3025_o = n3013_o[7];
  /* 6805.vhd:1343:37  */
  assign n3026_o = n3024_o & n3025_o;
  /* 6805.vhd:1342:56  */
  assign n3027_o = n3023_o | n3026_o;
  /* 6805.vhd:1344:31  */
  assign n3028_o = n3013_o[7];
  /* 6805.vhd:1344:48  */
  assign n3029_o = regx[7];
  /* 6805.vhd:1344:40  */
  assign n3030_o = ~n3029_o;
  /* 6805.vhd:1344:35  */
  assign n3031_o = n3028_o & n3030_o;
  /* 6805.vhd:1343:50  */
  assign n3032_o = n3027_o | n3031_o;
  /* 6805.vhd:1345:27  */
  assign n3034_o = opcode == 8'b10100011;
  /* 6805.vhd:1346:34  */
  assign n3036_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1345:17  */
  assign n3037_o = n3034_o ? n3036_o : regpc;
  /* 6805.vhd:1333:15  */
  assign n3039_o = opcode == 8'b10100011;
  /* 6805.vhd:1333:26  */
  assign n3041_o = opcode == 8'b10110011;
  /* 6805.vhd:1333:26  */
  assign n3042_o = n3039_o | n3041_o;
  /* 6805.vhd:1333:34  */
  assign n3044_o = opcode == 8'b11000011;
  /* 6805.vhd:1333:34  */
  assign n3045_o = n3042_o | n3044_o;
  /* 6805.vhd:1333:42  */
  assign n3047_o = opcode == 8'b11010011;
  /* 6805.vhd:1333:42  */
  assign n3048_o = n3045_o | n3047_o;
  /* 6805.vhd:1333:50  */
  assign n3050_o = opcode == 8'b11100011;
  /* 6805.vhd:1333:50  */
  assign n3051_o = n3048_o | n3050_o;
  /* 6805.vhd:1333:58  */
  assign n3053_o = opcode == 8'b11110011;
  /* 6805.vhd:1333:58  */
  assign n3054_o = n3051_o | n3053_o;
  /* 6805.vhd:1351:30  */
  assign n3055_o = rega & datain;
  /* 6805.vhd:1352:30  */
  assign n3056_o = rega & datain;
  /* 6805.vhd:1353:30  */
  assign n3057_o = n3056_o[7];
  /* 6805.vhd:1354:25  */
  assign n3059_o = n3056_o == 8'b00000000;
  /* 6805.vhd:1354:17  */
  assign n3062_o = n3059_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1359:27  */
  assign n3064_o = opcode == 8'b10100100;
  /* 6805.vhd:1360:34  */
  assign n3066_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1359:17  */
  assign n3067_o = n3064_o ? n3066_o : regpc;
  /* 6805.vhd:1349:15  */
  assign n3069_o = opcode == 8'b10100100;
  /* 6805.vhd:1349:26  */
  assign n3071_o = opcode == 8'b10110100;
  /* 6805.vhd:1349:26  */
  assign n3072_o = n3069_o | n3071_o;
  /* 6805.vhd:1349:34  */
  assign n3074_o = opcode == 8'b11000100;
  /* 6805.vhd:1349:34  */
  assign n3075_o = n3072_o | n3074_o;
  /* 6805.vhd:1349:42  */
  assign n3077_o = opcode == 8'b11010100;
  /* 6805.vhd:1349:42  */
  assign n3078_o = n3075_o | n3077_o;
  /* 6805.vhd:1349:50  */
  assign n3080_o = opcode == 8'b11100100;
  /* 6805.vhd:1349:50  */
  assign n3081_o = n3078_o | n3080_o;
  /* 6805.vhd:1349:58  */
  assign n3083_o = opcode == 8'b11110100;
  /* 6805.vhd:1349:58  */
  assign n3084_o = n3081_o | n3083_o;
  /* 6805.vhd:1365:30  */
  assign n3085_o = rega & datain;
  /* 6805.vhd:1366:30  */
  assign n3086_o = n3085_o[7];
  /* 6805.vhd:1367:25  */
  assign n3088_o = n3085_o == 8'b00000000;
  /* 6805.vhd:1367:17  */
  assign n3091_o = n3088_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1372:27  */
  assign n3093_o = opcode == 8'b10100101;
  /* 6805.vhd:1373:34  */
  assign n3095_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1372:17  */
  assign n3096_o = n3093_o ? n3095_o : regpc;
  /* 6805.vhd:1363:15  */
  assign n3098_o = opcode == 8'b10100101;
  /* 6805.vhd:1363:26  */
  assign n3100_o = opcode == 8'b10110101;
  /* 6805.vhd:1363:26  */
  assign n3101_o = n3098_o | n3100_o;
  /* 6805.vhd:1363:34  */
  assign n3103_o = opcode == 8'b11000101;
  /* 6805.vhd:1363:34  */
  assign n3104_o = n3101_o | n3103_o;
  /* 6805.vhd:1363:42  */
  assign n3106_o = opcode == 8'b11010101;
  /* 6805.vhd:1363:42  */
  assign n3107_o = n3104_o | n3106_o;
  /* 6805.vhd:1363:50  */
  assign n3109_o = opcode == 8'b11100101;
  /* 6805.vhd:1363:50  */
  assign n3110_o = n3107_o | n3109_o;
  /* 6805.vhd:1363:58  */
  assign n3112_o = opcode == 8'b11110101;
  /* 6805.vhd:1363:58  */
  assign n3113_o = n3110_o | n3112_o;
  /* 6805.vhd:1379:32  */
  assign n3114_o = datain[7];
  /* 6805.vhd:1380:27  */
  assign n3116_o = datain == 8'b00000000;
  /* 6805.vhd:1380:17  */
  assign n3119_o = n3116_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1385:27  */
  assign n3121_o = opcode == 8'b10100110;
  /* 6805.vhd:1386:34  */
  assign n3123_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1385:17  */
  assign n3124_o = n3121_o ? n3123_o : regpc;
  /* 6805.vhd:1376:15  */
  assign n3126_o = opcode == 8'b10100110;
  /* 6805.vhd:1376:26  */
  assign n3128_o = opcode == 8'b10110110;
  /* 6805.vhd:1376:26  */
  assign n3129_o = n3126_o | n3128_o;
  /* 6805.vhd:1376:34  */
  assign n3131_o = opcode == 8'b11000110;
  /* 6805.vhd:1376:34  */
  assign n3132_o = n3129_o | n3131_o;
  /* 6805.vhd:1376:42  */
  assign n3134_o = opcode == 8'b11010110;
  /* 6805.vhd:1376:42  */
  assign n3135_o = n3132_o | n3134_o;
  /* 6805.vhd:1376:50  */
  assign n3137_o = opcode == 8'b11100110;
  /* 6805.vhd:1376:50  */
  assign n3138_o = n3135_o | n3137_o;
  /* 6805.vhd:1376:58  */
  assign n3140_o = opcode == 8'b11110110;
  /* 6805.vhd:1376:58  */
  assign n3141_o = n3138_o | n3140_o;
  /* 6805.vhd:1391:30  */
  assign n3142_o = rega ^ datain;
  /* 6805.vhd:1392:30  */
  assign n3143_o = rega ^ datain;
  /* 6805.vhd:1393:30  */
  assign n3144_o = n3143_o[7];
  /* 6805.vhd:1394:25  */
  assign n3146_o = n3143_o == 8'b00000000;
  /* 6805.vhd:1394:17  */
  assign n3149_o = n3146_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1399:27  */
  assign n3151_o = opcode == 8'b10101000;
  /* 6805.vhd:1400:34  */
  assign n3153_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1399:17  */
  assign n3154_o = n3151_o ? n3153_o : regpc;
  /* 6805.vhd:1389:15  */
  assign n3156_o = opcode == 8'b10101000;
  /* 6805.vhd:1389:26  */
  assign n3158_o = opcode == 8'b10111000;
  /* 6805.vhd:1389:26  */
  assign n3159_o = n3156_o | n3158_o;
  /* 6805.vhd:1389:34  */
  assign n3161_o = opcode == 8'b11001000;
  /* 6805.vhd:1389:34  */
  assign n3162_o = n3159_o | n3161_o;
  /* 6805.vhd:1389:42  */
  assign n3164_o = opcode == 8'b11011000;
  /* 6805.vhd:1389:42  */
  assign n3165_o = n3162_o | n3164_o;
  /* 6805.vhd:1389:50  */
  assign n3167_o = opcode == 8'b11101000;
  /* 6805.vhd:1389:50  */
  assign n3168_o = n3165_o | n3167_o;
  /* 6805.vhd:1389:58  */
  assign n3170_o = opcode == 8'b11111000;
  /* 6805.vhd:1389:58  */
  assign n3171_o = n3168_o | n3170_o;
  /* 6805.vhd:1405:30  */
  assign n3172_o = rega + datain;
  /* 6805.vhd:1405:52  */
  assign n3174_o = {7'b0000000, flagc};
  /* 6805.vhd:1405:39  */
  assign n3175_o = n3172_o + n3174_o;
  /* 6805.vhd:1406:30  */
  assign n3176_o = rega + datain;
  /* 6805.vhd:1406:52  */
  assign n3178_o = {7'b0000000, flagc};
  /* 6805.vhd:1406:39  */
  assign n3179_o = n3176_o + n3178_o;
  /* 6805.vhd:1407:30  */
  assign n3180_o = n3179_o[7];
  /* 6805.vhd:1408:25  */
  assign n3182_o = n3179_o == 8'b00000000;
  /* 6805.vhd:1408:17  */
  assign n3185_o = n3182_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1413:31  */
  assign n3186_o = rega[3];
  /* 6805.vhd:1413:45  */
  assign n3187_o = datain[3];
  /* 6805.vhd:1413:35  */
  assign n3188_o = n3186_o & n3187_o;
  /* 6805.vhd:1414:33  */
  assign n3189_o = datain[3];
  /* 6805.vhd:1414:50  */
  assign n3190_o = n3179_o[3];
  /* 6805.vhd:1414:42  */
  assign n3191_o = ~n3190_o;
  /* 6805.vhd:1414:37  */
  assign n3192_o = n3189_o & n3191_o;
  /* 6805.vhd:1413:50  */
  assign n3193_o = n3188_o | n3192_o;
  /* 6805.vhd:1415:36  */
  assign n3194_o = n3179_o[3];
  /* 6805.vhd:1415:28  */
  assign n3195_o = ~n3194_o;
  /* 6805.vhd:1415:49  */
  assign n3196_o = rega[3];
  /* 6805.vhd:1415:41  */
  assign n3197_o = n3195_o & n3196_o;
  /* 6805.vhd:1414:56  */
  assign n3198_o = n3193_o | n3197_o;
  /* 6805.vhd:1416:31  */
  assign n3199_o = rega[7];
  /* 6805.vhd:1416:45  */
  assign n3200_o = datain[7];
  /* 6805.vhd:1416:35  */
  assign n3201_o = n3199_o & n3200_o;
  /* 6805.vhd:1417:33  */
  assign n3202_o = datain[7];
  /* 6805.vhd:1417:50  */
  assign n3203_o = n3179_o[7];
  /* 6805.vhd:1417:42  */
  assign n3204_o = ~n3203_o;
  /* 6805.vhd:1417:37  */
  assign n3205_o = n3202_o & n3204_o;
  /* 6805.vhd:1416:50  */
  assign n3206_o = n3201_o | n3205_o;
  /* 6805.vhd:1418:36  */
  assign n3207_o = n3179_o[7];
  /* 6805.vhd:1418:28  */
  assign n3208_o = ~n3207_o;
  /* 6805.vhd:1418:49  */
  assign n3209_o = rega[7];
  /* 6805.vhd:1418:41  */
  assign n3210_o = n3208_o & n3209_o;
  /* 6805.vhd:1417:56  */
  assign n3211_o = n3206_o | n3210_o;
  /* 6805.vhd:1419:27  */
  assign n3213_o = opcode == 8'b10101001;
  /* 6805.vhd:1420:34  */
  assign n3215_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1419:17  */
  assign n3216_o = n3213_o ? n3215_o : regpc;
  /* 6805.vhd:1403:15  */
  assign n3218_o = opcode == 8'b10101001;
  /* 6805.vhd:1403:26  */
  assign n3220_o = opcode == 8'b10111001;
  /* 6805.vhd:1403:26  */
  assign n3221_o = n3218_o | n3220_o;
  /* 6805.vhd:1403:34  */
  assign n3223_o = opcode == 8'b11001001;
  /* 6805.vhd:1403:34  */
  assign n3224_o = n3221_o | n3223_o;
  /* 6805.vhd:1403:42  */
  assign n3226_o = opcode == 8'b11011001;
  /* 6805.vhd:1403:42  */
  assign n3227_o = n3224_o | n3226_o;
  /* 6805.vhd:1403:50  */
  assign n3229_o = opcode == 8'b11101001;
  /* 6805.vhd:1403:50  */
  assign n3230_o = n3227_o | n3229_o;
  /* 6805.vhd:1403:58  */
  assign n3232_o = opcode == 8'b11111001;
  /* 6805.vhd:1403:58  */
  assign n3233_o = n3230_o | n3232_o;
  /* 6805.vhd:1425:30  */
  assign n3234_o = rega | datain;
  /* 6805.vhd:1426:30  */
  assign n3235_o = rega | datain;
  /* 6805.vhd:1427:30  */
  assign n3236_o = n3235_o[7];
  /* 6805.vhd:1428:25  */
  assign n3238_o = n3235_o == 8'b00000000;
  /* 6805.vhd:1428:17  */
  assign n3241_o = n3238_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1433:27  */
  assign n3243_o = opcode == 8'b10101010;
  /* 6805.vhd:1434:34  */
  assign n3245_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1433:17  */
  assign n3246_o = n3243_o ? n3245_o : regpc;
  /* 6805.vhd:1423:15  */
  assign n3248_o = opcode == 8'b10101010;
  /* 6805.vhd:1423:26  */
  assign n3250_o = opcode == 8'b10111010;
  /* 6805.vhd:1423:26  */
  assign n3251_o = n3248_o | n3250_o;
  /* 6805.vhd:1423:34  */
  assign n3253_o = opcode == 8'b11001010;
  /* 6805.vhd:1423:34  */
  assign n3254_o = n3251_o | n3253_o;
  /* 6805.vhd:1423:42  */
  assign n3256_o = opcode == 8'b11011010;
  /* 6805.vhd:1423:42  */
  assign n3257_o = n3254_o | n3256_o;
  /* 6805.vhd:1423:50  */
  assign n3259_o = opcode == 8'b11101010;
  /* 6805.vhd:1423:50  */
  assign n3260_o = n3257_o | n3259_o;
  /* 6805.vhd:1423:58  */
  assign n3262_o = opcode == 8'b11111010;
  /* 6805.vhd:1423:58  */
  assign n3263_o = n3260_o | n3262_o;
  /* 6805.vhd:1439:30  */
  assign n3264_o = rega + datain;
  /* 6805.vhd:1440:30  */
  assign n3265_o = rega + datain;
  /* 6805.vhd:1441:30  */
  assign n3266_o = n3265_o[7];
  /* 6805.vhd:1442:25  */
  assign n3268_o = n3265_o == 8'b00000000;
  /* 6805.vhd:1442:17  */
  assign n3271_o = n3268_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1447:31  */
  assign n3272_o = rega[3];
  /* 6805.vhd:1447:45  */
  assign n3273_o = datain[3];
  /* 6805.vhd:1447:35  */
  assign n3274_o = n3272_o & n3273_o;
  /* 6805.vhd:1448:33  */
  assign n3275_o = datain[3];
  /* 6805.vhd:1448:50  */
  assign n3276_o = n3265_o[3];
  /* 6805.vhd:1448:42  */
  assign n3277_o = ~n3276_o;
  /* 6805.vhd:1448:37  */
  assign n3278_o = n3275_o & n3277_o;
  /* 6805.vhd:1447:50  */
  assign n3279_o = n3274_o | n3278_o;
  /* 6805.vhd:1449:36  */
  assign n3280_o = n3265_o[3];
  /* 6805.vhd:1449:28  */
  assign n3281_o = ~n3280_o;
  /* 6805.vhd:1449:49  */
  assign n3282_o = rega[3];
  /* 6805.vhd:1449:41  */
  assign n3283_o = n3281_o & n3282_o;
  /* 6805.vhd:1448:56  */
  assign n3284_o = n3279_o | n3283_o;
  /* 6805.vhd:1450:31  */
  assign n3285_o = rega[7];
  /* 6805.vhd:1450:45  */
  assign n3286_o = datain[7];
  /* 6805.vhd:1450:35  */
  assign n3287_o = n3285_o & n3286_o;
  /* 6805.vhd:1451:33  */
  assign n3288_o = datain[7];
  /* 6805.vhd:1451:50  */
  assign n3289_o = n3265_o[7];
  /* 6805.vhd:1451:42  */
  assign n3290_o = ~n3289_o;
  /* 6805.vhd:1451:37  */
  assign n3291_o = n3288_o & n3290_o;
  /* 6805.vhd:1450:50  */
  assign n3292_o = n3287_o | n3291_o;
  /* 6805.vhd:1452:36  */
  assign n3293_o = n3265_o[7];
  /* 6805.vhd:1452:28  */
  assign n3294_o = ~n3293_o;
  /* 6805.vhd:1452:49  */
  assign n3295_o = rega[7];
  /* 6805.vhd:1452:41  */
  assign n3296_o = n3294_o & n3295_o;
  /* 6805.vhd:1451:56  */
  assign n3297_o = n3292_o | n3296_o;
  /* 6805.vhd:1453:27  */
  assign n3299_o = opcode == 8'b10101011;
  /* 6805.vhd:1454:34  */
  assign n3301_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1453:17  */
  assign n3302_o = n3299_o ? n3301_o : regpc;
  /* 6805.vhd:1437:15  */
  assign n3304_o = opcode == 8'b10101011;
  /* 6805.vhd:1437:26  */
  assign n3306_o = opcode == 8'b10111011;
  /* 6805.vhd:1437:26  */
  assign n3307_o = n3304_o | n3306_o;
  /* 6805.vhd:1437:34  */
  assign n3309_o = opcode == 8'b11001011;
  /* 6805.vhd:1437:34  */
  assign n3310_o = n3307_o | n3309_o;
  /* 6805.vhd:1437:42  */
  assign n3312_o = opcode == 8'b11011011;
  /* 6805.vhd:1437:42  */
  assign n3313_o = n3310_o | n3312_o;
  /* 6805.vhd:1437:50  */
  assign n3315_o = opcode == 8'b11101011;
  /* 6805.vhd:1437:50  */
  assign n3316_o = n3313_o | n3315_o;
  /* 6805.vhd:1437:58  */
  assign n3318_o = opcode == 8'b11111011;
  /* 6805.vhd:1437:58  */
  assign n3319_o = n3316_o | n3318_o;
  /* 6805.vhd:1460:32  */
  assign n3320_o = datain[7];
  /* 6805.vhd:1461:27  */
  assign n3322_o = datain == 8'b00000000;
  /* 6805.vhd:1461:17  */
  assign n3325_o = n3322_o ? 1'b1 : 1'b0;
  /* 6805.vhd:1466:27  */
  assign n3327_o = opcode == 8'b10101110;
  /* 6805.vhd:1467:34  */
  assign n3329_o = regpc + 16'b0000000000000001;
  /* 6805.vhd:1466:17  */
  assign n3330_o = n3327_o ? n3329_o : regpc;
  /* 6805.vhd:1457:15  */
  assign n3332_o = opcode == 8'b10101110;
  /* 6805.vhd:1457:26  */
  assign n3334_o = opcode == 8'b10111110;
  /* 6805.vhd:1457:26  */
  assign n3335_o = n3332_o | n3334_o;
  /* 6805.vhd:1457:34  */
  assign n3337_o = opcode == 8'b11001110;
  /* 6805.vhd:1457:34  */
  assign n3338_o = n3335_o | n3337_o;
  /* 6805.vhd:1457:42  */
  assign n3340_o = opcode == 8'b11011110;
  /* 6805.vhd:1457:42  */
  assign n3341_o = n3338_o | n3340_o;
  /* 6805.vhd:1457:50  */
  assign n3343_o = opcode == 8'b11101110;
  /* 6805.vhd:1457:50  */
  assign n3344_o = n3341_o | n3343_o;
  /* 6805.vhd:1457:58  */
  assign n3346_o = opcode == 8'b11111110;
  /* 6805.vhd:1457:58  */
  assign n3347_o = n3344_o | n3346_o;
  /* 6805.vhd:1473:24  */
  assign n3348_o = help[7];
  /* 6805.vhd:1473:28  */
  assign n3349_o = ~n3348_o;
  /* 6805.vhd:1474:43  */
  assign n3351_o = {8'b00000000, help};
  /* 6805.vhd:1474:34  */
  assign n3352_o = regpc + n3351_o;
  /* 6805.vhd:1476:43  */
  assign n3354_o = {8'b11111111, help};
  /* 6805.vhd:1476:34  */
  assign n3355_o = regpc + n3354_o;
  /* 6805.vhd:1473:17  */
  assign n3356_o = n3349_o ? n3352_o : n3355_o;
  /* 6805.vhd:1478:32  */
  assign n3358_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1470:15  */
  assign n3360_o = opcode == 8'b10101101;
  /* 6805.vhd:1483:32  */
  assign n3362_o = {8'b00000000, help};
  /* 6805.vhd:1484:32  */
  assign n3364_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1480:15  */
  assign n3366_o = opcode == 8'b10111101;
  /* 6805.vhd:1487:32  */
  assign n3368_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1486:15  */
  assign n3370_o = opcode == 8'b11001101;
  /* 6805.vhd:1486:26  */
  assign n3372_o = opcode == 8'b11011101;
  /* 6805.vhd:1486:26  */
  assign n3373_o = n3370_o | n3372_o;
  /* 6805.vhd:1493:33  */
  assign n3375_o = {8'b00000000, help};
  /* 6805.vhd:1493:50  */
  assign n3377_o = {8'b00000000, regx};
  /* 6805.vhd:1493:41  */
  assign n3378_o = n3375_o + n3377_o;
  /* 6805.vhd:1494:32  */
  assign n3380_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1490:15  */
  assign n3382_o = opcode == 8'b11101101;
  /* 6805.vhd:1499:33  */
  assign n3384_o = {8'b00000000, regx};
  /* 6805.vhd:1500:32  */
  assign n3386_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1496:15  */
  assign n3388_o = opcode == 8'b11111101;
  assign n3389_o = {n3388_o, n3382_o, n3373_o, n3366_o, n3360_o, n3347_o, n3319_o, n3263_o, n3233_o, n3171_o, n3141_o, n3113_o, n3084_o, n3054_o, n3012_o, n2963_o, n2921_o, n2878_o, n2871_o, n2864_o, n2706_o};
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3395_o = 1'b1;
      21'b010000000000000000000: n3395_o = 1'b1;
      21'b001000000000000000000: n3395_o = n3854_q;
      21'b000100000000000000000: n3395_o = 1'b1;
      21'b000010000000000000000: n3395_o = 1'b1;
      21'b000001000000000000000: n3395_o = n3854_q;
      21'b000000100000000000000: n3395_o = n3854_q;
      21'b000000010000000000000: n3395_o = n3854_q;
      21'b000000001000000000000: n3395_o = n3854_q;
      21'b000000000100000000000: n3395_o = n3854_q;
      21'b000000000010000000000: n3395_o = n3854_q;
      21'b000000000001000000000: n3395_o = n3854_q;
      21'b000000000000100000000: n3395_o = n3854_q;
      21'b000000000000010000000: n3395_o = n3854_q;
      21'b000000000000001000000: n3395_o = n3854_q;
      21'b000000000000000100000: n3395_o = n3854_q;
      21'b000000000000000010000: n3395_o = n3854_q;
      21'b000000000000000001000: n3395_o = n3854_q;
      21'b000000000000000000100: n3395_o = n3854_q;
      21'b000000000000000000010: n3395_o = 1'b1;
      21'b000000000000000000001: n3395_o = n3854_q;
      default: n3395_o = n3854_q;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3396_o = rega;
      21'b010000000000000000000: n3396_o = rega;
      21'b001000000000000000000: n3396_o = rega;
      21'b000100000000000000000: n3396_o = rega;
      21'b000010000000000000000: n3396_o = rega;
      21'b000001000000000000000: n3396_o = rega;
      21'b000000100000000000000: n3396_o = n3264_o;
      21'b000000010000000000000: n3396_o = n3234_o;
      21'b000000001000000000000: n3396_o = n3175_o;
      21'b000000000100000000000: n3396_o = n3142_o;
      21'b000000000010000000000: n3396_o = datain;
      21'b000000000001000000000: n3396_o = rega;
      21'b000000000000100000000: n3396_o = n3055_o;
      21'b000000000000010000000: n3396_o = rega;
      21'b000000000000001000000: n3396_o = n2967_o;
      21'b000000000000000100000: n3396_o = rega;
      21'b000000000000000010000: n3396_o = n2879_o;
      21'b000000000000000001000: n3396_o = rega;
      21'b000000000000000000100: n3396_o = rega;
      21'b000000000000000000010: n3396_o = rega;
      21'b000000000000000000001: n3396_o = rega;
      default: n3396_o = rega;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3397_o = regx;
      21'b010000000000000000000: n3397_o = regx;
      21'b001000000000000000000: n3397_o = regx;
      21'b000100000000000000000: n3397_o = regx;
      21'b000010000000000000000: n3397_o = regx;
      21'b000001000000000000000: n3397_o = datain;
      21'b000000100000000000000: n3397_o = regx;
      21'b000000010000000000000: n3397_o = regx;
      21'b000000001000000000000: n3397_o = regx;
      21'b000000000100000000000: n3397_o = regx;
      21'b000000000010000000000: n3397_o = regx;
      21'b000000000001000000000: n3397_o = regx;
      21'b000000000000100000000: n3397_o = regx;
      21'b000000000000010000000: n3397_o = regx;
      21'b000000000000001000000: n3397_o = regx;
      21'b000000000000000100000: n3397_o = regx;
      21'b000000000000000010000: n3397_o = regx;
      21'b000000000000000001000: n3397_o = regx;
      21'b000000000000000000100: n3397_o = datain;
      21'b000000000000000000010: n3397_o = regx;
      21'b000000000000000000001: n3397_o = regx;
      default: n3397_o = regx;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3398_o = n3386_o;
      21'b010000000000000000000: n3398_o = n3380_o;
      21'b001000000000000000000: n3398_o = n3368_o;
      21'b000100000000000000000: n3398_o = n3364_o;
      21'b000010000000000000000: n3398_o = n3358_o;
      21'b000001000000000000000: n3398_o = regsp;
      21'b000000100000000000000: n3398_o = regsp;
      21'b000000010000000000000: n3398_o = regsp;
      21'b000000001000000000000: n3398_o = regsp;
      21'b000000000100000000000: n3398_o = regsp;
      21'b000000000010000000000: n3398_o = regsp;
      21'b000000000001000000000: n3398_o = regsp;
      21'b000000000000100000000: n3398_o = regsp;
      21'b000000000000010000000: n3398_o = regsp;
      21'b000000000000001000000: n3398_o = regsp;
      21'b000000000000000100000: n3398_o = regsp;
      21'b000000000000000010000: n3398_o = regsp;
      21'b000000000000000001000: n3398_o = n2873_o;
      21'b000000000000000000100: n3398_o = n2866_o;
      21'b000000000000000000010: n3398_o = regsp;
      21'b000000000000000000001: n3398_o = regsp;
      default: n3398_o = regsp;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3399_o = n3384_o;
      21'b010000000000000000000: n3399_o = n3378_o;
      21'b001000000000000000000: n3399_o = regpc;
      21'b000100000000000000000: n3399_o = n3362_o;
      21'b000010000000000000000: n3399_o = n3356_o;
      21'b000001000000000000000: n3399_o = n3330_o;
      21'b000000100000000000000: n3399_o = n3302_o;
      21'b000000010000000000000: n3399_o = n3246_o;
      21'b000000001000000000000: n3399_o = n3216_o;
      21'b000000000100000000000: n3399_o = n3154_o;
      21'b000000000010000000000: n3399_o = n3124_o;
      21'b000000000001000000000: n3399_o = n3096_o;
      21'b000000000000100000000: n3399_o = n3067_o;
      21'b000000000000010000000: n3399_o = n3037_o;
      21'b000000000000001000000: n3399_o = n2995_o;
      21'b000000000000000100000: n3399_o = n2946_o;
      21'b000000000000000010000: n3399_o = n2904_o;
      21'b000000000000000001000: n3399_o = regpc;
      21'b000000000000000000100: n3399_o = regpc;
      21'b000000000000000000010: n3399_o = regpc;
      21'b000000000000000000001: n3399_o = n2659_o;
      default: n3399_o = regpc;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3400_o = flagh;
      21'b010000000000000000000: n3400_o = flagh;
      21'b001000000000000000000: n3400_o = flagh;
      21'b000100000000000000000: n3400_o = flagh;
      21'b000010000000000000000: n3400_o = flagh;
      21'b000001000000000000000: n3400_o = flagh;
      21'b000000100000000000000: n3400_o = n3284_o;
      21'b000000010000000000000: n3400_o = flagh;
      21'b000000001000000000000: n3400_o = n3198_o;
      21'b000000000100000000000: n3400_o = flagh;
      21'b000000000010000000000: n3400_o = flagh;
      21'b000000000001000000000: n3400_o = flagh;
      21'b000000000000100000000: n3400_o = flagh;
      21'b000000000000010000000: n3400_o = flagh;
      21'b000000000000001000000: n3400_o = flagh;
      21'b000000000000000100000: n3400_o = flagh;
      21'b000000000000000010000: n3400_o = flagh;
      21'b000000000000000001000: n3400_o = flagh;
      21'b000000000000000000100: n3400_o = flagh;
      21'b000000000000000000010: n3400_o = flagh;
      21'b000000000000000000001: n3400_o = flagh;
      default: n3400_o = flagh;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3401_o = flagn;
      21'b010000000000000000000: n3401_o = flagn;
      21'b001000000000000000000: n3401_o = flagn;
      21'b000100000000000000000: n3401_o = flagn;
      21'b000010000000000000000: n3401_o = flagn;
      21'b000001000000000000000: n3401_o = n3320_o;
      21'b000000100000000000000: n3401_o = n3266_o;
      21'b000000010000000000000: n3401_o = n3236_o;
      21'b000000001000000000000: n3401_o = n3180_o;
      21'b000000000100000000000: n3401_o = n3144_o;
      21'b000000000010000000000: n3401_o = n3114_o;
      21'b000000000001000000000: n3401_o = n3086_o;
      21'b000000000000100000000: n3401_o = n3057_o;
      21'b000000000000010000000: n3401_o = n3014_o;
      21'b000000000000001000000: n3401_o = n2972_o;
      21'b000000000000000100000: n3401_o = n2923_o;
      21'b000000000000000010000: n3401_o = n2881_o;
      21'b000000000000000001000: n3401_o = flagn;
      21'b000000000000000000100: n3401_o = flagn;
      21'b000000000000000000010: n3401_o = flagn;
      21'b000000000000000000001: n3401_o = flagn;
      default: n3401_o = flagn;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3402_o = flagz;
      21'b010000000000000000000: n3402_o = flagz;
      21'b001000000000000000000: n3402_o = flagz;
      21'b000100000000000000000: n3402_o = flagz;
      21'b000010000000000000000: n3402_o = flagz;
      21'b000001000000000000000: n3402_o = n3325_o;
      21'b000000100000000000000: n3402_o = n3271_o;
      21'b000000010000000000000: n3402_o = n3241_o;
      21'b000000001000000000000: n3402_o = n3185_o;
      21'b000000000100000000000: n3402_o = n3149_o;
      21'b000000000010000000000: n3402_o = n3119_o;
      21'b000000000001000000000: n3402_o = n3091_o;
      21'b000000000000100000000: n3402_o = n3062_o;
      21'b000000000000010000000: n3402_o = n3019_o;
      21'b000000000000001000000: n3402_o = n2977_o;
      21'b000000000000000100000: n3402_o = n2928_o;
      21'b000000000000000010000: n3402_o = n2886_o;
      21'b000000000000000001000: n3402_o = flagz;
      21'b000000000000000000100: n3402_o = flagz;
      21'b000000000000000000010: n3402_o = flagz;
      21'b000000000000000000001: n3402_o = flagz;
      default: n3402_o = flagz;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3403_o = flagc;
      21'b010000000000000000000: n3403_o = flagc;
      21'b001000000000000000000: n3403_o = flagc;
      21'b000100000000000000000: n3403_o = flagc;
      21'b000010000000000000000: n3403_o = flagc;
      21'b000001000000000000000: n3403_o = flagc;
      21'b000000100000000000000: n3403_o = n3297_o;
      21'b000000010000000000000: n3403_o = flagc;
      21'b000000001000000000000: n3403_o = n3211_o;
      21'b000000000100000000000: n3403_o = flagc;
      21'b000000000010000000000: n3403_o = flagc;
      21'b000000000001000000000: n3403_o = flagc;
      21'b000000000000100000000: n3403_o = flagc;
      21'b000000000000010000000: n3403_o = n3032_o;
      21'b000000000000001000000: n3403_o = n2990_o;
      21'b000000000000000100000: n3403_o = n2941_o;
      21'b000000000000000010000: n3403_o = n2899_o;
      21'b000000000000000001000: n3403_o = flagc;
      21'b000000000000000000100: n3403_o = flagc;
      21'b000000000000000000010: n3403_o = flagc;
      21'b000000000000000000001: n3403_o = flagc;
      default: n3403_o = flagc;
    endcase
  assign n3404_o = help[0];
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3405_o = n3404_o;
      21'b010000000000000000000: n3405_o = n3404_o;
      21'b001000000000000000000: n3405_o = n3404_o;
      21'b000100000000000000000: n3405_o = n3404_o;
      21'b000010000000000000000: n3405_o = n3404_o;
      21'b000001000000000000000: n3405_o = n3404_o;
      21'b000000100000000000000: n3405_o = n3404_o;
      21'b000000010000000000000: n3405_o = n3404_o;
      21'b000000001000000000000: n3405_o = n3404_o;
      21'b000000000100000000000: n3405_o = n3404_o;
      21'b000000000010000000000: n3405_o = n3404_o;
      21'b000000000001000000000: n3405_o = n3404_o;
      21'b000000000000100000000: n3405_o = n3404_o;
      21'b000000000000010000000: n3405_o = n3404_o;
      21'b000000000000001000000: n3405_o = n3404_o;
      21'b000000000000000100000: n3405_o = n3404_o;
      21'b000000000000000010000: n3405_o = n3404_o;
      21'b000000000000000001000: n3405_o = flagc;
      21'b000000000000000000100: n3405_o = n3404_o;
      21'b000000000000000000010: n3405_o = n3404_o;
      21'b000000000000000000001: n3405_o = n3404_o;
      default: n3405_o = n3404_o;
    endcase
  assign n3406_o = help[1];
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3407_o = n3406_o;
      21'b010000000000000000000: n3407_o = n3406_o;
      21'b001000000000000000000: n3407_o = n3406_o;
      21'b000100000000000000000: n3407_o = n3406_o;
      21'b000010000000000000000: n3407_o = n3406_o;
      21'b000001000000000000000: n3407_o = n3406_o;
      21'b000000100000000000000: n3407_o = n3406_o;
      21'b000000010000000000000: n3407_o = n3406_o;
      21'b000000001000000000000: n3407_o = n3406_o;
      21'b000000000100000000000: n3407_o = n3406_o;
      21'b000000000010000000000: n3407_o = n3406_o;
      21'b000000000001000000000: n3407_o = n3406_o;
      21'b000000000000100000000: n3407_o = n3406_o;
      21'b000000000000010000000: n3407_o = n3406_o;
      21'b000000000000001000000: n3407_o = n3406_o;
      21'b000000000000000100000: n3407_o = n3406_o;
      21'b000000000000000010000: n3407_o = n3406_o;
      21'b000000000000000001000: n3407_o = flagz;
      21'b000000000000000000100: n3407_o = n3406_o;
      21'b000000000000000000010: n3407_o = n3406_o;
      21'b000000000000000000001: n3407_o = n3406_o;
      default: n3407_o = n3406_o;
    endcase
  assign n3408_o = help[2];
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3409_o = n3408_o;
      21'b010000000000000000000: n3409_o = n3408_o;
      21'b001000000000000000000: n3409_o = n3408_o;
      21'b000100000000000000000: n3409_o = n3408_o;
      21'b000010000000000000000: n3409_o = n3408_o;
      21'b000001000000000000000: n3409_o = n3408_o;
      21'b000000100000000000000: n3409_o = n3408_o;
      21'b000000010000000000000: n3409_o = n3408_o;
      21'b000000001000000000000: n3409_o = n3408_o;
      21'b000000000100000000000: n3409_o = n3408_o;
      21'b000000000010000000000: n3409_o = n3408_o;
      21'b000000000001000000000: n3409_o = n3408_o;
      21'b000000000000100000000: n3409_o = n3408_o;
      21'b000000000000010000000: n3409_o = n3408_o;
      21'b000000000000001000000: n3409_o = n3408_o;
      21'b000000000000000100000: n3409_o = n3408_o;
      21'b000000000000000010000: n3409_o = n3408_o;
      21'b000000000000000001000: n3409_o = flagn;
      21'b000000000000000000100: n3409_o = n3408_o;
      21'b000000000000000000010: n3409_o = n3408_o;
      21'b000000000000000000001: n3409_o = n3408_o;
      default: n3409_o = n3408_o;
    endcase
  assign n3410_o = help[3];
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3411_o = n3410_o;
      21'b010000000000000000000: n3411_o = n3410_o;
      21'b001000000000000000000: n3411_o = n3410_o;
      21'b000100000000000000000: n3411_o = n3410_o;
      21'b000010000000000000000: n3411_o = n3410_o;
      21'b000001000000000000000: n3411_o = n3410_o;
      21'b000000100000000000000: n3411_o = n3410_o;
      21'b000000010000000000000: n3411_o = n3410_o;
      21'b000000001000000000000: n3411_o = n3410_o;
      21'b000000000100000000000: n3411_o = n3410_o;
      21'b000000000010000000000: n3411_o = n3410_o;
      21'b000000000001000000000: n3411_o = n3410_o;
      21'b000000000000100000000: n3411_o = n3410_o;
      21'b000000000000010000000: n3411_o = n3410_o;
      21'b000000000000001000000: n3411_o = n3410_o;
      21'b000000000000000100000: n3411_o = n3410_o;
      21'b000000000000000010000: n3411_o = n3410_o;
      21'b000000000000000001000: n3411_o = flagi;
      21'b000000000000000000100: n3411_o = n3410_o;
      21'b000000000000000000010: n3411_o = n3410_o;
      21'b000000000000000000001: n3411_o = n3410_o;
      default: n3411_o = n3410_o;
    endcase
  assign n3412_o = help[4];
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3413_o = n3412_o;
      21'b010000000000000000000: n3413_o = n3412_o;
      21'b001000000000000000000: n3413_o = n3412_o;
      21'b000100000000000000000: n3413_o = n3412_o;
      21'b000010000000000000000: n3413_o = n3412_o;
      21'b000001000000000000000: n3413_o = n3412_o;
      21'b000000100000000000000: n3413_o = n3412_o;
      21'b000000010000000000000: n3413_o = n3412_o;
      21'b000000001000000000000: n3413_o = n3412_o;
      21'b000000000100000000000: n3413_o = n3412_o;
      21'b000000000010000000000: n3413_o = n3412_o;
      21'b000000000001000000000: n3413_o = n3412_o;
      21'b000000000000100000000: n3413_o = n3412_o;
      21'b000000000000010000000: n3413_o = n3412_o;
      21'b000000000000001000000: n3413_o = n3412_o;
      21'b000000000000000100000: n3413_o = n3412_o;
      21'b000000000000000010000: n3413_o = n3412_o;
      21'b000000000000000001000: n3413_o = flagh;
      21'b000000000000000000100: n3413_o = n3412_o;
      21'b000000000000000000010: n3413_o = n3412_o;
      21'b000000000000000000001: n3413_o = n3412_o;
      default: n3413_o = n3412_o;
    endcase
  assign n3414_o = help[5];
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3415_o = n3414_o;
      21'b010000000000000000000: n3415_o = n3414_o;
      21'b001000000000000000000: n3415_o = n3414_o;
      21'b000100000000000000000: n3415_o = n3414_o;
      21'b000010000000000000000: n3415_o = n3414_o;
      21'b000001000000000000000: n3415_o = n3414_o;
      21'b000000100000000000000: n3415_o = n3414_o;
      21'b000000010000000000000: n3415_o = n3414_o;
      21'b000000001000000000000: n3415_o = n3414_o;
      21'b000000000100000000000: n3415_o = n3414_o;
      21'b000000000010000000000: n3415_o = n3414_o;
      21'b000000000001000000000: n3415_o = n3414_o;
      21'b000000000000100000000: n3415_o = n3414_o;
      21'b000000000000010000000: n3415_o = n3414_o;
      21'b000000000000001000000: n3415_o = n3414_o;
      21'b000000000000000100000: n3415_o = n3414_o;
      21'b000000000000000010000: n3415_o = n3414_o;
      21'b000000000000000001000: n3415_o = 1'b1;
      21'b000000000000000000100: n3415_o = n3414_o;
      21'b000000000000000000010: n3415_o = n3414_o;
      21'b000000000000000000001: n3415_o = n3414_o;
      default: n3415_o = n3414_o;
    endcase
  assign n3416_o = help[6];
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3417_o = n3416_o;
      21'b010000000000000000000: n3417_o = n3416_o;
      21'b001000000000000000000: n3417_o = n3416_o;
      21'b000100000000000000000: n3417_o = n3416_o;
      21'b000010000000000000000: n3417_o = n3416_o;
      21'b000001000000000000000: n3417_o = n3416_o;
      21'b000000100000000000000: n3417_o = n3416_o;
      21'b000000010000000000000: n3417_o = n3416_o;
      21'b000000001000000000000: n3417_o = n3416_o;
      21'b000000000100000000000: n3417_o = n3416_o;
      21'b000000000010000000000: n3417_o = n3416_o;
      21'b000000000001000000000: n3417_o = n3416_o;
      21'b000000000000100000000: n3417_o = n3416_o;
      21'b000000000000010000000: n3417_o = n3416_o;
      21'b000000000000001000000: n3417_o = n3416_o;
      21'b000000000000000100000: n3417_o = n3416_o;
      21'b000000000000000010000: n3417_o = n3416_o;
      21'b000000000000000001000: n3417_o = 1'b1;
      21'b000000000000000000100: n3417_o = n3416_o;
      21'b000000000000000000010: n3417_o = n3416_o;
      21'b000000000000000000001: n3417_o = n3416_o;
      default: n3417_o = n3416_o;
    endcase
  assign n3418_o = help[7];
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3419_o = n3418_o;
      21'b010000000000000000000: n3419_o = n3418_o;
      21'b001000000000000000000: n3419_o = n3418_o;
      21'b000100000000000000000: n3419_o = n3418_o;
      21'b000010000000000000000: n3419_o = n3418_o;
      21'b000001000000000000000: n3419_o = n3418_o;
      21'b000000100000000000000: n3419_o = n3418_o;
      21'b000000010000000000000: n3419_o = n3418_o;
      21'b000000001000000000000: n3419_o = n3418_o;
      21'b000000000100000000000: n3419_o = n3418_o;
      21'b000000000010000000000: n3419_o = n3418_o;
      21'b000000000001000000000: n3419_o = n3418_o;
      21'b000000000000100000000: n3419_o = n3418_o;
      21'b000000000000010000000: n3419_o = n3418_o;
      21'b000000000000001000000: n3419_o = n3418_o;
      21'b000000000000000100000: n3419_o = n3418_o;
      21'b000000000000000010000: n3419_o = n3418_o;
      21'b000000000000000001000: n3419_o = 1'b1;
      21'b000000000000000000100: n3419_o = n3418_o;
      21'b000000000000000000010: n3419_o = n3418_o;
      21'b000000000000000000001: n3419_o = n3418_o;
      default: n3419_o = n3418_o;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3442_o = 4'b0010;
      21'b010000000000000000000: n3442_o = 4'b0010;
      21'b001000000000000000000: n3442_o = 4'b0110;
      21'b000100000000000000000: n3442_o = 4'b0010;
      21'b000010000000000000000: n3442_o = 4'b0010;
      21'b000001000000000000000: n3442_o = 4'b0010;
      21'b000000100000000000000: n3442_o = 4'b0010;
      21'b000000010000000000000: n3442_o = 4'b0010;
      21'b000000001000000000000: n3442_o = 4'b0010;
      21'b000000000100000000000: n3442_o = 4'b0010;
      21'b000000000010000000000: n3442_o = 4'b0010;
      21'b000000000001000000000: n3442_o = 4'b0010;
      21'b000000000000100000000: n3442_o = 4'b0010;
      21'b000000000000010000000: n3442_o = 4'b0010;
      21'b000000000000001000000: n3442_o = 4'b0010;
      21'b000000000000000100000: n3442_o = 4'b0010;
      21'b000000000000000010000: n3442_o = 4'b0010;
      21'b000000000000000001000: n3442_o = 4'b0110;
      21'b000000000000000000100: n3442_o = 4'b0110;
      21'b000000000000000000010: n3442_o = 4'b0010;
      21'b000000000000000000001: n3442_o = 4'b0010;
      default: n3442_o = 4'b0000;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3461_o = 3'b000;
      21'b010000000000000000000: n3461_o = 3'b000;
      21'b001000000000000000000: n3461_o = addrmux;
      21'b000100000000000000000: n3461_o = 3'b000;
      21'b000010000000000000000: n3461_o = 3'b000;
      21'b000001000000000000000: n3461_o = 3'b000;
      21'b000000100000000000000: n3461_o = 3'b000;
      21'b000000010000000000000: n3461_o = 3'b000;
      21'b000000001000000000000: n3461_o = 3'b000;
      21'b000000000100000000000: n3461_o = 3'b000;
      21'b000000000010000000000: n3461_o = 3'b000;
      21'b000000000001000000000: n3461_o = 3'b000;
      21'b000000000000100000000: n3461_o = 3'b000;
      21'b000000000000010000000: n3461_o = 3'b000;
      21'b000000000000001000000: n3461_o = 3'b000;
      21'b000000000000000100000: n3461_o = 3'b000;
      21'b000000000000000010000: n3461_o = 3'b000;
      21'b000000000000000001000: n3461_o = addrmux;
      21'b000000000000000000100: n3461_o = addrmux;
      21'b000000000000000000010: n3461_o = 3'b000;
      21'b000000000000000000001: n3461_o = 3'b000;
      default: n3461_o = addrmux;
    endcase
  /* 6805.vhd:1239:13  */
  always @*
    case (n3389_o)
      21'b100000000000000000000: n3464_o = datamux;
      21'b010000000000000000000: n3464_o = datamux;
      21'b001000000000000000000: n3464_o = 4'b0110;
      21'b000100000000000000000: n3464_o = datamux;
      21'b000010000000000000000: n3464_o = datamux;
      21'b000001000000000000000: n3464_o = datamux;
      21'b000000100000000000000: n3464_o = datamux;
      21'b000000010000000000000: n3464_o = datamux;
      21'b000000001000000000000: n3464_o = datamux;
      21'b000000000100000000000: n3464_o = datamux;
      21'b000000000010000000000: n3464_o = datamux;
      21'b000000000001000000000: n3464_o = datamux;
      21'b000000000000100000000: n3464_o = datamux;
      21'b000000000000010000000: n3464_o = datamux;
      21'b000000000000001000000: n3464_o = datamux;
      21'b000000000000000100000: n3464_o = datamux;
      21'b000000000000000010000: n3464_o = datamux;
      21'b000000000000000001000: n3464_o = 4'b0010;
      21'b000000000000000000100: n3464_o = datamux;
      21'b000000000000000000010: n3464_o = datamux;
      21'b000000000000000000001: n3464_o = datamux;
      default: n3464_o = datamux;
    endcase
  /* 6805.vhd:1238:11  */
  assign n3467_o = mainfsm == 4'b0101;
  /* 6805.vhd:1511:32  */
  assign n3469_o = regsp + 16'b0000000000000001;
  /* 6805.vhd:1509:15  */
  assign n3471_o = opcode == 8'b10000000;
  /* 6805.vhd:1509:26  */
  assign n3473_o = opcode == 8'b10000010;
  /* 6805.vhd:1509:26  */
  assign n3474_o = n3471_o | n3473_o;
  /* 6805.vhd:1514:32  */
  assign n3476_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1513:15  */
  assign n3478_o = opcode == 8'b10000011;
  /* 6805.vhd:1520:32  */
  assign n3480_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1517:15  */
  assign n3482_o = opcode == 8'b11001101;
  /* 6805.vhd:1526:32  */
  assign n3484_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1527:40  */
  assign n3486_o = {8'b00000000, regx};
  /* 6805.vhd:1527:31  */
  assign n3487_o = temp + n3486_o;
  /* 6805.vhd:1523:15  */
  assign n3489_o = opcode == 8'b11011101;
  assign n3490_o = {n3489_o, n3482_o, n3478_o, n3474_o};
  /* 6805.vhd:1508:13  */
  always @*
    case (n3490_o)
      4'b1000: n3493_o = 1'b1;
      4'b0100: n3493_o = 1'b1;
      4'b0010: n3493_o = n3854_q;
      4'b0001: n3493_o = n3854_q;
      default: n3493_o = n3854_q;
    endcase
  /* 6805.vhd:1508:13  */
  always @*
    case (n3490_o)
      4'b1000: n3494_o = n3484_o;
      4'b0100: n3494_o = n3480_o;
      4'b0010: n3494_o = n3476_o;
      4'b0001: n3494_o = n3469_o;
      default: n3494_o = regsp;
    endcase
  assign n3495_o = temp[7:0];
  assign n3496_o = n3487_o[7:0];
  assign n3497_o = regpc[7:0];
  /* 6805.vhd:1508:13  */
  always @*
    case (n3490_o)
      4'b1000: n3498_o = n3496_o;
      4'b0100: n3498_o = n3495_o;
      4'b0010: n3498_o = n3497_o;
      4'b0001: n3498_o = n3497_o;
      default: n3498_o = n3497_o;
    endcase
  assign n3499_o = temp[15:8];
  assign n3500_o = n3487_o[15:8];
  assign n3501_o = regpc[15:8];
  /* 6805.vhd:1508:13  */
  always @*
    case (n3490_o)
      4'b1000: n3502_o = n3500_o;
      4'b0100: n3502_o = n3499_o;
      4'b0010: n3502_o = n3501_o;
      4'b0001: n3502_o = datain;
      default: n3502_o = n3501_o;
    endcase
  /* 6805.vhd:1508:13  */
  always @*
    case (n3490_o)
      4'b1000: n3508_o = 4'b0010;
      4'b0100: n3508_o = 4'b0010;
      4'b0010: n3508_o = 4'b0111;
      4'b0001: n3508_o = 4'b0111;
      default: n3508_o = 4'b0000;
    endcase
  /* 6805.vhd:1508:13  */
  always @*
    case (n3490_o)
      4'b1000: n3511_o = 3'b000;
      4'b0100: n3511_o = 3'b000;
      4'b0010: n3511_o = addrmux;
      4'b0001: n3511_o = addrmux;
      default: n3511_o = addrmux;
    endcase
  /* 6805.vhd:1508:13  */
  always @*
    case (n3490_o)
      4'b1000: n3513_o = datamux;
      4'b0100: n3513_o = datamux;
      4'b0010: n3513_o = 4'b0000;
      4'b0001: n3513_o = datamux;
      default: n3513_o = datamux;
    endcase
  /* 6805.vhd:1507:11  */
  assign n3515_o = mainfsm == 4'b0110;
  /* 6805.vhd:1536:15  */
  assign n3517_o = opcode == 8'b10000000;
  /* 6805.vhd:1536:26  */
  assign n3519_o = opcode == 8'b10000010;
  /* 6805.vhd:1536:26  */
  assign n3520_o = n3517_o | n3519_o;
  /* 6805.vhd:1541:34  */
  assign n3522_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1544:26  */
  assign n3523_o = ~trace;
  /* 6805.vhd:1551:19  */
  assign n3526_o = sciirqrequest ? 16'b0001111111110110 : 16'b0001111111111100;
  /* 6805.vhd:1551:19  */
  assign n3528_o = sciirqrequest ? 1'b0 : n116_o;
  /* 6805.vhd:1548:19  */
  assign n3530_o = timerirqrequest ? 16'b0001111111111000 : n3526_o;
  /* 6805.vhd:1548:19  */
  assign n3532_o = timerirqrequest ? 1'b0 : n111_o;
  /* 6805.vhd:1548:19  */
  assign n3533_o = timerirqrequest ? n116_o : n3528_o;
  /* 6805.vhd:1545:19  */
  assign n3535_o = extirqrequest ? 16'b0001111111111010 : n3530_o;
  /* 6805.vhd:1544:17  */
  assign n3537_o = n3545_o ? 1'b0 : n106_o;
  /* 6805.vhd:1545:19  */
  assign n3538_o = extirqrequest ? n111_o : n3532_o;
  /* 6805.vhd:1545:19  */
  assign n3539_o = extirqrequest ? n116_o : n3533_o;
  /* 6805.vhd:1544:17  */
  assign n3541_o = n3523_o ? n3535_o : 16'b0001111111111000;
  /* 6805.vhd:1544:17  */
  assign n3544_o = n3523_o ? 4'b1000 : 4'b1011;
  /* 6805.vhd:1544:17  */
  assign n3545_o = extirqrequest & n3523_o;
  /* 6805.vhd:1544:17  */
  assign n3546_o = n3523_o ? n3538_o : n111_o;
  /* 6805.vhd:1544:17  */
  assign n3547_o = n3523_o ? n3539_o : n116_o;
  /* 6805.vhd:1540:15  */
  assign n3549_o = opcode == 8'b10000011;
  assign n3550_o = {n3549_o, n3520_o};
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3551_o = n3522_o;
      2'b01: n3551_o = regsp;
      default: n3551_o = regsp;
    endcase
  assign n3552_o = regpc[7:0];
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3553_o = n3552_o;
      2'b01: n3553_o = datain;
      default: n3553_o = n3552_o;
    endcase
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3555_o = 1'b1;
      2'b01: n3555_o = flagi;
      default: n3555_o = flagi;
    endcase
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3556_o = n3541_o;
      2'b01: n3556_o = temp;
      default: n3556_o = temp;
    endcase
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3559_o = n3544_o;
      2'b01: n3559_o = 4'b0010;
      default: n3559_o = 4'b0000;
    endcase
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3561_o = addrmux;
      2'b01: n3561_o = 3'b000;
      default: n3561_o = addrmux;
    endcase
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3563_o = 4'b1001;
      2'b01: n3563_o = datamux;
      default: n3563_o = datamux;
    endcase
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3564_o = n3537_o;
      2'b01: n3564_o = n106_o;
      default: n3564_o = n106_o;
    endcase
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3565_o = n3546_o;
      2'b01: n3565_o = n111_o;
      default: n3565_o = n111_o;
    endcase
  /* 6805.vhd:1535:13  */
  always @*
    case (n3550_o)
      2'b10: n3566_o = n3547_o;
      2'b01: n3566_o = n116_o;
      default: n3566_o = n116_o;
    endcase
  /* 6805.vhd:1534:11  */
  assign n3568_o = mainfsm == 4'b0111;
  /* 6805.vhd:1572:34  */
  assign n3570_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1569:15  */
  assign n3572_o = opcode == 8'b10000011;
  /* 6805.vhd:1568:13  */
  always @*
    case (n3572_o)
      1'b1: n3574_o = 1'b1;
      default: n3574_o = n3854_q;
    endcase
  /* 6805.vhd:1568:13  */
  always @*
    case (n3572_o)
      1'b1: n3575_o = n3570_o;
      default: n3575_o = regsp;
    endcase
  /* 6805.vhd:1568:13  */
  always @*
    case (n3572_o)
      1'b1: n3578_o = 4'b1001;
      default: n3578_o = 4'b0000;
    endcase
  /* 6805.vhd:1568:13  */
  always @*
    case (n3572_o)
      1'b1: n3580_o = 3'b011;
      default: n3580_o = addrmux;
    endcase
  /* 6805.vhd:1567:11  */
  assign n3582_o = mainfsm == 4'b1000;
  /* 6805.vhd:1582:30  */
  assign n3584_o = temp + 16'b0000000000000001;
  /* 6805.vhd:1580:15  */
  assign n3586_o = opcode == 8'b10000011;
  assign n3587_o = regpc[15:8];
  /* 6805.vhd:1579:13  */
  always @*
    case (n3586_o)
      1'b1: n3588_o = datain;
      default: n3588_o = n3587_o;
    endcase
  /* 6805.vhd:1579:13  */
  always @*
    case (n3586_o)
      1'b1: n3589_o = n3584_o;
      default: n3589_o = temp;
    endcase
  /* 6805.vhd:1579:13  */
  always @*
    case (n3586_o)
      1'b1: n3592_o = 4'b1010;
      default: n3592_o = 4'b0000;
    endcase
  /* 6805.vhd:1578:11  */
  assign n3594_o = mainfsm == 4'b1001;
  /* 6805.vhd:1590:15  */
  assign n3596_o = opcode == 8'b10000011;
  assign n3597_o = regpc[7:0];
  /* 6805.vhd:1589:13  */
  always @*
    case (n3596_o)
      1'b1: n3598_o = datain;
      default: n3598_o = n3597_o;
    endcase
  /* 6805.vhd:1589:13  */
  always @*
    case (n3596_o)
      1'b1: n3601_o = 4'b0010;
      default: n3601_o = 4'b0000;
    endcase
  /* 6805.vhd:1589:13  */
  always @*
    case (n3596_o)
      1'b1: n3603_o = 3'b000;
      default: n3603_o = addrmux;
    endcase
  /* 6805.vhd:1588:11  */
  assign n3605_o = mainfsm == 4'b1010;
  /* 6805.vhd:1599:30  */
  assign n3607_o = regsp - 16'b0000000000000001;
  /* 6805.vhd:1598:11  */
  assign n3609_o = mainfsm == 4'b1011;
  assign n3610_o = {n3609_o, n3605_o, n3594_o, n3582_o, n3568_o, n3515_o, n3467_o, n2641_o, n1969_o, n1320_o, n122_o, n120_o};
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3611_o = n3854_q;
      12'b010000000000: n3611_o = n3854_q;
      12'b001000000000: n3611_o = n3854_q;
      12'b000100000000: n3611_o = n3574_o;
      12'b000010000000: n3611_o = n3854_q;
      12'b000001000000: n3611_o = n3493_o;
      12'b000000100000: n3611_o = n3395_o;
      12'b000000010000: n3611_o = n2538_o;
      12'b000000001000: n3611_o = n1869_o;
      12'b000000000100: n3611_o = n1297_o;
      12'b000000000010: n3611_o = n3854_q;
      12'b000000000001: n3611_o = n3854_q;
      default: n3611_o = n3854_q;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3612_o = rega;
      12'b010000000000: n3612_o = rega;
      12'b001000000000: n3612_o = rega;
      12'b000100000000: n3612_o = rega;
      12'b000010000000: n3612_o = rega;
      12'b000001000000: n3612_o = rega;
      12'b000000100000: n3612_o = n3396_o;
      12'b000000010000: n3612_o = n2539_o;
      12'b000000001000: n3612_o = rega;
      12'b000000000100: n3612_o = n1298_o;
      12'b000000000010: n3612_o = rega;
      12'b000000000001: n3612_o = rega;
      default: n3612_o = rega;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3613_o = regx;
      12'b010000000000: n3613_o = regx;
      12'b001000000000: n3613_o = regx;
      12'b000100000000: n3613_o = regx;
      12'b000010000000: n3613_o = regx;
      12'b000001000000: n3613_o = regx;
      12'b000000100000: n3613_o = n3397_o;
      12'b000000010000: n3613_o = regx;
      12'b000000001000: n3613_o = regx;
      12'b000000000100: n3613_o = n1299_o;
      12'b000000000010: n3613_o = regx;
      12'b000000000001: n3613_o = regx;
      default: n3613_o = regx;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3614_o = n3607_o;
      12'b010000000000: n3614_o = regsp;
      12'b001000000000: n3614_o = regsp;
      12'b000100000000: n3614_o = n3575_o;
      12'b000010000000: n3614_o = n3551_o;
      12'b000001000000: n3614_o = n3494_o;
      12'b000000100000: n3614_o = n3398_o;
      12'b000000010000: n3614_o = n2540_o;
      12'b000000001000: n3614_o = n1870_o;
      12'b000000000100: n3614_o = n1300_o;
      12'b000000000010: n3614_o = regsp;
      12'b000000000001: n3614_o = regsp;
      default: n3614_o = regsp;
    endcase
  assign n3615_o = n1301_o[7:0];
  assign n3616_o = n3399_o[7:0];
  assign n3617_o = regpc[7:0];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3618_o = n3617_o;
      12'b010000000000: n3618_o = n3598_o;
      12'b001000000000: n3618_o = n3617_o;
      12'b000100000000: n3618_o = n3617_o;
      12'b000010000000: n3618_o = n3553_o;
      12'b000001000000: n3618_o = n3498_o;
      12'b000000100000: n3618_o = n3616_o;
      12'b000000010000: n3618_o = n2553_o;
      12'b000000001000: n3618_o = n1891_o;
      12'b000000000100: n3618_o = n3615_o;
      12'b000000000010: n3618_o = datain;
      12'b000000000001: n3618_o = n3617_o;
      default: n3618_o = n3617_o;
    endcase
  assign n3619_o = n1301_o[15:8];
  assign n3620_o = n3399_o[15:8];
  assign n3621_o = regpc[15:8];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3622_o = n3621_o;
      12'b010000000000: n3622_o = n3621_o;
      12'b001000000000: n3622_o = n3588_o;
      12'b000100000000: n3622_o = n3621_o;
      12'b000010000000: n3622_o = n3621_o;
      12'b000001000000: n3622_o = n3502_o;
      12'b000000100000: n3622_o = n3620_o;
      12'b000000010000: n3622_o = n2566_o;
      12'b000000001000: n3622_o = n1912_o;
      12'b000000000100: n3622_o = n3619_o;
      12'b000000000010: n3622_o = n3621_o;
      12'b000000000001: n3622_o = datain;
      default: n3622_o = n3621_o;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3623_o = flagh;
      12'b010000000000: n3623_o = flagh;
      12'b001000000000: n3623_o = flagh;
      12'b000100000000: n3623_o = flagh;
      12'b000010000000: n3623_o = flagh;
      12'b000001000000: n3623_o = flagh;
      12'b000000100000: n3623_o = n3400_o;
      12'b000000010000: n3623_o = flagh;
      12'b000000001000: n3623_o = n1913_o;
      12'b000000000100: n3623_o = n1302_o;
      12'b000000000010: n3623_o = flagh;
      12'b000000000001: n3623_o = flagh;
      default: n3623_o = flagh;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3624_o = flagi;
      12'b010000000000: n3624_o = flagi;
      12'b001000000000: n3624_o = flagi;
      12'b000100000000: n3624_o = flagi;
      12'b000010000000: n3624_o = n3555_o;
      12'b000001000000: n3624_o = flagi;
      12'b000000100000: n3624_o = flagi;
      12'b000000010000: n3624_o = flagi;
      12'b000000001000: n3624_o = n1914_o;
      12'b000000000100: n3624_o = n1303_o;
      12'b000000000010: n3624_o = flagi;
      12'b000000000001: n3624_o = flagi;
      default: n3624_o = flagi;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3625_o = flagn;
      12'b010000000000: n3625_o = flagn;
      12'b001000000000: n3625_o = flagn;
      12'b000100000000: n3625_o = flagn;
      12'b000010000000: n3625_o = flagn;
      12'b000001000000: n3625_o = flagn;
      12'b000000100000: n3625_o = n3401_o;
      12'b000000010000: n3625_o = n2568_o;
      12'b000000001000: n3625_o = n1916_o;
      12'b000000000100: n3625_o = n1304_o;
      12'b000000000010: n3625_o = flagn;
      12'b000000000001: n3625_o = flagn;
      default: n3625_o = flagn;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3626_o = flagz;
      12'b010000000000: n3626_o = flagz;
      12'b001000000000: n3626_o = flagz;
      12'b000100000000: n3626_o = flagz;
      12'b000010000000: n3626_o = flagz;
      12'b000001000000: n3626_o = flagz;
      12'b000000100000: n3626_o = n3402_o;
      12'b000000010000: n3626_o = n2569_o;
      12'b000000001000: n3626_o = n1918_o;
      12'b000000000100: n3626_o = n1305_o;
      12'b000000000010: n3626_o = flagz;
      12'b000000000001: n3626_o = flagz;
      default: n3626_o = flagz;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3627_o = flagc;
      12'b010000000000: n3627_o = flagc;
      12'b001000000000: n3627_o = flagc;
      12'b000100000000: n3627_o = flagc;
      12'b000010000000: n3627_o = flagc;
      12'b000001000000: n3627_o = flagc;
      12'b000000100000: n3627_o = n3403_o;
      12'b000000010000: n3627_o = n2571_o;
      12'b000000001000: n3627_o = n1919_o;
      12'b000000000100: n3627_o = n1306_o;
      12'b000000000010: n3627_o = flagc;
      12'b000000000001: n3627_o = flagc;
      default: n3627_o = flagc;
    endcase
  assign n3628_o = n1307_o[0];
  assign n3629_o = n1921_o[0];
  assign n3630_o = n2572_o[0];
  assign n3631_o = help[0];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3632_o = n3631_o;
      12'b010000000000: n3632_o = n3631_o;
      12'b001000000000: n3632_o = n3631_o;
      12'b000100000000: n3632_o = n3631_o;
      12'b000010000000: n3632_o = n3631_o;
      12'b000001000000: n3632_o = n3631_o;
      12'b000000100000: n3632_o = n3405_o;
      12'b000000010000: n3632_o = n3630_o;
      12'b000000001000: n3632_o = n3629_o;
      12'b000000000100: n3632_o = n3628_o;
      12'b000000000010: n3632_o = n3631_o;
      12'b000000000001: n3632_o = n3631_o;
      default: n3632_o = n3631_o;
    endcase
  assign n3633_o = n1307_o[1];
  assign n3634_o = n1921_o[1];
  assign n3635_o = n2572_o[1];
  assign n3636_o = help[1];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3637_o = n3636_o;
      12'b010000000000: n3637_o = n3636_o;
      12'b001000000000: n3637_o = n3636_o;
      12'b000100000000: n3637_o = n3636_o;
      12'b000010000000: n3637_o = n3636_o;
      12'b000001000000: n3637_o = n3636_o;
      12'b000000100000: n3637_o = n3407_o;
      12'b000000010000: n3637_o = n3635_o;
      12'b000000001000: n3637_o = n3634_o;
      12'b000000000100: n3637_o = n3633_o;
      12'b000000000010: n3637_o = n3636_o;
      12'b000000000001: n3637_o = n3636_o;
      default: n3637_o = n3636_o;
    endcase
  assign n3638_o = n1307_o[2];
  assign n3639_o = n1921_o[2];
  assign n3640_o = n2572_o[2];
  assign n3641_o = help[2];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3642_o = n3641_o;
      12'b010000000000: n3642_o = n3641_o;
      12'b001000000000: n3642_o = n3641_o;
      12'b000100000000: n3642_o = n3641_o;
      12'b000010000000: n3642_o = n3641_o;
      12'b000001000000: n3642_o = n3641_o;
      12'b000000100000: n3642_o = n3409_o;
      12'b000000010000: n3642_o = n3640_o;
      12'b000000001000: n3642_o = n3639_o;
      12'b000000000100: n3642_o = n3638_o;
      12'b000000000010: n3642_o = n3641_o;
      12'b000000000001: n3642_o = n3641_o;
      default: n3642_o = n3641_o;
    endcase
  assign n3643_o = n1307_o[3];
  assign n3644_o = n1921_o[3];
  assign n3645_o = n2572_o[3];
  assign n3646_o = help[3];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3647_o = n3646_o;
      12'b010000000000: n3647_o = n3646_o;
      12'b001000000000: n3647_o = n3646_o;
      12'b000100000000: n3647_o = n3646_o;
      12'b000010000000: n3647_o = n3646_o;
      12'b000001000000: n3647_o = n3646_o;
      12'b000000100000: n3647_o = n3411_o;
      12'b000000010000: n3647_o = n3645_o;
      12'b000000001000: n3647_o = n3644_o;
      12'b000000000100: n3647_o = n3643_o;
      12'b000000000010: n3647_o = n3646_o;
      12'b000000000001: n3647_o = n3646_o;
      default: n3647_o = n3646_o;
    endcase
  assign n3648_o = n1307_o[4];
  assign n3649_o = n1921_o[4];
  assign n3650_o = n2572_o[4];
  assign n3651_o = help[4];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3652_o = n3651_o;
      12'b010000000000: n3652_o = n3651_o;
      12'b001000000000: n3652_o = n3651_o;
      12'b000100000000: n3652_o = n3651_o;
      12'b000010000000: n3652_o = n3651_o;
      12'b000001000000: n3652_o = n3651_o;
      12'b000000100000: n3652_o = n3413_o;
      12'b000000010000: n3652_o = n3650_o;
      12'b000000001000: n3652_o = n3649_o;
      12'b000000000100: n3652_o = n3648_o;
      12'b000000000010: n3652_o = n3651_o;
      12'b000000000001: n3652_o = n3651_o;
      default: n3652_o = n3651_o;
    endcase
  assign n3653_o = n1307_o[5];
  assign n3654_o = n1921_o[5];
  assign n3655_o = n2572_o[5];
  assign n3656_o = help[5];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3657_o = n3656_o;
      12'b010000000000: n3657_o = n3656_o;
      12'b001000000000: n3657_o = n3656_o;
      12'b000100000000: n3657_o = n3656_o;
      12'b000010000000: n3657_o = n3656_o;
      12'b000001000000: n3657_o = n3656_o;
      12'b000000100000: n3657_o = n3415_o;
      12'b000000010000: n3657_o = n3655_o;
      12'b000000001000: n3657_o = n3654_o;
      12'b000000000100: n3657_o = n3653_o;
      12'b000000000010: n3657_o = n3656_o;
      12'b000000000001: n3657_o = n3656_o;
      default: n3657_o = n3656_o;
    endcase
  assign n3658_o = n1307_o[6];
  assign n3659_o = n1921_o[6];
  assign n3660_o = n2572_o[6];
  assign n3661_o = help[6];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3662_o = n3661_o;
      12'b010000000000: n3662_o = n3661_o;
      12'b001000000000: n3662_o = n3661_o;
      12'b000100000000: n3662_o = n3661_o;
      12'b000010000000: n3662_o = n3661_o;
      12'b000001000000: n3662_o = n3661_o;
      12'b000000100000: n3662_o = n3417_o;
      12'b000000010000: n3662_o = n3660_o;
      12'b000000001000: n3662_o = n3659_o;
      12'b000000000100: n3662_o = n3658_o;
      12'b000000000010: n3662_o = n3661_o;
      12'b000000000001: n3662_o = n3661_o;
      default: n3662_o = n3661_o;
    endcase
  assign n3663_o = n1307_o[7];
  assign n3664_o = n1921_o[7];
  assign n3665_o = n2572_o[7];
  assign n3666_o = help[7];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3667_o = n3666_o;
      12'b010000000000: n3667_o = n3666_o;
      12'b001000000000: n3667_o = n3666_o;
      12'b000100000000: n3667_o = n3666_o;
      12'b000010000000: n3667_o = n3666_o;
      12'b000001000000: n3667_o = n3666_o;
      12'b000000100000: n3667_o = n3419_o;
      12'b000000010000: n3667_o = n3665_o;
      12'b000000001000: n3667_o = n3664_o;
      12'b000000000100: n3667_o = n3663_o;
      12'b000000000010: n3667_o = n3666_o;
      12'b000000000001: n3667_o = n3666_o;
      default: n3667_o = n3666_o;
    endcase
  assign n3668_o = n118_o[7:0];
  assign n3669_o = n1308_o[7:0];
  assign n3670_o = n3556_o[7:0];
  assign n3671_o = n3589_o[7:0];
  assign n3672_o = temp[7:0];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3673_o = n3672_o;
      12'b010000000000: n3673_o = n3672_o;
      12'b001000000000: n3673_o = n3671_o;
      12'b000100000000: n3673_o = n3672_o;
      12'b000010000000: n3673_o = n3670_o;
      12'b000001000000: n3673_o = n3672_o;
      12'b000000100000: n3673_o = n3672_o;
      12'b000000010000: n3673_o = n2574_o;
      12'b000000001000: n3673_o = n1924_o;
      12'b000000000100: n3673_o = n3669_o;
      12'b000000000010: n3673_o = n3672_o;
      12'b000000000001: n3673_o = n3668_o;
      default: n3673_o = n3672_o;
    endcase
  assign n3674_o = n118_o[15:8];
  assign n3675_o = n1308_o[15:8];
  assign n3676_o = n3556_o[15:8];
  assign n3677_o = n3589_o[15:8];
  assign n3678_o = temp[15:8];
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3679_o = n3678_o;
      12'b010000000000: n3679_o = n3678_o;
      12'b001000000000: n3679_o = n3677_o;
      12'b000100000000: n3679_o = n3678_o;
      12'b000010000000: n3679_o = n3676_o;
      12'b000001000000: n3679_o = n3678_o;
      12'b000000100000: n3679_o = n3678_o;
      12'b000000010000: n3679_o = n3678_o;
      12'b000000001000: n3679_o = n1927_o;
      12'b000000000100: n3679_o = n3675_o;
      12'b000000000010: n3679_o = n3678_o;
      12'b000000000001: n3679_o = n3674_o;
      default: n3679_o = n3678_o;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3684_o = 4'b1000;
      12'b010000000000: n3684_o = n3601_o;
      12'b001000000000: n3684_o = n3592_o;
      12'b000100000000: n3684_o = n3578_o;
      12'b000010000000: n3684_o = n3559_o;
      12'b000001000000: n3684_o = n3508_o;
      12'b000000100000: n3684_o = n3442_o;
      12'b000000010000: n3684_o = n2605_o;
      12'b000000001000: n3684_o = n1952_o;
      12'b000000000100: n3684_o = n1310_o;
      12'b000000000010: n3684_o = 4'b0010;
      12'b000000000001: n3684_o = 4'b0001;
      default: n3684_o = 4'b0000;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3686_o = addrmux;
      12'b010000000000: n3686_o = n3603_o;
      12'b001000000000: n3686_o = addrmux;
      12'b000100000000: n3686_o = n3580_o;
      12'b000010000000: n3686_o = n3561_o;
      12'b000001000000: n3686_o = n3511_o;
      12'b000000100000: n3686_o = n3461_o;
      12'b000000010000: n3686_o = n2617_o;
      12'b000000001000: n3686_o = n1961_o;
      12'b000000000100: n3686_o = n1312_o;
      12'b000000000010: n3686_o = 3'b000;
      12'b000000000001: n3686_o = addrmux;
      default: n3686_o = addrmux;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3688_o = 4'b1010;
      12'b010000000000: n3688_o = datamux;
      12'b001000000000: n3688_o = datamux;
      12'b000100000000: n3688_o = datamux;
      12'b000010000000: n3688_o = n3563_o;
      12'b000001000000: n3688_o = n3513_o;
      12'b000000100000: n3688_o = n3464_o;
      12'b000000010000: n3688_o = n2638_o;
      12'b000000001000: n3688_o = n1967_o;
      12'b000000000100: n3688_o = n1313_o;
      12'b000000000010: n3688_o = datamux;
      12'b000000000001: n3688_o = datamux;
      default: n3688_o = datamux;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3689_o = opcode;
      12'b010000000000: n3689_o = opcode;
      12'b001000000000: n3689_o = opcode;
      12'b000100000000: n3689_o = opcode;
      12'b000010000000: n3689_o = opcode;
      12'b000001000000: n3689_o = opcode;
      12'b000000100000: n3689_o = opcode;
      12'b000000010000: n3689_o = opcode;
      12'b000000001000: n3689_o = opcode;
      12'b000000000100: n3689_o = n1315_o;
      12'b000000000010: n3689_o = opcode;
      12'b000000000001: n3689_o = opcode;
      default: n3689_o = opcode;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3690_o = n106_o;
      12'b010000000000: n3690_o = n106_o;
      12'b001000000000: n3690_o = n106_o;
      12'b000100000000: n3690_o = n106_o;
      12'b000010000000: n3690_o = n3564_o;
      12'b000001000000: n3690_o = n106_o;
      12'b000000100000: n3690_o = n106_o;
      12'b000000010000: n3690_o = n106_o;
      12'b000000001000: n3690_o = n106_o;
      12'b000000000100: n3690_o = n106_o;
      12'b000000000010: n3690_o = n106_o;
      12'b000000000001: n3690_o = n106_o;
      default: n3690_o = n106_o;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3691_o = n111_o;
      12'b010000000000: n3691_o = n111_o;
      12'b001000000000: n3691_o = n111_o;
      12'b000100000000: n3691_o = n111_o;
      12'b000010000000: n3691_o = n3565_o;
      12'b000001000000: n3691_o = n111_o;
      12'b000000100000: n3691_o = n111_o;
      12'b000000010000: n3691_o = n111_o;
      12'b000000001000: n3691_o = n111_o;
      12'b000000000100: n3691_o = n111_o;
      12'b000000000010: n3691_o = n111_o;
      12'b000000000001: n3691_o = n111_o;
      default: n3691_o = n111_o;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3692_o = n116_o;
      12'b010000000000: n3692_o = n116_o;
      12'b001000000000: n3692_o = n116_o;
      12'b000100000000: n3692_o = n116_o;
      12'b000010000000: n3692_o = n3566_o;
      12'b000001000000: n3692_o = n116_o;
      12'b000000100000: n3692_o = n116_o;
      12'b000000010000: n3692_o = n116_o;
      12'b000000001000: n3692_o = n116_o;
      12'b000000000100: n3692_o = n116_o;
      12'b000000000010: n3692_o = n116_o;
      12'b000000000001: n3692_o = n116_o;
      default: n3692_o = n116_o;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3694_o = 1'b0;
      12'b010000000000: n3694_o = trace;
      12'b001000000000: n3694_o = trace;
      12'b000100000000: n3694_o = trace;
      12'b000010000000: n3694_o = trace;
      12'b000001000000: n3694_o = trace;
      12'b000000100000: n3694_o = trace;
      12'b000000010000: n3694_o = trace;
      12'b000000001000: n3694_o = trace;
      12'b000000000100: n3694_o = trace_i;
      12'b000000000010: n3694_o = trace;
      12'b000000000001: n3694_o = trace;
      default: n3694_o = trace;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3696_o = 1'b0;
      12'b010000000000: n3696_o = trace_i;
      12'b001000000000: n3696_o = trace_i;
      12'b000100000000: n3696_o = trace_i;
      12'b000010000000: n3696_o = trace_i;
      12'b000001000000: n3696_o = trace_i;
      12'b000000100000: n3696_o = trace_i;
      12'b000000010000: n3696_o = trace_i;
      12'b000000001000: n3696_o = trace_i;
      12'b000000000100: n3696_o = n1316_o;
      12'b000000000010: n3696_o = trace_i;
      12'b000000000001: n3696_o = trace_i;
      default: n3696_o = trace_i;
    endcase
  /* 6805.vhd:308:9  */
  always @*
    case (n3610_o)
      12'b100000000000: n3697_o = traceopcode;
      12'b010000000000: n3697_o = traceopcode;
      12'b001000000000: n3697_o = traceopcode;
      12'b000100000000: n3697_o = traceopcode;
      12'b000010000000: n3697_o = traceopcode;
      12'b000001000000: n3697_o = traceopcode;
      12'b000000100000: n3697_o = traceopcode;
      12'b000000010000: n3697_o = traceopcode;
      12'b000000001000: n3697_o = traceopcode;
      12'b000000000100: n3697_o = n1317_o;
      12'b000000000010: n3697_o = traceopcode;
      12'b000000000001: n3697_o = traceopcode;
      default: n3697_o = traceopcode;
    endcase
  assign n3703_o = {n3622_o, n3618_o};
  assign n3710_o = {n3667_o, n3662_o, n3657_o, n3652_o, n3647_o, n3642_o, n3637_o, n3632_o};
  assign n3712_o = {n3679_o, n3673_o};
  /* 6805.vhd:307:7  */
  assign n3718_o = clken ? n3690_o : n106_o;
  /* 6805.vhd:307:7  */
  assign n3719_o = clken ? n3691_o : n111_o;
  /* 6805.vhd:307:7  */
  assign n3720_o = clken ? n3692_o : n116_o;
  /* 6805.vhd:264:5  */
  assign n3805_o = {8'b11111110, 8'b11111101, 8'b11111011, 8'b11110111, 8'b11101111, 8'b11011111, 8'b10111111, 8'b01111111};
  assign n3806_o = {8'b00000001, 8'b00000010, 8'b00000100, 8'b00001000, 8'b00010000, 8'b00100000, 8'b01000000, 8'b10000000};
  /* 6805.vhd:290:7  */
  assign n3807_o = clken ? n3612_o : rega;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3808_q <= 8'b00000000;
    else
      n3808_q <= n3807_o;
  /* 6805.vhd:290:7  */
  assign n3809_o = clken ? n3613_o : regx;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3810_q <= 8'b00000000;
    else
      n3810_q <= n3809_o;
  /* 6805.vhd:290:7  */
  assign n3811_o = clken ? n3614_o : regsp;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3812_q <= 16'b0000000011111111;
    else
      n3812_q <= n3811_o;
  /* 6805.vhd:290:7  */
  assign n3813_o = clken ? n3703_o : regpc;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3814_q <= 16'b0001111111111110;
    else
      n3814_q <= n3813_o;
  /* 6805.vhd:290:7  */
  assign n3815_o = clken ? n3623_o : flagh;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3816_q <= 1'b0;
    else
      n3816_q <= n3815_o;
  /* 6805.vhd:290:7  */
  assign n3817_o = clken ? n3624_o : flagi;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3818_q <= 1'b1;
    else
      n3818_q <= n3817_o;
  /* 6805.vhd:290:7  */
  assign n3819_o = clken ? n3625_o : flagn;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3820_q <= 1'b0;
    else
      n3820_q <= n3819_o;
  /* 6805.vhd:290:7  */
  assign n3821_o = clken ? n3626_o : flagz;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3822_q <= 1'b0;
    else
      n3822_q <= n3821_o;
  /* 6805.vhd:290:7  */
  assign n3823_o = clken ? n3627_o : flagc;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3824_q <= 1'b0;
    else
      n3824_q <= n3823_o;
  /* 6805.vhd:290:7  */
  assign n3825_o = clken ? n3710_o : help;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3826_q <= 8'b00000000;
    else
      n3826_q <= n3825_o;
  /* 6805.vhd:290:7  */
  assign n3827_o = clken ? n3712_o : temp;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3828_q <= 16'b0001111111111110;
    else
      n3828_q <= n3827_o;
  /* 6805.vhd:290:7  */
  assign n3829_o = clken ? n3684_o : mainfsm;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3830_q <= 4'b0000;
    else
      n3830_q <= n3829_o;
  /* 6805.vhd:290:7  */
  assign n3831_o = clken ? n3686_o : addrmux;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3832_q <= 3'b011;
    else
      n3832_q <= n3831_o;
  /* 6805.vhd:290:7  */
  assign n3833_o = clken ? n3688_o : datamux;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3834_q <= 4'b0000;
    else
      n3834_q <= n3833_o;
  /* 6805.vhd:260:3  */
  assign n3835_o = ~n100_o;
  /* 6805.vhd:260:3  */
  assign n3836_o = clken & n3835_o;
  /* 6805.vhd:290:7  */
  assign n3837_o = n3836_o ? n3689_o : opcode;
  /* 6805.vhd:290:7  */
  always @(posedge clk)
    n3838_q <= n3837_o;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3839_q <= 1'b1;
    else
      n3839_q <= extirq;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3840_q <= 1'b1;
    else
      n3840_q <= timerirq;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3841_q <= 1'b1;
    else
      n3841_q <= sciirq;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3842_q <= 1'b0;
    else
      n3842_q <= n3718_o;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3843_q <= 1'b0;
    else
      n3843_q <= n3719_o;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3844_q <= 1'b0;
    else
      n3844_q <= n3720_o;
  /* 6805.vhd:290:7  */
  assign n3845_o = clken ? n3694_o : trace;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3846_q <= 1'b0;
    else
      n3846_q <= n3845_o;
  /* 6805.vhd:290:7  */
  assign n3847_o = clken ? n3696_o : trace_i;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3848_q <= 1'b0;
    else
      n3848_q <= n3847_o;
  /* 6805.vhd:260:3  */
  assign n3849_o = ~n100_o;
  /* 6805.vhd:260:3  */
  assign n3850_o = clken & n3849_o;
  /* 6805.vhd:290:7  */
  assign n3851_o = n3850_o ? n3697_o : traceopcode;
  /* 6805.vhd:290:7  */
  always @(posedge clk)
    n3852_q <= n3851_o;
  /* 6805.vhd:290:7  */
  assign n3853_o = clken ? n3611_o : n3854_q;
  /* 6805.vhd:290:7  */
  always @(posedge clk or posedge n100_o)
    if (n100_o)
      n3854_q <= 1'b1;
    else
      n3854_q <= n3853_o;
  /* 6805.vhd:217:13  */
  assign n3855_o = mask1[7:0];
  /* 6805.vhd:214:3  */
  assign n3856_o = mask1[15:8];
  /* 6805.vhd:146:6  */
  assign n3857_o = mask1[23:16];
  /* 6805.vhd:145:6  */
  assign n3858_o = mask1[31:24];
  /* 6805.vhd:143:6  */
  assign n3859_o = mask1[39:32];
  /* 6805.vhd:142:6  */
  assign n3860_o = mask1[47:40];
  /* 6805.vhd:290:7  */
  assign n3861_o = mask1[55:48];
  /* 6805.vhd:290:7  */
  assign n3862_o = mask1[63:56];
  /* 6805.vhd:948:37  */
  assign n3863_o = n1973_o[1:0];
  /* 6805.vhd:948:37  */
  always @*
    case (n3863_o)
      2'b00: n3864_o = n3855_o;
      2'b01: n3864_o = n3856_o;
      2'b10: n3864_o = n3857_o;
      2'b11: n3864_o = n3858_o;
    endcase
  /* 6805.vhd:948:37  */
  assign n3865_o = n1973_o[1:0];
  /* 6805.vhd:948:37  */
  always @*
    case (n3865_o)
      2'b00: n3866_o = n3859_o;
      2'b01: n3866_o = n3860_o;
      2'b10: n3866_o = n3861_o;
      2'b11: n3866_o = n3862_o;
    endcase
  /* 6805.vhd:948:37  */
  assign n3867_o = n1973_o[2];
  /* 6805.vhd:948:37  */
  assign n3868_o = n3867_o ? n3866_o : n3864_o;
  /* 6805.vhd:948:37  */
  assign n3869_o = mask1[7:0];
  /* 6805.vhd:948:38  */
  assign n3870_o = mask1[15:8];
  /* 6805.vhd:290:7  */
  assign n3871_o = mask1[23:16];
  /* 6805.vhd:290:7  */
  assign n3872_o = mask1[31:24];
  /* 6805.vhd:290:7  */
  assign n3873_o = mask1[39:32];
  /* 6805.vhd:290:7  */
  assign n3874_o = mask1[47:40];
  /* 6805.vhd:290:7  */
  assign n3875_o = mask1[55:48];
  /* 6805.vhd:290:7  */
  assign n3876_o = mask1[63:56];
  /* 6805.vhd:960:43  */
  assign n3877_o = n2034_o[1:0];
  /* 6805.vhd:960:43  */
  always @*
    case (n3877_o)
      2'b00: n3878_o = n3869_o;
      2'b01: n3878_o = n3870_o;
      2'b10: n3878_o = n3871_o;
      2'b11: n3878_o = n3872_o;
    endcase
  /* 6805.vhd:960:43  */
  assign n3879_o = n2034_o[1:0];
  /* 6805.vhd:960:43  */
  always @*
    case (n3879_o)
      2'b00: n3880_o = n3873_o;
      2'b01: n3880_o = n3874_o;
      2'b10: n3880_o = n3875_o;
      2'b11: n3880_o = n3876_o;
    endcase
  /* 6805.vhd:960:43  */
  assign n3881_o = n2034_o[2];
  /* 6805.vhd:960:43  */
  assign n3882_o = n3881_o ? n3880_o : n3878_o;
  /* 6805.vhd:960:43  */
  assign n3883_o = mask0[7:0];
  /* 6805.vhd:960:44  */
  assign n3884_o = mask0[15:8];
  /* 6805.vhd:290:7  */
  assign n3885_o = mask0[23:16];
  /* 6805.vhd:290:7  */
  assign n3886_o = mask0[31:24];
  /* 6805.vhd:290:7  */
  assign n3887_o = mask0[39:32];
  /* 6805.vhd:290:7  */
  assign n3888_o = mask0[47:40];
  /* 6805.vhd:290:7  */
  assign n3889_o = mask0[55:48];
  /* 6805.vhd:308:9  */
  assign n3890_o = mask0[63:56];
  /* 6805.vhd:962:43  */
  assign n3891_o = n2041_o[1:0];
  /* 6805.vhd:962:43  */
  always @*
    case (n3891_o)
      2'b00: n3892_o = n3883_o;
      2'b01: n3892_o = n3884_o;
      2'b10: n3892_o = n3885_o;
      2'b11: n3892_o = n3886_o;
    endcase
  /* 6805.vhd:962:43  */
  assign n3893_o = n2041_o[1:0];
  /* 6805.vhd:962:43  */
  always @*
    case (n3893_o)
      2'b00: n3894_o = n3887_o;
      2'b01: n3894_o = n3888_o;
      2'b10: n3894_o = n3889_o;
      2'b11: n3894_o = n3890_o;
    endcase
  /* 6805.vhd:962:43  */
  assign n3895_o = n2041_o[2];
  /* 6805.vhd:962:43  */
  assign n3896_o = n3895_o ? n3894_o : n3892_o;
endmodule

