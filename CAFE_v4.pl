#!/opt/local/bin/perl
################################################################################
# +--------------------------------------------------------------------------+ #
# |                                                                          | #
# |  CAFE.PL (version 4)                                                     | #
# |  Computer-Assisted Formative Evaluations                                 | #
# |                                                                          | #
# |  This script was written to generate formative feedback documents in an  | #
# |  html file for my students following major exams. These documents can be | #
# |  emailed to each student, uploaded to a course management system, or     | #
# |  directly returned to the students. I hope that these detailed reports   | #
# |  will provide an effective means to address potential study strategies,  | #
# |  test-taking skills. Ultimately, I hope to encourage metacognitive       | #
# |  reflection and increase student involvement in their own learning.      | #
# |                                                                          | #
# |                THE ORGANIZATION OF THIS SCRIPT'S PROCESSES               | #
# |             --------------------------------------------------------     | #
# |             1) Data input from external sources                          | #
# |             2) Calculations necessary for the reports                    | #
# |             3) Drawing graphs and figures for the instructor report      | #
# |             4) Generation of individual student feedback reports         | #
# |             5) Generation of an instructor summary report                | #
# |             6) Subroutines that are called for repetitive tasks          | #
# |                                                                          | #
# |  written by:   Dr. Clifton Franklund                                     | #
# |                Professor of Microbiology                                 | #
# |                Department of Biological Sciences                         | #
# |                Ferris State University                                   | #
# |                January 23, 2007                                          | #
# |                                                                          | #
# |  last revised: January 12, 2015                                          | #
# |                Changed from Bloom's to specific reasoning skills         | #
# |                Item scores now use Attali PBd instead of slopes          | #
# |                                                                          | #
# +--------------------------------------------------------------------------+ #
################################################################################

# +--------------------------------------------------------------------------+ #
# |         Loading packages to enhance the program function                 | #
# +--------------------------------------------------------------------------+ #

use lib '/Library/Perl/5.16';
# use lib '/opt/local/lib/perl5/vendor_perl/5.16.3';
use MIME::Lite;
use GD;

################################################################################
# +--------------------------------------------------------------------------+ #
# | [-1-]                Data input from external sources                    | #
# +--------------------------------------------------------------------------+ #
################################################################################


# +--------------------------------------------------------------------------+ #
# |               Reading in variables to format the reports                 | #
# +--------------------------------------------------------------------------+ #

##open(CONFIG,"@ARGV[1]") || die "can not find the configuration file\n";

open(CONFIG,"/Users/anaerobe/Documents/Ferris Files/Perl Scripts/CAFE/My_Courses/2015_01_BIOL286/Exam1/configuration/config1.txt") || die "can not find configuration file\n";
@config=<CONFIG>;
close(CONFIG);

foreach $line(@config) {
	chop $line;
	($name, $value)=split('\t',$line); 
	@report{$name}=$value;
}

$directory = $report{'path'};

push @descriptions, "0";
push @descriptions, $report{'description1'};
push @descriptions, $report{'description2'};
push @descriptions, $report{'description3'};
push @descriptions, $report{'description4'};
push @descriptions, $report{'description5'};
push @descriptions, $report{'description6'};
push @descriptions, $report{'description7'};
push @descriptions, $report{'description8'};
push @descriptions, $report{'description9'};
push @descriptions, $report{'description10'};

push @outcomes, "0";
push @outcomes, $report{'outcome1'};
push @outcomes, $report{'outcome2'};
push @outcomes, $report{'outcome3'};
push @outcomes, $report{'outcome4'};
push @outcomes, $report{'outcome5'};
push @outcomes, $report{'outcome6'};

push @outdefs, "0";
push @outdefs, $report{'out_def1'};
push @outdefs, $report{'out_def2'};
push @outdefs, $report{'out_def3'};
push @outdefs, $report{'out_def4'};
push @outdefs, $report{'out_def5'};
push @outdefs, $report{'out_def6'};

push @areas, $report{'lec1'};
push @shortareas, substr($report{'lec1'},0,30);
push @areas, $report{'lec2'};
push @shortareas, substr($report{'lec2'},0,30);
push @areas, $report{'lec3'};
push @shortareas, substr($report{'lec3'},0,30);
push @areas, $report{'lec4'};
push @shortareas, substr($report{'lec4'},0,30);
push @areas, $report{'lec5'};
push @shortareas, substr($report{'lec5'},0,30);
push @areas, $report{'lec6'};
push @shortareas, substr($report{'lec6'},0,30);
push @areas, $report{'lec7'};
push @shortareas, substr($report{'lec7'},0,30);
push @areas, $report{'lec8'};
push @shortareas, substr($report{'lec8'},0,30);
push @areas, $report{'lec9'};
push @shortareas, substr($report{'lec9'},0,30);
push @areas, $report{'lec10'};
push @shortareas, substr($report{'lec10'},0,30);

# +--------------------------------------------------------------------------+ #
# |                      Reading in the exam key                             | #
# |                                                                          | #
# |       [Number][Key][Points][Objective][Lecture][Skill][Feedback]        | #
# +--------------------------------------------------------------------------+ #

open(EXAM,"$directory/configuration/$report{'examfile'}") || die "can not find the examfile\n";
@exam = <EXAM>;
close(EXAM);

foreach $line(@exam) {
	chop $line;
	($one, $two, $three, $four, $five, $six, $seven)=split('\t',$line); 
	push @num, $one;
	push @key, $two;
	push @points, $three;
	push @objective, $four;
	push @lecture, $five;
	push @skill, $six;
	push @feedback, $seven;
}


# +--------------------------------------------------------------------------+ #
# |              Getting the student responses into a matrix                 | #
# |                                                                          | #
# |   [LAST][FIRST][ID][EMAIL][VAR1][VAR2][VAR3][RESPONSE1]...[RESPONSEn]    | #
# +--------------------------------------------------------------------------+ #

open(RESPONSES,"$directory/configuration/$report{'responsefile'}") || die "can not find responsefile\n";
@responses = <RESPONSES>;
close(RESPONSES);

foreach $student(@responses) {
	chop $student;
	@fields = split('\t', $student);
	push @choices, [@fields];
	$numstudents++;
}

$numfields=@fields;
$numquestions=$numfields-7;
for ($adder=0; $adder<$numquestions; $adder++) {
	$maxpoints=$maxpoints+$points[$adder];
}
$freedom=$numstudents-1;
$freedomval=$numstudents-1;
if($freedom>200) {
	$freedom=200;
}


# +--------------------------------------------------------------------------+ #
# |                     T-test critical values up to 200 df                  | +
# +--------------------------------------------------------------------------+ #

@crit_100=(0.1,6.3138,2.9200,2.3534,2.1319,2.0150,1.9432,1.8946,1.8595,1.8331,1.8124,1.7959,1.7823,1.7709,1.7613,1.7530,1.7459,1.7396,1.7341,1.7291,1.7247,1.7207,1.7172,1.7139,1.7109,1.7081,1.7056,1.7033,1.7011,1.6991,1.6973,1.6955,1.6939,1.6924,1.6909,1.6896,1.6883,1.6871,1.6859,1.6849,1.6839,1.6829,1.6820,1.6811,1.6802,1.6794,1.6787,1.6779,1.6772,1.6766,1.6759,1.6753,1.6747,1.6741,1.6736,1.6730,1.6725,1.6720,1.6715,1.6711,1.6706,1.6702,1.6698,1.6694,1.6690,1.6686,1.6683,1.6679,1.6676,1.6673,1.6669,1.6666,1.6663,1.6660,1.6657,1.6654,1.6652,1.6649,1.6646,1.6644,1.6641,1.6639,1.6636,1.6634,1.6632,1.6630,1.6628,1.6626,1.6623,1.6622,1.6620,1.6618,1.6616,1.6614,1.6612,1.6610,1.6609,1.6607,1.6606,1.6604,1.6602,1.6601,1.6599,1.6598,1.6596,1.6595,1.6593,1.6592,1.6591,1.6589,1.6588,1.6587,1.6586,1.6585,1.6583,1.6582,1.6581,1.6580,1.6579,1.6578,1.6577,1.6575,1.6574,1.6573,1.6572,1.6571,1.6570,1.6570,1.6568,1.6568,1.6567,1.6566,1.6565,1.6564,1.6563,1.6562,1.6561,1.6561,1.6560,1.6559,1.6558,1.6557,1.6557,1.6556,1.6555,1.6554,1.6554,1.6553,1.6552,1.6551,1.6551,1.6550,1.6549,1.6549,1.6548,1.6547,1.6547,1.6546,1.6546,1.6545,1.6544,1.6544,1.6543,1.6543,1.6542,1.6542,1.6541,1.6540,1.6540,1.6539,1.6539,1.6538,1.6537,1.6537,1.6537,1.6536,1.6536,1.6535,1.6535,1.6534,1.6534,1.6533,1.6533,1.6532,1.6532,1.6531,1.6531,1.6531,1.6530,1.6529,1.6529,1.6529,1.6528,1.6528,1.6528,1.6527,1.6527,1.6526,1.6526,1.6525,1.6525);

@crit_050=(0.05,12.7065,4.3026,3.1824,2.7764,2.5706,2.4469,2.3646,2.3060,2.2621,2.2282,2.2010,2.1788,2.1604,2.1448,2.1314,2.1199,2.1098,2.1009,2.0930,2.0860,2.0796,2.0739,2.0686,2.0639,2.0596,2.0555,2.0518,2.0484,2.0452,2.0423,2.0395,2.0369,2.0345,2.0322,2.0301,2.0281,2.0262,2.0244,2.0227,2.0211,2.0196,2.0181,2.0167,2.0154,2.0141,2.0129,2.0117,2.0106,2.0096,2.0086,2.0076,2.0066,2.0057,2.0049,2.0041,2.0032,2.0025,2.0017,2.0010,2.0003,1.9996,1.9990,1.9983,1.9977,1.9971,1.9966,1.9960,1.9955,1.9950,1.9944,1.9939,1.9935,1.9930,1.9925,1.9921,1.9917,1.9913,1.9909,1.9904,1.9901,1.9897,1.9893,1.9889,1.9886,1.9883,1.9879,1.9876,1.9873,1.9870,1.9867,1.9864,1.9861,1.9858,1.9855,1.9852,1.9850,1.9847,1.9845,1.9842,1.9840,1.9837,1.9835,1.9833,1.9830,1.9828,1.9826,1.9824,1.9822,1.9820,1.9818,1.9816,1.9814,1.9812,1.9810,1.9808,1.9806,1.9805,1.9803,1.9801,1.9799,1.9798,1.9796,1.9794,1.9793,1.9791,1.9790,1.9788,1.9787,1.9785,1.9784,1.9782,1.9781,1.9779,1.9778,1.9777,1.9776,1.9774,1.9773,1.9772,1.9771,1.9769,1.9768,1.9767,1.9766,1.9765,1.9764,1.9762,1.9761,1.9760,1.9759,1.9758,1.9757,1.9756,1.9755,1.9754,1.9753,1.9752,1.9751,1.9750,1.9749,1.9748,1.9747,1.9746,1.9745,1.9744,1.9744,1.9743,1.9742,1.9741,1.9740,1.9739,1.9739,1.9738,1.9737,1.9736,1.9735,1.9735,1.9734,1.9733,1.9732,1.9731,1.9731,1.9730,1.9729,1.9729,1.9728,1.9727,1.9727,1.9726,1.9725,1.9725,1.9724,1.9723,1.9723,1.9722,1.9721,1.9721,1.9720,1.9720,1.9719);

@crit_020=(0.02,31.8193,6.9646,4.5407,3.7470,3.3650,3.1426,2.9980,2.8965,2.8214,2.7638,2.7181,2.6810,2.6503,2.6245,2.6025,2.5835,2.5669,2.5524,2.5395,2.5280,2.5176,2.5083,2.4998,2.4922,2.4851,2.4786,2.4727,2.4671,2.4620,2.4572,2.4528,2.4487,2.4448,2.4411,2.4377,2.4345,2.4315,2.4286,2.4258,2.4233,2.4208,2.4185,2.4162,2.4142,2.4121,2.4102,2.4083,2.4066,2.4049,2.4033,2.4017,2.4002,2.3988,2.3974,2.3961,2.3948,2.3936,2.3924,2.3912,2.3901,2.3890,2.3880,2.3870,2.3860,2.3851,2.3842,2.3833,2.3824,2.3816,2.3808,2.3800,2.3793,2.3785,2.3778,2.3771,2.3764,2.3758,2.3751,2.3745,2.3739,2.3733,2.3727,2.3721,2.3716,2.3710,2.3705,2.3700,2.3695,2.3690,2.3685,2.3680,2.3676,2.3671,2.3667,2.3662,2.3658,2.3654,2.3650,2.3646,2.3642,2.3638,2.3635,2.3631,2.3627,2.3624,2.3620,2.3617,2.3614,2.3611,2.3607,2.3604,2.3601,2.3598,2.3595,2.3592,2.3589,2.3586,2.3583,2.3581,2.3578,2.3576,2.3573,2.3571,2.3568,2.3565,2.3563,2.3561,2.3559,2.3556,2.3554,2.3552,2.3549,2.3547,2.3545,2.3543,2.3541,2.3539,2.3537,2.3535,2.3533,2.3531,2.3529,2.3527,2.3525,2.3523,2.3522,2.3520,2.3518,2.3516,2.3515,2.3513,2.3511,2.3510,2.3508,2.3507,2.3505,2.3503,2.3502,2.3500,2.3499,2.3497,2.3496,2.3495,2.3493,2.3492,2.3490,2.3489,2.3487,2.3486,2.3485,2.3484,2.3482,2.3481,2.3480,2.3478,2.3477,2.3476,2.3475,2.3474,2.3472,2.3471,2.3470,2.3469,2.3468,2.3467,2.3466,2.3465,2.3463,2.3463,2.3461,2.3460,2.3459,2.3458,2.3457,2.3456,2.3455,2.3454,2.3453,2.3452,2.3451);

@crit_010=(0.01,63.6551,9.9247,5.8408,4.6041,4.0322,3.7074,3.4995,3.3554,3.2498,3.1693,3.1058,3.0545,3.0123,2.9768,2.9467,2.9208,2.8983,2.8784,2.8609,2.8454,2.8314,2.8188,2.8073,2.7970,2.7874,2.7787,2.7707,2.7633,2.7564,2.7500,2.7440,2.7385,2.7333,2.7284,2.7238,2.7195,2.7154,2.7115,2.7079,2.7045,2.7012,2.6981,2.6951,2.6923,2.6896,2.6870,2.6846,2.6822,2.6800,2.6778,2.6757,2.6737,2.6718,2.6700,2.6682,2.6665,2.6649,2.6633,2.6618,2.6603,2.6589,2.6575,2.6561,2.6549,2.6536,2.6524,2.6512,2.6501,2.6490,2.6479,2.6468,2.6459,2.6449,2.6439,2.6430,2.6421,2.6412,2.6404,2.6395,2.6387,2.6379,2.6371,2.6364,2.6356,2.6349,2.6342,2.6335,2.6328,2.6322,2.6316,2.6309,2.6303,2.6297,2.6292,2.6286,2.6280,2.6275,2.6269,2.6264,2.6259,2.6254,2.6249,2.6244,2.6240,2.6235,2.6230,2.6225,2.6221,2.6217,2.6212,2.6208,2.6204,2.6200,2.6196,2.6192,2.6189,2.6185,2.6181,2.6178,2.6174,2.6171,2.6168,2.6164,2.6161,2.6158,2.6154,2.6151,2.6148,2.6145,2.6142,2.6139,2.6136,2.6133,2.6130,2.6127,2.6125,2.6122,2.6119,2.6117,2.6114,2.6112,2.6109,2.6106,2.6104,2.6102,2.6099,2.6097,2.6094,2.6092,2.6090,2.6088,2.6085,2.6083,2.6081,2.6079,2.6077,2.6075,2.6073,2.6071,2.6069,2.6067,2.6065,2.6063,2.6062,2.6060,2.6058,2.6056,2.6054,2.6052,2.6051,2.6049,2.6047,2.6046,2.6044,2.6042,2.6041,2.6039,2.6037,2.6036,2.6034,2.6033,2.6031,2.6030,2.6028,2.6027,2.6025,2.6024,2.6022,2.6021,2.6019,2.6018,2.6017,2.6015,2.6014,2.6013,2.6012,2.6010,2.6009,2.6008,2.6007);

@crit_005=(0.005,127.3447,14.0887,7.4534,5.5976,4.7734,4.3168,4.0294,3.8325,3.6896,3.5814,3.4966,3.4284,3.3725,3.3257,3.2860,3.2520,3.2224,3.1966,3.1737,3.1534,3.1352,3.1188,3.1040,3.0905,3.0782,3.0669,3.0565,3.0469,3.0380,3.0298,3.0221,3.0150,3.0082,3.0019,2.9961,2.9905,2.9853,2.9803,2.9756,2.9712,2.9670,2.9630,2.9591,2.9555,2.9521,2.9488,2.9456,2.9426,2.9397,2.9370,2.9343,2.9318,2.9293,2.9270,2.9247,2.9225,2.9204,2.9184,2.9164,2.9146,2.9127,2.9110,2.9092,2.9076,2.9060,2.9045,2.9030,2.9015,2.9001,2.8987,2.8974,2.8961,2.8948,2.8936,2.8925,2.8913,2.8902,2.8891,2.8880,2.8870,2.8859,2.8850,2.8840,2.8831,2.8821,2.8813,2.8804,2.8795,2.8787,2.8779,2.8771,2.8763,2.8755,2.8748,2.8741,2.8734,2.8727,2.8720,2.8713,2.8706,2.8700,2.8694,2.8687,2.8682,2.8675,2.8670,2.8664,2.8658,2.8653,2.8647,2.8642,2.8637,2.8632,2.8627,2.8622,2.8617,2.8612,2.8608,2.8603,2.8599,2.8594,2.8590,2.8585,2.8582,2.8577,2.8573,2.8569,2.8565,2.8561,2.8557,2.8554,2.8550,2.8546,2.8542,2.8539,2.8536,2.8532,2.8529,2.8525,2.8522,2.8519,2.8516,2.8512,2.8510,2.8506,2.8503,2.8500,2.8497,2.8494,2.8491,2.8489,2.8486,2.8483,2.8481,2.8478,2.8475,2.8472,2.8470,2.8467,2.8465,2.8463,2.8460,2.8458,2.8455,2.8452,2.8450,2.8448,2.8446,2.8443,2.8441,2.8439,2.8437,2.8435,2.8433,2.8430,2.8429,2.8427,2.8424,2.8423,2.8420,2.8419,2.8416,2.8415,2.8413,2.8411,2.8409,2.8407,2.8406,2.8403,2.8402,2.8400,2.8398,2.8397,2.8395,2.8393,2.8392,2.8390,2.8388,2.8387,2.8385);

@crit_002=(0.002,318.4930,22.3276,10.2145,7.1732,5.8934,5.2076,4.7852,4.5008,4.2969,4.1437,4.0247,3.9296,3.8520,3.7874,3.7328,3.6861,3.6458,3.6105,3.5794,3.5518,3.5272,3.5050,3.4850,3.4668,3.4502,3.4350,3.4211,3.4082,3.3962,3.3852,3.3749,3.3653,3.3563,3.3479,3.3400,3.3326,3.3256,3.3190,3.3128,3.3069,3.3013,3.2959,3.2909,3.2861,3.2815,3.2771,3.2729,3.2689,3.2651,3.2614,3.2579,3.2545,3.2513,3.2482,3.2451,3.2423,3.2394,3.2368,3.2342,3.2317,3.2293,3.2269,3.2247,3.2225,3.2204,3.2184,3.2164,3.2144,3.2126,3.2108,3.2090,3.2073,3.2056,3.2040,3.2025,3.2010,3.1995,3.1980,3.1966,3.1953,3.1939,3.1926,3.1913,3.1901,3.1889,3.1877,3.1866,3.1854,3.1844,3.1833,3.1822,3.1812,3.1802,3.1792,3.1782,3.1773,3.1764,3.1755,3.1746,3.1738,3.1729,3.1720,3.1712,3.1704,3.1697,3.1689,3.1681,3.1674,3.1667,3.1660,3.1653,3.1646,3.1640,3.1633,3.1626,3.1620,3.1614,3.1607,3.1601,3.1595,3.1589,3.1584,3.1578,3.1573,3.1567,3.1562,3.1556,3.1551,3.1546,3.1541,3.1536,3.1531,3.1526,3.1522,3.1517,3.1512,3.1508,3.1503,3.1499,3.1495,3.1491,3.1486,3.1482,3.1478,3.1474,3.1470,3.1466,3.1462,3.1458,3.1455,3.1451,3.1447,3.1443,3.1440,3.1436,3.1433,3.1430,3.1426,3.1423,3.1419,3.1417,3.1413,3.1410,3.1407,3.1403,3.1400,3.1398,3.1394,3.1392,3.1388,3.1386,3.1383,3.1380,3.1377,3.1375,3.1372,3.1369,3.1366,3.1364,3.1361,3.1358,3.1356,3.1354,3.1351,3.1349,3.1346,3.1344,3.1341,3.1339,3.1337,3.1334,3.1332,3.1330,3.1328,3.1326,3.1323,3.1321,3.1319,3.1317,3.1315);

@crit_001=(0.001,636.0450,31.5989,12.9242,8.6103,6.8688,5.9589,5.4079,5.0414,4.7809,4.5869,4.4369,4.3178,4.2208,4.1404,4.0728,4.0150,3.9651,3.9216,3.8834,3.8495,3.8193,3.7921,3.7676,3.7454,3.7251,3.7067,3.6896,3.6739,3.6594,3.6459,3.6334,3.6218,3.6109,3.6008,3.5912,3.5822,3.5737,3.5657,3.5581,3.5510,3.5442,3.5378,3.5316,3.5258,3.5202,3.5149,3.5099,3.5051,3.5004,3.4960,3.4917,3.4877,3.4838,3.4800,3.4764,3.4730,3.4696,3.4663,3.4632,3.4602,3.4573,3.4545,3.4518,3.4491,3.4466,3.4441,3.4417,3.4395,3.4372,3.4350,3.4329,3.4308,3.4288,3.4269,3.4250,3.4232,3.4214,3.4197,3.4180,3.4164,3.4147,3.4132,3.4117,3.4101,3.4087,3.4073,3.4059,3.4046,3.4032,3.4020,3.4006,3.3995,3.3982,3.3970,3.3959,3.3947,3.3936,3.3926,3.3915,3.3905,3.3894,3.3885,3.3875,3.3866,3.3856,3.3847,3.3838,3.3829,3.3820,3.3812,3.3803,3.3795,3.3787,3.3779,3.3771,3.3764,3.3756,3.3749,3.3741,3.3735,3.3727,3.3721,3.3714,3.3707,3.3700,3.3694,3.3688,3.3682,3.3676,3.3669,3.3663,3.3658,3.3652,3.3646,3.3641,3.3635,3.3630,3.3624,3.3619,3.3614,3.3609,3.3604,3.3599,3.3594,3.3589,3.3584,3.3579,3.3575,3.3570,3.3565,3.3561,3.3557,3.3552,3.3548,3.3544,3.3540,3.3536,3.3531,3.3528,3.3523,3.3520,3.3516,3.3512,3.3508,3.3505,3.3501,3.3497,3.3494,3.3490,3.3487,3.3483,3.3480,3.3477,3.3473,3.3470,3.3466,3.3464,3.3460,3.3457,3.3454,3.3451,3.3448,3.3445,3.3442,3.3439,3.3436,3.3433,3.3430,3.3428,3.3425,3.3422,3.3419,3.3417,3.3414,3.3411,3.3409,3.3406,3.3403,3.3401,3.3398);


# +--------------------------------------------------------------------------+ #
# |                    Chi squared critical values for 2 df                  | #
# |                     0.100, 0.050, 0.025, 0.010, 0.005                    | #
# +--------------------------------------------------------------------------+ #

@crit_chi2=(4.60517,5.99146,7.37776,9.21034,10.59663);




###############################################################################
# +--------------------------------------------------------------------------+ #
# | [-2-]         Calculations concerning the class performance              | #
# +--------------------------------------------------------------------------+ #
###############################################################################

# +--------------------------------------------------------------------------+ #
# |                 Grading the responses into a new matrix                  | #
# |                                                                          | #
# |                       Correct responses scored as 1                      | #
# |                     Incorrect responses scored as 0                      | #
# +--------------------------------------------------------------------------+ #

for ($adapt=0; $adapt<@key; $adapt++) {
	if ($key[$adapt] eq A) {
		$num_key[$adapt] = 1;
	}
	elsif ($key[$adapt] eq B) {
		$num_key[$adapt] = 2;
	}
	elsif ($key[$adapt] eq C) {
		$num_key[$adapt] = 3;
	}
	else {
		$num_key[$adapt] = 4;
	}
}

for($student=0; $student<$numstudents; $student++) {
	for($position=0; $position<$numquestions; $position++) {
		$shift=$position+7;
		if($choices[$student][$shift] eq $key[$position]) {
			$grades[$student][$position]=1;
		}
		else {
			$grades[$student][$position]=0;
		}
		
		if ($choices[$student][$shift] eq A) {
			$num_choices[$student][$position] = "1";
		}
		elsif ($choices[$student][$shift] eq B) {
			$num_choices[$student][$position] = "2";
		}
		elsif ($choices[$student][$shift] eq C) {
			$num_choices[$student][$position] = "3";
		}
		else {
			$num_choices[$student][$position] = "4";
		}
	}
}

for($student=0; $student<$numstudents; $student++) {
	for($position=0; $position<=$numquestions; $position++) {
		$sum[$student]=$sum[$student]+$grades[$student][$position];
		$score[$student]=$score[$student]+$grades[$student][$position]*$points[$position];
		$scores[$student][$position]=$grades[$student][$position]*$points[$position];
	}	
	$total=$total+$sum[$student];
	$squared[$student]=($sum[$student])**2;
	$total_squared=$total_squared+$squared[$student];

	$total_score=$total_score+$score[$student];
	$squared_score[$student]=($score[$student])**2;
	$total_squared_score=$total_squared_score+$squared_score[$student];
	
	
# +--------------------------------------------------------------------------+ #
# |                    Score distribution in percentiles                     | #
# +--------------------------------------------------------------------------+ #
	
	if ($score[$student]/$maxpoints*100 >= $report{'criterion'}) {
		$met++;
	}
	
	$sum1=$score[$student]/$maxpoints;
	
	if($sum1>=0.900){$bin[9]++;}
	elsif($sum1>=0.800){$bin[8]++;}
	elsif($sum1>=0.700){$bin[7]++;}
	elsif($sum1>=0.600){$bin[6]++;}
	elsif($sum1>=0.500){$bin[5]++;}
	elsif($sum1>=0.400){$bin[4]++;}
	elsif($sum1>=0.300){$bin[3]++;}
	elsif($sum1>=0.200){$bin[2]++;}
	elsif($sum1>=0.100){$bin[1]++;}
	else{$bin[0]++;}
}


# +--------------------------------------------------------------------------+ #
# |                        Descriptive statistics                            | #
# +--------------------------------------------------------------------------+ #

$average=$total/$numstudents;
$stdev=sqrt(($total_squared-($total*$average))/($numstudents-1));
$sterr=$stdev/sqrt($numstudents);

$average_score=$total_score/$numstudents;
$stdev_score=sqrt(($total_squared_score-($total_score*$average_score))/($numstudents-1));
$sterr_score=$stdev_score/sqrt($numstudents);

$average_percent=$average_score/$maxpoints*100;
$stdev_percent=$stdev_score/$maxpoints*100;
$sterr_percent=$sterr_score/$maxpoints*100;


# +--------------------------------------------------------------------------+ #
# |       Calculating the skew and kurtosis values of the distribution       | #
# +--------------------------------------------------------------------------+ #

for($student=0; $student<$numstudents; $student++) {
	$var_sum=$var_sum+($sum[$student]-$average)**2;
	$skew_sum=$skew_sum+($sum[$student]-$average)**3;
	$kurt_sum=$kurt_sum+($sum[$student]-$average)**4;
}
$m2=$var_sum/$numstudents;
$m3=$skew_sum/$numstudents;
$m4=$kurt_sum/$numstudents;

$g1=$m3/sqrt($m2**3);
$skew=sqrt($numstudents*($numstudents-1))/($numstudents-2)*$g1;
$SES=sqrt((6*$numstudents*($numstudents-1))/(($numstudents-1)*($numstudents+1)*($numstudents+3)));
$Z_skew=$skew/$SES;

$g2=($m4/($m2)**2)-3;
$kurtosis=($numstudents-1)/(($numstudents-2)*($numstudents-3))*(($numstudents+1)*$g2+6);
$SEK=2*$SES*sqrt(($numstudents**2-1)/(($numstudents-3)*($numstudents+5)));
$Z_kurtosis=$kurtosis/$SEK;

$DP=($Z_skew)**2+($Z_kurtosis)**2;


# +--------------------------------------------------------------------------+ #
# |                       Finding the median score                           | #
# +--------------------------------------------------------------------------+ #

@sorted = sort {$a <=> $b} @score;
if (@sorted % 2) { 
 $median = $sorted[int(@sorted/2)]; 
} else { 
 $median = ($sorted[@sorted/2] + $sorted[@sorted/2 - 1]) / 2; 
}
$med_percent=$median/$maxpoints*100;


# +--------------------------------------------------------------------------+ #
# |                   Performing item analysis calculations                  | #
# +--------------------------------------------------------------------------+ #

for($student=0; $student<$numstudents; $student++) {
	for($position=0; $position<=$numquestions; $position++) {
		$p_total[$position]=$p_total[$position]+$grades[$student][$position];
		if($grades[$student][$position]==1) {
			$Mp_total[$position]=$Mp_total[$position]+$sum[$student];
			$Mp_num[$position]=$Mp_num[$position]+1;
		}
		else {
			$Mq_total[$position]=$Mq_total[$position]+$sum[$student];
			$Mq_num[$position]=$Mq_num[$position]+1;
		}
	}
}

for($question=0; $question<$numquestions; $question++) {
	$p[$question] = $p_total[$question]/$numstudents;
	$q[$question] = 1-$p[$question];

	if($Mp_num[$question]==0) {  # avoid division by zero errors
		$Mp[$question]=0;
	}
	else {
		$Mp[$question] = $Mp_total[$question]/$Mp_num[$question];
	}
	if($Mq_num[$question]==0) {  # avoid division by zero errors
		$r_pbi[$question]=0;
	}
	else {
		$Mq[$question] = $Mq_total[$question]/$Mq_num[$question];
		$r_pbi[$question] = ($Mp[$question]-$Mq[$question])/$stdev*sqrt($p[$question]*$q[$question]);
	}
}




# +--------------------------------------------------------------------------+ #
# |            Performing Attali PBDC item analysis calculations               | #
# +--------------------------------------------------------------------------+ #

for($question=0;$question<$numquestions;$question++){
	#reset values for each question loop
	$totalA = $totalB = $totalC = $totalD = $totalAB = $totalAC = $totalAD = $totalBC = $totalBD = $totalCD = 0;
	$countA = $countB = $countC = $countD = $countAB = $countAC = $countAD = $countBC = $countBD = $countCD = 0;
	$total_squared_A = $total_squared_B = $total_squared_C = $total_squared_D = $total_squared_AB = $total_squared_AC = $total_squared_AD = $total_squared_BC = $total_squared_BD = $total_squared_CD = 0;
	for($student=0;$student<$numstudents;$student++) {
		if($num_choices[$student][$question]==1) {
			$countA++;
			$totalA += $score[$student];
			$total_squared_A += $score[$student]**2;
			$countAB++;
			$totalAB += $score[$student];
			$total_squared_AB += $score[$student]**2;
			$countAC++;
			$totalAC += $score[$student];
			$total_squared_AC += $score[$student]**2;
			$countAD++;
			$totalAD += $score[$student];
			$total_squared_AD += $score[$student]**2;
		}
		elsif($num_choices[$student][$question]==2) {
			$countB++;
			$totalB += $score[$student];
			$total_squared_B += $score[$student]**2;
			$countAB++;
			$totalAB += $score[$student];
			$total_squared_AB += $score[$student]**2;
			$countBC++;
			$totalBC += $score[$student];
			$total_squared_BC += $score[$student]**2;
			$countBD++;
			$totalBD += $score[$student];
			$total_squared_BD += $score[$student]**2;
		}
		elsif($num_choices[$student][$question]==3) {
			$countC++;
			$totalC += $score[$student];
			$total_squared_C += $score[$student]**2;
			$countAC++;
			$totalAC += $score[$student];
			$total_squared_AC += $score[$student]**2;
			$countBC++;
			$totalBC += $score[$student];
			$total_squared_BC += $score[$student]**2;
			$countCD++;
			$totalCD += $score[$student];
			$total_squared_CD += $score[$student]**2;
		}
		else {
			$countD++;
			$totalD += $score[$student];
			$total_squared_D += $score[$student]**2;
			$countAD++;
			$totalAD += $score[$student];
			$total_squared_AD += $score[$student]**2;
			$countBD++;
			$totalBD += $score[$student];
			$total_squared_BD += $score[$student]**2;
			$countCD++;
			$totalCD += $score[$student];
			$total_squared_CD += $score[$student]**2;
		}
	}
	push @nA, $countA;
	push @pA, $countA/$numstudents;
	if($countA == 0){
		push @mA, 0;
		push @sA, 0;
	}
	elsif($countA == 1){
		push @mA, $totalA/$countA;
		push @sA, 0;
	}
	else{ 
		push @mA, $totalA/$countA;
		push @sA, sqrt(($total_squared_A-($totalA*$totalA/$countA))/($countA-1));
	}
		
	push @nB, $countB;
	push @pB, $countB/$numstudents;
	if($countB == 0){
		push @mB, 0;
		push @sB, 0;
	}
	elsif($countB == 1){
		push @mB, $totalB/$countB;
		push @sB, 0;
	}
	else{ 
		push @mB, $totalB/$countB;
		push @sB, sqrt(($total_squared_B-($totalB*$totalB/$countB))/($countB-1));
	}
		
	push @nC, $countC;
	push @pC, $countC/$numstudents;
	if($countC == 0){
		push @mC, 0;
		push @sC, 0;
	}
	elsif($countC == 1){
		push @mC, $totalC/$countC;
		push @sC, 0;
	}
	else{ 
		push @mC, $totalC/$countC;
		push @sC, sqrt(($total_squared_C-($totalC*$totalC/$countC))/($countC-1));
	}
		
	push @nD, $countD;
	push @pD, $countD/$numstudents;
	if($countD == 0){
		push @mD, 0;
		push @sD, 0;
	}
	elsif($countD == 1){
		push @mD, $totalD/$countD;
		push @sD, 0;
	}
	else{ 
		push @mD, $totalD/$countD;
		push @sD, sqrt(($total_squared_D-($totalD*$totalD/$countD))/($countD-1));
	}
		
	push @nAB, $countAB;
	push @pAB, $countAB/$numstudents;
	if($countAB == 0){
		push @mAB, 0;
		push @sAB, 0;
	}
	elsif($countAB == 1){
		push @mAB, $totalAB/$countAB;
		push @sAB, 0;
	}
	else{ 
		push @mAB, $totalAB/$countAB;
		push @sAB, sqrt(($total_squared_AB-($totalAB*$totalAB/$countAB))/($countAB-1));
	}
		
	push @nAC, $countAC;
	push @pAC, $countAC/$numstudents;
	if($countAC == 0){
		push @mAC, 0;
		push @sAC, 0;
	}
	elsif($countAC == 1){
		push @mAC, $totalAC/$countAC;
		push @sAC, 0;
	}
	else{ 
		push @mAC, $totalAC/$countAC;
		push @sAC, sqrt(($total_squared_AC-($totalAC*$totalAC/$countAC))/($countAC-1));
	}
		
	push @nAD, $countAD;
	push @pAD, $countAD/$numstudents;
	if($countAD == 0){
		push @mAD, 0;
		push @sAD, 0;
	}
	elsif($countAD == 1){
		push @mAD, $totalAD/$countAD;
		push @sAD, 0;
	}
	else{ 
		push @mAD, $totalAD/$countAD;
		push @sAD, sqrt(($total_squared_AD-($totalAD*$totalAD/$countAD))/($countAD-1));
	}
		
	push @nBC, $countBC;
	push @pBC, $countBC/$numstudents;
	if($countBC == 0){
		push @mBC, 0;
		push @sBC, 0;
	}
	elsif($countBC == 1){
		push @mBC, $totalBC/$countBC;
		push @sBC, 0;
	}
	else{ 
		push @mBC, $totalBC/$countBC;
		push @sBC, sqrt(($total_squared_BC-($totalBC*$totalBC/$countBC))/($countBC-1));
	}
		
	push @nBD, $countBD;
	push @pBD, $countBD/$numstudents;
	if($countBD == 0){
		push @mBD, 0;
		push @sBD, 0;
	}
	elsif($countBD == 1){
		push @mBD, $totalBD/$countBD;
		push @sBD, 0;
	}
	else{ 
		push @mBD, $totalBD/$countBD;
		push @sBD, sqrt(($total_squared_BD-($totalBD*$totalBD/$countBD))/($countBD-1));
	}
		
	push @nCD, $countCD;
	push @pCD, $countCD/$numstudents;
	if($countCD == 0){
		push @mCD, 0;
		push @sCD, 0;
	}
	elsif($countCD == 1){
		push @mCD, $totalCD/$countCD;
		push @sCD, 0;
	}
	else{ 
		push @mCD, $totalCD/$countCD;
		push @sCD, sqrt(($total_squared_CD-($totalCD*$totalCD/$countCD))/($countCD-1));
	}
}

# Now we run a loop to calculate PBDCa, PBDCb, PBDCc, and PBDCd
# Initialize the arrays first	
@PBDCa = @PBDCb = @PBDCc = @PBDCd = ();

for($question=0;$question<$numquestions;$question++){
	if($num_key[$question] == 1){
		push @PBDCa, "NA"; 
		push @PBDCb, (($mB[$question]-$mAB[$question])/$sAB[$question])*sqrt($pB[$question]/$pA[$question]); 
		push @PBDCc, (($mC[$question]-$mAC[$question])/$sAC[$question])*sqrt($pC[$question]/$pA[$question]); 
		push @PBDCd, (($mD[$question]-$mAD[$question])/$sAD[$question])*sqrt($pD[$question]/$pA[$question]); 
	} 
	elsif($num_key[$question] == 2){
		push @PBDCa, (($mA[$question]-$mAB[$question])/$sAB[$question])*sqrt($pA[$question]/$pB[$question]); 
		push @PBDCb, "NA"; 
		push @PBDCc, (($mC[$question]-$mBC[$question])/$sBC[$question])*sqrt($pC[$question]/$pB[$question]); 
		push @PBDCd, (($mD[$question]-$mBD[$question])/$sBD[$question])*sqrt($pD[$question]/$pB[$question]); 
	} 
	elsif($num_key[$question] == 3){
		push @PBDCa, (($mA[$question]-$mAC[$question])/$sAC[$question])*sqrt($pA[$question]/$pC[$question]); 
		push @PBDCb, (($mB[$question]-$mBC[$question])/$sBC[$question])*sqrt($pB[$question]/$pC[$question]); 
		push @PBDCc, "NA"; 
		push @PBDCd, (($mD[$question]-$mCD[$question])/$sCD[$question])*sqrt($pD[$question]/$pC[$question]); 
	} 
	else{
		push @PBDCa, (($mA[$question]-$mAD[$question])/$sAD[$question])*sqrt($pA[$question]/$pD[$question]); 
		push @PBDCb, (($mB[$question]-$mBD[$question])/$sBD[$question])*sqrt($pB[$question]/$pD[$question]); 
		push @PBDCc, (($mC[$question]-$mCD[$question])/$sCD[$question])*sqrt($pC[$question]/$pD[$question]); 
		push @PBDCd, "NA"; 
	} 
}		
for($question=0;$question<$numquestions;$question++){
	$PBDC[$question][1] = $PBDCa[$question];
	$PBDC[$question][2] = $PBDCb[$question];
	$PBDC[$question][3] = $PBDCc[$question];
	$PBDC[$question][4] = $PBDCd[$question];
}


# +--------------------------------------------------------------------------+ #
# |              Calculating the skew and kurtosis values for p              | #
# +--------------------------------------------------------------------------+ #

for($quest=0; $quest<$numquestions; $quest++) {
	$p_calc+=$p[$quest];
}

$p_average = $p_calc/$numquestions;

for($quest=0; $quest<$numquestions; $quest++) {
	$var_sum_p+=($p[$quest]-$p_average)**2;
	$skew_sum_p+=($p[$quest]-$p_average)**3;
	$kurt_sum_p+=($p[$quest]-$p_average)**4;
}
$m2_p=$var_sum_p/$numquestions;
$m3_p=$skew_sum_p/$numquestions;
$m4_p=$kurt_sum_p/$numquestions;

$g1_p=$m3_p/sqrt($m2_p**3);
$skew_p=sqrt($numquestions*($numquestions-1))/($numquestions-2)*$g1_p;
$SES_p=sqrt((6*$numquestions*($numquestions-1))/(($numquestions-1)*($numquestions+1)*($numquestions+3)));
$Z_skew_p=$skew_p/$SES_p;

$g2_p=($m4_p/($m2_p)**2)-3;
$kurtosis_p=($numquestions-1)/(($numquestions-2)*($numquestions-3))*(($numquestions+1)*$g2_p+6);
$SEK_p=2*$SES_p*sqrt(($numquestions**2-1)/(($numquestions-3)*($numquestions+5)));
$Z_kurtosis_p=$kurtosis_p/$SEK_p;

$DP_p=($skew_p)**2+($kurtosis_p)**2;


# +--------------------------------------------------------------------------+ #
# |             Calculating the skew and kurtosis values for r_pbi           | #
# +--------------------------------------------------------------------------+ #

for($quest=0; $quest<$numquestions; $quest++) {
	$r_calc+=$r_pbi[$quest];
}

$r_average = $r_calc/$numquestions;

for($quest=0; $quest<$numquestions; $quest++) {
	$var_sum_r+=($r_pbi[$quest]-$r_average)**2;
	$skew_sum_r+=($r_pbi[$quest]-$r_average)**3;
	$kurt_sum_r+=($r_pbi[$quest]-$r_average)**4;
}
$m2_r=$var_sum_r/$numquestions;
$m3_r=$skew_sum_r/$numquestions;
$m4_r=$kurt_sum_r/$numquestions;

$g1_r=$m3_r/sqrt($m2_r**3);
$skew_r=sqrt($numquestions*($numquestions-1))/($numquestions-2)*$g1_r;
$SES_r=sqrt((6*$numquestions*($numquestions-1))/(($numquestions-1)*($numquestions+1)*($numquestions+3)));
$Z_skew_r=$skew_r/$SES_r;

$g2_r=($m4_r/($m2_r)**2)-3;
$kurtosis_r=($numquestions-1)/(($numquestions-2)*($numquestions-3))*(($numquestions+1)*$g2_r+6);
$SEK_r=2*$SES_r*sqrt(($numquestions**2-1)/(($numquestions-3)*($numquestions+5)));
$Z_kurtosis_r=$kurtosis_r/$SEK_r;

$DP_r=($skew_r)**2+($kurtosis_r)**2;


# +--------------------------------------------------------------------------+ #
# |                  Performing exam reliability calculations                | #
# +--------------------------------------------------------------------------+ #

for ($question=0; $question<$numquestions; $question++) {
	$item_var=$item_var+($p[$question]*$q[$question]);
}

$KR20=($numquestions/($numquestions-1))*(1-($item_var/($stdev**2)));
$KR21=($numquestions/($numquestions-1))*(1-($average*($numquestions-$average)/($numquestions*$stdev**2)));
$seMeasure=$stdev_score*sqrt(1-$KR20)*sqrt($KR20);
$seMeasure_percent=$seMeasure/$maxpoints*100;
$true_conf=1.28*$seMeasure;

for ($loop=0; $loop<$numstudents; $loop++) {
	$true_score[$loop]=$average_score+($KR20*($score[$loop]-$average_score));
}


# +--------------------------------------------------------------------------+ #
# |         Calculating performance by course learning objective             | #
# +--------------------------------------------------------------------------+ #

for ($student=0; $student<$numstudents; $student++) {
	for ($question=0; $question<$numquestions; $question++) {
		if ($objective[$question] =~ /^A/) {
			$A_sum[$student]+=$scores[$student][$question];
			$A_max[$student]+=$points[$question];
		}
		elsif ($objective[$question] =~ /^B/) {
			$B_sum[$student]+=$scores[$student][$question];
			$B_max[$student]+=$points[$question];
		}
		elsif ($objective[$question] =~ /^C/) {
			$C_sum[$student]+=$scores[$student][$question];
			$C_max[$student]+=$points[$question];
		}
		elsif ($objective[$question] =~ /^D/) {
			$D_sum[$student]+=$scores[$student][$question];
			$D_max[$student]+=$points[$question];
		}
		elsif ($objective[$question] =~ /^E/) {
			$E_sum[$student]+=$scores[$student][$question];
			$E_max[$student]+=$points[$question];
		}
		elsif ($objective[$question] =~ /^F/) {
			$F_sum[$student]+=$scores[$student][$question];
			$F_max[$student]+=$points[$question];
		}
	}
	
	if ($A_max[$student]>0) {
		$A_points+=$A_sum[$student];
		$A_squared_points=($A_sum[$student])*($A_sum[$student]);
		$A_total_squared_points+=$A_squared_points;
		
		$A_total+=$A_sum[$student]/$A_max[$student]*100;
		$A_squared[$student]=($A_sum[$student]/$A_max[$student]*100)*($A_sum[$student]/$A_max[$student]*100);
		$A_total_squared+=$A_squared[$student];
		if ($A_sum[$student]/$A_max[$student]*100 >= $report{'criterion'} ) {
			$meto[1]++;
		}
	}	
	if ($B_max[$student]>0) {
		$B_points+=$B_sum[$student];
		$B_squared_points=($B_sum[$student])*($B_sum[$student]);
		$B_total_squared_points+=$B_squared_points;
		
		$B_total+=$B_sum[$student]/$B_max[$student]*100;
		$B_squared[$student]=($B_sum[$student]/$B_max[$student]*100)*($B_sum[$student]/$B_max[$student]*100);
		$B_total_squared+=$B_squared[$student];
		if ($B_sum[$student]/$B_max[$student]*100 >= $report{'criterion'} ) {
			$meto[2]++;
		}
	}	
	if ($C_max[$student]>0) {
		$C_points+=$C_sum[$student];
		$C_squared_points=($C_sum[$student])*($C_sum[$student]);
		$C_total_squared_points+=$C_squared_points;
		
		$C_total+=$C_sum[$student]/$C_max[$student]*100;
		$C_squared[$student]=($C_sum[$student]/$C_max[$student]*100)*($C_sum[$student]/$C_max[$student]*100);
		$C_total_squared+=$C_squared[$student];
		if ($C_sum[$student]/$C_max[$student]*100 >= $report{'criterion'} ) {
			$meto[3]++;
		}	
	}	
	if ($D_max[$student]>0) {
		$D_points+=$D_sum[$student];
		$D_squared_points=($D_sum[$student])*($D_sum[$student]);
		$D_total_squared_points+=$D_squared_points;
		
		$D_total+=$D_sum[$student]/$D_max[$student]*100;
		$D_squared[$student]=($D_sum[$student]/$D_max[$student]*100)*($D_sum[$student]/$D_max[$student]*100);
		$D_total_squared+=$D_squared[$student];
		if ($D_sum[$student]/$D_max[$student]*100 >= $report{'criterion'} ) {
			$meto[4]++;
		}
	}	
	if ($E_max[$student]>0) {
		$E_points+=$E_sum[$student];
		$E_squared_points=($E_sum[$student])*($E_sum[$student]);
		$E_total_squared_points+=$E_squared_points;
		
		$E_total+=$E_sum[$student]/$E_max[$student]*100;
		$E_squared[$student]=($E_sum[$student]/$E_max[$student]*100)*($E_sum[$student]/$E_max[$student]*100);
		$E_total_squared+=$E_squared[$student];
		if ($E_sum[$student]/$E_max[$student]*100 >= $report{'criterion'} ) {
			$meto[5]++;
		}
	}	
	if ($F_max[$student]>0) {
		$F_points+=$F_sum[$student];
		$F_squared_points=($F_sum[$student])*($F_sum[$student]);
		$F_total_squared_points+=$F_squared_points;
		
		$F_total+=$F_sum[$student]/$F_max[$student]*100;
		$F_squared[$student]=($F_sum[$student]/$F_max[$student]*100)*($F_sum[$student]/$F_max[$student]*100);
		$F_total_squared+=$F_squared[$student];
		if ($F_sum[$student]/$F_max[$student]*100 >= $report{'criterion'} ) {
			$meto[6]++;
		}
	}		
}

if ($A_max[0]>0) {
	$numobjs++;
	$A_max=$A_max[0];
	
	$A_average_points=$A_points/$numstudents;
	$A_stdev_points=sqrt(($A_total_squared_points-($A_points*$A_average_points))/($numstudents-1));
	$A_stderr_points=$A_stdev_points/sqrt($numstudents);
	$A_conf_points=$A_stderr_points*1.96;
	
	$A_average=$A_total/$numstudents;
	$A_stdev=sqrt(($A_total_squared-($A_total*$A_average))/($numstudents-1));
	$A_stderr=$A_stdev/sqrt($numstudents);
	$A_conf=$A_stderr*1.96;
}
if ($B_max[0]>0) {
	$numobjs++;
	$B_max=$B_max[0];
	
	$B_average_points=$B_points/$numstudents;
	$B_stdev_points=sqrt(($B_total_squared_points-($B_points*$B_average_points))/($numstudents-1));
	$B_stderr_points=$B_stdev_points/sqrt($numstudents);
	$B_conf_points=$B_stderr_points*1.96;
	
	$B_average=$B_total/$numstudents;
	$B_stdev=sqrt(($B_total_squared-($B_total*$B_average))/($numstudents-1));
	$B_stderr=$B_stdev/sqrt($B_max);
	$B_conf=$B_stderr*1.96;
}
if ($C_max[0]>0) {
	$numobjs++;
	$C_max=$C_max[0];
	
	$C_average_points=$C_points/$numstudents;
	$C_stdev_points=sqrt(($C_total_squared_points-($C_points*$C_average_points))/($numstudents-1));
	$C_stderr_points=$C_stdev_points/sqrt($numstudents);
	$C_conf_points=$C_stderr_points*1.96;
	
	$C_average=$C_total/$numstudents;
	$C_stdev=sqrt(($C_total_squared-($C_total*$C_average))/($numstudents-1));
	$C_stderr=$C_stdev/sqrt($C_max);
	$C_conf=$C_stderr*1.96;
}
if ($D_max[0]>0) {
	$numobjs++;
	$D_max=$D_max[0];
	
	$D_average_points=$D_points/$numstudents;
	$D_stdev_points=sqrt(($D_total_squared_points-($D_points*$D_average_points))/($numstudents-1));
	$D_stderr_points=$D_stdev_points/sqrt($numstudents);
	$D_conf_points=$D_stderr_points*1.96;
	
	$D_average=$D_total/$numstudents;
	$D_stdev=sqrt(($D_total_squared-($D_total*$D_average))/($numstudents-1));
	$D_stderr=$D_stdev/sqrt($D_max);
	$D_conf=$D_stderr*1.96;
}
if ($E_max[0]>0) {
	$numobjs++;
	$E_max=$E_max[0];
	
	$E_average_points=$E_points/$numstudents;
	$E_stdev_points=sqrt(($E_total_squared_points-($E_points*$E_average_points))/($numstudents-1));
	$E_stderr_points=$E_stdev_points/sqrt($numstudents);
	$E_conf_points=$E_stderr_points*1.96;
	
	$E_average=$E_total/$numstudents;
	$E_stdev=sqrt(($E_total_squared-($E_total*$E_average))/($numstudents-1));
	$E_stderr=$E_stdev/sqrt($E_max);
	$E_conf=$E_stderr*1.96;
}
if ($F_max[0]>0) {
	$numobjs++;
	$F_max=$F_max[0];
	
	$F_average_points=$F_points/$numstudents;
	$F_stdev_points=sqrt(($F_total_squared_points-($F_points*$F_average_points))/($numstudents-1));
	$F_stderr_points=$F_stdev_points/sqrt($numstudents);
	$F_conf_points=$F_stderr_points*1.96;
	
	$F_average=$F_total/$numstudents;
	$F_stdev=sqrt(($F_total_squared-($F_total*$F_average))/($numstudents-1));
	$F_stderr=$F_stdev/sqrt($F_max);
	$F_conf=$F_stderr*1.96;
}	

push @objective_averages, "0";
push @objective_averages, $A_average;
push @objective_averages, $B_average;
push @objective_averages, $C_average;
push @objective_averages, $D_average;
push @objective_averages, $E_average;
push @objective_averages, $F_average;

push @objective_ave_points, "0";
push @objective_ave_points, $A_average_points;
push @objective_ave_points, $B_average_points;
push @objective_ave_points, $C_average_points;
push @objective_ave_points, $D_average_points;
push @objective_ave_points, $E_average_points;
push @objective_ave_points, $F_average_points;

push @objective_stdevs, "0";
push @objective_stdevs, $A_stdev;
push @objective_stdevs, $B_stdev;
push @objective_stdevs, $C_stdev;
push @objective_stdevs, $D_stdev;
push @objective_stdevs, $E_stdev;
push @objective_stdevs, $F_stdev;

push @objective_stderrs, "0";
push @objective_stderrs, $A_stderr;
push @objective_stderrs, $B_stderr;
push @objective_stderrs, $C_stderr;
push @objective_stderrs, $D_stderr;
push @objective_stderrs, $E_stderr;
push @objective_stderrs, $F_stderr;

push @objective_conf, "0";
push @objective_conf, $A_conf;
push @objective_conf, $B_conf;
push @objective_conf, $C_conf;
push @objective_conf, $D_conf;
push @objective_conf, $E_conf;
push @objective_conf, $F_conf;

push @objective_conf_points, "0";
push @objective_conf_points, $A_conf_points;
push @objective_conf_points, $B_conf_points;
push @objective_conf_points, $C_conf_points;
push @objective_conf_points, $D_conf_points;
push @objective_conf_points, $E_conf_points;
push @objective_conf_points, $F_conf_points;

push @objective_max, "0";
push @objective_max, $A_max;
push @objective_max, $B_max;
push @objective_max, $C_max;
push @objective_max, $D_max;
push @objective_max, $E_max;
push @objective_max, $F_max;


if ($numobjs==1) {
	@crit_obj=@crit_050;
	$crit_val_obj=0.05;
}
elsif ($numobjs==2) {
	@crit_obj=@crit_020;
	$crit_val_obj=0.020;	
}
elsif ($numobjs<6) {
	@crit_obj=@crit_010;
	$crit_val_obj=0.01;
}
elsif ($numobjs<11) {
	@crit_obj=@crit_005;
	$crit_val_obj=0.005;
}
elsif ($numobjs<25) {
	@crit_obj=@crit_002;
	$crit_val_obj=0.002;
}
else {
	@crit_obj=@crit_001;
	$crit_val_obj=0.001;
}

$df=$numstudents-1;

for ($loop=1; $loop<=6; $loop++) {
	if ($objective_averages[$loop] > 0) {
		$objective_t[$loop]=($objective_averages[$loop]-$report{'criterion'})/$objective_stderrs[$loop];
		$objective_d[$loop]=($objective_averages[$loop]-$report{'criterion'})/$objective_stdevs[$loop];		
		$objective_size[$loop]=abs(($objective_averages[$loop]-$report{'criterion'})/$objective_stdevs[$loop]);
		if (abs($objective_t[$loop])>$crit_obj[$df]) {
			if ($objective_t[$loop]>0) {
				$objective_sig[$loop]=1;
			}
			else {
				$objective_sig[$loop]=-1;
			}
		}
		else {
			$objective_sig[$loop]=0;
		}
	}
}



# +--------------------------------------------------------------------------+ #
# |                Gathering data for the exam blueprint table               | #
# +--------------------------------------------------------------------------+ #

for ($question=0; $question<$numquestions; $question++) {
	if ($lecture[$question] eq @report{'lec1'}) {$row=1;}
	elsif ($lecture[$question] eq @report{'lec2'}) {$row=2;}
	elsif ($lecture[$question] eq @report{'lec3'}) {$row=3;}
	elsif ($lecture[$question] eq @report{'lec4'}) {$row=4;}
	elsif ($lecture[$question] eq @report{'lec5'}) {$row=5;}
	elsif ($lecture[$question] eq @report{'lec6'}) {$row=6;}
	elsif ($lecture[$question] eq @report{'lec7'}) {$row=7;}
	elsif ($lecture[$question] eq @report{'lec8'}) {$row=8;}
	elsif ($lecture[$question] eq @report{'lec9'}) {$row=9;}
	elsif ($lecture[$question] eq @report{'lec10'}) {$row=10;}
	else {$row=11;}
	
	if ($skill[$question] eq "Identifying") {$col=1;}
	elsif ($skill[$question] eq "Categorizing") {$col=2;}
	elsif ($skill[$question] eq "Calculating") {$col=3;}
	elsif ($skill[$question] eq "Interpreting") {$col=4;}
	elsif ($skill[$question] eq "Predicting") {$col=5;}
	elsif ($skill[$question] eq "Judging") {$col=6;}
	else {$col=7;}

	$specification[0][$col]=$specification[0][$col]+$points[$question];
	$specification[$row][0]=$specification[$row][0]+$points[$question];
	$specification[$row][$col]=$specification[$row][$col]+$points[$question];
	$specification[0][0]=$specification[0][0]+$points[$question];
}


# +--------------------------------------------------------------------------+ #
# |                    Aggregating scores by content area                    | #
# +--------------------------------------------------------------------------+ #

for ($student=0; $student<$numstudents; $student++) {
	for ($question=0; $question<$numquestions; $question++) {
		if ($lecture[$question] eq @report{'lec1'}) {
			$content1_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec2'}) {
			$content2_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec3'}) {
			$content3_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec4'}) {
			$content4_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec5'}) {
			$content5_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec6'}) {
			$content6_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec7'}) {
			$content7_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec8'}) {
			$content8_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec9'}) {
			$content9_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($lecture[$question] eq @report{'lec10'}) {
			$content10_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		else {
			$content11_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}


# +--------------------------------------------------------------------------+ #
# |                   Aggregating scores by reasoning skills                 | #
# +--------------------------------------------------------------------------+ #
	
		if ($skill[$question] eq "Identifying") {
			$skill1_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($skill[$question] eq "Categorizing") {
			$skill2_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($skill[$question] eq "Calculating") {
			$skill3_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($skill[$question] eq "Interpreting") {
			$skill4_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		elsif ($skill[$question] eq "Predicting") {
			$skill5_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
		else {
			$skill6_sum[$student]+=($grades[$student][$question]*$points[$question]);
		}
	}
	if ($specification[1][0] > 0 && $content1_sum[$student]/$specification[1][0]*100 >= $report{'criterion'}) {$metc1++;}
	if ($specification[2][0] > 0 && $content2_sum[$student]/$specification[2][0]*100 >= $report{'criterion'}) {$metc2++;}
	if ($specification[3][0] > 0 && $content3_sum[$student]/$specification[3][0]*100 >= $report{'criterion'}) {$metc3++;}
	if ($specification[4][0] > 0 && $content4_sum[$student]/$specification[4][0]*100 >= $report{'criterion'}) {$metc4++;}
	if ($specification[5][0] > 0 && $content5_sum[$student]/$specification[5][0]*100 >= $report{'criterion'}) {$metc5++;}
	if ($specification[6][0] > 0 && $content6_sum[$student]/$specification[6][0]*100 >= $report{'criterion'}) {$metc6++;}
	if ($specification[7][0] > 0 && $content7_sum[$student]/$specification[7][0]*100 >= $report{'criterion'}) {$metc7++;}
	if ($specification[8][0] > 0 && $content8_sum[$student]/$specification[8][0]*100 >= $report{'criterion'}) {$metc8++;}
	if ($specification[9][0] > 0 && $content9_sum[$student]/$specification[9][0]*100 >= $report{'criterion'}) {$metc9++;}
	if ($specification[10][0] > 0 && $content10_sum[$student]/$specification[10][0]*100 >= $report{'criterion'}) {$metc10++;}
	if ($specification[11][0] > 0 && $content11_sum[$student]/$specification[11][0]*100 >= $report{'criterion'}) {$metc11++;}
	
	if ($specification[0][1] > 0 && $skill1_sum[$student]/$specification[0][1]*100 >= $report{'criterion'}) {$metb1++;}
	if ($specification[0][2] > 0 && $skill2_sum[$student]/$specification[0][2]*100 >= $report{'criterion'}) {$metb2++;}
	if ($specification[0][3] > 0 && $skill3_sum[$student]/$specification[0][3]*100 >= $report{'criterion'}) {$metb3++;}
	if ($specification[0][4] > 0 && $skill4_sum[$student]/$specification[0][4]*100 >= $report{'criterion'}) {$metb4++;}
	if ($specification[0][5] > 0 && $skill5_sum[$student]/$specification[0][5]*100 >= $report{'criterion'}) {$metb5++;}
	if ($specification[0][6] > 0 && $skill6_sum[$student]/$specification[0][6]*100 >= $report{'criterion'}) {$metb6++;}
	
}

@skill_desc = ("Skills","respond to these questions by simply recalling memorized factual information. Although these items may involve remembering a wide range of material from specific facts to complete theories, all that is required is the bringing to mind of the appropriate information. ","demonstrate an ability to grasp broader concepts or the meaning of the material from class. The items may require students to identify examples of a category, classify specific items into groups, summarize concepts, or compare and contrast material. ","exhibit an ability to calculate an appropriate answer to a mathematical problem. The students may or may not be provided with the necessary formulae and mor or may not be allowed to use calculators to find their answers. ","show an ability to use critical thinking skills to evaluate data presented in illustrations, tables, graphs, or case studies. The students need to discern the relevant information and correctly apply it in order to respond to the item. ","apply their understanding of microbiological concepts to accurately forecast the results of specific perturbations to a biological system. ","display the ability to judge the most appropriate of a particular action, explanation, or potential solution for a given purpose. Their conclusions would be based on definite criteria, which may be internal (organization) or external (relevance to the purpose). ");

push @metc, ($metc1, $metc2, $metc3, $metc4, $metc5, $metc6, $metc7, $metc8, $metc9, $metc10, $metc11);
push @metb, ($metb1, $metb2, $metb3, $metb4, $metb5, $metb6);

for ($question=0; $question<$numquestions; $question++) {
	if ($skill[$question] eq "Identifying") {
			push @skill1q, $question+1;
	}
	elsif ($skill[$question] eq "Categorizing") {
			push @skill2q, $question+1;
	}
	elsif ($skill[$question] eq "Calculating") {
			push @skill3q, $question+1;
	}
	elsif ($skill[$question] eq "Interpreting") {
			push @skill4q, $question+1;
	}
	elsif ($skill[$question] eq "Predicting") {
			push @skill5q, $question+1;
	}
	else {
			push @skill6q, $question+1;
	}
}

for ($question=0; $question<$numquestions; $question++) {
	if ($lecture[$question] eq @report{'lec1'}) {
		push @content1q, $question+1;
	}
	elsif ($lecture[$question] eq @report{'lec2'}) {
		push @content2q, $question+1;
	}
	elsif ($lecture[$question] eq @report{'lec3'}) {
		push @content3q, $question+1;
	}
	elsif ($lecture[$question] eq @report{'lec4'}) {
		push @content4q, $question+1;
	}
	elsif ($lecture[$question] eq @report{'lec5'}) {
		push @content5q, $question+1;
	}
	elsif ($lecture[$question] eq @report{'lec6'}) {
		push @content6q, $question+1;
	}
	elsif ($lecture[$question] eq @report{'lec7'}) {
		push @content7q, $question+1;
	}
	elsif ($lecture[$question] eq @report{'lec8'}) {
		push @content8q, $question+1;
	}
	elsif ($lecture[$question] eq @report{'lec9'}) {
		push @content9q, $question+1;
	}
	else {
		push @content10q, $value;
	}
}


# +--------------------------------------------------------------------------+ #
# |       Making sure that a directory exists for the data file              | #
# +--------------------------------------------------------------------------+ #

	$reportpath="$directory/reports/";
	if (-e $reportpath && -d $reportpath) {
		#the directory exists
	}
	else {mkdir $reportpath}

# +--------------------------------------------------------------------------+ #
# |          Creating a tab-delimited data file for the assessment           | #
# +--------------------------------------------------------------------------+ #

# Open a file for writing
open(DATAFILE, ">$directory/reports/$report{'statfile'}") or die("Cannot open file for writing");

# The maximum values possible
print DATAFILE "Maximum\tPoints\tPossible\t";
if ($report{'var1'}) {
	print DATAFILE "\t";
}
if ($report{'var2'}) {
	print DATAFILE "\t";
}
if ($report{'var3'}) {
	print DATAFILE "\t";
}
for ($qnum=0; $qnum<$numquestions; $qnum++) {
	print DATAFILE $points[$qnum] ."\t";
}
if ($report{'outcome1'}) {
	print DATAFILE $A_max."\t";
}
if ($report{'outcome2'}) {
	print DATAFILE $B_max."\t";
}
if ($report{'outcome3'}) {
	print DATAFILE $C_max."\t";
}
if ($report{'outcome4'}) {
	print DATAFILE $D_max."\t";
}
if ($report{'outcome5'}) {
	print DATAFILE $E_max."\t";
}
if ($report{'outcome6'}) {
	print DATAFILE $F_max."\t";
}
if ($report{'lec1'}) {
	print DATAFILE $specification[1][0]."\t";
}
if ($report{'lec2'}) {
	print DATAFILE $specification[2][0]."\t";
}
if ($report{'lec3'}) {
	print DATAFILE $specification[3][0]."\t";
}
if ($report{'lec4'}) {
	print DATAFILE $specification[4][0]."\t";
}
if ($report{'lec5'}) {
	print DATAFILE $specification[5][0]."\t";
}
if ($report{'lec6'}) {
	print DATAFILE $specification[6][0]."\t";
}
if ($report{'lec7'}) {
	print DATAFILE $specification[7][0]."\t";
}
if ($report{'lec8'}) {
	print DATAFILE $specification[8][0]."\t";
}
if ($report{'lec9'}) {
	print DATAFILE $specification[9][0]."\t";
}
if ($report{'lec10'}) {
	print DATAFILE $specification[10][0]."\t";
}
print DATAFILE $specification[0][1]."\t".$specification[0][2]."\t".$specification[0][3]."\t".$specification[0][4]."\t".$specification[0][5]."\t".$specification[0][6]."\t";
print DATAFILE $maxpoints . "\t";
printf DATAFILE "%4.1f \n", 100;


# Headings
print DATAFILE "Last \t First \t UserID \t";
if ($report{'var1'}) {
	print DATAFILE $report{'var1'}."\t";
}
if ($report{'var2'}) {
	print DATAFILE $report{'var2'}."\t";
}
if ($report{'var3'}) {
	print DATAFILE $report{'var3'}."\t";
}
for ($qnum=1; $qnum<=$numquestions; $qnum++) {
	print DATAFILE $qnum ."\t";
}
if ($report{'outcome1'}) {
	print DATAFILE $report{'outcome1'}."\t";
}
if ($report{'outcome2'}) {
	print DATAFILE $report{'outcome2'}."\t";
}
if ($report{'outcome3'}) {
	print DATAFILE $report{'outcome3'}."\t";
}
if ($report{'outcome4'}) {
	print DATAFILE $report{'outcome4'}."\t";
}
if ($report{'outcome5'}) {
	print DATAFILE $report{'outcome5'}."\t";
}
if ($report{'outcome6'}) {
	print DATAFILE $report{'outcome6'}."\t";
}
if ($report{'lec1'}) {
	print DATAFILE $report{'lec1'}."\t";
}
if ($report{'lec2'}) {
	print DATAFILE $report{'lec2'}."\t";
}
if ($report{'lec3'}) {
	print DATAFILE $report{'lec3'}."\t";
}
if ($report{'lec4'}) {
	print DATAFILE $report{'lec4'}."\t";
}
if ($report{'lec5'}) {
	print DATAFILE $report{'lec5'}."\t";
}
if ($report{'lec6'}) {
	print DATAFILE $report{'lec6'}."\t";
}
if ($report{'lec7'}) {
	print DATAFILE $report{'lec7'}."\t";
}
if ($report{'lec8'}) {
	print DATAFILE $report{'lec8'}."\t";
}
if ($report{'lec9'}) {
	print DATAFILE $report{'lec9'}."\t";
}
if ($report{'lec10'}) {
	print DATAFILE $report{'lec10'}."\t";
}
print DATAFILE "Identifying \t Categorizing \t Calculating \t Interpreting \t Predicting \t Judging \t";
print DATAFILE "Score \t Percent\n";


# The data
for ($loop=0; $loop<$numstudents; $loop++) {
	print DATAFILE $choices[$loop][0]."\t".$choices[$loop][1]."\t".$choices[$loop][2]."\t";
	if ($report{'var1'}) {
		print DATAFILE $choices[$loop][4]."\t";
	}
	if ($report{'var2'}) {
		print DATAFILE $choices[$loop][5]."\t";
	}
	if ($report{'var3'}) {
		print DATAFILE $choices[$loop][6]."\t";
	}
	for ($question=0; $question<$numquestions; $question++) {
		print DATAFILE $scores[$loop][$question]."\t";
	}
	if ($report{'outcome1'}) {
		print DATAFILE $A_sum[$loop]."\t";
	}
	if ($report{'outcome2'}) {
		print DATAFILE $B_sum[$loop]."\t";
	}
	if ($report{'outcome3'}) {
		print DATAFILE $C_sum[$loop]."\t";
	}
	if ($report{'outcome4'}) {
		print DATAFILE $D_sum[$loop]."\t";
	}
	if ($report{'outcome5'}) {
		print DATAFILE $E_sum[$loop]."\t";
	}
	if ($report{'outcome6'}) {
		print DATAFILE $F_sum[$loop]."\t";
	}
	if ($report{'lec1'}) {
		print DATAFILE $content1_sum[$loop]."\t";
	}
	if ($report{'lec2'}) {
		print DATAFILE $content2_sum[$loop]."\t";
	}
	if ($report{'lec3'}) {
		print DATAFILE $content3_sum[$loop]."\t";
	}
	if ($report{'lec4'}) {
		print DATAFILE $content4_sum[$loop]."\t";
	}
	if ($report{'lec5'}) {
		print DATAFILE $content5_sum[$loop]."\t";
	}
	if ($report{'lec6'}) {
		print DATAFILE $content6_sum[$loop]."\t";
	}
	if ($report{'lec7'}) {
		print DATAFILE $content7_sum[$loop]."\t";
	}
	if ($report{'lec8'}) {
		print DATAFILE $content8_sum[$loop]."\t";
	}
	if ($report{'lec9'}) {
		print DATAFILE $content9_sum[$loop]."\t";
	}
	if ($report{'lec10'}) {
		print DATAFILE $content10_sum[$loop]."\t";
	}
	print DATAFILE $skill1_sum[$loop] . "\t" . $skill2_sum[$loop] . "\t" . $skill3_sum[$loop] . "\t" . $skill4_sum[$loop] . "\t" . $skill5_sum[$loop] . "\t" . $skill6_sum[$loop]."\t";
	print DATAFILE $score[$loop] . "\t";
	printf DATAFILE "%4.1f \n", $score[$loop]/$maxpoints*100;
}
close(DATAFILE);



# Creating another file with item analysis
# Open a file for writing
open(DATAFILE, ">$directory/reports/item_analysis.txt") or die("Cannot open file for writing");
print DATAFILE "Question \t Key \t Facility \t PBc \t nA \t nB \t nC \t nD \t PBDCa \t PBDCb \t PBDCc \t PBDCd \n";
for($question=0;$question<$numquestions;$question++){
	print DATAFILE $question+1,"\t";
	print DATAFILE $key[$question],"\t";
	print DATAFILE $p[$question],"\t";
	print DATAFILE $r_pbi[$question],"\t";
	print DATAFILE $nA[$question],"\t";
	print DATAFILE $nB[$question],"\t";
	print DATAFILE $nC[$question],"\t";
	print DATAFILE $nD[$question],"\t";
	print DATAFILE $PBDCa[$question],"\t";
	print DATAFILE $PBDCb[$question],"\t";
	print DATAFILE $PBDCc[$question],"\t";
	print DATAFILE $PBDCd[$question],"\n";
	}
close(DATAFILE);


# +--------------------------------------------------------------------------+ #
# |                   Calculating statistics by content area                 | #
# +--------------------------------------------------------------------------+ #

for ($counter=0; $counter<$numstudents; $counter++) {
	$content1_total+=$content1_sum[$counter];
	$content1_squared_sum+=($content1_sum[$counter])**2;
	$content2_total+=$content2_sum[$counter];
	$content2_squared_sum+=($content2_sum[$counter])**2;
	$content3_total+=$content3_sum[$counter];
	$content3_squared_sum+=($content3_sum[$counter])**2;
	$content4_total+=$content4_sum[$counter];
	$content4_squared_sum+=($content4_sum[$counter])**2;
	$content5_total+=$content5_sum[$counter];
	$content5_squared_sum+=($content5_sum[$counter])**2;
	$content6_total+=$content6_sum[$counter];
	$content6_squared_sum+=($content6_sum[$counter])**2;
	$content7_total+=$content7_sum[$counter];
	$content7_squared_sum+=($content7_sum[$counter])**2;
	$content8_total+=$content8_sum[$counter];
	$content8_squared_sum+=($content8_sum[$counter])**2;
	$content9_total+=$content9_sum[$counter];
	$content9_squared_sum+=($content9_sum[$counter])**2;
	$content10_total+=$content10_sum[$counter];
	$content10_squared_sum+=($content10_sum[$counter])**2;
	$content11_total+=$content11_sum[$counter];
	$content11_squared_sum+=($content11_sum[$counter])**2;
}

if ($specification[1][0]>0) {
	$numcats++;
	$content1_average=$content1_total/$numstudents;
	$content1_stdev=sqrt(($content1_squared_sum-($content1_total*$content1_average))/($numstudents-1));
	$content1_stderr=$content1_stdev/sqrt($numstudents);
	$content1_conf=$content1_stderr*1.96;
	push @content_ave_score, $content1_average;
	push @content_conf_score, $content1_conf;
	push @content_averages, $content1_average*100/$specification[1][0];
	push @content_stdevs, $content1_stdev*100/$specification[1][0];
	push @content_stderrs, $content1_stderr*100/$specification[1][0];
	push @content_conf, $content1_conf*100/$specification[1][0];
}

if ($specification[2][0]>0) {
	$numcats++;
	$content2_average=$content2_total/$numstudents;
	$content2_stdev=sqrt(($content2_squared_sum-($content2_total*$content2_average))/($numstudents-1));
	$content2_stderr=$content2_stdev/sqrt($numstudents);
	$content2_conf=$content2_stderr*1.96;
	push @content_ave_score, $content2_average;
	push @content_conf_score, $content2_conf;
	push @content_averages, $content2_average*100/$specification[2][0];
	push @content_stdevs, $content2_stdev*100/$specification[2][0];
	push @content_stderrs, $content2_stderr*100/$specification[2][0];
	push @content_conf, $content2_conf*100/$specification[2][0];
}

if ($specification[3][0]>0) {
	$numcats++;
	$content3_average=$content3_total/$numstudents;
	$content3_stdev=sqrt(($content3_squared_sum-($content3_total*$content3_average))/($numstudents-1));
	$content3_stderr=$content3_stdev/sqrt($numstudents);
	$content3_conf=$content3_stderr*1.96;
	push @content_ave_score, $content3_average;
	push @content_conf_score, $content3_conf;
	push @content_averages, $content3_average*100/$specification[3][0];
	push @content_stdevs, $content3_stdev*100/$specification[3][0];
	push @content_stderrs, $content3_stderr*100/$specification[3][0];
	push @content_conf, $content3_conf*100/$specification[3][0];
}

if ($specification[4][0]>0) {
	$numcats++;
	$content4_average=$content4_total/$numstudents;
	$content4_stdev=sqrt(($content4_squared_sum-($content4_total*$content4_average))/($numstudents-1));
	$content4_stderr=$content4_stdev/sqrt($numstudents);
	$content4_conf=$content4_stderr*1.96;
	push @content_ave_score, $content4_average;
	push @content_conf_score, $content4_conf;
	push @content_averages, $content4_average*100/$specification[4][0];
	push @content_stdevs, $content4_stdev*100/$specification[4][0];
	push @content_stderrs, $content4_stderr*100/$specification[4][0];
	push @content_conf, $content4_conf*100/$specification[4][0];
}

if ($specification[5][0]>0) {
	$numcats++;
	$content5_average=$content5_total/$numstudents;
	$content5_stdev=sqrt(($content5_squared_sum-($content5_total*$content5_average))/($numstudents-1));
	$content5_stderr=$content5_stdev/sqrt($numstudents);
	$content5_conf=$content5_stderr*1.96;
	push @content_ave_score, $content5_average;
	push @content_conf_score, $content5_conf;
	push @content_averages, $content5_average*100/$specification[5][0];
	push @content_stdevs, $content5_stdev*100/$specification[5][0];
	push @content_stderrs, $content5_stderr*100/$specification[5][0];
	push @content_conf, $content5_conf*100/$specification[5][0];
}

if ($specification[6][0]>0) {
	$numcats++;
	$content6_average=$content6_total/$numstudents;
	$content6_stdev=sqrt(($content6_squared_sum-($content6_total*$content6_average))/($numstudents-1));
	$content6_stderr=$content6_stdev/sqrt($numstudents);
	$content6_conf=$content6_stderr*1.96;
	push @content_ave_score, $content6_average;
	push @content_conf_score, $content6_conf;
	push @content_averages, $content6_average*100/$specification[6][0];
	push @content_stdevs, $content6_stdev*100/$specification[6][0];
	push @content_stderrs, $content6_stderr*100/$specification[6][0];
	push @content_conf, $content6_conf*100/$specification[6][0];
}

if ($specification[7][0]>0) {
	$numcats++;
	$content7_average=$content7_total/$numstudents;
	$content7_stdev=sqrt(($content7_squared_sum-($content7_total*$content7_average))/($numstudents-1));
	$content7_stderr=$content7_stdev/sqrt($numstudents);
	$content7_conf=$content7_stderr*1.96;
	push @content_ave_score, $content7_average;
	push @content_conf_score, $content7_conf;
	push @content_averages, $content7_average*100/$specification[7][0];
	push @content_stdevs, $content7_stdev*100/$specification[7][0];
	push @content_stderrs, $content7_stderr*100/$specification[7][0];
	push @content_conf, $content7_conf*100/$specification[7][0];
}

if ($specification[8][0]>0) {
	$numcats++;
	$content8_average=$content8_total/$numstudents;
	$content8_stdev=sqrt(($content8_squared_sum-($content8_total*$content8_average))/($numstudents-1));
	$content8_stderr=$content8_stdev/sqrt($numstudents);
	$content8_conf=$content8_stderr*1.96;
	push @content_ave_score, $content8_average;
	push @content_conf_score, $content8_conf;
	push @content_averages, $content8_average*100/$specification[8][0];
	push @content_stdevs, $content8_stdev*100/$specification[8][0];
	push @content_stderrs, $content8_stderr*100/$specification[8][0];
	push @content_conf, $content8_conf*100/$specification[8][0];
}

if ($specification[9][0]>0) {
	$numcats++;
	$content9_average=$content9_total/$numstudents;
	$content9_stdev=sqrt(($content9_squared_sum-($content9_total*$content9_average))/($numstudents-1));
	$content9_stderr=$content9_stdev/sqrt($numstudents);
	$content9_conf=$content9_stderr*1.96;
	push @content_ave_score, $content9_average;
	push @content_conf_score, $content9_conf;
	push @content_averages, $content9_average*100/$specification[9][0];
	push @content_stdevs, $content9_stdev*100/$specification[9][0];
	push @content_stderrs, $content9_stderr*100/$specification[9][0];
	push @content_conf, $content9_conf*100/$specification[9][0];
}

if ($specification[10][0]>0) {
	$numcats++;
	$content10_average=$content10_total/$numstudents;
	$content10_stdev=sqrt(($content10_squared_sum-($content10_total*$content10_average))/($numstudents-1));
	$content10_stderr=$content10_stdev/sqrt($numstudents);
	$content10_conf=$content10_stderr*1.96;
	push @content_ave_score, $content10_average;
	push @content_conf_score, $content10_conf;
	push @content_averages, $content10_average*100/$specification[10][0];
	push @content_stdevs, $content10_stdev*100/$specification[10][0];
	push @content_stderrs, $content10_stderr*100/$specification[10][0];
	push @content_conf, $content10_conf*100/$specification[10][0];
}

if ($specification[11][0]>0) {
	$numcats++;
	$content11_average=$content11_total/$numstudents;
	$content11_stdev=sqrt(($content11_squared_sum-($content11_total*$content11_average))/($numstudents-1));
	$content11_stderr=$content11_stdev/sqrt($numstudents);
	$content11_conf=$content11_stderr*1.96;
	push @content_ave_score, $content11_average;
	push @content_conf_score, $content11_conf;
	push @content_averages, $content11_average*100/$specification[11][0];
	push @content_stdevs, $content11_stdev*100/$specification[11][0];
	push @content_stderrs, $content11_stderr*100/$specification[11][0];
	push @content_conf, $content11_conf*100/$specification[11][0];
}

if ($numcats==1) {
	@crit_cat=@crit_050;
	$crit_val_cat=0.05;
}
elsif ($numcats==2) {
	@crit_cat=@crit_020;
	$crit_val_cat=0.020;
}
elsif ($numcats<6) {
	@crit_cat=@crit_010;
	$crit_val_cat=0.01;
}
elsif ($numcats<11) {
	@crit_cat=@crit_005;
	$crit_val_cat=0.005;
}
elsif ($numobjs<25) {
	@crit_cat=@crit_002;
	$crit_val_cat=0.002;
}
else {
	@crit_cat=@crit_001;
	$crit_val_cat=0.001;
}

$df=$numstudents-1;
if ($df > 200) {
	$df = 200;
}

for ($loop=0; $loop<11; $loop++) {
	if ($content_averages[$loop] > 0) {
		$content_t[$loop]=($content_averages[$loop]-$report{'criterion'})/$content_stderrs[$loop];
		$content_d[$loop]=($content_averages[$loop]-$report{'criterion'})/$content_stdevs[$loop];		
		$content_size[$loop]=abs(($content_averages[$loop]-$report{'criterion'})/$content_stdevs[$loop]);
		if (abs($content_t[$loop])>$crit_cat[$df]) {
			if ($content_t[$loop]>0) {
				$content_sig[$loop]=1;
			}
			else {
				$content_sig[$loop]=-1;
			}
		}
		else {
			$content_sig[$loop]=0;
		}
	}
}

# +--------------------------------------------------------------------------+ #
# |               Calculating statistics by reasoning skills                 | #
# +--------------------------------------------------------------------------+ #

for ($counter=0; $counter<$numstudents; $counter++) {
	$skill1_total+=$skill1_sum[$counter];
	$skill1_squared_sum+=($skill1_sum[$counter])**2;
	$skill2_total+=$skill2_sum[$counter];
	$skill2_squared_sum+=($skill2_sum[$counter])**2;
	$skill3_total+=$skill3_sum[$counter];
	$skill3_squared_sum+=($skill3_sum[$counter])**2;
	$skill4_total+=$skill4_sum[$counter];
	$skill4_squared_sum+=($skill4_sum[$counter])**2;
	$skill5_total+=$skill5_sum[$counter];
	$skill5_squared_sum+=($skill5_sum[$counter])**2;
	$skill6_total+=$skill6_sum[$counter];
	$skill6_squared_sum+=($skill6_sum[$counter])**2;
	$skill7_total+=$skill7_sum[$counter];
	$skill7_squared_sum+=($skill7_sum[$counter])**2;
}

if ($specification[0][1]>0) {
	$numskills++;
	$skill1_average=$skill1_total/$numstudents;
	$skill1_stdev=sqrt(($skill1_squared_sum-($skill1_total*$skill1_average))/($numstudents-1));
	$skill1_stderr=$skill1_stdev/sqrt($numstudents);
	$skill1_conf=$skill1_stderr*1.96;
	push @skill_ave_score, $skill1_average;
	push @skill_conf_score, $skill1_conf;
	push @skill_averages, $skill1_average*100/$specification[0][1];
	push @skill_stdevs, $skill1_stdev*100/$specification[0][1];
	push @skill_stderrs, $skill1_stderr*100/$specification[0][1];
	push @skill_conf, $skill1_conf*100/$specification[0][1];
}

if ($specification[0][2]>0) {
	$numskills++;
	$skill2_average=$skill2_total/$numstudents;
	$skill2_stdev=sqrt(($skill2_squared_sum-($skill2_total*$skill2_average))/($numstudents-1));
	$skill2_stderr=$skill2_stdev/sqrt($numstudents);
	$skill2_conf=$skill2_stderr*1.96;
	push @skill_ave_score, $skill2_average;
	push @skill_conf_score, $skill2_conf;
	push @skill_averages, $skill2_average*100/$specification[0][2];
	push @skill_stdevs, $skill2_stdev*100/$specification[0][2];
	push @skill_stderrs, $skill2_stderr*100/$specification[0][2];
	push @skill_conf, $skill2_conf*100/$specification[0][2];
}

if ($specification[0][3]>0) {
	$numskills++;
	$skill3_average=$skill3_total/$numstudents;
	$skill3_stdev=sqrt(($skill3_squared_sum-($skill3_total*$skill3_average))/($numstudents-1));
	$skill3_stderr=$skill3_stdev/sqrt($numstudents);
	$skill3_conf=$skill3_stderr*1.96;
	push @skill_ave_score, $skill3_average;
	push @skill_conf_score, $skill3_conf;
	push @skill_averages, $skill3_average*100/$specification[0][3];
	push @skill_stdevs, $skill3_stdev*100/$specification[0][3];
	push @skill_stderrs, $skill3_stderr*100/$specification[0][3];
	push @skill_conf, $skill3_conf*100/$specification[0][3];
}

if ($specification[0][4]>0) {
	$numskills++;
	$skill4_average=$skill4_total/$numstudents;
	$skill4_stdev=sqrt(($skill4_squared_sum-($skill4_total*$skill4_average))/($numstudents-1));
	$skill4_stderr=$skill4_stdev/sqrt($numstudents);
	$skill4_conf=$skill4_stderr*1.96;
	push @skill_ave_score, $skill4_average;
	push @skill_conf_score, $skill4_conf;
	push @skill_averages, $skill4_average*100/$specification[0][4];
	push @skill_stdevs, $skill4_stdev*100/$specification[0][4];
	push @skill_stderrs, $skill4_stderr*100/$specification[0][4];
	push @skill_conf, $skill4_conf*100/$specification[0][4];
}

if ($specification[0][5]>0) {
	$numskills++;
	$skill5_average=$skill5_total/$numstudents;
	$skill5_stdev=sqrt(($skill5_squared_sum-($skill5_total*$skill5_average))/($numstudents-1));
	$skill5_stderr=$skill5_stdev/sqrt($numstudents);
	$skill5_conf=$skill5_stderr*1.96;
	push @skill_ave_score, $skill5_average;
	push @skill_conf_score, $skill5_conf;
	push @skill_averages, $skill5_average*100/$specification[0][5];
	push @skill_stdevs, $skill5_stdev*100/$specification[0][5];
	push @skill_stderrs, $skill5_stderr*100/$specification[0][5];
	push @skill_conf, $skill5_conf*100/$specification[0][5];
}

if ($specification[0][6]>0) {
	$numskills++;
	$skill6_average=$skill6_total/$numstudents;
	$skill6_stdev=sqrt(($skill6_squared_sum-($skill6_total*$skill6_average))/($numstudents-1));
	$skill6_stderr=$skill6_stdev/sqrt($numstudents);
	$skill6_conf=$skill6_stderr*1.96;
	push @skill_ave_score, $skill6_average;
	push @skill_conf_score, $skill6_conf;
	push @skill_averages, $skill6_average*100/$specification[0][6];
	push @skill_stdevs, $skill6_stdev*100/$specification[0][6];
	push @skill_stderrs, $skill6_stderr*100/$specification[0][6];
	push @skill_conf, $skill6_conf*100/$specification[0][6];
}
if ($numskills==1) {
	@crit_skill=@crit_050;
	$crit_val_skill=0.05;
}
elsif ($numskills==2) {
	@crit_skill=@crit_020;
	$crit_val_skill=0.020;
}
elsif ($numskills<6) {
	@crit_skill=@crit_010;
	$crit_val_skill=0.01;
}
elsif ($numskills<11) {
	@crit_skill=@crit_005;
	$crit_val_skill=0.005;
}
elsif ($numskills<25) {
	@crit_skill=@crit_002;
	$crit_val_skill=0.002;
}
else {
	@crit_skill=@crit_001;
	$crit_val_skill=0.001;
}


for ($loop=0; $loop<11; $loop++) {
	if ($skill_averages[$loop] > 0) {
		$skill_t[$loop]=($skill_averages[$loop]-$report{'criterion'})/$skill_stderrs[$loop];
		$skill_d[$loop]=($skill_averages[$loop]-$report{'criterion'})/$skill_stdevs[$loop];
		$skill_size[$loop]=abs(($skill_averages[$loop]-$report{'criterion'})/$skill_stdevs[$loop]);
		if (abs($skill_t[$loop])>$crit_skill[$df]) {
			if ($skill_t[$loop]>0) {
				$skill_sig[$loop]=1;
			}
			else {
				$skill_sig[$loop]=-1;
			}
		}
		else {
			$skill_sig[$loop]=0;
		}
	}
}


# +--------------------------------------------------------------------------+ #
# |                 Calculating data for item analysis graphs                | #
# +--------------------------------------------------------------------------+ #

### Setting quintile cutoff values

$cut1 = (int($numstudents/5));
$cut2 = (2*int($numstudents/5));
$cut3 = ((3*int($numstudents/5))+$numstudents%5);
$cut4 = ((4*int($numstudents/5))+$numstudents%5);
$cut1val = $sorted[$cut1];
$cut2val = $sorted[$cut2];
$cut3val = $sorted[$cut3];
$cut4val = $sorted[$cut4];

### Assigning quintiles

for ($step=0; $step<@score; $step++) {
	if ($score[$step] < $cut1val) {
		$quintile[$step] = 1;
	}
	elsif ($score[$step] < $cut2val) {
		$quintile[$step] = 2;
	}
	elsif ($score[$step] < $cut3val) {
		$quintile[$step] = 3;
	}
	elsif ($score[$step] < $cut4val) {
		$quintile[$step] = 4;
	}
	else {
		$quintile[$step] = 5;
	}
}


### Loading up the 3-D array for the item analysis plots
### [Question][Response][Quintile]

for ($question=0; $question<$numquestions; $question++) {
	for ($student=0; $student<$numstudents; $student++) {
		$plotdata[$question][0][0]++;
		$plotdata[$question][0][$quintile[$student]]++;
		$plotdata[$question][$num_choices[$student][$question]][0]++;
		$plotdata[$question][$num_choices[$student][$question]][$quintile[$student]]++;
	}
}

### Calculating the slope intercept and correlation for each line in the item traces

for ($question=0; $question<$numquestions; $question++) {
	for ($option=1; $option<5; $option++) {
		for ($qbin=1; $qbin<=5; $qbin++) {
			$y_sig[$question][$option]+=($plotdata[$question][$option][$qbin]/$plotdata[$question][0][$qbin])*100;
			$y2_sig[$question][$option]+=($y_sig[$question][$option])**2;
			$xy_sig[$question][$option]+=($plotdata[$question][$option][$qbin]/$plotdata[$question][0][$qbin])*100*$qbin;
			$sig_y[$question][$option]+=(158-($plotdata[$question][$option][$qbin]/$plotdata[$question][0][$qbin])*125);
			$sig_y2[$question][$option]+=($sig_y[$question][$option])**2;
			$sig_xy[$question][$option]+=(158-($plotdata[$question][$option][$qbin]/$plotdata[$question][0][$qbin])*125)*$qbin;
		}
		$slope[$question][$option]=((5*$sig_xy[$question][$option])-(15*$sig_y[$question][$option]))/50;
		$slope2[$question][$option]=((5*$xy_sig[$question][$option])-(15*$y_sig[$question][$option]))/50;
		$intercept[$question][$option]=((55*$sig_y[$question][$option])-(15*$sig_xy[$question][$option]))/50;
		$r_numerator[$question][$option]=(5*$xy_sig[$question][$option])-(15*$y_sig[$question][$option]);
		$r_denom1[$question][$option]=5*$y2_sig[$question][$option];
		$r_denom2[$question][$option]=$y_sig[$question][$option]*$y_sig[$question][$option];
		$r_denominator[$question][$option]=sqrt((50*$r_denom1[$question][$option])-(50*$r_denom2[$question][$option]));
		if ($r_denominator[$question][$option] == 0) {
			$correl[$question][$option]=0;
		}
		else {
			$correl[$question][$option]=$r_numerator[$question][$option]/$r_denominator[$question][$option];
		}
	}
}

### Score the quality of each exam item

for ($question=0; $question<$numquestions; $question++) {

# Old code to calculate based upon the slope of the trace lines
#	for ($option=1; $option<5; $option++) {
#		if ($option != $num_key[$question]) {
#			if ($plotdata[$question][$option][0] > $numstudents*0.03) {
#				$distractor[$question][0]++;
#				$distractor[$question][$option]++;
#			}
#			if ($slope2[$question][$option] <= -4) {
#				$distractor[$question][0]+=2;
#				$distractor[$question][$option]+=2;
#			}
#			elsif ($slope2[$question][$option] <= -2) {
#				$distractor[$question][0]++;
#				$distractor[$question][$option]++;
#			}
#			elsif ($slope2[$question][$option] >= 0.5) {
#				$distractor[$question][0]-=2;
#				$distractor[$question][$option]-=2;
#			}
#		}
#		else {
#			$distractor[$question][$option]="NA";
#		}	
#	}

	for ($option=1; $option<5; $option++) {
		if ($option != $num_key[$question]) {
			if ($plotdata[$question][$option][0] >= $numstudents*0.03) {
				$distractor[$question][0]++;
				$distractor[$question][$option]++;
				if ($PBDC[$question][$option] <= -0.4) {
					$distractor[$question][0]+=2;
					$distractor[$question][$option]+=2;
				}
				elsif ($PBDC[$question][$option] <= -0.2) {
					$distractor[$question][0]++;
					$distractor[$question][$option]++;
				}
				elsif ($PBDC[$question][$option] <= 0) {
				}
				else{
					$distractor[$question][0]-=2;
					$distractor[$question][$option]-=2;
				}
				if ($plotdata[$question][$option][0] > $plotdata[$question][$num_key[$question]][0]){
					$distractor[$question][0]-=1;
					$distractor[$question][$option]-=1;
				}
			}
		}
	}
				
	if ($p[$question] >= 0.9) {
		$distractor[$question][0]+=2;
	}	
	elsif ($p[$question] >= 0.74) {
		$distractor[$question][0]+=3;
	}	
	elsif ($p[$question] >= 0.52) {
		$distractor[$question][0]+=4;
	}	
	elsif ($p[$question] >= 0.4) {
		$distractor[$question][0]+=2;
	}	
	else {
		$distractor[$question][0]+=0;
	}	
	if ($r_pbi[$question] >= 0.4) {
		$distractor[$question][0]+=7;
	}	
	elsif ($r_pbi[$question] >= 0.3) {
		$distractor[$question][0]+=5;
	}	
	elsif ($r_pbi[$question] >= 0.2) {
		$distractor[$question][0]+=3;
	}	
	elsif ($r_pbi[$question] >= 0.1) {
		$distractor[$question][0]+=1;
	}	
	else {
		;
	}
	if ($distractor[$question][0] < 1) {
		$distractor[$question][0]=1;
	}
	$psych_distribution[$distractor[$question][0]]++;	
}	

### STDOUT routine to check distractor evaluation
# for ($question=0; $question<$numquestions; $question++) {
# 	print $question+1;
# 	for ($option=0; $option<5; $option++) {
# 		$temp = $distractor[$question][$option];
# 		print "\t $temp";
# 	}
# 	if ($distractor[$question][0] >15) {
# 		print "\t Excellent \n";
# 	}
# 	elsif ($distractor[$question][0] >10) {
# 		print "\t Good \n";
# 	}
# 	elsif ($distractor[$question][0] >5) {
# 		print "\t Marginal \n";
# 	}
# 	else {
# 		print "\t Poor \n";
# 	}
# }



	

################################################################################
# +--------------------------------------------------------------------------+ #
# | [-3-]     Drawing graphics and figures for the instructor report         | #
# +--------------------------------------------------------------------------+ #
################################################################################

# +--------------------------------------------------------------------------+ #
# |         Making sure that a directory exists for the graphic files        | #
# +--------------------------------------------------------------------------+ #

$graphicpath="$directory/graphics";
if (-e $graphicpath && -d $graphicpath) {
	#the directory exists
}
else {mkdir $graphicpath}


# +--------------------------------------------------------------------------+ #
# |                 Creating an icon for the score database                  | #
# +--------------------------------------------------------------------------+ #

# Create a new image
$im = new GD::Image(30,40);

# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,102,51);
$blue = $im->colorAllocate(0,0,255);
$ltBlue = $im->colorAllocate(51,204,255);
$green = $im->colorAllocate(74,160,44);
$yellow = $im->colorAllocate(255,255,51);
$orange = $im->colorAllocate(245,184,0);
$ltGray = $im->colorAllocate(241,241,241);
$medGray = $im->colorAllocate(227,227,227);
$gray = $im->colorAllocate(153,153,153);
@color=($red,$red,$red,$red,$red,$red,$orange,$yellow,$green,$ltBlue);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Draw the icon
$im->line(0,0,23,0,$black);
$im->line(0,0,0,39,$black);
$im->line(0,39,29,39,$black);
$im->line(29,5,29,39,$black);
$im->line(23,0,23,5,$black);
$im->line(23,5,29,5,$black);
$im->line(23,0,29,5,$black);
$im->fill(10,10,$ltBlue);
$im->line(7,14,25,14,$blue);
$im->line(3,18,25,18,$blue);
$im->line(3,22,25,22,$blue);
$im->line(3,26,25,26,$blue);
$im->line(3,30,25,30,$blue);
$im->line(3,34,25,34,$blue);
$im->string(gdSmallFont,0,0,".txt",$black);

open(PICTURE, ">$graphicpath/icon.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;


# +--------------------------------------------------------------------------+ #
# |               Plotting the score distribution for the class              | #
# +--------------------------------------------------------------------------+ #

$top=0;
for ($count=0; $count<@bin; $count++) {
  if ($bin[$count]>$top) {
    $top=$bin[$count];
  }
}

if ($top%5>0) {
  $max = $top + (5 - $top%5);
}
else {
  $max=$top;
}

$interval = $max/5;

# Create a new image
$im = new GD::Image(395,300);

# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,102,51);
$blue = $im->colorAllocate(0,0,255);
$ltBlue = $im->colorAllocate(51,204,255);
$green = $im->colorAllocate(74,160,44);
$yellow = $im->colorAllocate(255,255,51);
$orange = $im->colorAllocate(245,184,0);
$ltGray = $im->colorAllocate(241,241,241);
$medGray = $im->colorAllocate(227,227,227);
$gray = $im->colorAllocate(153,153,153);
@color=($red,$red,$red,$red,$red,$red,$orange,$yellow,$green,$ltBlue);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Draw the constant portion: plot areas, ticks, and labels
# Frequency of option selection plot first
$im->rectangle(50, 25, 370, 250, $black);
$im->filledRectangle(51,26,369,249,$ltGray);
$im->line(51,50,369,50,$gray);
$im->line(51,90,369,90,$gray);
$im->line(51,130,369,130,$gray);
$im->line(51,170,369,170,$gray);
$im->line(51,210,369,210,$gray);

$im->string(gdSmallFont,32,244,0,$black);
$im->line(46,210,50,210,$black);
if ($interval<10) {
  $im->string(gdSmallFont,32,204,$interval,$black);
}
else {
  $im->string(gdSmallFont,28,204,$interval,$black);
}
$im->line(46,170,50,170,$black);
if ($interval*2<10) {
  $im->string(gdSmallFont,32,164,$interval*2,$black);
}
else {
  $im->string(gdSmallFont,28,164,$interval*2,$black);
}
$im->line(46,130,50,130,$black);
if ($interval*3<10) {
  $im->string(gdSmallFont,32,124,$interval*3,$black);
}
else {
  $im->string(gdSmallFont,28,124,$interval*3,$black);
}
$im->line(46,90,50,90,$black);
if ($interval*4<10) {
  $im->string(gdSmallFont,32,84,$interval*4,$black);
}
else {
  $im->string(gdSmallFont,28,84,$interval*4,$black);
}
$im->line(46,50,50,50,$black);
if ($max<10) {
  $im->string(gdSmallFont,32,44,$max,$black);
}
else {
  $im->string(gdSmallFont,28,44,$max,$black);
}
$im->line(46,250,50,250,$black);
$im->string(gdMediumBoldFont,150,280,"Score Percentiles",$black);
$im->stringUp(gdMediumBoldFont,10,170,Frequency,$black);
$im->string(gdLargeFont,85,5,"Distribution of Student Scores",$black);
$im->dashedLine($report{'criterion'}/10*32+50,25,$report{'criterion'}/10*32+50,250,$black);
# Automatically build frequency bars
for($count=0; $count<10; $count++) {
  $im->filledRectangle($count*32+56,250-int($bin[$count]*200/$max),$count*32+76,249,$color[$count]);
  $im->rectangle($count*32+56,250-int($bin[$count]*200/$max),$count*32+76,250,$black);
   if($bin[$count]==0) {
      $im->string(gdSmallFont,$count*32+64,235-int($bin[$count]*200/$max),"0",$black);
  }
  elsif($bin[$count]<10) {
    $im->string(gdSmallFont,$count*32+64,235-int($bin[$count]*200/$max),"$bin[$count]",$black);
  }
  else {
    $im->string(gdSmallFont,$count*32+61,235-int($bin[$count]*200/$max),"$bin[$count]",$black);
  }
  
  $im->line($count*32+50,250,$count*32+50,254,$black);
  if($count*10<10) {
    $im->string(gdSmallFont,$count*32+48,260,$count*10,$black);
  }
  else {
    $im->string(gdSmallFont,$count*32+46,260,$count*10,$black);
  }
}
$im->line(370,250,370,254,$black);
$im->string(gdSmallFont,364,260,100,$black);


# Open a file for writing
open(PICTURE, ">$graphicpath/distribution.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;


# +--------------------------------------------------------------------------+ #
# |       Plotting observed and estimated true scores for each student       | #
# +--------------------------------------------------------------------------+ #

for($counter=0; $counter<$numstudents; $counter++) {
	
	# Create a new image
	$im = new GD::Image(600,25);

	# Define a few colors
	$white = $im->colorAllocate(255,255,255);
	$black = $im->colorAllocate(0,0,0);
	$blue = $im->colorAllocate(102,51,255);
	$gray = $im->colorAllocate(210,210,210);
	$f = $im->colorAllocate(255,102,51);
	$d = $im->colorAllocate(245,184,0);
	$c = $im->colorAllocate(255,255,51);
	$b = $im->colorAllocate(51,255,102);
	$a = $im->colorAllocate(51,204,255);
	$border = $im->colorAllocate(100,100,100);

	# Make the background transparent and interlaced
	$im->transparent($white);
	$im->interlaced('true');

	# Draw the constant portion: border, grade regions, divisions
	$im->filledRectangle(0,0,360,25,$f);
	$im->filledRectangle(360,0,420,25,$d);
	$im->filledRectangle(420,0,480,25,$c);
	$im->filledRectangle(480,0,540,25,$b);
	$im->filledRectangle(540,0,599,25,$a);

	$im->line(0,0,0,25,$black);
	$im->line(60,0,60,25,$black);
	$im->line(120,0,120,25,$black);
	$im->line(180,0,180,25,$black);
	$im->line(240,0,240,25,$black);
	$im->line(300,0,300,25,$black);
	$im->line(360,0,360,25,$black);
	$im->line(420,0,420,25,$black);
	$im->line(480,0,480,25,$black);
	$im->line(540,0,540,25,$black);
	$im->line(599,0,599,25,$black);
	
	$top=6;
	$bottom=18;
	$true_min=$score[$counter]-$true_conf;
	$true_max=$score[$counter]+$true_conf;
	$left=int($true_min/$maxpoints*600);
	$right=int($true_max/$maxpoints*600);
	if ($right >= 600) {
		$right = 598;
	}
	$im->filledRectangle($left,$top,$right,$bottom,$gray);
	$im->rectangle($left,$top,$right,$bottom,$border);
	$im->line(int($true_score[$counter]/$maxpoints*600),$top,int($true_score[$counter]/$maxpoints*600),$bottom,$blue);
	$im->filledArc(int($score[$counter]/$maxpoints*600),12,8,8,0,360,$blue);
	$im->line(1,24,598,24,$gray);
	
	# Open a file for writing
	open(PICTURE, ">$graphicpath/Student$counter.png") or die("Cannot open file for writing");

	# Make sure we are writing to a binary stream
	binmode PICTURE;

	# Convert the image to PNG and print it to the file PICTURE
	print PICTURE $im->png;
	close PICTURE;
}

# Create a new image
$im = new GD::Image(600,25);

# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$blue = $im->colorAllocate(102,51,255);
$gray = $im->colorAllocate(210,210,210);
$f = $im->colorAllocate(255,102,51);
$d = $im->colorAllocate(245,184,0);
$c = $im->colorAllocate(255,255,51);
$b = $im->colorAllocate(51,255,102);
$a = $im->colorAllocate(51,204,255);
$border = $im->colorAllocate(100,100,100);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

$im->line(0,0,599,0,$black);
$im->line(60,0,60,5,$black);
$im->line(120,0,120,5,$black);
$im->line(180,0,180,5,$black);
$im->line(240,0,240,5,$black);
$im->line(300,0,300,5,$black);
$im->line(360,0,360,5,$black);
$im->line(420,0,420,5,$black);
$im->line(480,0,480,5,$black);
$im->line(540,0,540,5,$black);

$im->string(gdMediumBoldFont,55,10,"10%",$black);
$im->string(gdMediumBoldFont,115,10,"20%",$black);
$im->string(gdMediumBoldFont,175,10,"30%",$black);
$im->string(gdMediumBoldFont,235,10,"40%",$black);
$im->string(gdMediumBoldFont,295,10,"50%",$black);
$im->string(gdMediumBoldFont,355,10,"60%",$black);
$im->string(gdMediumBoldFont,415,10,"70%",$black);
$im->string(gdMediumBoldFont,475,10,"80%",$black);
$im->string(gdMediumBoldFont,535,10,"90%",$black);

$im->filledArc(331,15,18,18,0,360,$f);
$im->filledArc(391,15,18,18,0,360,$d);
$im->filledArc(451,15,18,18,0,360,$c);
$im->filledArc(511,15,18,18,0,360,$b);
$im->filledArc(571,15,18,18,0,360,$a);

$im->arc(331,15,18,18,0,360,$black);
$im->arc(391,15,18,18,0,360,$black);
$im->arc(451,15,18,18,0,360,$black);
$im->arc(511,15,18,18,0,360,$black);
$im->arc(571,15,18,18,0,360,$black);

$im->string(gdLargeFont,328,8,"F",$black);
$im->string(gdLargeFont,388,8,"D",$black);
$im->string(gdLargeFont,448,8,"C",$black);
$im->string(gdLargeFont,508,8,"B",$black);
$im->string(gdLargeFont,568,8,"A",$black);

# Open a file for writing
open(PICTURE, ">$graphicpath/Student_labels.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;
	


# +--------------------------------------------------------------------------+ #
# |     Creating a blueprint of the point distribution for the assessment    | #
# +--------------------------------------------------------------------------+ #

# Make sure that some content areas have been defined
$numcontents=0;
for ($areas=1; $areas<=@content_averages; $areas++) {
	if ($specification[$areas][0]>0) {
		$numcontents++;
	}
}

# Create a new image
$im = new GD::Image(900,$numcontents*40+125);

# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,102,51);
$blue = $im->colorAllocate(0,0,255);
$ltBlue = $im->colorAllocate(51,204,255);
$green = $im->colorAllocate(74,160,44);
$yellow = $im->colorAllocate(255,255,51);
$orange = $im->colorAllocate(245,184,0);
$ltGray = $im->colorAllocate(241,241,241);
$medGray = $im->colorAllocate(227,227,227);
$gray = $im->colorAllocate(153,153,153);
@color=($gray,$black,$blue,$green,$red);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Draw the graphing area
$im->filledRectangle(0,25,899,60,$ltBlue);
$im->filledRectangle(0,60,230,$numcontents*40+100,$ltBlue);
$im->rectangle(0,25,899,$numcontents*40+100,$black);

# Set up image mapped
$blueprintMap = "<map name=\"blueprintMap\"> \n <area shape=\"rect\" coords=\"230,25,329,60\" title=\"Go to Identifying\" href=\"#Skill1\"> \n <area shape=\"rect\" coords=\"330,25,429,60\" title=\"Go to Categorizing\" href=\"#Skill2\"> \n <area shape=\"rect\" coords=\"430,25,529,60\" title=\"Go to Calculating\" href=\"#Skill3\"> \n <area shape=\"rect\" coords=\"530,25,629,60\" title=\"Go to Interpreting\" href=\"#Skill4\"> \n <area shape=\"rect\" coords=\"630,25,729,60\" title=\"Go to Predicting\" href=\"#Skill5\"> \n <area shape=\"rect\" coords=\"730,25,829,60\" title=\"Go to Judging\" href=\"#Skill6\">\n";

# table title
$im->string(gdLargeFont,250,5,"Blueprint of the Point Distribution for This Assessment",$black);

# labels for rows and columns as well as the table grid
$im->string(gdMediumBoldFont,70,40,"Content Areas",$black);
$im->string(gdMediumBoldFont,242,40,"Identifying",$black);
$im->string(gdMediumBoldFont,337,40,"Categorizing",$black);
$im->string(gdMediumBoldFont,444,40,"Calculating",$black);
$im->string(gdMediumBoldFont,541,40,"Interpreting",$black);
$im->string(gdMediumBoldFont,645,40,"Predicting",$black);
$im->string(gdMediumBoldFont,755,40,"Judging",$black);
$im->string(gdMediumBoldFont,850,40,"Total",$black);

for ($vert=0; $vert<7; $vert++) {
	$im->line($vert*100+230,25,$vert*100+230,$numcontents*40+100,$black);
}

for ($loop=0; $loop<=$numcontents; $loop++) {
	$im->line(0,$loop*40+60,899,$loop*40+60,$black);
	if ($loop<$numcontents) {
		$blueprintMap.="<area shape=\"rect\" coords=\"0,";
		$blueprintMap.= $loop*40+60;
		$blueprintMap.= ",229,";
		$blueprintMap.= $loop*40+100;
		$blueprintMap.= "\" title=\"Go to ";
		$blueprintMap.= $areas[$loop];
		$blueprintMap.= "\" href=\"#Area";
		$blueprintMap.= $loop+1;
		$blueprintMap.="\">\n";
		$im->string(gdMediumBoldFont,10,$loop*40+75,"$shortareas[$loop]",$black);	
	}
}
$blueprintMap.="</map>\n";
$im->string(gdMediumBoldFont,10,$numcontents*40+75,"Total",$black);

for ($row=0; $row<=$numcontents; $row++) {
	for ($col=0; $col<7; $col++) {
		if($row eq 0) {
			$vertical=$numcontents*40+67;
		}
		else {
			$vertical=$row*40+35;
			if ($specification[$row][$col]>0) {
				$background=$yellow;
			}
			else {
				$background=$orange;
			}			
		}

		if ($col eq 0) {
			$horizontal=865;
			$background=$medGray;
			if ($row != 0) {
				$vertical-=8;
			}
		}
		else {
			$horizontal=$col*100+175;
			if ($row != 0) {
				if ($specification[$row][$col]>0) {
					$background=$yellow;
				}
				else {
					$background=$orange;
				}
			}
		}
		$im->fill($horizontal,$vertical,$background);
		if ($specification[$row][$col]>=100) {
			$horizontal-=6;
		}
		elsif ($specification[$row][$col]>=10) {
			$horizontal-=3;
		}
		if ($col eq 0) {
			if($specification[$row][$col] == 0) {
				$im->string(gdMediumBoldFont,$horizontal,$vertical,"0",$black);
			}
			else {
				$im->string(gdMediumBoldFont,$horizontal-3,$vertical,$specification[$row][$col],$black);
			}
		}
		else {
			if($specification[$row][$col] == 0) {
				$im->string(gdMediumBoldFont,$horizontal,$vertical,"0",$black);
			}
			else {
				$im->string(gdMediumBoldFont,$horizontal,$vertical,$specification[$row][$col],$black);
			}
		}
	}
}

for ($vert=1; $vert<7; $vert++) {
	$xpos=$vert*100+175;
	if ($specification[0][$vert]>=100) {
		$xpos-=6;
	}
	elsif ($specification[0][$vert]>=10) {
		$xpos-=3;
	}
	$cellval=int($specification[0][$vert]/$specification[0][0]*1000+.5)/10;
	$im->string(gdMediumBoldFont,$xpos,$numcontents*40+83,"$cellval\%",$black);
}
for ($horz=1; $horz<=$numcontents; $horz++) {
	$xpos=863;
	$ypos=$horz*40+43;
	if ($specification[$horz][0]>=100) {
		$xpos-=8;
	}
	elsif ($specification[$horz][0]>=10) {
		$xpos-=4;
	}
	$cellval=int($specification[$horz][0]/$specification[0][0]*1000+.5)/10;
	$im->string(gdMediumBoldFont,$xpos,$ypos,"$cellval\%",$black);
}

$im->string(gdMediumBoldFont,856,$numcontents*40+83,"100%",$black);

# Open a file for writing
open(PICTURE, ">$graphicpath/blueprint.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;


# +--------------------------------------------------------------------------+ #
# |             Plotting the scores by course learning outcome               | #
# +--------------------------------------------------------------------------+ #

# Make sure that some content areas have been assigned
$numcontents=0;
for ($sample=0; $sample<@outcomes; $sample++) {
	if ($outcomes[$sample]) {
		$numcontents++;
	}
}

# Create a new image
$im = new GD::Image(($numcontents*35)+85,295);
# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,102,51);
$blue = $im->colorAllocate(0,0,255);
$ltBlue = $im->colorAllocate(51,204,255);
$green = $im->colorAllocate(74,160,44);
$yellow = $im->colorAllocate(255,255,51);
$orange = $im->colorAllocate(245,184,0);
$ltGray = $im->colorAllocate(241,241,241);
$medGray = $im->colorAllocate(227,227,227);
$gray = $im->colorAllocate(153,153,153);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Set up the graph area
$im->filledRectangle(50,25,($numcontents*35)+60,245,$ltGray);
$im->rectangle(50, 25,($numcontents*35)+60, 245, $black);

# Add the title
$im->string(gdLargeFont,($numcontents*18)/2,5,"Performance by Outcome",$black);

# Add ticks and y-axis labels
for ($tick=0; $tick<11; $tick++) {
  $im->line(46,$tick*20+45,50,$tick*20+45,$black);
  if ($tick<10) {
  	if ($tick*20+45!=245-$report{'criterion'}*2) {
  		$im->line(51,$tick*20+45,($numcontents*35)+59,$tick*20+45,$gray);
  	}
  }	
  if ($tick==0) {
    $im->string(gdSmallFont,25,$tick*20+39,100,$black);
  }
  elsif ($tick<10) {
    $im->string(gdSmallFont,31,$tick*20+39,100-$tick*10,$black);
  }
  else {
    $im->string(gdSmallFont,37,$tick*20+39,100-$tick*10,$black);
  }
}
$im->string(gdMediumBoldFont,($numcontents*35)/2,270,"Learning Outcomes",$black);
$im->stringUp(gdMediumBoldFont,7,200,"Average +/- 95% C.I.",$black);

# Add the criterion threshold
$im->dashedLine(51,245-$report{'criterion'}*2,$numcontents*35+59,245-$report{'criterion'}*2,$black);

# Set up image maps
$outcomesMap = "<map name = \"outcomesMap\">\n";

# Plot the topic data
for ($cat=1; $cat<=$numcontents; $cat++) {
	if ($objective_sig[$cat] eq -1) {
		$barfill=$red;
	}
	elsif ($objective_sig[$cat] eq 0) {
		$barfill=$gray;
	}
	else {
		$barfill=$ltBlue;
	}
	$outcomesMap .= "<area shape=\"rect\" coords=\"";
	$outcomesMap .= $cat*35+25;
	$outcomesMap .= ",";
	$outcomesMap .= 245-int($objective_averages[$cat]*2);
	$outcomesMap .= ",";
	$outcomesMap .= $cat*35+50;
	$outcomesMap .= ",244\" title=\"Go to ";
	$outcomesMap .= $outcomes[$cat];
	$outcomesMap .= "\" href=\"#Outcome";
	$outcomesMap .= $cat;
	$outcomesMap .= "\">\n";
	$im->filledRectangle($cat*35+25,245-int($objective_averages[$cat]*2),$cat*35+50,244,$barfill);
	$im->rectangle($cat*35+25,245-int($objective_averages[$cat]*2),$cat*35+50,245,$black);
	$im->line($cat*35+37,245-int($objective_averages[$cat]*2)-int($objective_conf[$cat]*2),$cat*35+37,245-int($objective_averages[$cat]*2),$black);
  $im->line($cat*35+32,245-int($objective_averages[$cat]*2)-int($objective_conf[$cat]*2),$cat*35+42,245-int($objective_averages[$cat]*2)-int($objective_conf[$cat]*2),$black);
  $im->line($cat*35+37,245,$cat*35+37,249,$black);
  $im->string(gdSmallFont,$cat*35+35,252,$cat,$black);
}
$outcomesMap .= "</map>";

# Open a file for writing
open(PICTURE, ">$graphicpath/learningOutcomes.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;




# +--------------------------------------------------------------------------+ #
# |                    Plotting the scores by content area                   | #
# +--------------------------------------------------------------------------+ #

# Make sure that some content areas have been assigned
$numcontents=0;
for ($areas=1; $areas<=@content_averages; $areas++) {
	if ($specification[$areas][0]>0) {
		$numcontents++;
	}
}

# Create a new image
$im = new GD::Image(($numcontents*35)+85,295);
# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,102,51);
$blue = $im->colorAllocate(0,0,255);
$ltBlue = $im->colorAllocate(51,204,255);
$green = $im->colorAllocate(74,160,44);
$yellow = $im->colorAllocate(255,255,51);
$orange = $im->colorAllocate(245,184,0);
$ltGray = $im->colorAllocate(241,241,241);
$medGray = $im->colorAllocate(227,227,227);
$gray = $im->colorAllocate(153,153,153);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Set up the graph area
$im->filledRectangle(50,25,($numcontents*35)+60,245,$ltGray);
$im->rectangle(50, 25,($numcontents*35)+60, 245, $black);

# Add the title
$im->string(gdLargeFont,($numcontents*18)/2,5,"Performance by Content Area",$black);

# Add ticks and y-axis labels
for ($tick=0; $tick<11; $tick++) {
  $im->line(46,$tick*20+45,50,$tick*20+45,$black);
  if ($tick<10) {
  	if ($tick*20+45!=245-$report{'criterion'}*2) {
  		$im->line(51,$tick*20+45,($numcontents*35)+59,$tick*20+45,$gray);
  	}
  }	
  if ($tick==0) {
    $im->string(gdSmallFont,25,$tick*20+39,100,$black);
  }
  elsif ($tick<10) {
    $im->string(gdSmallFont,31,$tick*20+39,100-$tick*10,$black);
  }
  else {
    $im->string(gdSmallFont,37,$tick*20+39,100-$tick*10,$black);
  }
}
$im->string(gdMediumBoldFont,($numcontents*35+10)/2,270,"Content Areas",$black);
$im->stringUp(gdMediumBoldFont,7,200,"Average +/- 95% C.I.",$black);

# Add the criterion threshold
$im->dashedLine(51,245-$report{'criterion'}*2,$numcontents*35+59,245-$report{'criterion'}*2,$black);

# Set up image maps
$contentMap = "<map name = \"contentMap\">\n";

# Plot the topic data
for ($cat=0; $cat<$numcontents; $cat++) {
	if ($content_sig[$cat] eq -1) {
		$barfill=$red;
	}
	elsif ($content_sig[$cat] eq 0) {
		$barfill=$gray;
	}
	else {
		$barfill=$ltBlue;
	}
	$contentMap .= "<area shape=\"rect\" coords=\"";
	$contentMap .= $cat*35+60;
	$contentMap .= ",";
	$contentMap .= 245-int($content_averages[$cat]*2);
	$contentMap .= ",";
	$contentMap .= $cat*35+85;
	$contentMap .= ",244\" title=\"Go to ";
	$contentMap .= $areas[$cat];
	$contentMap .= "\" href=\"#Area";
	$contentMap .= $cat+1;
	$contentMap .= "\">\n";
	$im->filledRectangle($cat*35+60,245-int($content_averages[$cat]*2),$cat*35+85,244,$barfill);
	$im->rectangle($cat*35+60,245-int($content_averages[$cat]*2),$cat*35+85,245,$black);
	$im->line($cat*35+72,245-int($content_averages[$cat]*2)-int($content_conf[$cat]*2),$cat*35+72,245-int($content_averages[$cat]*2),$black);
  $im->line($cat*35+67,245-int($content_averages[$cat]*2)-int($content_conf[$cat]*2),$cat*35+77,245-int($content_averages[$cat]*2)-int($content_conf[$cat]*2),$black);
  $im->line($cat*35+72,245,$cat*35+72,249,$black);
  $im->string(gdSmallFont,$cat*35+70,252,$cat+1,$black);
}
$contentMap .= "</map>";

# Open a file for writing
open(PICTURE, ">$graphicpath/contentAreas.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;



# +--------------------------------------------------------------------------+ #
# |                Plotting the scores by thinking skills                    | #
# +--------------------------------------------------------------------------+ #

@skill_labels = ("Skills","Identifying","Categorizing","Calculating","Interpreting","Predicting","Judging");

# Create a new image
$im = new GD::Image(295,295);

# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,102,51);
$blue = $im->colorAllocate(0,0,255);
$ltBlue = $im->colorAllocate(51,204,255);
$green = $im->colorAllocate(74,160,44);
$yellow = $im->colorAllocate(255,255,51);
$orange = $im->colorAllocate(245,184,0);
$ltGray = $im->colorAllocate(241,241,241);
$medGray = $im->colorAllocate(227,227,227);
$gray = $im->colorAllocate(153,153,153);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Set up the graph area
$im->filledRectangle(50,25,270,245,$ltGray);
$im->rectangle(50, 25,270, 245, $black);

# Add the title
$im->string(gdLargeFont,42,5,"Performance by Thinking Skills",$black);

# Add ticks and y-axis labels
for ($tick=0; $tick<11; $tick++) {
  $im->line(46,$tick*20+45,50,$tick*20+45,$black);
  if ($tick<10) {
  	if ($tick*20+45!=245-$report{'criterion'}*2) {
  		$im->line(51,$tick*20+45,269,$tick*20+45,$gray);
  	}
  }	
  if ($tick==0) {
    $im->string(gdSmallFont,25,$tick*20+39,100,$black);
  }
  elsif ($tick<10) {
    $im->string(gdSmallFont,31,$tick*20+39,100-$tick*10,$black);
  }
  else {
    $im->string(gdSmallFont,37,$tick*20+39,100-$tick*10,$black);
  }
}
$im->string(gdMediumBoldFont,110,270,"Thinking Skill",$black);
$im->stringUp(gdMediumBoldFont,7,200,"Average +/- 95% C.I.",$black);

# Add the criterion threshold
$im->dashedLine(51,245-$report{'criterion'}*2,269,245-$report{'criterion'}*2,$black);

# Set up image maps
$skillMap = "<map name = \"skillMap\">\n";

# Plot the topic data
for ($cat=0; $cat<6; $cat++) {
	if ($skill_sig[$cat] == -1) {
		$barfill=$red;
	}
	elsif ($skill_sig[$cat] == 1) {
		$barfill=$ltBlue;
	}
	else {
		$barfill=$gray;
	}
	$skillMap .= "<area shape=\"rect\" coords=\"";
	$skillMap .= $cat*35+60;
	$skillMap .= ",";
	$skillMap .= 245-int($skill_averages[$cat]*2);
	$skillMap .= ",";
	$skillMap .= $cat*35+85;
	$skillMap .= ",244\" title=\"Go to ";
	$skillMap .= $skill_labels[$cat+1];
	$skillMap .= "\" href=\"#Skill";
	$skillMap .= $cat+1;
	$skillMap .= "\">\n";

	$im->filledRectangle($cat*35+60,245-int($skill_averages[$cat]*2),$cat*35+85,244,$barfill);
	$im->rectangle($cat*35+60,245-int($skill_averages[$cat]*2),$cat*35+85,245,$black);
	$im->line($cat*35+72,245-int($skill_averages[$cat]*2)-int($skill_conf[$cat]*2),$cat*35+72,245-int($skill_averages[$cat]*2),$black);
  $im->line($cat*35+67,245-int($skill_averages[$cat]*2)-int($skill_conf[$cat]*2),$cat*35+77,245-int($skill_averages[$cat]*2)-int($skill_conf[$cat]*2),$black);
  $im->line($cat*35+72,245,$cat*35+72,249,$black);
  $im->string(gdSmallFont,$cat*35+70,252,$cat+1,$black);
}
$skillMap .= "</map>";

# Open a file for writing
open(PICTURE, ">$graphicpath/skillLevels.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;



# +--------------------------------------------------------------------------+ #
# |                Plotting facility versus discrimination                   | #
# +--------------------------------------------------------------------------+ #

# Create a new image
$im = new GD::Image(470,550);

# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,102,51);
$bkRed = $im->colorAllocate(255,220,220);
$blue = $im->colorAllocate(0,0,255);
$bkBlue = $im->colorAllocate(202,225,255);
$ltBlue = $im->colorAllocate(51,204,255);
$green = $im->colorAllocate(74,160,44);
$bkGreen = $im->colorAllocate(210,255,210);
$yellow = $im->colorAllocate(255,255,51);
$bkYellow = $im->colorAllocate(255,255,220);
$orange = $im->colorAllocate(245,184,0);
$ltGray = $im->colorAllocate(241,241,241);
$medGray = $im->colorAllocate(227,227,227);
$gray = $im->colorAllocate(153,153,153);


for ($loop=0; $loop<$numquestions; $loop++) {
	$total_facility+=$p[$loop];
	$total_discrimination+=$r_pbi[$loop];
}
$total_facility=$total_facility/@p;
$total_discrimination=$total_discrimination/@r_pbi;

$ave_facility=int(100*$total_facility+0.5)/100;
$ave_discrimination=int(100*$total_discrimination+0.5)/100;


# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Draw the graphing area
$im->filledRectangle(50,25,450,505,$bkRed);
$im->filledArc(310,165,440,440,0,360,$bkYellow);
$im->filledRectangle(90,25,450,165,$bkYellow);
$im->filledArc(310,165,320,320,0,360,$bkGreen);
$im->filledRectangle(150,50,450,165,$bkGreen);
$im->filledArc(310,165,200,200,0,360,$bkBlue);
$im->filledRectangle(210,50,410,165,$bkBlue);
$im->filledRectangle(0,0,450,50,$white);
$im->filledRectangle(450,0,470,550,$white);
$im->filledRectangle(50,25,450,105,$medGray);
$im->filledRectangle(265,32,443,98,$ltGray);
$im->rectangle(265,32,443,98,$gray);
$im->line(290,32,290,98,$gray);

$im->rectangle(50,25,450,505,$black);
$im->line(50,105,450,105,$gray);

# graph title
$im->string(gdLargeFont,150,5,"Plot of Item Performance",$black);

# zero line
$im->line(50,425,450,425,$black);

# plot average facility
$im->dashedLine($ave_facility*400+50,105,$ave_facility*400+50,505,$black);
$im->stringUp(gdSmallFont,$ave_facility*400+50,500,"mean=$ave_facility",$black);

# Plot average discrimination
$im->dashedLine(50,425-$ave_discrimination*400,450,425-$ave_discrimination*400,$black);
$im->string(gdSmallFont,55,410-$ave_discrimination*400,"mean=$ave_discrimination",$black);

# y-axis ticks
$im->line(45,25,50,25,$black);
$im->line(45,65,50,65,$black);
$im->line(45,105,50,105,$black);
$im->line(45,145,50,145,$black);
$im->line(45,185,50,185,$black);
$im->line(45,225,50,225,$black);
$im->line(45,265,50,265,$black);
$im->line(45,305,50,305,$black);
$im->line(45,345,50,345,$black);
$im->line(45,385,50,385,$black);
$im->line(45,425,50,425,$black);
$im->line(45,465,50,465,$black);
$im->line(45,505,50,505,$black);

#  y-axis labels
$im->string(gdSmallFont,26,19,"1.0",$black);
$im->string(gdSmallFont,26,59,"0.9",$black);
$im->string(gdSmallFont,26,99,"0.8",$black);
$im->string(gdSmallFont,26,139,"0.7",$black);
$im->string(gdSmallFont,26,179,"0.6",$black);
$im->string(gdSmallFont,26,219,"0.5",$black);
$im->string(gdSmallFont,26,259,"0.4",$black);
$im->string(gdSmallFont,26,299,"0.3",$black);
$im->string(gdSmallFont,26,339,"0.2",$black);
$im->string(gdSmallFont,26,379,"0.1",$black);
$im->string(gdSmallFont,26,419,"0.0",$black);
$im->string(gdSmallFont,20,459,"-0.1",$black);
$im->string(gdSmallFont,20,499,"-0.2",$black);

# y-axis title
$im->stringUp(gdMediumBoldFont,8,365,"Discrimination (point biserial)",$black);

# x-axis ticks
$im->line(50,505,50,510,$black);
$im->line(90,505,90,510,$black);
$im->line(130,505,130,510,$black);
$im->line(170,505,170,510,$black);
$im->line(210,505,210,510,$black);
$im->line(250,505,250,510,$black);
$im->line(290,505,290,510,$black);
$im->line(330,505,330,510,$black);
$im->line(370,505,370,510,$black);
$im->line(410,505,410,510,$black);
$im->line(450,505,450,510,$black);

# x-axis labels
$im->string(gdSmallFont,42,512,"0.0",$black);
$im->string(gdSmallFont,82,512,"0.1",$black);
$im->string(gdSmallFont,122,512,"0.2",$black);
$im->string(gdSmallFont,162,512,"0.3",$black);
$im->string(gdSmallFont,202,512,"0.4",$black);
$im->string(gdSmallFont,242,512,"0.5",$black);
$im->string(gdSmallFont,282,512,"0.6",$black);
$im->string(gdSmallFont,322,512,"0.7",$black);
$im->string(gdSmallFont,362,512,"0.8",$black);
$im->string(gdSmallFont,402,512,"0.9",$black);
$im->string(gdSmallFont,442,512,"1.0",$black);

# x-axis title
$im->string(gdMediumBoldFont,158,528,"Facility (fraction correct)",$black);

# adding a legend for the point colors
$im->string(gdMediumBoldFont,65,37,"Click on a point to go",$black);
$im->string(gdMediumBoldFont,65,51,"to that question.",$black);
$im->stringUp(gdMediumBoldFont,270,90,"Quality",$black);
$im->filledArc(300,45,8,8,0,360,$ltBlue);
$im->arc(300,45,8,8,0,360,$black);
$im->string(gdSmallFont,309,38,"- Excellent questions",$black);
$im->filledArc(300,59,8,8,0,360,$green);
$im->arc(300,59,8,8,0,360,$black);
$im->string(gdSmallFont,309,52,"- Good questions",$black);
$im->filledArc(300,73,8,8,0,360,$yellow);
$im->arc(300,73,8,8,0,360,$black);
$im->string(gdSmallFont,309,66,"- Marginal questions",$black);
$im->filledArc(300,87,8,8,0,360,$red);
$im->arc(300,87,8,8,0,360,$black);
$im->string(gdSmallFont,309,80,"- Poor questions",$black);

# Set up image maps
$psychoMap = "<map name=\"psychoMap\">\n";

# plotting the data points and labels
for ($plotting=0; $plotting<@p; $plotting++) {
	if ($distractor[$plotting][0] > 15) {$dot = $ltBlue;}
	elsif ($distractor[$plotting][0] > 10) {$dot = $green;}
	elsif ($distractor[$plotting][0] > 5) {$dot = $yellow;}
	else {$dot = $red;}
	$im->filledArc($p[$plotting]*400+50,425-$r_pbi[$plotting]*400,8,8,0,360,$dot);
	$im->arc($p[$plotting]*400+50,425-$r_pbi[$plotting]*400,8,8,0,360,$black);
	$im->string(gdSmallFont,$p[$plotting]*400+56,419-$r_pbi[$plotting]*400,$plotting+1,$black);
	$psychoMap .= "<area shape=\"circle\" coords=\"";
	$psychoMap .= int($p[$plotting]*400+50);
	$psychoMap .= ",";
	$psychoMap .= int(425-$r_pbi[$plotting]*400);
	$psychoMap .= ",6\" title=\"Go to Question ";
	$psychoMap .= $plotting+1;
	$psychoMap .= "\" href=\"#Question";
	$psychoMap .= $plotting+1;
	$psychoMap .= "\" />\n";
}

$psychoMap .= "</map>\n";

# Open a file for writing
open(PICTURE, ">$graphicpath/itemPlot.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;



# +--------------------------------------------------------------------------+ #
# |                Plotting each of the item responses                       | #
# +--------------------------------------------------------------------------+ #

$bigmax = $plotdata[1][0][0]+(5 - $plotdata[1][0][0]%5);
$biginterval = $bigmax/5;


for($question=0; $question<$numquestions; $question++) {
	$numval=$question+1;
	# Create a new image
	$im = new GD::Image(500,200);

	# Define a few colors
	$white = $im->colorAllocate(255,255,255);
	$black = $im->colorAllocate(0,0,0);
	$red = $im->colorAllocate(255,102,51);
	$blue = $im->colorAllocate(0,0,255);
	$ltBlue = $im->colorAllocate(51,204,255);
	$green = $im->colorAllocate(74,160,44);
	$yellow = $im->colorAllocate(255,255,51);
	$orange = $im->colorAllocate(245,184,0);
	$ltGray = $im->colorAllocate(241,241,241);
	$medGray = $im->colorAllocate(227,227,227);
	$gray = $im->colorAllocate(153,153,153);
	@color=($gray,$black,$ltBlue,$green,$red);


	# Make the background transparent and interlaced
	$im->transparent($white);
	$im->interlaced('true');


	# Draw the constant portion: plot areas, ticks, and labels
	# Frequency of option selection plot first
	$im->rectangle(50, 25, 151, 158, $black);
	$im->filledRectangle(51,26,150,157,$ltGray);
	$im->line(51,133,150,133,$gray);
	$im->line(51,108,150,108,$gray);
	$im->line(51,83,150,83,$gray);
	$im->line(51,58,150,58,$gray);
	$im->line(51,33,150,33,$gray);
	$im->string(gdSmallFont,38,152,0,$black);
	$im->line(46,158,50,158,$black);
	
	if ($biginterval<10) {$labelpos=38;}
	elsif ($biginteral<100) {$labelpos=32;}
	else {$labelpos=26;}
	
	$im->string(gdSmallFont,$labelpos,127,$biginterval,$black);
	$im->line(46,133,50,133,$black);
	
	if ($biginterval*2<10) {$labelpos=38;}
	elsif ($biginteral*2<100) {$labelpos=32;}
	else {$labelpos=26;}
	
	$im->string(gdSmallFont,$labelpos,102,$biginterval*2,$black);
	$im->line(46,108,50,108,$black);
	
	if ($biginterval*3<10) {$labelpos=38;}
	elsif ($biginteral*3<100) {$labelpos=32;}
	else {$labelpos=26;}
	
	$im->string(gdSmallFont,$labelpos,77,$biginterval*3,$black);
	$im->line(46,83,50,83,$black);
	
	if ($biginterval*4<10) {$labelpos=38;}
	elsif ($biginteral*4<100) {$labelpos=32;}
	else {$labelpos=26;}
	
	$im->string(gdSmallFont,$labelpos,52,$biginterval*4,$black);
	$im->line(46,58,50,58,$black);
	
	if ($bigmax<10) {$labelpos=38;}
	elsif ($bigmax<100) {$labelpos=32;}
	else {$labelpos=26;}
	
	$im->string(gdSmallFont,$labelpos,27,$bigmax,$black);
	$im->line(46,33,50,33,$black);
	$im->line(63,158,63,162,$black);
	$im->filledArc(38+$num_key[$question]*25,171,16,16,0,360,$orange);
	$im->arc(38+$num_key[$question]*25,171,16,16,0,360,$gray);
	$im->string(gdSmallFont,61,165,A,$black);
	$im->line(88,158,88,162,$black);
	$im->string(gdSmallFont,86,165,B,$black);
	$im->line(113,158,113,162,$black);
	$im->string(gdSmallFont,111,165,C,$black);
	$im->line(138,158,138,162,$black);
	$im->string(gdSmallFont,136,165,D,$black);
	$im->string(gdMediumBoldFont,76,180,Options,$black);
	$im->stringUp(gdMediumBoldFont,10,123,Frequency,$black);
	 
	# Quintile regression analysis second
	$im->rectangle(235,25,445,158,$black);
	$im->filledRectangle(236,26,444,157,$ltGray);
	$im->string(gdSmallFont,222,152,"0",$black);
	$im->line(231,158,235,158,$black);
	$im->string(gdSmallFont,216,127,"20",$black);
	$im->line(231,133,235,133,$black);
	$im->string(gdSmallFont,216,102,"40",$black);
	$im->line(231,108,235,108,$black);
	$im->string(gdSmallFont,216,77,"60",$black);
	$im->line(231,83,235,83,$black);
	$im->string(gdSmallFont,216,52,"80",$black);
	$im->line(231,58,235,58,$black);
	$im->string(gdSmallFont,210,27,"100",$black);
	$im->line(231,33,235,33,$black);
	$im->line(270,158,270,162,$black);
	$im->string(gdSmallFont,268,165,"1",$black);
	$im->line(305,158,305,162,$black);
	$im->string(gdSmallFont,303,165,"2",$black);	
	$im->line(340,158,340,162,$black);
	$im->string(gdSmallFont,338,165,"3",$black);
	$im->line(375,158,375,162,$black);
	$im->string(gdSmallFont,373,165,"4",$black);
	$im->line(410,158,410,162,$black);
	$im->string(gdSmallFont,408,165,"5",$black);
	$im->string(gdMediumBoldFont,310,180,"Quintiles",$black);
	$im->stringUp(gdMediumBoldFont,190,152,"Percent Selected",$black);
	$im->filledArc(460,70,8,8,0,360,$black);
	$im->string(gdSmallFont,470,64,"A",$black);
	$im->filledArc(460,90,8,8,0,360,$ltBlue);
	$im->string(gdSmallFont,470,84,"B",$black);
	$im->filledArc(460,110,8,8,0,360,$green);
	$im->string(gdSmallFont,470,104,"C",$black);
	$im->filledArc(460,130,8,8,0,360,$red);
	$im->string(gdSmallFont,470,124,"D",$black);

	if ($distractor[$question][0] > 15) {
		$adjective="Excellent";
	}
	elsif ($distractor[$question][0] > 10) {
		$adjective="Good";
	}
	elsif ($distractor[$question][0] > 5) {
		$adjective="Marginal";
	}
	else {
		$adjective="Poor";
	}

	# Add the variable portions: unique for each question
	$im->string(gdLargeFont,55,5,"Question: $numval",$black);
	$im->string(gdLargeFont,240,5,"Score: $distractor[$question][0], $adjective",$black);

	# Automatically build frequency bars
	$im->filledRectangle(55,158-int($plotdata[$question][1][0]*125/$bigmax),71,157,$black);
	if($plotdata[$question][1][0]>9) {
		$im->string(gdSmallFont,57,144-int($plotdata[$question][1][0]*125/$bigmax),$plotdata[$question][1][0],$black);
	}
	elsif($plotdata[$question][1][0]>0) {
		$im->string(gdSmallFont,61,144-int($plotdata[$question][1][0]*125/$bigmax),$plotdata[$question][1][0],$black);
	}
	else {
		$im->string(gdSmallFont,61,144-int($plotdata[$question][1][0]*125/$bigmax),"0",$black);
	}
	$im->filledRectangle(80,158-int($plotdata[$question][2][0]*125/$bigmax),96,157,$ltBlue);
	if($plotdata[$question][2][0]>9) {
		$im->string(gdSmallFont,82,144-int($plotdata[$question][2][0]*125/$bigmax),$plotdata[$question][2][0],$black);
	}
	elsif($plotdata[$question][2][0]>0) {
		$im->string(gdSmallFont,86,144-int($plotdata[$question][2][0]*125/$bigmax),$plotdata[$question][2][0],$black);
	}
	else {
		$im->string(gdSmallFont,86,144-int($plotdata[$question][2][0]*125/$bigmax),"0",$black);
	}
	$im->filledRectangle(105,158-int($plotdata[$question][3][0]*125/$bigmax),121,157,$green);
	if($plotdata[$question][3][0]>9) {
		$im->string(gdSmallFont,107,144-int($plotdata[$question][3][0]*125/$bigmax),$plotdata[$question][3][0],$black);
	}
	elsif($plotdata[$question][3][0]>0) {
		$im->string(gdSmallFont,111,144-int($plotdata[$question][3][0]*125/$bigmax),$plotdata[$question][3][0],$black);
	}
	else {
		$im->string(gdSmallFont,111,144-int($plotdata[$question][3][0]*125/$bigmax),"0",$black);
	}
	$im->filledRectangle(130,158-int($plotdata[$question][4][0]*125/$bigmax),146,157,$red);
	if($plotdata[$question][4][0]>9) {
		$im->string(gdSmallFont,132,144-int($plotdata[$question][4][0]*125/$bigmax),$plotdata[$question][4][0],$black);
	}
	elsif($plotdata[$question][4][0]>0) {
		$im->string(gdSmallFont,136,144-int($plotdata[$question][4][0]*125/$bigmax),$plotdata[$question][4][0],$black);
	}
	else {
		$im->string(gdSmallFont,136,144-int($plotdata[$question][4][0]*125/$bigmax),"0",$black);
	}
	
	$im->line(236,133,444,133,$gray);
	$im->line(236,108,444,108,$gray);
	$im->line(236,83,444,83,$gray);
	$im->line(236,58,444,58,$gray);
	$im->line(236,33,444,33,$gray);
	
# Generate scatter plots
	for ($test=1; $test<5; $test++) {
		$im->filledArc(270,158-($plotdata[$question][$test][1]/$plotdata[$question][0][1])*125,8,8,0,360,$color[$test]);
		$im->filledArc(305,158-($plotdata[$question][$test][2]/$plotdata[$question][0][2])*125,8,8,0,360,$color[$test]);
		$im->filledArc(340,158-($plotdata[$question][$test][3]/$plotdata[$question][0][3])*125,8,8,0,360,$color[$test]);
		$im->filledArc(375,158-($plotdata[$question][$test][4]/$plotdata[$question][0][4])*125,8,8,0,360,$color[$test]);
		$im->filledArc(410,158-($plotdata[$question][$test][5]/$plotdata[$question][0][5])*125,8,8,0,360,$color[$test]);
 
		if((5*$slope[$question][$test])+$intercept[$question][$test]<=158 && (5*$slope[$question][$test])+$intercept[$question][$test]>=33) {  
	    	$im->line(270,($intercept[$question][$test]+$slope[$question][$test]),410,(5*$slope[$question][$test])+$intercept[$question][$test],$color[$test]);
	  	}
	  	
	  	elsif((5*$slope[$question][$test])+$intercept[$question][$test]<33) { 
	    	$im->line(270,($intercept[$question][$test]+$slope[$question][$test]),410-((33-5*$slope[$question][$test])/$slope[$question][$test]),33,$color[$test]);
		}

	  	else {
	    	$im->line(270,($intercept[$question][$test]+$slope[$question][$test]),410-(((5*$slope[$question][$test]+$intercept[$question][$test])-158)/$slope[$question][$test]*35),158,$color[$test]);
		}
	}

	# Open a file for writing
	open(PICTURE, ">$graphicpath/question$numval.png") or die("Cannot open file for writing");

	# Make sure we are writing to a binary stream
	binmode PICTURE;
	
	# Convert the image to PNG and print it to the file PICTURE
	print PICTURE $im->png;
	close PICTURE;
}


# +--------------------------------------------------------------------------+ #
# |        Plotting the distribution of the psychometric scores              | #
# +--------------------------------------------------------------------------+ #
$topscore=0;
for ($count=1; $count<=20; $count++) {
  if ($psych_distribution[$count] > $topscore) {
    $topscore=$psych_distribution[$count];
  }
}

if ($topscore%5>0) {
  $maxvalue = $topscore + (5 - $topscore%5);
}
else {
  $maxvalue=$topscore+5;
}

$interval = $maxvalue/5;

# Create a new image
$im = new GD::Image(710,300);

# Define a few colors
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);
$red = $im->colorAllocate(255,102,51);
$bkRed = $im->colorAllocate(255,220,220);
$blue = $im->colorAllocate(0,0,255);
$bkBlue = $im->colorAllocate(220,220,255);
$ltBlue = $im->colorAllocate(51,204,255);
$green = $im->colorAllocate(74,160,44);
$bkGreen = $im->colorAllocate(220,255,220);
$yellow = $im->colorAllocate(255,255,51);
$bkYellow = $im->colorAllocate(255,255,220);
$orange = $im->colorAllocate(245,184,0);
$ltGray = $im->colorAllocate(241,241,241);
$medGray = $im->colorAllocate(227,227,227);
$gray = $im->colorAllocate(153,153,153);
@color=($gray,$black,$blue,$green,$red);

# Make the background transparent and interlaced
$im->transparent($white);
$im->interlaced('true');

# Draw the constant portion: plot areas, ticks, and labels
# Frequency of option selection plot first
$im->filledRectangle(50,25,693,250,$ltGray);
$im->rectangle(50,25,693,250,$black);
$im->line(51,50,692,50,$gray);
$im->line(51,90,692,90,$gray);
$im->line(51,130,692,130,$gray);
$im->line(51,170,692,170,$gray);
$im->line(51,210,692,210,$gray);

$im->filledRectangle(51,26,214,49,$red);
$im->filledRectangle(214,26,374,49,$yellow);
$im->filledRectangle(374,26,534,49,$green);
$im->filledRectangle(534,26,692,49,$ltBlue);

$im->line(214,26,214,249,$gray);
$im->line(374,26,374,249,$gray);
$im->line(534,26,534,249,$gray);

$im->string(gdMediumBoldFont,118,30,Poor,$black);
$im->string(gdMediumBoldFont,267,30,Marginal,$black);
$im->string(gdMediumBoldFont,437,30,Good,$black);
$im->string(gdMediumBoldFont,582,30,Excellent,$black);

$im->string(gdSmallFont,32,244,0,$black);
$im->line(46,210,50,210,$black);
if ($interval<10) {
  $im->string(gdSmallFont,32,204,$interval,$black);
}
else {
  $im->string(gdSmallFont,28,204,$interval,$black);
}
$im->line(46,170,50,170,$black);
if ($interval*2<10) {
  $im->string(gdSmallFont,32,164,$interval*2,$black);
}
else {
  $im->string(gdSmallFont,28,164,$interval*2,$black);
}
$im->line(46,130,50,130,$black);
if ($interval*3<10) {
  $im->string(gdSmallFont,32,124,$interval*3,$black);
}
else {
  $im->string(gdSmallFont,28,124,$interval*3,$black);
}
$im->line(46,90,50,90,$black);
if ($interval*4<10) {
  $im->string(gdSmallFont,32,84,$interval*4,$black);
}
else {
  $im->string(gdSmallFont,28,84,$interval*4,$black);
}
$im->line(46,50,50,50,$black);
if ($max<10) {
  $im->string(gdSmallFont,32,44,$maxvalue,$black);
}
else {
  $im->string(gdSmallFont,28,44,$maxvalue,$black);
}
$im->line(46,250,50,250,$black);
$im->string(gdMediumBoldFont,300,280,"Psychometric Quality Scores",$black);
$im->stringUp(gdMediumBoldFont,10,170,Frequency,$black);
$im->string(gdLargeFont,220,5,"Distribution of Psychometric Quality Scores",$black);

# Automatically build frequency bars
for($count=1; $count<=20; $count++) {
  $im->filledRectangle($count*32+28,250-int($psych_distribution[$count]*200/$maxvalue),$count*32+48,249,$blue);
    
  if($psych_distribution[$count] > 9) {
    $im->string(gdSmallFont,$count*32+33,235-int($psych_distribution[$count]*200/$maxvalue),$psych_distribution[$count],$black);
  }
  elsif ($psych_distribution[$count] > 0) {
    $im->string(gdSmallFont,$count*32+36,235-int($psych_distribution[$count]*200/$maxvalue),$psych_distribution[$count],$black);
  }
  else {
  	$im->string(gdSmallFont,$count*32+36,235-int($psych_distribution[$count]*200/$maxvalue),"0",$black);
  }	
  
  $im->line($count*32+38,250,$count*32+38,254,$black);
  if($count<10) {
    $im->string(gdSmallFont,$count*32+36,260,$count,$black);
  }
  else {
    $im->string(gdSmallFont,$count*32+34,260,$count,$black);
  }
}

# Open a file for writing
open(PICTURE, ">$graphicpath/psychometric.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $im->png;
close PICTURE;






################################################################################
# +--------------------------------------------------------------------------+ #
# | [-4-]        Generation of individual student feedback reports           | #
# |                                                                          | #
# |           The reports may be emailed to each student if desired          | #
# +--------------------------------------------------------------------------+ #
################################################################################

# +--------------------------------------------------------------------------+ #
# |       Making sure that a directory exists for the student reports        | #
# +--------------------------------------------------------------------------+ #

	$reportpath="$directory/reports/";
	if (-e $reportpath && -d $reportpath) {
		#the directory exists
	}
	else {mkdir $reportpath}

# +--------------------------------------------------------------------------+ #
# |       The loop begins here to generate a report for each student         | #
# +--------------------------------------------------------------------------+ #

for($student=0; $student<$numstudents; $student++) {
	$this_percent=$sum[$student]*100/$numquestions;
	
## Reset all variables between each individual calculation
	$lec1=$lec2=$lec3=$lec4=$lec5=$lec6=$lec7=$lec8=$lec9=$lec10=0;
	$total1=$total2=$total3=$total4=$total5=$total6=$total7=$total8=$total9=$total10=0;
	$mt=$tf=$mc=$cp=$sq=0;
	$totalmt=$totaltf=$totalmc=$totalcp=$totalsq=0;

## Begin writing to the file
	open (FEEDBACK, ">$reportpath$choices[$student][2].html") || die "can not open student file\n";
	print FEEDBACK "<html>\n";
	print FEEDBACK "<head>\n";
	print FEEDBACK "<title>Student Feedback for $report{'course'} $report{'assignment'}</title>\n";
	print FEEDBACK <<EOS;
<style type="text/css">
<!--
#feedback {margin:auto; width: 900px; background: #ffffff; }
body {font-family: Arial, Helvetica, sans-serif; font-size: 12pt; line-height: 18pt; }
h1 {font-family: Arial, Helvetica, sans-serif; font-size: 24px; font-weight: bold; padding-top: 0px; padding-bottom: 0px;}
h2 {font-family: Arial, Helvetica, sans-serif; font-size: 14pt; font-weight: bold; margin: 12px 0px; }
a:link {font-family: Arial, Helvetica, sans-serif; font-weight: bold; text-decoration: none; }
a:visited {text-decoration: none; color: #0000ff; }
a:hover {text-decoration: underline; }
blockquote {margin-top: 4px; margin-bottom: 4px;}
p {margin: 8px 0px; }
.style_table_head {font-family: Arial, Helvetica, sans-serif; font-size: 12pt; color: #FFFFFF; font-weight: bold; }
.style_table {font-family: Arial, Helvetica, sans-serif; font-size: 10pt; font-weight: bold; }
.style_grade {font-family: "Courier New", Courier, monospace; font-size: 12pt; }
.style_question {font-family: Arial, Helvetica, sans-serif; font-size: 24px; font-weight: bold; }
.style_feedback {font-family: Arial, Helvetica, sans-serif; font-size: 10pt; line-height: 12pt;}
.style_better {color: #0000FF; font-weight: bold; }
.style_worse {color: #FF0000; font-weight: bold; }
.topSpace {margin-top: 20px;}
.myButton {
	-moz-box-shadow:inset 0px 1px 0px 0px #ffffff;
	-webkit-box-shadow:inset 0px 1px 0px 0px #ffffff;
	box-shadow:inset 0px 1px 0px 0px #ffffff;
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #1e6bfa), color-stop(1, #b7c0f0) );
	background:-moz-linear-gradient( center top, #1e6bfa 5%, #b7c0f0 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#1e6bfa', endColorstr='#b7c0f0');
	background-color:#1e6bfa;
	-moz-border-radius:42px;
	-webkit-border-radius:42px;
	border-radius:42px;
	border:1px solid #3b3b3b;
	display:inline-block;
	color:#ffffff;
	font-family:arial;
	font-size:10px;
	font-weight:bold;
	line-height:10pt;
	padding:4px 10px;
	text-decoration:none;
	text-shadow:1px 1px 2px #474747;
}.myButton:hover {
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #b7c0f0), color-stop(1, #1e6bfa) );
	background:-moz-linear-gradient( center top, #b7c0f0 5%, #1e6bfa 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#b7c0f0', endColorstr='#1e6bfa');
	background-color:#b7c0f0;text-decoration:none;
}.myButton:active {
	position:relative;
	top:1px;
}
.myButton:visited {text-decoration: none; color: #ffffff; }

.summary { margin-left: auto; margin-right: auto; font-style: normal; background-color: #f6f6f6; }
.summary caption { text-align: left; padding-top: 0.5em; padding-bottom: 0.5em; font-style:italic; font-weight: bold; }
.summary td { text-align: center; padding-left: 10px; border: 0px; }
.summary .bar { text-align: left; }
.summary .label { text-align: right; vertical-align: middle; line-height: 20px; border: 0; font-weight:100; font-style:italic; }
.summary .barblock { text-align: left; vertical-align: middle; border:0; font-style: normal; font-size: 10px; padding-bottom: 2px; padding-top: 2px; text-shadow: gray 3px 3px 5px; }


.barchart { margin-left: auto; margin-right: auto; font-style: normal; background-color: #f6f6f6; }
.barchart a:visited {text-decoration: none; color: #0000ff; }
.barchart caption { text-align: left; padding-top: 0.5em; padding-bottom: 0.5em; font-style:italic; font-weight: bold; }
.barchart td { text-align: center; padding-left: 10px; border:0; }
.barchart .bar { text-align: left; }
.barchart .label {vertical-align: middle; line-height: 20px; border: 0; font-weight:100; font-size: 10pt; font-style:italic; }
.barchart .barblock { text-align: left; vertical-align: middle; font-style: normal; font-size: 14px; width:auto; padding-bottom: 5px; padding-top: 5px; text-shadow: gray 3px 3px 5px; }
.style7 {font-family: Arial, Helvetica, sans-serif; font-size: 24px; font-weight: bold; color: #fcfcfc; }
.style8 {color: #009900}

-->
</style>
</head>

<body>
EOS
	print FEEDBACK "<div id=\"feedback\">\n";
  	print FEEDBACK "<h1 align=center><a name=\"top\" id=\"top\"></a>$report{'course'} - $report{'assignment'}</h1>\n";
  	print FEEDBACK "<h2 align=center>$report{'faculty'} - $report{'semester'}</h2>\n";

	print FEEDBACK <<EOS;
	  <h2>Introduction</h2>
<p>Welcome!  This is an automated report with feedback concerning your performance on our recent
 class exam. The purpose of this document is to provide you with 
specific and timely information about your progress toward achieving the
 course learning outcomes. The report is divided into six different 
sections wherein your performance is analyzed with respect to several 
different criteria. A brief description of each section is provided 
below along with links to enable rapid navigation within this document.</p>

<p><a href="#A" class="myButton">Part A</a>
 &nbsp;<strong>How did you do? </strong> I think that we both recognize that your first instinct is to find out 
how well you did on the exam overall. This section contains a summary of
 your performance on the assignment. Your exam score will determine 
whether or not you are required to schedule an office visit with Dr. 
Franklund to discuss your results. </p>
<p><a href="#B" class="myButton">Part B </a>
 &nbsp;<strong>What should you review? </strong> Our exams typically include material from several different topical areas that were covered
over a period of a few weeks. Your performance is broken down by lecture topic in this section. </p>
<p><a href="#C" class="myButton">Part C </a>
 &nbsp;<strong>How should you review?</strong> This exam also required various levels of "critical thinking". 
Your performance is broken down by different levels of thinking skills in this section. </p>
<p><a href="#D" class="myButton">Part D </a> &nbsp;<strong>What questions did you miss? </strong> If you have missed one or more questions on the exam, you will next 
  want to find them to check your answers. This section consists of a 
  listing of your responses for each item on the exam along with an 
  indication of whether your answer was correct or incorrect. </p>
<p><a href="#E" class="myButton">Part E </a>
 &nbsp;<strong>What factors contributed to your performance? </strong> This section will guide you to try to identify conditions that lead to the
 selection of incorrect answers for each item that you missed on the 
exam. You performance on an exam can be influenced by a variety of 
factors (note-taking, study skills, time management, test anxiety, <em>etc</em>.). Figuring out which ones are the most important for you is an 
important part of modifying your behavior for future assessments.</p>
<p><a href="#F" class="myButton">Part F </a>
  <strong>What are your thoughts about the exam? </strong> This report concludes with some prompts for our required metacognitive 
(self-reflection) activity. You will be expected to use this report to analyze your current
 study attitudes and habits. You may be required to write up and post your conclusions and revised study strategies in a reflective learning journal.</p>
<p>Please analyze these materials thoroughly and consult your notes and textbook to verify any 
factual information. If you have questions concerning either this 
report, the exam, or the materials covered in the exam - please, do not 
hesitate to contact $report{'instructor'}.</p>
<hr size="1">
<h2><a name="A" id="A"></a>A) Summary of your performance <a href="#top" class="myButton">back to top</a></h2>
EOS

	$temp_score=$sum[$student]/$numquestions*100;
	print FEEDBACK "<p>You correctly answered $sum[$student] out of $numquestions possible questions (scoring $score[$student] out of $maxpoints possible points) on this assignment. This gives you a score of <strong>";
	printf FEEDBACK ("%.1f", $temp_score);
	print FEEDBACK "\%</strong>, or <strong>";
	print FEEDBACK &letter_grade($temp_score);
	print FEEDBACK "</strong>. ";
	if($temp_score==100) {
		print FEEDBACK "You have clearly mastered the content covered by this assessement. Fantastic work! It is not a trivial thing to ace one of my exams; keep up the excellent work. Look over your exam to make sure that you understand why each answer was correct. As you did not miss any questions, the break down of your score below may not be of much use to you. ";
	}
	elsif($temp_score>=90) {
		print FEEDBACK "This indicates that you have an excellent understanding of the course materials (good job!). Look over your responses in the next section to find the few questions that you may have missed. Also check to see if there is a pattern to the missed questions - are they from the same lecture material or were they a similar style question? If you can determine <b>why</b> you made the errors that you did, you may be able to score even higher on the next exam. ";
	}
	elsif($temp_score>=80) {
		print FEEDBACK "You seem to have a very good grasp of the course materials on this assignment. Take some time to look for patterns in the questions that you missed in the sections below. Did they come from the same lecture or one kind of exam question? Use this report to try to determine <b>why</b> you missed each question. If you can determine what your weaknesses are, you will be in a position to better prepare for the next assesssment. ";
	}
	elsif($temp_score>=70) {
		print FEEDBACK "You seem to have an adequate understanding of the main concepts evaluated in this assessment. However, there are a few areas that you probably need to review. Try to determine if there are particular topics or critical thinking skills that are difficult for you. If you can determine what your weaknesses are, you will be in a position to better prepare for the next assesssment. ";
	}
	elsif($temp_score>=60) {
		print FEEDBACK "This would indicate that you have had some difficulty with this material. You probably have a basic grasp of some of this material, but may have some trouble applying what you know to new situations (different questions). You ought to use this report to determine if there are particular topics or critical thinking skills that are especially difficult for you. If you can determine what your weaknesses are, you will be in a position to better prepare for the next assesssment. I would encourage you to bring this report and your exam to my office hours so that we can discuss how you might go about improving your retention of the course materials (an your performance on the next exam). ";
	}
	else {
		print FEEDBACK "You apparently have had a great deal of difficulty with this material. I realize that you are likely very disappointed with this score, but try not to get discouraged. You ought to use this report to determine if there are particular topics or critical thinking skills that are especially difficult for you. If you can determine what your weaknesses are, you will be in a position to better prepare for the next assesssment. I would encourage you to bring this report and your exam to my office hours. We can try to sort out alternative study strategies for you to try for future exams. ";
	}
		
	print FEEDBACK <<EOS;
	Your score is plotted relative to the class average in the graph below. The width of the bars is proportional to the total possible score (100%). The colored portions of the bars indicate the level achieved by the class as a whole and by you individually on this assignment. Study the analyses that follow in order to identify the materials that were difficult for you.</p>

<table rules="none" frame="box" class="summary" summary="A comparison of your score versus the class average" border="1" cellpadding="7" cellspacing="0" width="900px">
<caption>
Figure 1: Summary of your exam performance 
</caption>
  <tbody><tr>
    <td class="label">Average </td>
    <td>

EOS
	$block="\&#9608;";
	printf FEEDBACK ("%.1f", $average_percent);
	print FEEDBACK "\%</td> \n <td class=\"barblock\"><font color=\"black\">";
    for ($printblock=0; $printblock<int($average_percent+0.5); $printblock++) {
    	print FEEDBACK $block;
	}
	print FEEDBACK "</font><font color=\"#c0c0c0\">";
	for ($printblock=0; $printblock<100-int($average_percent+0.5); $printblock++) {
		print FEEDBACK $block;
	}
	print FEEDBACK "</font></td></tr><tr><td class=\"label\"><strong>Your score</strong></td><td><strong>";
	printf FEEDBACK ("%.1f", $temp_score);
	print FEEDBACK "\%</strong></td><td class=\"barblock\"><font color=";
	if ($temp_score<60) {
		print FEEDBACK "\"red\">";
	}
	elsif ($temp_score<80) {
		print FEEDBACK "\"green\">";
	}
	else {
		print FEEDBACK "\"blue\">";
	}
	for ($printblock=0; $printblock<int($temp_score+0.5); $printblock++) {
		print FEEDBACK $block;
	}
	print FEEDBACK "</font><font color=\"#c0c0c0\">";
	for ($printblock=0; $printblock<100-int($temp_score+0.5); $printblock++) {
		print FEEDBACK $block;
	}
	print FEEDBACK "</font></td></tr></tbody></table><p>Based upon this performance, a visit with $report{'instructor'} during office hours is <font color=";
	if ($temp_score<60) {
		print FEEDBACK "\"red\"><em>MANDITORY</em></font>. Let's plan to meet together sometime this week to go over your exam and study strategies. ";
	}
	elsif ($temp_score<80) {
		print FEEDBACK "\"green\"><em>optional (but highly recommended</em>)</font>. ";
	}
	else {
		print FEEDBACK "\"blue\"><em>entirely optional</em></font>. ";
	}
	print FEEDBACK "You can sign up for an appointment in 15-minute blocks on the schedule posted at my office (ASC 2011). Before arranging an appointment though, you should first carefully analyze this report and complete the self-analysis portion in part E. Then bring this report along with your copy of the exam and your lecture notes to our scheduled meeting. Together, we will try to find the best strategy for improving your comprehension and performance in the class.</p><hr size=\"1\"><h2><a name=\"B\" id=\"B\"></a>B) Your performance by content area <a href=\"#top\" class=\"myButton\">back to top</a></h2><p>This exam assessed your understanding of material from several different content areas. Your performance on questions from each of these topics is shown graphically and summarized below. The total width of each bar is proportional to the number of points from questions keyed to that topic; the 
width of the blue bars indicates the number of those points that you earned on this exam. Take some time and examine the summary of your scores for each of these topics below. Look for areas of strength or weakness in your performance. Work to retain  your areas of strength and review your notes and textbook to improve in areas where your comprehension was not quite as 
robust.</p>";

	for($loop=0;$loop<@lecture; $loop++) {
		if($lecture[$loop] eq @report{'lec1'}) {
			$lec1+= $scores[$student][$loop];
			$total1+=$points[$loop];
		}
		elsif($lecture[$loop] eq @report{'lec2'}) {
			$lec2+= $scores[$student][$loop];
			$total2+=$points[$loop];
		}
		elsif($lecture[$loop] eq @report{'lec3'}) {
			$lec3+= $scores[$student][$loop];
			$total3+=$points[$loop];
		}
		elsif($lecture[$loop] eq @report{'lec4'}) {
			$lec4+= $scores[$student][$loop];
			$total4+=$points[$loop];
		}
		elsif($lecture[$loop] eq @report{'lec5'}) {
			$lec5+= $scores[$student][$loop];
			$total5+=$points[$loop];
		}
		elsif($lecture[$loop] eq @report{'lec6'}) {
			$lec6+= $scores[$student][$loop];
			$total6+=$points[$loop];
		}
		elsif($lecture[$loop] eq @report{'lec7'}) {
			$lec7+= $scores[$student][$loop];
			$total7+=$points[$loop];
		}
		elsif($lecture[$loop] eq @report{'lec8'}) {
			$lec8+= $scores[$student][$loop];
			$total8+=$points[$loop];
		}
		elsif($lecture[$loop] eq @report{'lec9'}) {
			$lec9+= $scores[$student][$loop];
			$total9+=$points[$loop];
		}
		else {
			$lec10+= $scores[$student][$loop];
			$total10+=$points[$loop];
		}
	}
	$max_total=$total1;
	if ($max_total<$total2) {$max_total=$total2;}
	if ($max_total<$total3) {$max_total=$total3;}
	if ($max_total<$total4) {$max_total=$total4;}
	if ($max_total<$total5) {$max_total=$total5;}
	if ($max_total<$total6) {$max_total=$total6;}
	if ($max_total<$total7) {$max_total=$total7;}
	if ($max_total<$total8) {$max_total=$total8;}
	if ($max_total<$total9) {$max_total=$total9;}
	if ($max_total<$total10) {$max_total=$total10;}
	
	if ($max_total<=15) {$scale=4;}
	elsif ($max_total<=20) {$scale=3;}
	elsif ($max_total<=30) {$scale=2;}
	else {$scale=1;}
	
	print FEEDBACK "<table rules=\"none\" frame=\"box\" class=\"barchart\" summary=\"A plot of your performance by lecture topic\" border=\"1\" cellpadding=\"7\" cellspacing=\"0\" width=\"900px\"><caption>Figure 2: Your performance by  topic - click on a bar to navigate to the corresponding summary</caption><tbody>";
	if($total1){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec1'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec1." of ".$total1."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic1\">";
		for ($printblock=0; $printblock<$lec1*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic1\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total1-$lec1)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	if($total2){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec2'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec2." of ".$total2."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic2\">";
		for ($printblock=0; $printblock<$lec2*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic2\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total2-$lec2)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";

	}
	if($total3){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec3'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec3." of ".$total3."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic3\">";
		for ($printblock=0; $printblock<$lec3*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic3\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total3-$lec3)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	if($total4){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec4'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec4." of ".$total4."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic4\">";
		for ($printblock=0; $printblock<$lec4*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic4\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total4-$lec4)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	if($total5){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec5'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec5." of ".$total5."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic5\">";
		for ($printblock=0; $printblock<$lec5*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic5\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total5-$lec5)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	if($total6){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec6'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec6." of ".$total6."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic6\">";
		for ($printblock=0; $printblock<$lec6*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic6\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total6-$lec6)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	if($total7){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec7'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec7." of ".$total7."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic7\">";
		for ($printblock=0; $printblock<$lec7*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic7\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total7-$lec7)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	if($total8){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec8'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec8." of ".$total8."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic8\">";
		for ($printblock=0; $printblock<$lec8*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic8\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total8-$lec8)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	if($total9){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec9'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec9." of ".$total9."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic9\">";
		for ($printblock=0; $printblock<$lec9*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic9\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total9-$lec9)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	if($total10){
		print FEEDBACK "<tr><td class=\"label\" width=\"225\"><div align=\"right\">".@report{'lec10'}."</div></td>\n";
		print FEEDBACK "<td class=\"label\" width=\"70px\"><div align=\"center\">".$lec10." of ".$total10."</div></td>\n";
		print FEEDBACK "<td class=\"barblock\"><font color=\"0000ff\"><a href=\"#topic10\">";
		for ($printblock=0; $printblock<$lec10*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</a></font><a href=\"#topic10\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($total10-$lec10)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK "</font></a></td></tr>\n";
	}
	print FEEDBACK "</tbody></table>\n\n";

	if($total1) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic1\" id=\"topic1\"></a>@report{'lec1'}</em></strong> - <i>$report{'description1'}</i></p><blockquote>You scored <strong>$lec1 out of $total1</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec1/$total1*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec1,$total1)."</blockquote><p>".$report{'source1'}."</p>\n";
	}
	if($total2) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic2\" id=\"topic2\"></a>@report{'lec2'}</em></strong> - <i>$report{'description2'}</i></p><blockquote>You scored <strong>$lec2 out of $total2</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec2/$total2*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec2,$total2)."</blockquote><p>".$report{'source2'}."</p>\n";
	}
	if($total3) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic3\" id=\"topic3\"></a>@report{'lec3'}</em></strong> - <i>$report{'description3'}</i></p><blockquote>You scored <strong>$lec3 out of $total3</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec3/$total3*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec3,$total3)."</blockquote><p>".$report{'source3'}."</p>\n";
	}
	if($total4) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic4\" id=\"topic4\"></a>@report{'lec4'}</em></strong> - <i>$report{'description4'}</i></p><blockquote>You scored <strong>$lec4 out of $total4</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec4/$total4*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec4,$total4)."</blockquote><p>".$report{'source4'}."</p>\n";
	}
	if($total5) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic5\" id=\"topic5\"></a>@report{'lec5'}</em></strong> - <i>$report{'description5'}</i></p><blockquote>You scored <strong>$lec5 out of $total5</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec5/$total5*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec5,$total5)."</blockquote><p>".$report{'source5'}."</p>\n";
	}
	if($total6) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic6\" id=\"topic6\"></a>@report{'lec6'}</em></strong> - <i>$report{'description6'}</i></p><blockquote>You scored <strong>$lec6 out of $total6</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec6/$total6*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec6,$total6)."</blockquote><p>".$report{'source6'}."</p>\n";
	}
	if($total7) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic7\" id=\"topic7\"></a>@report{'lec7'}</em></strong> - <i>$report{'description7'}</i></p><blockquote>You scored <strong>$lec7 out of $total7</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec7/$total7*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec7,$total7)."</blockquote><p>".$report{'source7'}."</p>\n";
	}
	if($total8) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic8\" id=\"topic8\"></a>@report{'lec8'}</em></strong> - <i>$report{'description8'}</i></p><blockquote>You scored <strong>$lec8 out of $total8</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec8/$total8*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec8,$total8)."</blockquote><p>".$report{'source8'}."</p>\n";
	}
	if($total9) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic9\" id=\"topic9\"></a>@report{'lec9'}</em></strong> - <i>$report{'description9'}</i></p><blockquote>You scored <strong>$lec9 out of $total9</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec9/$total9*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec9,$total9)."</blockquote><p>".$report{'source9'}."</p>\n";
	}
	if($total10) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"topic10\" id=\"topic10\"></a>@report{'lec10'}</em></strong> - <i>$report{'description10'}</i></p><blockquote>You scored <strong>$lec10 out of $total10</strong> points (<em>";
		printf FEEDBACK ('%1.f',$lec10/$total10*100);
		print FEEDBACK "\%</em>) on questions from this topic. ".&content_feedback($score[$student],$maxpoints,$lec10,$total10)."</blockquote><p>".$report{'source10'}."</p>\n";
	}
	print FEEDBACK "</blockquote>\n<hr size=\"1\">\n<h2><a name=\"C\" id=\"C\"></a>C) Your performance by thinking skill <a href=\"#top\" class=\"myButton\">back to top</a></h2><p>This exam assessed your ability to use the course material at several different cognitive levels. Your performance on questions from each of these levels of critical thinking is illustrated graphically and summarized below. The total width of each bar is proportional to the number of points that were assigned to that type of thinking skill. The width of the blue portion indicates the fraction of the available points that you earned. Take some time and review the summary below. Look for areas of strength or weakness in your performance. Work to retain and expand your strengths and examine your study habits to identify ways to improve your performance.</p>\n";

$skill1=$skill2=$skill3=$skill4=$skill5=$skill6=$max_skill1=$max_skill2=$max_skill3=$max_skill4=$max_skill5=$max_skill6=0;

	for($loop=0;$loop<@lecture; $loop++) {
		if($skill[$loop] eq "Identifying") {
			$skill1+= $scores[$student][$loop];
			$max_skill1+=$points[$loop];
		}
		elsif($skill[$loop] eq "Categorizing") {
			$skill2+= $scores[$student][$loop];
			$max_skill2+=$points[$loop];
		}
		elsif($skill[$loop] eq "Calculating") {
			$skill3+= $scores[$student][$loop];
			$max_skill3+=$points[$loop];
		}
		elsif($skill[$loop] eq "Interpreting") {
			$skill4+= $scores[$student][$loop];
			$max_skill4+=$points[$loop];
		}
		elsif($skill[$loop] eq "Predicting") {
			$skill5+= $scores[$student][$loop];
			$max_skill5+=$points[$loop];
		}
		elsif($skill[$loop] eq "Judging") {
			$skill6+= $scores[$student][$loop];
			$max_skill6+=$points[$loop];
		}
		else { 
			$no_skills_set=1;
		}
	}
	$max_total=$max_skill1;
	if ($max_total<$max_skill2) {$max_total=$max_skill2;}
	if ($max_total<$max_skill3) {$max_total=$max_skill3;}
	if ($max_total<$max_skill4) {$max_total=$max_skill4;}
	if ($max_total<$max_skill5) {$max_total=$max_skill5;}
	if ($max_total<$max_skill6) {$max_total=$max_skill6;}
	
	if ($max_total<=14) {$scale=4;}
	elsif ($max_total<=19) {$scale=3;}
	elsif ($max_total<=29) {$scale=2;}
	else {$scale=1;}

	print FEEDBACK "<table rules=\"none\" frame=\"box\" class=\"barchart\" summary=\"A plot of your performance by thinking skill\" border=\"1\" cellpadding=\"7\" cellspacing=\"0\" width=\"900px\"><caption>Figure 3: Your performance by thinking skills - click on a bar to jump to the corresponding summary</caption><tbody>\n";
	if($max_skill1){
		print FEEDBACK "<tr><td class=\"label\" width=\"100\"><div align=\"right\">Identifying</div></td><td class=\"label\" width=\"70\"><div align=\"center\">$skill1 of $max_skill1</div></td><td class=\"barblock\"><font color=\"0000ff\"><a href=\"#cognitive1\">";
		for ($printblock=0; $printblock<$skill1*$scale; $printblock++) {
			print FEEDBACK $block;
		}		
		print FEEDBACK "</a></font><a href=\"#cognitive1\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($max_skill1-$skill1)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK"</font></a></td></tr>\n";
	}	
	if($max_skill2){
		print FEEDBACK "<tr><td class=\"label\" width=\"100\"><div align=\"right\">Categorizing</div></td><td class=\"label\" width=\"70\"><div align=\"center\">$skill2 of $max_skill2</div></td><td class=\"barblock\"><font color=\"0000ff\"><a href=\"#cognitive2\">";
		for ($printblock=0; $printblock<$skill2*$scale; $printblock++) {
			print FEEDBACK $block;
		}		
		print FEEDBACK "</a></font><a href=\"#cognitive2\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($max_skill2-$skill2)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK"</font></a></td></tr>\n";
	}	
	if($max_skill3){
		print FEEDBACK "<tr><td class=\"label\" width=\"100\"><div align=\"right\">Calculating</div></td><td class=\"label\" width=\"70\"><div align=\"center\">$skill3 of $max_skill3</div></td><td class=\"barblock\"><font color=\"0000ff\"><a href=\"#cognitive3\">";
		for ($printblock=0; $printblock<$skill3*$scale; $printblock++) {
			print FEEDBACK $block;
		}		
		print FEEDBACK "</a></font><a href=\"#cognitive3\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($max_skill3-$skill3)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK"</font></a></td></tr>\n";
	}	
	if($max_skill4){
		print FEEDBACK "<tr><td class=\"label\" width=\"100\"><div align=\"right\">Interpreting</div></td><td class=\"label\" width=\"70\"><div align=\"center\">$skill4 of $max_skill4</div></td><td class=\"barblock\"><font color=\"0000ff\"><a href=\"#cognitive4\">";
		for ($printblock=0; $printblock<$skill4*$scale; $printblock++) {
			print FEEDBACK $block;
		}		
		print FEEDBACK "</a></font><a href=\"#cognitive4\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($max_skill4-$skill4)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK"</font></a></td></tr>\n";
	}	
	if($max_skill5){
		print FEEDBACK "<tr><td class=\"label\" width=\"100\"><div align=\"right\">Predicting</div></td><td class=\"label\" width=\"70\"><div align=\"center\">$skill5 of $max_skill5</div></td><td class=\"barblock\"><font color=\"0000ff\"><a href=\"#cognitive5\">";
		for ($printblock=0; $printblock<$skill5*$scale; $printblock++) {
			print FEEDBACK $block;
		}		
		print FEEDBACK "</a></font><a href=\"#cognitive5\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($max_skill5-$skill5)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK"</font></a></td></tr>\n";
	}	
	if($max_skill6){
		print FEEDBACK "<tr><td class=\"label\" width=\"100\"><div align=\"right\">Judging</div></td><td class=\"label\" width=\"70\"><div align=\"center\">$skill6 of $max_skill6</div></td><td class=\"barblock\"><font color=\"0000ff\"><a href=\"#cognitive6\">";
		for ($printblock=0; $printblock<$skill6*$scale; $printblock++) {
			print FEEDBACK $block;
		}		
		print FEEDBACK "</a></font><a href=\"#cognitive6\"><font color=\"#c0c0c0\">";
		for ($printblock=0; $printblock<($max_skill6-$skill6)*$scale; $printblock++) {
			print FEEDBACK $block;
		}
		print FEEDBACK"</font></a></td></tr>\n";
	}
	
	print FEEDBACK "</tbody></table>\n\n";

	if($max_skill1) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"cognitive1\" id=\"cognitive1\"></a>Identifying</em></strong> - <i>In order to successfully work at this level, you must $skill_desc[1]</i></p><blockquote>" .&skills_feedback($score[$student],$maxpoints,$skill1,$max_skill1)."</blockquote><p>Questions at this cognitive level stress simple recall of facts, concepts, and procedures. There are many ways to improve your memory of course materials - study practices that involve drill are often effective. Try making flashcards of the bold-face items from our lecture slides. The StudyMate resource on our FerrisConnect site is a fun and easy way to create electronic flashcards and other types of interative drill activities. You should also use the online practice quizzes to get in some extra review time.</p>\n";
	}
	if($max_skill2) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"cognitive2\" id=\"cognitive2\"></a>Categorizing</em></strong> - <i>In order to successfully work at this level, you must $skill_desc[2]</i></p><blockquote>" .&skills_feedback($score[$student],$maxpoints,$skill2,$max_skill2)."</blockquote><p>Questions at this cognitive level focus upon the concepts underlying specific facts and procedures. There are many ways to improve your understanding of course materials. Activities that emphasize classification and sorting are often most helpful. Try making concept maps of the terms found in the course material. Focus more on how things are similar or different from each other, rather than just learning the definitions.</p>\n";
	}
	if($max_skill3) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"cognitive3\" id=\"cognitive3\"></a>Calculating</em></strong> - <i>In order to successfully work at this level, you must $skill_desc[3]</i></p><blockquote>" .&skills_feedback($score[$student],$maxpoints,$skill3,$max_skill3)."</blockquote><p>Questions at this cognitive level require you to use your knowledge to solve specific problems using mathematics. There are ways to improve your problem solving abilities. When you review that material, look for any formulas that were covered in class. Practice making calculations using those formulas by substituting in new values. When looking over any worked problems or case studies from class, ask yourself \"what would happen if this factor were altered?\".</p>\n";
	}
	if($max_skill4) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"cognitive4\" id=\"cognitive4\"></a>Interpreting</em></strong> - <i>In order to successfully work at this level, you must $skill_desc[4]</i></p><blockquote>" .&skills_feedback($score[$student],$maxpoints,$skill4,$max_skill4)."</blockquote><p>Questions at this cognitive level have you interpret data or analyze a novel situation. To improve in this ability, try to practice recognizing the most important details or facts in the problems or case studies mentioned in class. Go back over those problems and try to find any patterns in the way that they were answered or solved. Try to see the logic behind the questions, - not just the facts that were presented. You should also try to explain key figures or datasets covered in class in your own words.</p>\n";
	}
	if($max_skill5) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"cognitive5\" id=\"cognitive5\"></a>Predicting</em></strong> - <i>In order to successfully work at this level, you must $skill_desc[5]</i></p><blockquote>" .&skills_feedback($score[$student],$maxpoints,$skill5,$max_skill5)."</blockquote><p>Questions at this cognitive level involve finding the most likely consequence of changes made to a biological system. To improve in this area, review the key processes covered in class again. This time, try to see how the system relies upon each component. Then ask yourself - what would happen if this component were missing or damaged? We will actually cover a few examples like this in class to help you along.</p>\n";
	}
	if($max_skill6) {
		print FEEDBACK "<p class=\"topSpace\"><strong><em><a name=\"cognitive6\" id=\"cognitive6\"></a>Judging</em></strong> - <i>In order to successfully work at this level, you must $skill_desc[6]</i></p><blockquote>" .&skills_feedback($score[$student],$maxpoints,$skill6,$max_skill6)."</blockquote><p>Questions at this cognitive level involve finding the best possible explanation when presented with a novel situation. To improve in this area, review the situations covered in class again. This time, look for strengths or weaknesses in the predicitons made. Why were they weak (or strong) and how could this be altered? Try to determine what the best interpretation of any data presented is - focusing now upon WHY it is the best explanation.</p>\n";
	}
	print FEEDBACK "<hr size=\"1\"><h2><a name=\"D\" id=\"D\"></a>D) Record of your responses <a href=\"#top\" class=\"myButton\">back to top</a></h2><p>Information is provided in the table below for each item of the assessment. The the cognitive task required and topic addressed by each question is shown along with your response and an indication of whether or not you responded correctly. If you miss a question, a clue will be given to help you sort out where you went wrong. It is more important to understand why your response was
  incorrect that to spend a lot of time trying to memorize the \'right\' answer.</p><table border=\"1\" cellpadding=\"5\" cellspacing=\"0\" width=\"900\"><tbody>\n";

	for($position=0; $position<$numquestions; $position++) {
		if($grades[$student][$position]==0) {
			print FEEDBACK "<tr><td align=\"center\" bgcolor=\"#CC0000\" valign=\"middle\" width=\"35\" height=\"40\"><span class=\"style7\">$num[$position]</span></td><td bgcolor=\"#CCCCCC\"><span class=\"style_feedback\">This question required <em>$skill[$position]</em> information covered in  <em>$lecture[$position]</em>.<br />Your response of <strong>$choices[$student][$position+7] was <u>incorrect</u></strong>. <em><strong>Hint: $feedback[$position]</strong></em></span></td></tr>\n";
		}
		else {
			print FEEDBACK "<tr><td align=\"center\" bgcolor=\"#33FF99\" valign=\"middle\" width=\"35\" height=\"40\"><span class=\"style_question\">$num[$position]</span></td><td class=\"style_feedback\">This question required <em>$skill[$position]</em> information  covered in <em>$lecture[$position]</em>.<br />
        Your response of <strong>$choices[$student][$position+7] was correct</strong> ($points[$position] points).</td></tr>\n";
		}
	}

	print FEEDBACK <<EOS;
  </tbody>
</table>
<hr size="1" />
<h2><a name="E" id="E"></a>E) Self-analysis of your responses <a href="#top" class="myButton">back to top</a></h2>
<p>Learning and test-taking are complex 
activities. There are many different factors that can interact to 
affect your performance on any course assignment. Sections B, C, and D from above should help you to determine <strong><em>what</em></strong> you had the most difficulty with on this exam. This section tries to help you to determine <strong><em>why</em></strong>
 you had these difficulties. You are expected 
to use this feedback to diagnose which factors are most relevant to you and to then to prepare a plan in order to address those issues for future assessments. </p>
<p>The process of learning can break down at one of three levels: 1) accurately receiving the information, 2) effectively studying the information, and 3) correctly using the information. Some common problems at each of these levels are briefly described below. Following these descriptions is a table containing the questions numbers  for each of your incorrect responses on this assessment. For each question, take a little time to consider which of these problems contributed <em>most</em> to your incorrect response and indicate them with an 'X'. As you complete the table, look for patterns in your responses. Which area seems to predominate for you? What steps can you take to address these patterns? This analysis should be included in your reflective learning journal entry for part F. </p>
<p><strong>1) Receiving the course content</strong> (<em>have you accurately heard or read the relevant materials?</em>) </p>
  <blockquote>
    <p><strong>a) Absent from class </strong>- Did you miss class on the day that the content was covered? Trying to study without lecture notes is much more difficult. Even if you do get a  set of someone else's notes, you are relying upon them to accurately record all of the important information. That may or may not be the case. In addition, the actual process of hearing and seeing the material presented in class does matter. I have noted a strong positive correlation between class attendance and overall performance over the years. Problems with lecture attendance often correlate with other extra-curricular issues that can negatively impact course performance. If this is the case, we need to talk. </p>
    <p><strong>b) Did not enter into the lecture notes</strong> - Simply being physically present in the lecture hall is not enough. Concepts that are not adequately and accurately recorded in your notes are probably not studied well either. Do not fret is everything is not perfectly captured during lecture. Instead, get the main points down and fill in the gaps after class. It is best to review your lecture notes and correct any deficiencies within 24 hours of each lecture. You should consider using the lecture outline and PowerPoint handouts to facilitate note taking. Use abbreviations, symbols, and pictures in your notes to increase your writing speed. You can also ask questions during lecture to clarify points that are not making sense to you. </p>
    <p><strong>c) Did not read about this in the textbook</strong> - I am not in collusion with the textbook publishing company. Our textbook is actually quite good and amplifies most of the concepts that I present in class. The assigned readings provide important additional information to supplement our lectures and labs. Failure to utilize this resource will place you at a significant disadvantage on course assessments. Compare your incorrect responses against the assigned readings. Chances are - you will find the correct answers right there in the book. </p>
  </blockquote>
<p><strong>2) Practicing the course content </strong>(<em>have you effectively studied the relevant materials?</em>)</p>
  <blockquote>
    <p class="style_body"><strong>a) Did not review in notes</strong> - Good lecture notes are of little help if you do not review them regularly. A lot of information is presented in this course. As a consequence, some people pick and choose what to study based upon what they <em>think</em> will be covered. Listen for clues in lecture for important materials (repetition, emphasis, bold terms, and direct indications). You should re-read your notes within 24 hours of the initial lecture and then review them on at least a weekly basis. Waiting until the day before an exam (or even a couple of days) and then cramming usually leads to disappointing results. </p>
    <p class="style_body"><strong>b) Did not highlight in notes</strong> - This is related to the previous problem. When you recognize important materials - highlight them in your notes. You can color-code them, circle them, add asterisks.... I don't care what. Just make sure that they stand out so that you are sure to practice them well. If you take Cornell-style notes, you should embed prompts (questions) about the main concepts into your notes to facilitate your review. Practice covering the material and answering the prompts for the key materials that you have identified. </p>
    <p class="style_body"><strong>c) Did not correctly understand the concept</strong> - Finally, having things in your notes is not helpful if you discover that your understanding of the material was incorrect or incomplete. If something is unclear at all... ASK! Speak up in class, email Dr. Franklund, visit his office hours, or just pull him aside for a quick chat. I cannot always tell when people are not properly understanding - until it is too late. </p>
  </blockquote>
<p><strong>3) Using the course content </strong>(<em>can you correctly apply what you have learned?</em>)</p>
  <blockquote>
    <p class="style_body"><strong>a) Second-guessed the response</strong> - Oh, how this one used to drive me nuts as a student. I usually suggest that students stick with their original intuition unless they spot an obvious mistake. Sometimes you will be able to get a question down to two possible answers. Carefully read the question and take your best shot. If you find that you are second-guessing yourself out of too many points, you will need to modify your test-taking strategies. </p>
    <p class="style_body"><strong>b) Misread the question</strong> - Many questions are missed just by sloppy reading. Carefully read each question. If any vocabulary terms are unfamiliar, ask for clarification. I try to keep the verbiage straight-forward on exam questions, but will rephrase the question for you if I can if your ask. </p>
    <p class="style_body"><strong>c) Response entry error</strong> - Sometimes students know the correct answer, but enter an incorrect response. Double-check all of your responses before leaving the lecture hall. I cannot know what you <em>meant</em>. I can only grade what you submit to me. </p>
  </blockquote>

<table border="1" cellpadding="0" cellspacing="0" width="900">
  <tbody><tr>
    <td align="center" bgcolor="#000000" valign="middle" width="90" height="35"></td>
    <td colspan="3" align="center" bgcolor="#000000" valign="middle" height="35"><span class="style_table_head">Receiving content </span></td>
    <td colspan="3" align="center" bgcolor="#000000" valign="middle" height="35"><span class="style_table_head">Practicing content </span></td>
    <td colspan="3" align="center" bgcolor="#000000" valign="middle" height="35"><span class="style_table_head">Using content </span></td>
  </tr>
  <tr>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Question</span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Absent that day </span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Not in lecture notes </span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Not read in textbook </span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Not reviewed for exam </span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Not highlighted</span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Not understood </span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Second guessed </span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Misread question </span></td>
    <td align="center" bgcolor="#CCCCCC" valign="middle" width="90" height="35"><span class="style_table">Incorrect entry </span></td>
  </tr>
EOS

	for($position=0; $position<$numquestions; $position++) {
		if($grades[$student][$position]==0) {
			print FEEDBACK "<tr><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\"><span class=\"style_table\">$num[$position]</span></td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td><td align=\"center\" valign=\"middle\" width=\"90\" height=\"35\">&nbsp;</td></tr>\n";
		}
	}

	print FEEDBACK <<EOS;
</tbody></table>
<hr size="1">
<h2><a name="F" id="F"></a>F) Reflections about your performance <a href="#top" class="myButton">back to top</a></h2>
<p>This section is the culmination of the post-assessment feedback. You should now summarize for yourself what you have learned and where you need to yet make progress. This process will involve metacognitive knowledge (thinking about how you think and learn) and communication (writing) skills. These activities, in turn, correspond to the course outcomes described in your syllabus.</p>
EOS

if (defined $report{'duedate'}) {
	print FEEDBACK "<p><strong>Due date</strong>: You must complete and post your online learning journal entry for credit. Late postings will suffer a 50% penalty. The last day for accepted journal entries is $report{'duedate'}</p>\n";
}	
if (defined $report{'prompt'}) {
	print FEEDBACK "<p><strong>Instructions</strong>: Your learning journal posting should directly and completely address the following questions.</p><p>$report{'prompt'}</p>\n";
}

print FEEDBACK <<EOS;
<hr size="1">
<p>I hope that you have found this feedback to be useful! I would be happy to receive your comments, questions, concerns, constructive criticisms, or suggestions concerning the course, the exam, or this report at any time.</p>
<p>Cheers!</p>
<p>Dr. Franklund</p>
<p>&nbsp;  </p>
</div>


</body></html>
EOS
	close (FEEDBACK);

# +--------------------------------------------------------------------------+ #
# | This is the routine to automatically send the reports to each student    | #
# | containing a user-specified subject line, message, and the report file   | #
# | attached as an HTML file.                                                | #
# | If the mail setting is >0, this code will execute. Else, just a local    | #
# | HTML report file will be generated.                                      | #
# +--------------------------------------------------------------------------+ #
	
	if($report{'mail'}>0) {
		$to = "$choices[$student][3], $report{'instructormail'}";
		## $to = "$report{'instructormail'}";
		$from = "$report{'instructormail'}";
		$subject = $report{'mailsubject'};
		$message = $report{'mailmessage'};
		$file = "$reportpath$choices[$student][2].html";
		$name = "$report{'mailattachmentname'}";

		# send email
		email($to, $from, $subject, $message, $file);

		# email function
		sub email{
			local ($to, $from, $subject, $message, $file) = @_;

			# create a new message
 			$msg = MIME::Lite->new(
  			From => $from,
  			To => $to,
  			Subject => $subject,
  			Data => $message
 			);

 			# add the attachment
 			$msg->attach(
  			Type => "text/html",
  			Path => $file,
  			Filename => $name,
  			Disposition => "attachment"
 			);

 			# send the email
 			MIME::Lite->send('smtp', $report{'mailserver'}, Timeout => 60);
 			$msg->send();
		}
	}
}



################################################################################
# +--------------------------------------------------------------------------+ #
# | [-5-]          Generation of the instructor summary report               | #
# |                                                                          | #
# |       This HTML document has links to each of the student reports        | #
# +--------------------------------------------------------------------------+ #
################################################################################

open (REPORT, ">$directory/$report{'logfile'}") || die "can not open the logfile\n";
	print REPORT "<html>\n";
	print REPORT "<head>\n";
	print REPORT "<title>Instructor's Report for $report{'course'} $report{'assignment'}</title>\n";
	print REPORT <<EOS;

<style type="text/css">
<!--
#feedback {margin:auto; width: 960px; background: #ffffff; }
body {font-family: Arial, Helvetica, sans-serif; font-size: 12pt; line-height: 18pt; }
h1 {font-family: Arial, Helvetica, sans-serif; font-size: 24px; font-weight: bold; padding-top: 0px; padding-bottom: 0px;}
h2 {font-family: Arial, Helvetica, sans-serif; font-size: 14pt; font-weight: bold; margin: 12px 0px; }
ol li {margin: 5px; padding: 5px; font-family: Arial, Helvetica, sans-serif; font-size: 12pt;}
a:link {font-family: Arial, Helvetica, sans-serif; font-weight: bold; text-decoration: none; }
a:visited {text-decoration: none; color: #0000ff; }
a:hover {text-decoration: underline; }
p {margin: 8px 0px; }
blockquote {margin-left: 14px; margin-top:0px; margin-bottom:0px;}
.style_table_head {font-family: Arial, Helvetica, sans-serif; font-size: 12pt; color: #FFFFFF; font-weight: bold; }
.style_table {font-family: Arial, Helvetica, sans-serif; font-size: 10pt; font-weight: bold; }
.style_grade {font-family: "Courier New", Courier, monospace; font-size: 12pt; }
.style_question {font-family: Arial, Helvetica, sans-serif; font-size: 24px; font-weight: bold; }
.style_feedback {font-family: Arial, Helvetica, sans-serif; font-size: 10pt; line-height: 12pt;}
.style_better {color: #0000FF; font-weight: bold; }
.style_same {color: #404040; font-weight: bold; }
.style_worse {color: #FF0000; font-weight: bold; }
.style_items {font-family:Arial, Helvetica, sans-serif; font-size:12pt; line-height:14pt;}

.myButton {
	-moz-box-shadow:inset 0px 1px 0px 0px #ffffff;
	-webkit-box-shadow:inset 0px 1px 0px 0px #ffffff;
	box-shadow:inset 0px 1px 0px 0px #ffffff;
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #1e6bfa), color-stop(1, #b7c0f0) );
	background:-moz-linear-gradient( center top, #1e6bfa 5%, #b7c0f0 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#1e6bfa', endColorstr='#b7c0f0');
	background-color:#1e6bfa;
	-moz-border-radius:42px;
	-webkit-border-radius:42px;
	border-radius:42px;
	border:1px solid #3b3b3b;
	display:inline-block;
	color:#ffffff;
	font-family:arial;
	font-size:10px;
	font-weight:bold;
	line-height:10pt;
	padding:4px 10px;
	text-decoration:none;
	text-shadow:1px 1px 2px #474747;
}.myButton:hover {
	background:-webkit-gradient( linear, left top, left bottom, color-stop(0.05, #b7c0f0), color-stop(1, #1e6bfa) );
	background:-moz-linear-gradient( center top, #b7c0f0 5%, #1e6bfa 100% );
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#b7c0f0', endColorstr='#1e6bfa');
	background-color:#b7c0f0;text-decoration:none;
}.myButton:active {
	position:relative;
	top:1px;
}
.myButton:visited {text-decoration: none; color: #ffffff; }
.topSpace {margin-top: 5px;}
.listing_head {font-size: 12px; font-family: Arial, Helvetica, sans-serif; color:#ffffff; line-height: 14px;}
.listing {font-size: 12px; font-family: Arial, Helvetica, sans-serif; color:#000000; line-height: 14px;}

.style10 {font-size: 12px; font-weight: bold; }
.style13 {color: #FFFFFF}
.style8 {font-size: 12px}
.style9 {font-family: Arial, Helvetica, sans-serif}
.style24 {font-size: 12pt}
.style28 {color: #FFFFFF; font-weight: bold; }
.style29 {
	color: #000000;
	font-weight: bold;
}
span.myPop {font-family:"Arial", Helvetica, sans-serif;
  font-size:36px; 
  border-bottom: thin dotted;}
span.myPop:hover {text-decoration: none; 
  background: #ffffff; 
  z-index: 6; }
span.myPop span {position: absolute; left: -9999px;
  margin: 0px 0 0 0px; padding: 3px 3px 3px 3px;
  border-style:solid; border-color:black; border-width:1px; z-index: 6;}
span.myPop:hover span {left: 4%; background: #ffffff;} 
span.myPop span {position: absolute; left: -9999px;
  margin: 4px 0 0 0px; padding: 3px 3px 3px 3px; 
  border-style:solid; border-color:black; border-width:1px;}
span.myPop:hover span {margin: 20px 0 0 20px; background: #ffffff; z-index:6;} 
#pop-table{font-family:"Arial", Helvetica, sans-serif;
  font-size:12px;
  width:460px;
  text-align:center;
  border-collapse:collapse;
  margin:20px;}
#pop-table th{font-size:13px;
  font-weight:normal;
  background:#333333;
  border-top:4px solid #000000;
  border-bottom:1px solid #fff;
  color:#fff;
  padding:8px;}
#pop-table td{background:#eeeeee;
  border-bottom:1px solid #fff;
  color:#000;
  border-top:1px solid transparent;
  padding:8px;}
#pop-table tr.key td{background:#9f9f9f;
color:#000;}
#pop-table caption{font-size:16px;
  font-weight:bold;}
-->
</style>
</head>

<body>
EOS
	print REPORT "<div id=\"feedback\">\n";
  	print REPORT "<h1 align=center><a name=\"top\" id=\"top\"></a>$report{'course'} - $report{'assignment'}</h1>\n";
  	print REPORT "<h2 align=center>Instructor Report for $report{'faculty'} - $report{'semester'}</h2>\n";

	print REPORT <<EOS;

  <h2>Introduction</h2>
<p>Welcome!  This is an automated report concerning the class' performance on a recent
  exam. This analysis is based upon classical test theory and is presented in several sections. A brief description of each section is provided 
below along with links to enable rapid navigation within this document. The document can be used to evaluate the performance of the class and the exam and to identify weaknesses and strengths therein. </p>

<p><a href="#A" class="myButton">Part A</a>
 &nbsp;<strong>Summary of exam scores: </strong> This section reports the overall distribution of class score for the assessment. Descriptive statistics are provided and some of their implications are discussed. </p>
<p><a href="#B" class="myButton">Part B </a>
 &nbsp;<strong>Listing of student scores: </strong> The performance of each student in the class is reported in this section. The actual (observed) score is provided along with an estimate of the students' true score. The observed and true scores are plotted with a score band that represents the 90% confidence interval for the students' true score. </p>
<p><a href="#C" class="myButton">Part C </a>
 &nbsp;<strong>Outcome assessment:</strong> Some or all of the items in this exam have been mapped to specific course outcomes. The results of these questions have been compiled and analyzed to determine what progress the class has made so far toward achieving these goals. </p>
<p><a href="#D" class="myButton">Part D </a>
 &nbsp;<strong>Exam specifications:</strong> The balance of exam items corresponding to each content area and relevant thinking skill is tabulated here. This information can be useful for evaluating the validity of the assessment. </p>
<p><a href="#E" class="myButton">Part E </a> &nbsp;<strong>Performance by content area: </strong> The class scores are reported by content area here. This can facilitate the identification of weaknesses in different areas of the material presented. </p>
<p><a href="#F" class="myButton">Part F </a>
 &nbsp;<strong>Performance by thinking skill: </strong>The class scores are reported by kinds of thinking skills required here. This can facilitate the identification of weaknesses in comprehension. </p>
<p><a href="#G" class="myButton">Part G </a>
  <strong>&nbsp;Psychometric assessment of exam items: </strong> The performance of each exam item is evaluated in this section. This allows for the identification of weak or poorly functioning questions. </p>
<p><a href="#H" class="myButton">Part H </a> <strong>&nbsp;Annotated reading list: </strong> A few useful references are included at the end of this report to aid those interested in learning more about the analyses performed by this program. </p>
<hr size="1">
<h2><a name="A" id="A"></a>A) Summary of exam scores <a href="#top" class="myButton">back to top</a></h2>
<p>A total of $numstudents students took this assessment; the distribution of scores (as percentages) is plotted below. The exam had $numquestions questions worth a maximum of $maxpoints points. The criterion of success (set at $report{'criterion'}\%) is indicated by the vertical dashed line. Some descriptive statistics for this assignment are also provided in this section. </p>
<img src="graphics/distribution.png" width="395" height="300" align="right" />
<ul>
  <li>The class average was 
EOS
 
printf REPORT "%4.1f", $average_score/$maxpoints*100;
print REPORT "\%, with students scoring ";
printf REPORT "%4.1f", $average_score;
print REPORT " out of $maxpoints possible points (a letter grade of ";
print REPORT &letter_grade($average_score/$maxpoints*100);
print REPORT "). </li> \n <li>The standard deviation of the mean was ";
printf REPORT "%4.1f",$stdev_score/$maxpoints*100;
print REPORT "\% (";
printf REPORT "%4.1f", $stdev_score;
print REPORT " points). </li>";
print REPORT "<li>The standard error of the mean was ";
printf REPORT "%4.1f",$sterr_score/$maxpoints*100;
print REPORT "% (";
printf REPORT "%3.1f", $sterr_score;
print REPORT " points). </li>";
print REPORT "<li>The median class score was ";
printf REPORT "%4.1f", $med_percent;
print REPORT "\%, or $median points. (a letter grade of ";
print REPORT &letter_grade($med_percent);
print REPORT ").</li>";

# skew report
if ($skew < -1.0) {
	print REPORT  "<li>This score distribution was <span class=style_worse>profoundedly skewed</span> to the left (skew = ";
	printf REPORT "%4.2f", $skew;
	print REPORT "). The Z-score for this skew was ";
	printf REPORT "%4.2f", $Z_skew;
	if ($Z_skew > 1.96 || $Z_skew < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> negative skew (<i>p</i> \< 0.05) - higher scores predominate with exam scores tailing off excessively to the left. A negative skew can, however, indicate that learning has occured in the class population. (a good thing!) </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span>; this is somewhat surprising given the magnitude of the skew - higher scores predominate with exam scores tailing off excessively to the left. A negative skew can indicate that learning has occured in the class population. (a good thing!) </li>";
	} 	
}
elsif ($skew < -0.5) {
	print REPORT  "<li>This score distribution was <span class=style_worse>moderately skewed</span> to the left (skew = ";
	printf REPORT "%4.2f", $skew;
	print REPORT "). The Z-score for this skew was ";
	printf REPORT "%4.2f", $Z_skew;
	if ($Z_skew > 1.96 || $Z_skew < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> negative skew (<i>p</i> \< 0.05) - higher scores predominate with exam scores tailing off excessively to the left. A negative skew can indicate that learning has occured in the class population. (a good thing!) </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span> - higher scores predominate with exam scores tailing off excessively to the left. A negative skew can indicate that learning has occured in the class population. (a good thing!) </li>";
	} 	
}
elsif ($skew < 0.5) {
	print REPORT  "<li>This score distribution <span class=style_same>did not exhibit very much skew</span> (skew = ";
	printf REPORT "%4.2f", $skew;
	print REPORT "). The Z-score for this skew was ";
	printf REPORT "%4.2f", $Z_skew;
	if ($Z_skew > 1.96 || $Z_skew < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> negative skew (<i>p</i> \< 0.05).  </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span>. Given the small magnitude of the skew value, this is not surprising. </li>";
	} 	
}
elsif ($skew < 1.0) {
	print REPORT  "<li>This score distribution was <span class=style_worse>moderately skewed</span> to the right (skew = ";
	printf REPORT "%4.2f", $skew;
	print REPORT "). The Z-score for this skew was ";
	printf REPORT "%4.2f", $Z_skew;
	if ($Z_skew > 1.96 || $Z_skew < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> negative skew (<i>p</i> \< 0.05) - lower scores predominate with exam scores tailing off excessively to the right. A positive skew can indicate that much of the class is not performing very well. (not such a good thing!) </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span> - lower scores predominate with exam scores tailing off excessively to the right. A positive skew can indicate that much of the class is not performing very well. (not such a good thing!) </li>";
	} 	
}
else {
	print REPORT  "<li>This score distribution was <span class=style_worse>profoundly skewed</span> to the right (skew = ";
	printf REPORT "%4.2f", $skew;
	print REPORT "). The Z-score for this skew was ";
	printf REPORT "%4.2f", $Z_skew;
	if ($Z_skew > 1.96 || $Z_skew < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> negative skew (<i>p</i> \< 0.05) - lower scores predominate with exam scores tailing off excessively to the right. A positive skew can indicate that much of the class is not performing very well. (not such a good thing!) </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span>; this is somewhat surprising given the magnitude of the skew - lower scores predominate with exam scores tailing off excessively to the right. A positive skew can indicate that much of the class is not performing very well. (not such a good thing!) </li>";
	} 	
}


# kurtosis report
if ($kurtosis < -1.0) {
	print REPORT  "<li>This score distribution was <span class=style_worse>profoundedly platykurtotic</span> - the curve had a low, broad peak with enhanced values at the shoulders (kurtosis = ";
	printf REPORT "%4.2f", $kurtosis;
	print REPORT "). The Z-score for this kurtosis was ";
	printf REPORT "%4.2f", $Z_kurtosis;
	if ($Z_kurtosis > 1.96 || $Z_kurtosis < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> platykurtosis (<i>p</i> \< 0.05) - Most of the class seemed to score near the middle values with fewer than expected scoring higher or lower than the group. </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span>; this is somewhat surprising given the magnitude of the kurtosis - Most of the class seemed to score near the middle values with fewer than expected scoring higher or lower than the group. </li>";
	} 	
}
elsif ($kurtosis < -0.5) {
	print REPORT  "<li>This score distribution was <span class=style_worse>moderately platykurtotic</span> - the curve had a low, broad peak with enhanced values at the shoulders (kurtosis = ";
	printf REPORT "%4.2f", $kurtosis;
	print REPORT "). The Z-score for this kurtosis was ";
	printf REPORT "%4.2f", $Z_kurtosis;
	if ($Z_kurtosis > 1.96 || $Z_kurtosis < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> platykurtosis (<i>p</i> \< 0.05) - Most of the class seemed to score near the middle values with fewer than expected scoring higher or lower than the group. </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span> - there is no reason to suspect anything other than a normal peakedness for this distribution.  </li>";
	} 	
}
elsif ($kurtosis < 0.5) {
	print REPORT  "<li>This score distribution <span class=style_same>did not exhibit very much kurtosis</span> (kurtosis = ";
	printf REPORT "%4.2f", $kurtosis;
	print REPORT "). The Z-score for this kurtosis was ";
	printf REPORT "%4.2f", $Z_kurtosis;
	if ($Z_kurtosis > 1.96 || $Z_kurtosis < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> difference in peakedness from a normal distribution. This is somewhat surprising, given the small kurtosis value. (<i>p</i> \< 0.05).  </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span>. Given the small magnitude of the kurtosis value, this is not surprising. </li>";
	} 	
}
elsif ($kurtosis < 1.0) {
	print REPORT  "<li>This score distribution was <span class=style_worse>moderately leptokurtotic</span>; the peak is higher than expected and the tails are heavy - more extreme scores than expected (kurtosis = ";
	printf REPORT "%4.2f", $kurtosis;
	print REPORT "). The Z-score for this kurtosis was ";
	printf REPORT "%4.2f", $Z_kurtosis;
	if ($Z_kurtosis > 1.96 || $Z_kurtosis < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> leptokurtosis (<i>p</i> \< 0.05) - The number of values at the shoulders of this peak are lower than expected. The number of extremely high and low scores may be proportionally higher than expected. </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span> - Although the distributions is somewhat \"peaky\", there is no good reason to suppose that this does not represent a normal distribution. </li>";
	} 	
}
else {
	print REPORT  "<li>This score distribution was <span class=style_worse>profoundly leptokurtotic</span> (kurtosis = ";
	printf REPORT "%4.2f", $kurtosis;
	print REPORT "). The Z-score for this kurtosis was ";
	printf REPORT "%4.2f", $Z_kurtosis;
	if ($Z_kurtosis > 1.96 || $Z_kurtosis < -1.96) {
		print REPORT ", which indicates a <span class=style_worse>statistically significant</span> leptokurtosis (<i>p</i> \< 0.05) - The number of values at the shoulders of this peak are lower than expected. The number of extremely high and low scores may be proportionally higher than expected. </li>";
	}
	else {
		print REPORT ", which is <span class=style_same>not statistically significant</span> - Although the distributions is somewhat \"peaky\", there is no good reason to suppose that this does not represent a normal distribution. </li>";
	} 	
}
# DP K2 REPORT
print REPORT "<li>The Z-values for the skew and kurtosis values from above were used to perform the D'Agostino-Pearson omnibus test. ";
if ($DP > $crit_chi2[1]) {
	print REPORT"The graph of these scores appears to <span class=style_worse>significantly deviate</span> from the expected normal distribution (<i>K</i><sup>2</sup> = ";
	printf REPORT "%4.2f", $DP;
	if ($DP > $crit_chi2[4]) {
		print REPORT ", <i>p</i> \< 0.005). ";
	}
	elsif ($DP > $crit_chi2[3]) {
		print REPORT ", <i>p</i> \< 0.01).";
	}
	elsif ($DP > $crit_chi2[2]) {
		print REPORT ", <i>p</i> \< 0.025).";
	}
	else {
		 print REPORT ", <i>p</i> \< 0.05). ";
	}
	print REPORT "Since the data may not follow a Gaussian distribution, you should interpret the rest of the statistical inferences in this report with a bit of caution. However, since our sample size is large (n = $numstudents), the central tendency of the data will most likely keep us from straying too far afield. In addition, the parametric tests used in this report are fairly robust with larger datasets, and the conclusions drawn from them are rather conservative. </li>";
}
else {
	print REPORT"The graph of these scores <span class=style_same>does not appear to significantly deviate</span> from the expected normal distribution (<i>K</i><sup>2</sup> = ";
	printf REPORT "%4.2f", $DP;
	print REPORT ", <i>p</i> \> 0.05). Since the data seems to follow a Gaussian distrubution, we are free to continue to analyze these results with a variety of parametric tests.</li>";
}

print REPORT "<li>The exam reliability, as measured by the Kuder-Richardson measure of internal consistency, was ";
if ($KR20 > 0.8) {
	print REPORT "<span class=style_better>very good (KR-20 = ";
	printf REPORT "%4.3f", $KR20;
	print REPORT ")</span>. This is a terrific score for a classroom exam. The KR-20 score can be improved by increasing the class size, the length of the exam, or the consistency of the exam items.</li>";
}
elsif ($KR20 > 0.7) {
	print REPORT "<span class=style_same>adequate (KR-20 = ";
	printf REPORT "%4.3f", $KR20;
	print REPORT ")</span>. This is an acceptable score for a classroom exam. The KR-20 score can be improved by increasing the class size, the length of the exam, or the consistency of the exam items.</li>";
}
else {
	print REPORT "<span class=style_worse>poor (KR-20 = ";
	printf REPORT "%4.3f", $KR20;
	print REPORT ")</span>. This is not a very good score. The results of this exam may not represent the true ability of the students very well. The KR-20 score can be improved by increasing the class size, the length of the exam, or the consistency of the exam items.</li>";
}

printf REPORT "<li>The standard error of measurement for this exam was %4.1f\%, or %4.1f points. ", $seMeasure_percent, $seMeasure;	
print REPORT "This value indicates the degree of uncertainty associated with each observed test score due to the sampling error associated with the test instrument. Lower error values indicate that the observed scores are highly correlated with the students' true latent abilities. Higher error scores indicate a poorer correlation between the observed and true score.</li>\n</ul>";

printf REPORT "<p>Overall, %3d out of %3d students (%4.1f\%) scored at or above the criterion of success defined for this assessment. ", $met, $numstudents, $met/$numstudents*100;
printf REPORT "The 95 percent confidence interval for the class average was %4.1f\% &plusmn; %4.1f\% (%4.1f points &plusmn; %4.1f points). ", $average_percent, $sterr_percent, $average_score, $sterr_score;

$t = ($average_percent-$report{'criterion'})/$sterr_percent;
$d = ($average_percent-$report{'criterion'})/$stdev_percent; 

if ($t > $crit_050[$freedom]) {
	print REPORT "This is <span class=style_better>significantly better</span> than the criterion of success - ";
	if ($t > $crit_001[$freedom]) {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.001). ", $freedomval, $t;
	}
	elsif ($t > $crit_005[$freedom]) {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.005). ", $freedomval, $t;
	}
	elsif ($t > $crit_010[$freedom]) {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.01). ", $freedomval, $t;
	}
	elsif ($t > $crit_025[$freedom]) {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.025). ", $freedomval, $t;
	}
	else {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.05). ", $freedomval, $t;
	}
}
elsif (abs($t) > $crit_050[$freedom]) {
	print REPORT "This is <span class=style_worse>significantly worse</span> than the criterion of success ";
	if (abs($t) > $crit_001[$freedom]) {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.001). ", $freedomval, $t;
	}
	elsif (abs($t) > $crit_005[$freedom]) {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.005). ", $freedomval, $t;
	}
	elsif (abs($t) > $crit_010[$freedom]) {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.01). ", $freedomval, $t;
	}
	elsif (abs($t) > $crit_025[$freedom]) {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.025). ", $freedomval, $t;
	}
	else {
		printf REPORT "<i>t</i> (%3d) = %4.1f, <i>p</i> &lt; 0.05). ", $freedomval, $t;
	}
}
else {
	printf REPORT "This is <span class=style_same>not significantly different</span> from the criterion of success defined for the exam - <i>t</i> (%3d) = %4.1f, <i>p</i> &gt; 0.05). ", $freedomval, $t;

}	
	
print REPORT "The magnitude of the effect size for this score ";
if ($d > 1.1) {
	printf REPORT "was <span class=style_better>very large (Cohen's <i>d</i> = %3.2f)</span>. <i>Therefore, we can conclude that the class as a whole performed extremely well on this exam - the class scores were obviously better than the criterion of success. </i></p>", $d;
}
elsif ($d > 0.8) {
	printf REPORT "was <span class=style_better>large (Cohen's <i>d</i> = %3.2f)</span>. <i>Therefore, we can conclude that the class as a whole performed very well on this exam - the class performance was substantially better than the criterion of success. </i></p>", $d;
}
elsif ($d > 0.5) {
	printf REPORT "was <span class=style_better>medium (Cohen's <i>d</i> = %3.2f)</span>. <i>Therefore, we can conclude that the class as a whole performed well on this exam - measurably better than the criterion of success. </i></p>", $d;
}
elsif ($d > 0.2) {
	printf REPORT "was <span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. <i>The class performance measurably exceeded the criterion of success. </i></p>", $d;
}
elsif ($d > -0.2) {
	printf REPORT "was <span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. <i>The class average is essentially indistingishable from the criterion of success; the class performance could be considered to be adequate. </i></p>", $d;
}
elsif ($d > -0.5) {
	printf REPORT "was <span class=style_worse>small (Cohen's <i>d</i> = %3.2f)</span>. <i>Therefore, we can conclude that the class as a whole performed measurably worse than the criterion of success. This suggests that many in the class have not yet mastered this material and some review of this material may be called for. </i></p>", $d;
}
elsif ($d > -0.8) {
	printf REPORT "was <span class=style_worse>medium (Cohen's <i>d</i> = %3.2f)</span>. <i>Therefore, we can conclude that the class as a whole performed very poorly on this exam - both significantly and meaningfully lower than the criterion of success. Some review of these materials is warranted in class. </i></p>", $d;
}
elsif ($d > -1.1) {
	printf REPORT "was <span class=style_worse>large (Cohen's <i>d</i> = %3.2f)</span>. <i>Therefore, we can conclude that the class as a whole performed very poorly on this exam - both significantly and meaningfully worse than the criterion of success. In-class review of these materials is strongly recommended. </i></p>", $d;
}
else {
	printf REPORT "was <span class=style_worse>very large (Cohen's <i>d</i> = %3.2f)</span>. <i>Therefore, we can conclude that the class as a whole performed extremely poorly on this exam - both significantly and meaningfully worse than the criterion of success. In-class review of these materials is strongly recommended. A follow-up assessment might also be used to track the improvement in student scores. </i></p>", $d;
}


print REPORT "<p><a href=\"reports/$report{'statfile'}\" title=\"Open the tab-delimited datafile\" border=\"0\"><img src=\"graphics/icon.png\" align=\"bottom\" hspace = \"10\">$report{'statfile'}</a></p><p>To facilitate additional statistical analysis of the results for this assignment, a simple tab-delimited file has been generated and may be accessed here. The scores for each exam item, exam subscores, and overall grades for each student are included. This file should be compatible with any statistics package that you might wish to use (i.e. Minitab, Microsoft Excel, SPSS, or even R).</p>";

print REPORT <<EOS; 
<hr size="1">
<h2><a name="B" id="B"></a>B) Listing of student scores <a href="#top" class="myButton">back to top</a></h2>
<p>A complete listing of all student scores for this assessment are listed below in alphabetical order. In classical test theory, the earned score for an assignment relects both the students' true, or latent, ability and and error component due to sampling. This is formated as: X(observed) = T(true) - E(error). The true scores for students (the thing that we really want to know) can never be directly measured. What we have instead is a single estimate of their ability in the observed score. True score values can be estimated by correcting for the error of measurment for the exam. A 90% confidence interval for the true score of each student has also been calculated and is plotted as a gray rectangle below - if we were able to repeatedly give this test (or one exactly like it) to the students, their true score would fall within the gray box range nine times out of ten. The true score estimates are shown as vertical lines within each rectangle; the observed scores are plotted as filled blue circles. </p>
<p>Individualized reports have been created for each member of the class. You may elect to have these HTML documents emailed automatically to each student as an attachment if you enable the corresponding option in the configuration file. Clicking on the students' last name will link you to the formative feedback report for that student.</p>
<table cellpadding="0" cellspacing="0" border="0" bordercolor="#000000">
  <tr>
    <td width="110" height="25" bgcolor="#333333"><div class="listing_head" align="center">Last Name</div></td>
    <td width="110" height="25" bgcolor="#333333"><div class="listing_head" align="center">First Name</div></td>
    <td width="60" height="25" bgcolor="#333333"><div class="listing_head" align="center">Score (Points)</div></td>
    <td width="60" height="25" bgcolor="#333333"><div class="listing_head" align="center">Score (%)</div></td>
    <td width="60" height="25" bgcolor="#333333"><div class="listing_head" align="center">True (Points)</div></td>
    <td width="60" height="25" bgcolor="#333333"><div class="listing_head" align="center">True (%)</div></td>
    <td width="600" height="25" bgcolor="#333333"><div class="listing_head" align="center">Estimated True Score Range (&plusmn; 90% confidence interval)</div></td>
  </tr>
EOS
	
	for ($loop=0; $loop<$numstudents; $loop++) {
		if ($loop%2) {
			$color="#CCCCCC";
		}
		else {
			$color="#FFFFFF";
		}
		print REPORT "<tr><td width=\"110\" height=\"25\" bgcolor=\"$color\"><div class=\"listing\" align=\"center\"><a href=\"reports/$choices[$loop][2].html\" title=\"Go to student report\">\n";
		print REPORT $choices[$loop][0];
		print REPORT "</a></div></td><td width=\"110\" height=\"25\" bgcolor=\"$color\"><div class=\"listing\" align=\"center\">\n";
      	print REPORT $choices[$loop][1];
      	print REPORT "</div></td><td width=\"60\" height=\"25\" bgcolor=\"$color\"><div class=\"listing\" align=\"center\">\n";
      	print REPORT $score[$loop];
      	print REPORT "</div></td><td width=\"60\" height=\"25\" bgcolor=\"$color\"><div class=\"listing\" align=\"center\">\n";
      	print REPORT int($score[$loop]/$maxpoints*1000+0.5)/10;
    	print REPORT "</div></td><td width=\"60\" height=\"25\" bgcolor=\"$color\"><div class=\"listing\" align=\"center\">\n";
      	printf REPORT "%4.1f", ($average_score + ($score[$loop]-$average_score)*$KR20);
    	print REPORT "</div></td><td width=\"60\" height=\"25\" bgcolor=\"$color\"><div class=\"listing\" align=\"center\">\n";
      	printf REPORT "%4.1f", ($average_score + ($score[$loop]-$average_score)*$KR20)/$maxpoints*100;
      	print REPORT "</div></td><td width=\"600\" height=\"25\"><div class=\"listing\"><img src=\"graphics/Student$loop.png\">";
      	print REPORT "</div></td></tr>\n";
    }
      	
	print REPORT "<tr><td colspan=\"6\" align=\"center\" valign=\"middle\"><div class=\"listing\"><b><font size=2>True and observed scores as percentages &rArr; </font></b></div></td><td><img src=\"graphics/Student_labels.png\"></td></tr>";
	print REPORT "</table></center>\n";
	print REPORT "<br />\n";
	print REPORT "<hr width=100%>\n";

$alpha_outcome = 1-(1-$crit_val_obj)**$numobjs;
	print REPORT <<EOF;
<h2><a name="C" id="C"></a>C) Outcome assessment <a href="#top" class="myButton">back to top</a></h2>
<p><img src="graphics/learningOutcomes.png" usemap="#outcomesMap" align="right" border="0">$outcomesMap Many or most of the questions in this exam have been mapped onto specific learning outcomes for the course. The class performance on each of these outcomes is plotted to the right, with the criterion of success ($report{'criterion'}%) indicated as a horizontal dashed line. The average values of each outcome were compared against the criterion of success using a series of two-tailed, one-sample t-tests. The Dunn-Sidak correction for multiple comparisons was used to limit the likelihood of type I errors. Each individual t-test was performed with a smaller &alpha; (<i>p</i> = $crit_val_obj) in order to keep the family-wise &alpha; low (<i>p</i> = 
EOF
printf REPORT "%4.3f",$alpha_outcome;
print REPORT <<EOF;
). The sheer size of the sample size keeps the probability of a type II error reasonable under these conditions.</p>
<p><span class=style_better>Blue</span> columns denote content areas with performance that was statistically better than the criterion of success.<br />
<span class=style_worse>Red</span> columns indicate content areas with performance that was statistically worse than the criterion of success.<br />
<span class=style_same>Gray</span> columns show the content areas with performances that were deemed to be not statistically different from the criterion of success.</p>
<p>The overall class results on the materials from each content area are summarized below. You may quickly navigate to a particular section by clicking on the desired column in the graph.</p>

EOF

print REPORT "<ol>";
for ($topic=1; $topic<=6; $topic++) {
	if ($outcomes[$topic]) {
		if ($objective_sig[$topic] eq 1) {
			$stylecolor = "<span class=\"style_better\">";
		}
		elsif ($objective_sig[$topic] eq -1) {
			$stylecolor = "<span class=\"style_worse\">";
		}	
		else {
			$stylecolor = "<span class=\"style_same\">";
		}	
		$fraction = $meto[$topic]/$numstudents*100;
		print REPORT "<li><p class=\"topspace\"><a name = \"Outcome$topic\"></a><b>$outcomes[$topic]</b> - <i>$outdefs[$topic]</i></p>";
		if ($objective_max[$topic] != 0) {
			print REPORT "<blockquote>This learning outcome was assessed by items worth a total of $objective_max[$topic] points (";
			printf REPORT "%4.1f",$objective_max[$topic]/$maxpoints*100;
			print REPORT "% of the total exam). The class scored ";
			printf REPORT "%4.1f ± %4.1f of these points (average ± 95",$objective_ave_points[$topic],$objective_conf_points[$topic];
			print REPORT "% confidence interval). That gives a subscore for this learning outcome of $stylecolor";	
			printf REPORT "%4.1f",$objective_averages[$topic];	
			print REPORT "\% &plusmn; ";	
			printf REPORT "%4.1f",$objective_conf[$topic];	
			print REPORT "\%</span>. A total of $meto[$topic] of the students (";
			printf REPORT "%4.1f", $fraction;
			print REPORT "\% of the class) met or exceeded the criterion of success defined for this section. The class average for this material was ";
			
			if ($objective_sig[$topic] == 1) {
				printf REPORT "$stylecolor significantly better</span> than the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &lt; %4.3f. The magnitude of the effect size for this score was ", $df, $objective_t[$topic], $alpha_outcome;
				if ($objective_d[$topic] > 1.1) {
					printf REPORT "<span class=style_better>very large (Cohen's <i>d</i> = %3.2f)</span>. The class obviously scored much better than the criterion of success on this learning outcome. ", $objective_d[$topic];
				}
				elsif ($objective_d[$topic] > 0.8) {
					printf REPORT "<span class=style_better>large (Cohen's <i>d</i> = %3.2f)</span>. The class scores were substantially better than the criterion of success for this learning outcome. ", $objective_d[$topic];
				}
				elsif ($objective_d[$topic] > 0.5) {
					printf REPORT "<span class=style_better>medium (Cohen's <i>d</i> = %3.2f)</span>. The class performed meaningfully better than the criterion of success for this learning outcome. ", $objective_d[$topic];
				}
				elsif ($objective_d[$topic] > 0.2) {
					printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>.  The class scored measurably better than the criterion of success on this learning outcome. ", $objective_d[$topic];
				}
				else {
					printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. Although the class scored better than the criterion of success on this outcome, the difference between the two scores is not very large. ", $objective_d[$topic];
				}
				print REPORT "The stated goal for this learning outcome <span class=style_better>has been exceeded</span> by the class.</blockquote>\n";
				if ($fraction >= 75) {
					print REPORT "<p class=\"topspace\"><i>The vast majority of the class performed well on the material mapped to this learning outcome; the class appears to have mastered this material.</i></p></li>";
				}
				elsif ($fraction >= 60) {
					print REPORT "<p class=\"topspace\"><i>Most of the class performed well on this learning outcome. However, a sizable number of students had difficulty with this material. The class as a whole appears to have a good grasp of this material.</i></p></li>";		
				}
				elsif ($fraction >= 50) {
					print REPORT "<p class=\"topspace\"><i>Over half of the class exceeded the criterion of success for this learning outcome. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. </i></p></li>";
				}
				elsif ($fraction >= 40) {
					print REPORT "<p class=\"topspace\"><i>Less than half of the class met the performance standard for this learning outcome. A large number of students are apparently struggling with facts, concepts, and procedures covered in these materials. The class does not yet exhibit an adequate mastery of this learning outcome.</i></p></li>";
				}
				elsif ($fraction >= 25) {
					print REPORT "<p class=\"topspace\"><p class=\"topspace\"><i>Very few members of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this learning outcome. The class does not yet exhibit an adequate mastery of this learning outcome.</i></p></li>";
				}
				else {
					print REPORT "<p class=\"topspace\"><i>Nearly noone met the performance standard for this learning outcome. Most students are apparently struggling with facts, concepts, and procedures covered in this section. This learning outcome is not even close to being adequately met by the class.</i></li>";
				}
			}
			elsif ($objective_sig[$topic] == -1) {
				printf REPORT "$stylecolor significantly worse</span> than the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &lt; %4.3f. The magnitude of the effect size for this score was ", $df, $objective_t[$topic], $alpha_outcome;
				if ($objective_d[$topic] > -0.2) {
					printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. Even though the results are statistically worse than the criterion of success, the the two values are, for all practical purposes, indistingishable from each other. ", $objective_d[$topic];
				}
				elsif ($objective_d[$topic] > -0.5) {
					printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. The scores were measurably lower than the criterion of success for this learning outcome. ", $objective_d[$topic];
				}
				elsif ($objective_d[$topic] > -0.8) {
					printf REPORT "<span class=style_worse>medium (Cohen's <i>d</i> = %3.2f)</span>. The scores were meaningfully lower than the criterion of success for this learning outcome. ", $objective_d[$topic];
				}
				elsif ($objective_d[$topic] > -1.1) {
					printf REPORT "<span class=style_worse>large (Cohen's <i>d</i> = %3.2f)</span>. The scores were substantially lower than the criterion of success for this learning outcome. ", $objective_d[$topic];
				}
				else {
					printf REPORT "<span class=style_worse>very large (Cohen's <i>d</i> = %3.2f)</span>. The scores were obviously lower than the criterion of success for this learning objective. ", $objective_d[$topic];
				}
				print REPORT "The stated goal for this learning outcome <span class=style_worse>has not yet been met</span> by the class.</blockquote>\n";
				if ($fraction >= 75) {
					print REPORT "<p class=\"topspace\"><i>The vast majority of the class performed well on the material mapped to this learning outcome; the class appears to have mastered this material.</i></p></li>";
				}
				elsif ($fraction >= 60) {
					print REPORT "<p class=\"topspace\"><i>Most of the class performed well on this learning outcome. However, a sizable number of students had difficulty with this material. The class as a whole appears to have a good grasp of this material.</i></p></li>";		
				}
				elsif ($fraction >= 50) {
					print REPORT "<p class=\"topspace\"><i>Over half of the class exceeded the criterion of success for this learning outcome. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. </i></p></li>";
				}
				elsif ($fraction >= 40) {
					print REPORT "<p class=\"topspace\"><i>Less than half of the class met the performance standard for this learning outcome. A large number of students are apparently struggling with facts, concepts, and procedures covered in these materials. The class does not yet exhibit an adequate mastery of this learning outcome.</i></p></li>";
				}
				elsif ($fraction >= 25) {
					print REPORT "<p class=\"topspace\"><p class=\"topspace\"><i>Very few members of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this learning outcome. The class does not yet exhibit an adequate mastery of this learning outcome.</i></p></li>";
				}
				else {
					print REPORT "<p class=\"topspace\"><i>Nearly noone met the performance standard for this learning outcome. Most students are apparently struggling with facts, concepts, and procedures covered in this section. This learning outcome is not even close to being adequately met by the class.</i></li>";
				}
			}	
			else {
				printf REPORT "$stylecolor not significantly different</span> from the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &gt; %4.3f. The magnitude of the effect size for this score was ", $df, $objective_t[$topic], $alpha_outcome;
				if ($objective_d[$topic] > 0.2) {
					printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. Although the scores exeed the criterion of success, the difference is not very impressive. ", $objective_d[$topic];
				}
				elsif ($objective_d[$topic] > -0.2) {
					printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. The class average is essentially indistingishable from the criterion of success. The class performance was adequate. ", $objective_d[$topic];
				}
				else {
					printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. Therefore, we can conclude that the class as a whole performed measurable worse than the criterion of success. ", $objective_d[$topic];
				}
				print REPORT "We are unable to discount the null hypothesis - that the course performance equals the criterion of success. Therefore, we retain the belief that the stated goal for this learning outcome <span class=style_same>has been met</span> by the class.</blockquote>\n";
				if ($fraction >= 75) {
					print REPORT "<p class=\"topspace\"><i>The vast majority of the class performed well on the material mapped to this learning outcome; the class appears to have mastered this material.</i></p></li>";
				}
				elsif ($fraction >= 60) {
					print REPORT "<p class=\"topspace\"><i>Most of the class performed well on this learning outcome. However, a sizable number of students had difficulty with this material. The class as a whole appears to have a good grasp of this material.</i></p></li>";		
				}
				elsif ($fraction >= 50) {
					print REPORT "<p class=\"topspace\"><i>Over half of the class exceeded the criterion of success for this learning outcome. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. </i></p></li>";
				}
				elsif ($fraction >= 40) {
					print REPORT "<p class=\"topspace\"><i>Less than half of the class met the performance standard for this learning outcome. A large number of students are apparently struggling with facts, concepts, and procedures covered in these materials. The class does not yet exhibit an adequate mastery of this learning outcome.</i></p></li>";
				}
				elsif ($fraction >= 25) {
					print REPORT "<p class=\"topspace\"><p class=\"topspace\"><i>Very few members of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this learning outcome. The class does not yet exhibit an adequate mastery of this learning outcome.</i></p></li>";
				}
				else {
					print REPORT "<p class=\"topspace\"><i>Nearly noone met the performance standard for this learning outcome. Most students are apparently struggling with facts, concepts, and procedures covered in this section. This learning outcome is not even close to being adequately met by the class.</i></li>";
				}
			}
		}
		
		else {
			print REPORT "<blockquote>This learning outcome was not assessed by any items in this exam.</blockquote></li>\n";
		}
	}
}	

print REPORT "</ol>";








	print REPORT <<EOF;
<hr width=100%><h2><a name="D" id="D"></a>D) Exam specifications <a href="#top" class="myButton">back to top</a></h2>
<p>Every exam can be view as a composite of several parts (be they the content areas that were covered, different levels of critical thinking, or even just a collection of individual items - the questions themselves). In order to assure exam validity - the assignment actually tests the students on the materials that were covered - an exam blueprint has been generated here. This table is a record of the point distribution in this particular assessment with regard to content areas and types of thinking skills required. You will have to decide for yourself is the balance of coverage in the exam matches that of the class presentations. The class' performance on these different dimensions (content and cognitive level) will be analyzed later in this report.</p><p>Clicking on one of the column or row headings in this table will link you to the corresponding analysis within this report.</p>
<p><img src="graphics/blueprint.png" usemap="#blueprintMap" align="center" border="0">\n$blueprintMap</p>
<hr size="1">
EOF

$alpha_content = 1-(1-$crit_val_cat)**$numcats;

print REPORT <<EOF;
<h2><a name="E" id="E"></a>E) Performance by content area <a href="#top" class="myButton">back to top</a></h2>
<p><img src="graphics/contentAreas.png" usemap="#contentMap" align="right" border="0">$contentMap This exam evaluated the class' comprehension of materials drawn from $numcats content areas. The class performance is plotted to the right, with the criterion of success ($report{'criterion'}%) indicated as a horizontal dashed line. The average values of each content area were compared against the criterion of success using a series of two-tailed, one-sample t-tests. The Dunn-Sidak correction for multiple comparisons was used to limit the likelihood of type I errors. Each individual t-test was performed with a smaller &alpha; (<i>p</i> = $crit_val_cat) in order to keep the family-wise &alpha; low (<i>p</i> = 
EOF
printf REPORT "%4.3f",$alpha_content;
print REPORT <<EOF;
). The sheer size of the sample size keeps the probability of a type II error reasonable under these conditions.</p>
<p><span class=style_better>Blue</span> columns denote content areas with performance that was statistically better than the criterion of success.<br />
<span class=style_worse>Red</span> columns indicate content areas with performance that was statistically worse than the criterion of success.<br />
<span class=style_same>Gray</span> columns show the content areas with performances that were deemed to be not statistically different from the criterion of success.</p>
<p>The overall class results on the materials from each content area are summarized below. You may quickly navigate to a particular section by clicking on the desired column in the graph.</p>
EOF

print REPORT "<ol>";
for ($topic=1; $topic<=$numcats; $topic++) {
	if ($content_sig[$topic-1] eq 1) {
		$stylecolor = "<span class=\"style_better\">";
	}
	elsif ($content_sig[$topic-1] eq -1) {
		$stylecolor = "<span class=\"style_worse\">";
	}	
	else {
		$stylecolor = "<span class=\"style_same\">";
	}
	$fraction = $metc[$topic-1]/$numstudents*100;
	print REPORT "<li><a name = \"Area$topic\"></a><b>$areas[$topic-1]</b> - <i>$descriptions[$topic]</i>";
	
	print REPORT "<p>The following questions probed the students' comprehension of this topic. The performance of each question is indicated as a superscript (P, poor; M, marginal; G, good; E, excellent). Click on a question number to skip down to the corresponding item analysis graph. <br />";
	if ($topic == 1) {
		for ($myloop=0; $myloop<@content1q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content1q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content1q[$myloop];
			print REPORT "\">";
			print REPORT $content1q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content1q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content1q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content1q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content1q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content1q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 2) {
		for ($myloop=0; $myloop<@content2q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content2q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content2q[$myloop];
			print REPORT "\">";
			print REPORT $content2q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content2q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content2q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content2q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content2q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content2q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 3) {
		for ($myloop=0; $myloop<@content3q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content3q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content3q[$myloop];
			print REPORT "\">";
			print REPORT $content3q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content3q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content3q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content3q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content3q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content3q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 4) {
		for ($myloop=0; $myloop<@content4q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content4q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content4q[$myloop];
			print REPORT "\">";
			print REPORT $content4q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content4q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content4q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content4q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content4q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content4q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 5) {
		for ($myloop=0; $myloop<@content5q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content5q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content5q[$myloop];
			print REPORT "\">";
			print REPORT $content5q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content5q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content5q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content5q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content5q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content5q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 6) {
		for ($myloop=0; $myloop<@content6q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content6q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content6q[$myloop];
			print REPORT "\">";
			print REPORT $content6q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content6q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content6q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content6q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content6q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content6q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 7) {
		for ($myloop=0; $myloop<@content7q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content7q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content7q[$myloop];
			print REPORT "\">";
			print REPORT $content7q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content7q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content7q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content7q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content7q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content7q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 8) {
		for ($myloop=0; $myloop<@content8q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content8q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content8q[$myloop];
			print REPORT "\">";
			print REPORT $content8q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content8q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content8q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content8q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content8q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content8q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 9) {
		for ($myloop=0; $myloop<@content9q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content9q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content9q[$myloop];
			print REPORT "\">";
			print REPORT $content9q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content9q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content9q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content9q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content9q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content9q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	else {
		for ($myloop=0; $myloop<@content10q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $content10q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $content10q[$myloop];
			print REPORT "\">";
			print REPORT $content10q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$content10q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$content10q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$content10q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @content10q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @content10q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		

	print REPORT "<p>This content area was assessed by items worth a total of $specification[$topic][0] points (";
	printf REPORT "%4.1f",$specification[$topic][0]/$maxpoints*100;
	print REPORT "% of the total exam). The class scored ";
	printf REPORT "%4.1f ± %4.1f of these points (average ± 95",$content_ave_score[$topic-1],$content_conf_score[$topic-1];
	print REPORT "% confidence interval). That gives a subscore for this content area of $stylecolor";
	printf REPORT "%4.1f",$content_averages[$topic-1];	
	print REPORT "\% &plusmn; ";	
	printf REPORT "%4.1f",$content_conf[$topic-1];	
	print REPORT "\%</span>. </p>";	
			
	print REPORT "</p><p>A total of $metc[$topic-1] of the students (";
	printf REPORT "%4.1f", $fraction;
	print REPORT "\% of the class) met or exceeded the criterion of success defined for this section. The class average for this material was ";
	if ($content_sig[$topic-1] == 1) {
		printf REPORT "$stylecolor significantly better</span> than the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &lt; %4.3f. The magnitude of the effect size for this score was ", $df, $content_t[$topic-1], $alpha_content;
		if ($content_d[$topic-1] > 1.1) {
			printf REPORT "<span class=style_better>very large (Cohen's <i>d</i> = %3.2f)</span>. The class obviously scored much better than the criterion of success on these materials.<br />", $content_d[$topic-1];
		}
		elsif ($content_d[$topic-1] > 0.8) {
			printf REPORT "<span class=style_better>large (Cohen's <i>d</i> = %3.2f)</span>. The class scores were substantially better than the criterion of success on these materials. <br />", $content_d[$topic-1];
		}
		elsif ($content_d[$topic-1] > 0.5) {
			printf REPORT "<span class=style_better>medium (Cohen's <i>d</i> = %3.2f)</span>. The class performed meaningfully better than the criterion of success on these materials.<br />", $content_d[$topic-1];
		}
		elsif ($content_d[$topic-1] > 0.2) {
			printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>.  The class scored measurably better than the criterion of success on these materials.<br />", $content_d[$topic-1];
		}
		else {
			printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. Although the class scored better than the criterion of success on these materials, the difference between the two scores is not very large.<br />", $content_d[$topic-1];
		}
		if ($fraction >= 75) {
			print REPORT "<i>The vast majority of the class performed well on this content. A little reinforcement of these facts, concepts, and procedures is probably all that is required. The class appears to have mastered this material.</i></li>";
		}
		elsif ($fraction >= 60) {
			print REPORT "<i>Most of the class performed well on this content. However, a sizable number of students had difficulty with this material. A bit of review concerning the key facts, concepts, and procedures would probably help these students to improve. The class as a whole appears to have a good grasp of this material.</i></li>";		
		}
		elsif ($fraction >= 50) {
			print REPORT "<i>Over half of the class exceeded the criterion of success. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. Some effort should probably be made to improve these scores.</i></li>";
		}
		elsif ($fraction >= 40) {
			print REPORT "<i>Less than half of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
		elsif ($fraction >= 25) {
			print REPORT "<i>Only some of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
		else {
			print REPORT "<i>Very few students met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
	}
	elsif ($content_sig[$topic-1] == -1) {
		printf REPORT "$stylecolor significantly worse</span> than the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &lt; %4.3f. The magnitude of the effect size for this score was ", $df, $content_t[$topic-1], $alpha_content;
		if ($content_d[$topic-1] > -0.2) {
			printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. Even though the results are statistically worse than the criterion of success, the the two values are, for all practical purposes, indistingishable from each other. <br />", $content_d[$topic-1];
		}
		elsif ($content_d[$topic-1] > -0.5) {
			printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. The scores were measurably lower than the criterion of success for this content area. <br />", $content_d[$topic-1];
		}
		elsif ($content_d[$topic-1] > -0.8) {
			printf REPORT "<span class=style_worse>medium (Cohen's <i>d</i> = %3.2f)</span>. The scores were meaningfully lower than the criterion of success for this content area. <br />", $content_d[$topic-1];
		}
		elsif ($content_d[$topic-1] > -1.1) {
			printf REPORT "<span class=style_worse>large (Cohen's <i>d</i> = %3.2f)</span>. The scores were substantially lower than the criterion of success for this content area. <br />", $content_d[$topic-1];
		}
		else {
			printf REPORT "<span class=style_worse>very large (Cohen's <i>d</i> = %3.2f)</span>. The scores were obviously lower than the criterion of success for this content area. <br />", $content_d[$topic-1];
		}
		if ($fraction >= 75) {
			print REPORT "<i>The vast majority of the class performed well on this content. A little reinforcement of these facts, concepts, and procedures is probably all that is required. The class appears to have mastered this material.</i></li>";
		}
		elsif ($fraction >= 60) {
			print REPORT "<i>Most of the class performed well on this content. However, a sizable number of students had difficulty with this material. A bit of review concerning the key facts, concepts, and procedures would probably help these students to improve. The class as a whole appears to have a good grasp of this material.</i></li>";		
		}
		elsif ($fraction >= 50) {
			print REPORT "<i>Over half of the class exceeded the criterion of success. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. Some effort should probably be made to improve these scores.</i></li>";
		}
		elsif ($fraction >= 40) {
			print REPORT "<i>Less than half of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
		elsif ($fraction >= 25) {
			print REPORT "<i>Only some of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
		else {
			print REPORT "<i>Very few students met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
	}	
	else {
		printf REPORT "$stylecolor not significantly different</span> from the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &gt; %4.3f. The magnitude of the effect size for this score was ", $df, $content_t[$topic-1], $alpha_content;
		if ($content_d[$topic-1] > 0.2) {
			printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. Although the scores exeed the criterion of success, the difference is not very impressive. <br />", $content_d[$topic-1];
		}
		elsif ($content_d[$topic-1] > -0.2) {
			printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. The class average is essentially indistingishable from the criterion of success. The class performance was adequate. <br />", $content_d[$topic-1];
		}
		else {
			printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. Therefore, we can conclude that the class as a whole performed measurable worse than the criterion of success. This may require some remediation. <br />", $content_d[$topic-1];
		}
		if ($fraction >= 75) {
			print REPORT "<i>The vast majority of the class performed well on this content. A little reinforcement of these facts, concepts, and procedures is probably all that is required. The class appears to have mastered this material.</i></li>";
		}
		elsif ($fraction >= 60) {
			print REPORT "<i>Most of the class performed well on this content. However, a sizable number of students had difficulty with this material. A bit of review concerning the key facts, concepts, and procedures would probably help these students to improve. The class as a whole appears to have a good grasp of this material.</i></li>";		
		}
		elsif ($fraction >= 50) {
			print REPORT "<i>Over half of the class exceeded the criterion of success. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. Some effort should probably be made to improve these scores.</i></li>";
		}
		elsif ($fraction >= 40) {
			print REPORT "<i>Less than half of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
		elsif ($fraction >= 25) {
			print REPORT "<i>Only some of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
		else {
			print REPORT "<i>Very few students met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
		}
	}
}
print REPORT "</ol><hr>";

$alpha_skill = 1-(1-$crit_val_skill)**$numskills;

print REPORT <<EOF;
<h2><a name="F" id="F"></a>F) Performance by Thinking Skills <a href="#top" class="myButton">back to top</a></h2>
<p><img src="graphics/skillLevels.png" usemap="#skillMap" align="right" border="0">$skillMap This exam also evaluated the class' ability to reason different kinds of thinking skills. For the purposes of this report, each question was mapped to one of six different skill levels. The class performance is plotted to the right, with the criterion of success ($report{'criterion'}%) indicated as a horizontal dashed line. The average values of scores for each level were compared against the criterion of success using a series of two-tailed, one-sample t-tests. The Dunn-Sidak correction for multiple comparisons was used to limit the likelihood of type I errors. Each individual t-test was performed with a smaller &alpha; (<i>p</i> = $crit_val_skill) in order to keep the family-wise &alpha; low (<i>p</i> = 
EOF
printf REPORT "%4.3f",$alpha_skill;
print REPORT <<EOF;
). The sheer size of the sample size keeps the probability of a type II error reasonable under these conditions.</p>
<p><span class=style_better>Blue</span> columns denote cognitive levels with performance that was statistically better than the criterion of success.<br />
<span class=style_worse>Red</span> columns indicate cognitive levels with performance that was statistically worse than the criterion of success.<br />
<span class=style_same>Gray</span> columns show the cognitive levels with performances that were deemed to be not statistically different from the criterion of success.</p>
<p>The overall class results on the materials from each content area are summarized below. You may quickly navigate to a particular section by clicking on the desired column in the graph.</p>
EOF

print REPORT "<ol>";
for ($topic=1; $topic<=6; $topic++) {
	if ($skill_sig[$topic-1] eq 1) {
		$stylecolor = "<span class=\"style_better\">";
	}
	elsif ($skill_sig[$topic-1] eq -1) {
		$stylecolor = "<span class=\"style_worse\">";
	}	
	else {
		$stylecolor = "<span class=\"style_same\">";
	}
	$fraction = $metb[$topic-1]/$numstudents*100;
	print REPORT "<li><a name = \"skill$topic\"></a><b>$skill_labels[$topic]</b> - Students were expected to $skill_desc[$topic]";

	if ($specification[0][$topic] > 0) {

	print REPORT "<p>The following questions probed the students' ability to work using the course materials this type of thinking skill. The performance of each question is indicated as a superscript (P, poor; M, marginal; G, good; E, excellent). Click on a question number to skip down to the corresponding item analysis graph. <br />";
	if ($topic == 1) {
		for ($myloop=0; $myloop<@skill1q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $skill1q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $skill1q[$myloop];
			print REPORT "\">";
			print REPORT $skill1q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$skill1q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$skill1q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$skill1q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @skill1q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @skill1q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 2) {
		for ($myloop=0; $myloop<@skill2q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $skill2q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $skill2q[$myloop];
			print REPORT "\">";
			print REPORT $skill2q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$skill2q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$skill2q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$skill2q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @skill2q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @skill2q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 3) {
		for ($myloop=0; $myloop<@skill3q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $skill3q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $skill3q[$myloop];
			print REPORT "\">";
			print REPORT $skill3q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$skill3q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$skill3q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$skill3q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @skill3q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @skill3q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 4) {
		for ($myloop=0; $myloop<@skill4q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $skill4q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $skill4q[$myloop];
			print REPORT "\">";
			print REPORT $skill4q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$skill4q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$skill4q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$skill4q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @skill4q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @skill4q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	elsif ($topic == 5) {
		for ($myloop=0; $myloop<@skill5q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $skill5q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $skill5q[$myloop];
			print REPORT "\">";
			print REPORT $skill5q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$skill5q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$skill5q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$skill5q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @skill5q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @skill5q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		
	else {
		for ($myloop=0; $myloop<@skill6q; $myloop++) {
			print REPORT "<a href=\"#Question";
			print REPORT $skill6q[$myloop];
			print REPORT "\" title=\"Go to question number ";
			print REPORT $skill6q[$myloop];
			print REPORT "\">";
			print REPORT $skill6q[$myloop];
			print REPORT "</a><sup>";
			if ($distractor[$skill6q[$myloop]-1][0]>15) {
				print REPORT "<b>E</b></sup>";
			}
			elsif ($distractor[$skill6q[$myloop]-1][0]>10) {
				print REPORT "<b>G</b></sup>";
			}
			elsif ($distractor[$skill6q[$myloop]-1][0]>5) {
				print REPORT "<b>M</b></sup>";
			}
			else {
				print REPORT "<b>P</b></sup>";
			}
			if ($myloop == @skill6q-1) {
				print REPORT ". ";
			}
			elsif ($myloop == @skill6q-2) {
				print REPORT ", and ";
			}	
			else {
				print REPORT ", ";
			}			
		}	
	}		

		print REPORT "<p>This content area was assessed by items worth a total of $specification[0][$topic] points (";
		printf REPORT "%4.1f",$specification[0][$topic]/$maxpoints*100;
		print REPORT "% of the total exam). The class scored ";
		printf REPORT "%4.1f ± %4.1f of these points (average ± 95",$skill_ave_score[$topic-1],$skill_conf_score[$topic-1];
		print REPORT "% confidence interval). That gives a subscore for this content area of $stylecolor";
		printf REPORT "%4.1f",$skill_averages[$topic-1];	
		print REPORT "\% &plusmn; ";		
		printf REPORT "%4.1f",$skill_conf[$topic-1];	
		print REPORT "\%</span>. </p>";		
		print REPORT "<p>A total of $metb[$topic-1] of the students (";
		printf REPORT "%4.1f", $fraction;
		print REPORT "\% of the class) met or exceeded the criterion of success defined for this section. The class average for this material was ";
		if ($skill_sig[$topic-1] == 1) {
			printf REPORT "$stylecolor significantly better</span> than the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &lt; %4.3f. The magnitude of the effect size for this score was ", $df, $skill_t[$topic-1], $alpha_skill;
			if ($skill_d[$topic-1] > 1.1) {
				printf REPORT "<span class=style_better>very large (Cohen's <i>d</i> = %3.2f)</span>. The class obviously scored much better than the criterion of success on these materials.<br />", $skill_d[$topic-1];
			}
			elsif ($skill_d[$topic-1] > 0.8) {
				printf REPORT "<span class=style_better>large (Cohen's <i>d</i> = %3.2f)</span>. The class scores were substantially better than the criterion of success on these materials. <br />", $skill_d[$topic-1];
			}
			elsif ($skill_d[$topic-1] > 0.5) {
				printf REPORT "<span class=style_better>medium (Cohen's <i>d</i> = %3.2f)</span>. The class performed meaningfully better than the criterion of success on these materials.<br />", $skill_d[$topic-1];
			}
			elsif ($skill_d[$topic-1] > 0.2) {
				printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>.  The class scored measurably better than the criterion of success on these materials.<br />", $skill_d[$topic-1];
			}
			else {
				printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. Although the class scored better than the criterion of success on these materials, the difference between the two scores is not very large.<br />", $skill_d[$topic-1];
			}
			if ($fraction >= 75) {
				print REPORT "<i>The vast majority of the class performed well on this content. A little reinforcement of these facts, concepts, and procedures is probably all that is required. The class appears to have mastered this material.</i></li>";
			}
			elsif ($fraction >= 60) {
				print REPORT "<i>Most of the class performed well on this content. However, a sizable number of students had difficulty with this material. A bit of review concerning the key facts, concepts, and procedures would probably help these students to improve. The class as a whole appears to have a good grasp of this material.</i></li>";		
			}
			elsif ($fraction >= 50) {
				print REPORT "<i>Over half of the class exceeded the criterion of success. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. Some effort should probably be made to improve these scores.</i></li>";
			}
			elsif ($fraction >= 40) {
				print REPORT "<i>Less than half of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
			elsif ($fraction >= 25) {
				print REPORT "<i>Only some of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
			else {
				print REPORT "<i>Very few students met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
		}
		elsif ($skill_sig[$topic-1] == -1) {
			printf REPORT "$stylecolor significantly worse</span> than the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &lt; %4.3f. The magnitude of the effect size for this score was ", $df, $skill_t[$topic-1], $alpha_skill;
			if ($skill_d[$topic-1] > -0.2) {
				printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. Even though the results are statistically worse than the criterion of success, the the two values are, for all practical purposes, indistingishable from each other. <br />", $skill_d[$topic-1];
			}
			elsif ($skill_d[$topic-1] > -0.5) {
				printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. The scores were measurably lower than the criterion of success for this content area. <br />", $skill_d[$topic-1];
			}
			elsif ($skill_d[$topic-1] > -0.8) {
				printf REPORT "<span class=style_worse>medium (Cohen's <i>d</i> = %3.2f)</span>. The scores were meaningfully lower than the criterion of success for this content area. <br />", $skill_d[$topic-1];
			}
			elsif ($skill_d[$topic-1] > -1.1) {
				printf REPORT "<span class=style_worse>large (Cohen's <i>d</i> = %3.2f)</span>. The scores were substantially lower than the criterion of success for this content area. <br />", $skill_d[$topic-1];
			}
			else {
				printf REPORT "<span class=style_worse>very large (Cohen's <i>d</i> = %3.2f)</span>. The scores were obviously lower than the criterion of success for this content area. <br />", $skill_d[$topic-1];
			}
			if ($fraction >= 75) {
				print REPORT "<i>The vast majority of the class performed well on this content. A little reinforcement of these facts, concepts, and procedures is probably all that is required. The class appears to have mastered this material.</i></li>";
			}
			elsif ($fraction >= 60) {
				print REPORT "<i>Most of the class performed well on this content. However, a sizable number of students had difficulty with this material. A bit of review concerning the key facts, concepts, and procedures would probably help these students to improve. The class as a whole appears to have a good grasp of this material.</i></li>";		
			}
			elsif ($fraction >= 50) {
				print REPORT "<i>Over half of the class exceeded the criterion of success. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. Some effort should probably be made to improve these scores.</i></li>";
			}
			elsif ($fraction >= 40) {
				print REPORT "<i>Less than half of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
			elsif ($fraction >= 25) {
				print REPORT "<i>Only some of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
			else {
				print REPORT "<i>Very few students met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
		}	
		else {
			printf REPORT "$stylecolor not significantly different</span> from the criterion of success - <i>t</i> (%3d) = %4.2f, <i>p</i> &gt; %4.3f. The magnitude of the effect size for this score was ", $df, $skill_t[$topic-1], $alpha_skill;
			if ($skill_d[$topic-1] > 0.2) {
				printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. Although the scores exeed the criterion of success, the difference is not very impressive. <br />", $skill_d[$topic-1];
			}
			elsif ($skill_d[$topic-1] > -0.2) {
				printf REPORT "<span class=style_same>tiny (Cohen's <i>d</i> = %3.2f)</span>. The class average is essentially indistingishable from the criterion of success. The class performance was adequate. <br />", $skill_d[$topic-1];
			}
			else {
				printf REPORT "<span class=style_same>small (Cohen's <i>d</i> = %3.2f)</span>. Therefore, we can conclude that the class as a whole performed measurable worse than the criterion of success. This may require some remediation. <br />", $skill_d[$topic-1];
			}
			if ($fraction >= 75) {
				print REPORT "<i>The vast majority of the class performed well on this content. A little reinforcement of these facts, concepts, and procedures is probably all that is required. The class appears to have mastered this material.</i></li>";
			}
			elsif ($fraction >= 60) {
				print REPORT "<i>Most of the class performed well on this content. However, a sizable number of students had difficulty with this material. A bit of review concerning the key facts, concepts, and procedures would probably help these students to improve. The class as a whole appears to have a good grasp of this material.</i></li>";		
			}
			elsif ($fraction >= 50) {
				print REPORT "<i>Over half of the class exceeded the criterion of success. Unfortunately, a large number of students also fell short of this goal. The overall class seems to have an adequate understanding of this topic. Some effort should probably be made to improve these scores.</i></li>";
			}
			elsif ($fraction >= 40) {
				print REPORT "<i>Less than half of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
			elsif ($fraction >= 25) {
				print REPORT "<i>Only some of the class met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
			else {
				print REPORT "<i>Very few students met the performance standard for this material. A large number of students are apparently struggling with facts, concepts, and procedures covered in this section. This material should be reviewed online and probably reassessed with some sort of quiz to monitor improvements in understanding.</i></li>";
			}
		}
	}
	else {
		print REPORT "<br /><i>This level of cognitive activity was not assessed by this exam.</i></li>";
	}
}
print REPORT "</p></ol><hr>";

print REPORT <<EOF;
<h2><a name="G" id="G"></a>G) Psychometric assessment of exam items <a href="#top" class="myButton">back to top</a></h2>
<p align="left"><font face="Arial, Helvetica, sans-serif">
 This portion of the  report summarizes how well each item performed in this assessment. In classical test theory, the quality of an item's function is affected by three factors: facility, discrimination, and distracter effectiveness. Facility (or difficulty) represents the fraction of the class that correctly answered the question. Very high (easy) and very low (hard) scores are generally undesirable. Since most of the students either correctly or incorrectly respond in these situations, the questions do not allow us to differentiate between students very well. Discrimination is a measure of how well the item score reflects or predicts the overall exam score. In this report, the point biserial correlation is calculated. Higher scores indicate a better relationship between the class performance on the item and the overall exam. Discrimination is the most important factor to consider when evaluating an item's performance. </font>The last factor affecting item performance is the quality of each distracter (incorrect option). Good distracters should be plausible responses (chosen by at least 3% of the class). However, they must not be so ambiguous as to outperform the actual key. In addition, good distracters ought to be more appealing to low-proficiency students (quintiles 1 and 2) than to high-proficiency students (quintiles 4 and 5). As a result, their quintile plots should exhibit a strong negative slope. The actual effectiveness of each distractor (as compared to the correct answer) are calculated using the PB<sub>DC</sub> correlation of Attali and Fraenkel.</p>
EOF

 
 print REPORT "<p><a href=\"reports/item_analysis.txt\" title=\"Open the tab-delimited item analysis report\" border=\"0\"><img src=\"graphics/icon.png\" align=\"bottom\" hspace = \"10\">Item analysis report</a></p><p>To facilitate additional statistical analysis of the results for this assignment, a simple tab-delimited file has been generated and may be accessed here. A complete item analysis for each question is included. Once again, this file should be compatible with any statistics package that you might wish to use.</p>";
 
print REPORT <<EOF;
<table width="100%" border="1" cellpadding="5" cellspacing="0" bordercolor="#333333">
  <tr>
    <td colspan="9" bgcolor="#333333"><div align="center" class="listing_head"><strong>Psychometric Score Factors </strong></div></td>
  </tr>
  <tr>
    <td colspan="3" bgcolor="#9f9f9f"><div align="center" class="listing"><strong>Facility</strong></div></td>
    <td colspan="3"><div align="center" class="listing"><strong>Discrimination</strong></div></td>
    <td colspan="3" bgcolor="#9f9f9f"><div align="center" class="listing"><strong>Distractors (X3) </strong></div></td>
  </tr>
  <tr>
    <td bgcolor="#f0f0f0"><div align="center" class="listing"><em><strong>Description</strong></em></div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing"><em><strong>Range</strong></em></div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing"><em><strong>Pts</strong></em></div></td>
    <td><div align="center" class="listing"><em><strong>Description</strong></em></div></td>
    <td><div align="center" class="listing"><em><strong>Range</strong></em></div></td>
    <td><div align="center" class="listing"><em><strong>Pts</strong></em></div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing"><em><strong>Description</strong></em></div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing"><em><strong>Range</strong></em></div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing"><em><strong>Pts</strong></em></div></td>
  </tr>
  <tr>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Very easy </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">p &ge; 0.90 </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">2</div></td>
    <td><div align="center" class="listing">Excellent</div></td>
    <td><div align="center" class="listing">Rpb &ge; 0.4 </div></td>
    <td><div align="center" class="listing">7</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Active</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">n &ge; 3%</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">1</div></td>
  </tr>
  <tr>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Easy</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">0.74 &le; p &lt; 0.9 </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">3</div></td>
    <td><div align="center" class="listing">Good</div></td>
    <td><div align="center" class="listing">0.3 &le; Rpb &lt; 0.4 </div></td>
    <td><div align="center" class="listing">4</div></td>
    <td bgcolor="#f5b800"><div align="center" class="listing">Inactive</div></td>
    <td bgcolor="#f5b800"><div align="center" class="listing">n &lt; 3% </div></td>
    <td bgcolor="#f5b800"><div align="center" class="listing">0</div></td>
  </tr>
  <tr>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Moderate</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">0.52 &le; p &lt; 0.74 </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">4</div></td>
    <td><div align="center" class="listing">Adequate </div></td>
    <td><div align="center" class="listing">0.2 &le; Rpb &lt; 0.3</div></td>
    <td><div align="center" class="listing">2</div></td>
    <td bgcolor="#ff6633"><div align="center" class="listing">Hyperactive</div></td>
    <td bgcolor="#ff6633"><div align="center" class="listing">n &gt; key </div></td>
    <td bgcolor="#ff6633"><div align="center" class="listing">-1</div></td>
  </tr>
  <tr>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Difficult</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">0.40 &le; p &lt; 0.52 </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">2</div></td>
    <td><div align="center" class="listing">Weak</div></td>
    <td><div align="center" class="listing">0.1 &le; Rpb &lt; 0.2 </div></td>
    <td><div align="center" class="listing">1</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Strong effect</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">PB<sub>DC</sub> &le; -0.40 </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">2</div></td>
  </tr>
  <tr>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Very difficult</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing"> p &lt; 0.40 </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">0</div></td>
    <td><div align="center" class="listing">Poor</div></td>
    <td><div align="center" class="listing">Rpb &lt; 0.1 </div></td>
    <td><div align="center" class="listing">0</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Medium effect </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">-0.40 &lt; PB<sub>DC</sub> &le; -0.20 </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">1</div></td>
  </tr>
  <tr>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">&nbsp;</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">&nbsp;</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">&nbsp;</div></td>
    <td><div align="center" class="listing">&nbsp;</div></td>
    <td><div align="center" class="listing">&nbsp;</div></td>
    <td><div align="center" class="listing">&nbsp;</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">Weak effect</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">-0.20 &lt; PB<sub>DC</sub> &le; 0 </div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">0</div></td>
  </tr>
  <tr>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">&nbsp;</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">&nbsp;</div></td>
    <td bgcolor="#f0f0f0"><div align="center" class="listing">&nbsp;</div></td>
    <td><div align="center" class="listing">&nbsp;</div></td>
    <td><div align="center" class="listing">&nbsp;</div></td>
    <td><div align="center" class="listing">&nbsp;</div></td>
    <td bgcolor="#ff6633"><div align="center" class="listing">Misleading</div></td>
    <td bgcolor="#ff6633"><div align="center" class="listing">PB<sub>DC</sub> &gt; 0 </div></td>
    <td bgcolor="#ff6633"><div align="center" class="listing">-2</div></td>
  </tr>
</table>
<p align="left"><font face="Arial, Helvetica, sans-serif">As a means of quantitating item quality, I have created a unique 20-point pysychometric  rating scale. Each question on the exam is given a quality score (based upon the item's difficulty, discrimination, and distractor performance). </font>The parameters employed and their relative values are set out in the table above. Items that are rarely selected are identified with a caution (orange). Defective distractors - either due to out-competing the key or giving a positive slope (poorer students excel more than better students) are identified with warnings (red). Summing all three of these factors produces a quality score for each question. A histogram of the quality scores for this assessment is presented below. The score range has been divided into four categories - poor, marginal, good, and excellent performance. </p>
<p align="center"><img src="graphics/psychometric.png" alt="Psychometric Scores" width="750" height="300" align="middle" /></p>
<p><strong><font face="Arial, Helvetica, sans-serif">Excellent items</font></strong><font face="Arial, Helvetica, sans-serif"> (16 to 20 points) &ndash; These items discriminate very well between students of differing abilities. The item&rsquo;s key and most of its distracters are performing as expected. A few minor improvements may be possible at the lower end of this range. </font></p>
<p><font face="Arial, Helvetica, sans-serif"><strong>Good items</strong> (11 to 15 points) &ndash; These items also discriminate between students of differing abilities and are contributing to the overall reliability of the assessment. The lower scores are often due to sub-optimal facility scores and one or two poorly functioning distracters. A bit of editing may improve the performance of these items. </font></p>
<p><font face="Arial, Helvetica, sans-serif"><strong>Marginal items</strong> (6 to 10 points) &ndash; These items still discriminate between students of differing abilities, but not very well. Facility scores tend toward the extremes (very easy or very hard) and the distracter performance is usually not very robust. These questions should be seriously evaluated and may require major editing or rethinking to improve their performance on future exams. </font></p>
<p><font face="Arial, Helvetica, sans-serif"><strong>Poor items</strong> (1 to 5 points) &ndash; These items are not functioning as intended and they are not adding to the reliability of the overall assessment. Such questions may need major edits or possibly be eliminated altogether. A few unsatisfactory items may just be <i>really</i> easy. If such items exist and are deemed to be important for the assessment, they can be retained. Unsatisfactory items should probably not comprise more than around 5 to 10 percent of all assessment items.</font> Too many poorly-functioning items may reduce the reliability of the exam.</p>
<p align="left"><font face="Arial, Helvetica, sans-serif"><img src="graphics/itemPlot.png" usemap="#psychoMap" alt="Item Plot" align="right" border="0">$psychoMap
The relative performance of each question can also be visualized by plotting the item facility versus its discrimination as shown to the right. The color of each point on this plot corresponds to a psychometric quality category described above. The plot area has been color-coded into a &quot;target&quot; for best item performance. The light blue &quot;bullseye&quot; indicates an area with moderate facility and high discrimination. This is the location of near-optimal question performance. The surrounding green area contains strong (but not optimal) items. The yellow area contains marginal items, while the red area contains poor items. The goal is to have most of the exam items plot in the blue and green areas. Poor items may occur for many reasons. Some items are just too easy and give poor discrimination. Others may give poor discrimination because they are too difficult (misleading or ambiguous). Quality color mismatches help to reveal problematic distracters. For instance, a green (good) point in the yellow (marginal band) indicates that the question is performing better than expected - its distracters must be working pretty well. Conversely, a green (good) point in the blue (excellent) bullseye indicates that the question is under-performing. Its distractors are probably pulling the item quality score down.</font></p>
<p align="left">The average item facility (the average exam score - since the exam score is actually just a composite of the individual item scores) and item discrimination are also plotted as dashed lines. Think of this as a rifle cross-hairs. You are aiming for the bullseye; this plot will let you rapidly assess how far you are from the mark.</p>
<p align="left">You may quickly navigate to the item analysis for each question by clicking on the points plotted in this graph. (closely spaced points may make this difficult at times).</p>
<p align="left">Each item of the exam is scored, color-coded to match the four levels of psychometric performance described above, and analyzed below. The facility and discrimination for each question is also given. To facilitate the evaluation of the exam questions, a brief summary of their performance is given. Warnings and cautions are provided to direct rational efforts to improve the performance of the exam for future classes. The left panel of the graph contains a color-coded histogram of the option frequencies for each question. The correct response is indicated with an orange circle. The frequency that each option was selected by different quintiles of the class is indicated in the right panel. Quintile 1 is the lowest 20% of all the exam scores, and quintile 5 is the highest 20% of the scores. The correct response ought to be selected more often by higher-scoring students and less often by those that performed poorly (that is, the plots should have a positive slope). The distractors should show the opposite trend (negative slopes). The color scheme for the options is the same in both panels. </p>
<table width="900px" border="1" cellpadding="5" cellspacing="0" bordercolor="#000000" summary="Item analysis">
EOF

for ($question=0; $question<$numquestions; $question++) {

	if ($distractor[$question][0] > 15) {
		$bg_color=" bgcolor=\"#33CCFF\"";
		$performance="nearly optimal performance. ";
	}
	elsif ($distractor[$question][0] > 10) {
		$bg_color=" bgcolor=\"#33FF66\"";
		$performance="a strong performance. ";
	}
	elsif ($distractor[$question][0] > 5) {
		$bg_color=" bgcolor=\"#FFFF33\"";
		$performance="an adequate performance. ";
	}
	else {
		$bg_color=" bgcolor=\"#FF6633\"";
		$performance="a rather weak performance. ";
	}

	print REPORT "\n<tr height=\"120\" >\n<td align=\"center\" valign=\"middle\" $bg_color><a name=\"Question";
	print REPORT $question+1;
	print REPORT "\"></a><p><font face=\"Arial, Helvetica, sans-serif\"><strong>Question</strong></font><br />";
	
	
	print REPORT "<span class=\"myPop\" title=\"Summary ",$question+1,"\">",$question+1;
	print REPORT "<span style=\"width:500px;\">";
	print REPORT "<table id=\"pop-table\" summary=\"test popup\">";
	print REPORT "<caption>Question ",$question+1," Summary</caption>";
	print REPORT <<EOF;
  		<thead>
			<tr>
				<th>Choice</th>
				<th>Number</th>
				<th>Percent</th>
				<th>PB<sub>C</sub></th>
				<th>PB<sub>DC</sub></th>
			</tr>
		</thead>
		<tbody>	
EOF
	
	if($num_key[$question] == 1) {
		print REPORT "<tr class=\"key\"><td>[ A ]</td><td>",$plotdata[$question][1][0],"</td><td>";
		printf REPORT "%4.1f\%", $plotdata[$question][1][0]/$numstudents*100;
		print REPORT "</td><td>";
		printf REPORT "%4.3f", $r_pbi[$question];
		print REPORT "</td><td>NA</td></tr>";
	}
	else {
		print REPORT "<tr><td>A</td><td>",$plotdata[$question][1][0],"</td><td>";
		printf REPORT "%4.1f\%", $plotdata[$question][1][0]/$numstudents*100;
		print REPORT "</td><td>NA</td><td>";
		printf REPORT "%4.3f", $PBDCa[$question];
		print REPORT "</td></tr>";
	}
	if($num_key[$question] == 2) {
		print REPORT "<tr class=\"key\"><td>[ B ]</td><td>",$plotdata[$question][2][0],"</td><td>";
		printf REPORT "%4.1f\%", $plotdata[$question][2][0]/$numstudents*100;
		print REPORT "</td><td>";
		printf REPORT "%4.3f", $r_pbi[$question];
		print REPORT "</td><td>NA</td></tr>";
	}
	else {
		print REPORT "<tr><td>B</td><td>",$plotdata[$question][2][0],"</td><td>";
		printf REPORT "%4.1f\%", $plotdata[$question][2][0]/$numstudents*100;
		print REPORT "</td><td>NA</td><td>";
		printf REPORT "%4.3f", $PBDCb[$question];
		print REPORT "</td></tr>";
	}
	if($num_key[$question] == 3) {
		print REPORT "<tr class=\"key\"><td>[ C ]</td><td>",$plotdata[$question][3][0],"</td><td>";
		printf REPORT "%4.1f\%", $plotdata[$question][3][0]/$numstudents*100;
		print REPORT "</td><td>";
		printf REPORT "%4.3f", $r_pbi[$question];
		print REPORT "</td><td>NA</td></tr>";
	}
	else {
		print REPORT "<tr><td>C</td><td>",$plotdata[$question][3][0],"</td><td>";
		printf REPORT "%4.1f\%", $plotdata[$question][3][0]/$numstudents*100;
		print REPORT "</td><td>NA</td><td>";
		printf REPORT "%4.3f", $PBDCc[$question];
		print REPORT "</td></tr>";
	}
	if($num_key[$question] == 4) {
		print REPORT "<tr class=\"key\"><td>[ D ]</td><td>",$plotdata[$question][4][0],"</td><td>";
		printf REPORT "%4.1f\%", $plotdata[$question][4][0]/$numstudents*100;
		print REPORT "</td><td>";
		printf REPORT "%4.3f", $r_pbi[$question];
		print REPORT "</td><td>NA</td></tr><tbody></table></span></span>";
	}
	else {
		print REPORT "<tr><td>D</td><td>",$plotdata[$question][4][0],"</td><td>";
		printf REPORT "%4.1f\%", $plotdata[$question][4][0]/$numstudents*100;
		print REPORT "</td><td>NA</td><td>";
		printf REPORT "%4.3f", $PBDCd[$question];
		print REPORT "</td></tr><tbody></table></span></span>";
	}
	
	
	print REPORT "</p><p>&nbsp;</p><p><font face=\"Arial, Helvetica, sans-serif\"><strong>Score</strong><br /><font size=\"+3\">";
	print REPORT $distractor[$question][0];
	print REPORT "</font></font></p></td><td width=\"360\" align=\"left\" valign=\"top\"><span class=\"style_items\"><font face=\"Arial, Helvetica, sans-serif\"><strong><font size=\"2\">Objective $objective[$question]: </font></strong><font size=\"2\"><em>";
	
	if ($skill[$question] eq "Identifying") {
		print REPORT "<a href=\"#Skill1\" title=\"Go to Identifying\">$skill[$question]</a> a fact about ";
	}
	elsif ($skill[$question] eq "Categorizing") {
		print REPORT "<a href=\"#Skill2\" title=\"Go to Categorizing\">$skill[$question]</a> a concept about ";
	}
	elsif ($skill[$question] eq "Calculating") {
		print REPORT "<a href=\"#Skill3\" title=\"Go to Calculating\">$skill[$question]</a> a procedure involving ";
	}
	elsif ($skill[$question] eq "Interpreting") {
		print REPORT "<a href=\"#Skill4\" title=\"Go to Interpreting\">$skill[$question]</a> data related to ";
	}
	elsif ($skill[$question] eq "Predicting") {
		print REPORT "<a href=\"#Skill5\" title=\"Go to Predicting\">$skill[$question]</a> a situation concerning ";
	}
	else {
		print REPORT "<a href=\"#Skill6\" title=\"Go to Judging\">$skill[$question]</a> a response about ";
	}
	
	if ($lecture[$question] eq $report{'lec1'}) {
		print REPORT "<a href=\"#Area1\" title=\"Go to $report{'lec1'}\">";
	}
	elsif ($lecture[$question] eq $report{'lec2'}) {
		print REPORT "<a href=\"#Area2\" title=\"Go to $report{'lec2'}\">";
	}
	elsif ($lecture[$question] eq $report{'lec3'}) {
		print REPORT "<a href=\"#Area3\" title=\"Go to $report{'lec3'}\">";
	}
	elsif ($lecture[$question] eq $report{'lec4'}) {
		print REPORT "<a href=\"#Area4\" title=\"Go to $report{'lec4'}\">";
	}
	elsif ($lecture[$question] eq $report{'lec5'}) {
		print REPORT "<a href=\"#Area5\" title=\"Go to $report{'lec5'}\">";
	}
	elsif ($lecture[$question] eq $report{'lec6'}) {
		print REPORT "<a href=\"#Area6\" title=\"Go to $report{'lec6'}\">";
	}
	elsif ($lecture[$question] eq $report{'lec7'}) {
		print REPORT "<a href=\"#Area7\" title=\"Go to $report{'lec7'}\">";
	}
	elsif ($lecture[$question] eq $report{'lec8'}) {
		print REPORT "<a href=\"#Area8\" title=\"Go to $report{'lec8'}\">";
	}
	elsif ($lecture[$question] eq $report{'lec9'}) {
		print REPORT "<a href=\"#Area9\" title=\"Go to $report{'lec9'}\">";
	}
	else {
		print REPORT "<a href=\"#Area10\" title=\"Go to $report{'lec10'}\">";
	}
	
	print REPORT "$lecture[$question] </a></em> </font></font></span><p class=\"style_items\"><font size=\"2\" face=\"Arial, Helvetica, sans-serif\"><strong>Facility</strong> = ";
	printf REPORT "%4.3f", $p[$question];
	
	if ($p[$question] >= 0.9) {
		print REPORT " (Very easy question)";
	}	
	elsif ($p[$question] >= 0.74) {
		print REPORT " (Easy question)";
	}	
	elsif ($p[$question] >= 0.52) {
		print REPORT " (Moderate difficulty)";
	}	
	elsif ($p[$question] >= 0.4) {
		print REPORT " (Hard question)";
	}	
	else {
		print REPORT " (Very hard question)";
	}	

	print REPORT "<br /><strong>Point Biserial </strong>= ";
	printf REPORT "%4.3f", $r_pbi[$question];
	
	if ($r_pbi[$question] >= 0.4) {
		print REPORT " (Excellent discrimination)";
	}	
	elsif ($r_pbi[$question] >= 0.3) {
		print REPORT " (Good discrimination)";
	}	
	elsif ($r_pbi[$question] >= 0.2) {
		print REPORT " (Adequate discrimination)";
	}	
	elsif ($r_pbi[$question] >= 0.1) {
		print REPORT " (Weak discrimination)";
	}	
	else {
		print REPORT " (Poor discrimination)";
	}	
	
	print REPORT "</font></p><p class=\"style_items\"><font size=\"2\" face=\"Arial, Helvetica, sans-serif\"><strong>Summary:</strong> This question exibited $performance";
	
	if ($r_pbi[$question] < 0.2) {
		if ($p[$question] > 0.80) {
			print REPORT "The low discrimination value for this item is due, at least in part, to the fact that so many students correctly answered it. ";
		}
		elsif ($p[$question] < 0.40) {
			print REPORT "This item was so difficult that it failed to discriminate adequately. This question should be reviewed for clarity and accuracy. ";
		}
		else {
			print REPORT "Despite having reasonable difficulty, this question did not discriminate very well. It should be reviewed for clarity and accuracy. ";
		}
	}	
	else {
		if ($p[$question] > 0.80) {
			print REPORT "Despite being relatively easy, this question still discriminated well. ";
		}
		elsif ($p[$question] < 0.40) {
			print REPORT "Despite being rather difficult, this question still discriminated well. ";
		}
		else {
			print REPORT "The facility and discrimination scores for this question are both very good. ";
		}
	}	
	@optionNames=("-","A","B","C","D");
	for ($myloop=1; $myloop<5; $myloop++) {
		if ($myloop!=$num_key[$question]) {
			if ($plotdata[$question][$myloop][0] > $plotdata[$question][$num_key[$question]][0]) {
				print REPORT "<br><font color=red><b>Warning</b></font>: $optionNames[$myloop] was chosen more often than the key.";
			}
		}
	}
	
	for ($myloop=1; $myloop<5; $myloop++) {
		if ($myloop!=$num_key[$question]) {
			if ($PBDC[$question][$myloop] > 0) {
				print REPORT "<br><font color=red><b>Warning</b></font>: $optionNames[$myloop] had a positive PB<sub>DC</sub> value.";
			}
		}
	}

	for ($myloop=1; $myloop<5; $myloop++) {
		if ($myloop!=$num_key[$question]) {
			if ($plotdata[$question][$myloop][0] <= $numstudents*0.03) {
				print REPORT "<br><font color=orange><b>Caution</b></font>: $optionNames[$myloop] was not chosen very often.";
			}
		}
	}

	
	print REPORT "</font></p></td><td ><font face=\"Arial, Helvetica, sans-serif\"><img src=\"graphics/question";
	print REPORT $question+1;
	print REPORT ".png\" alt=\"Question ";
	print REPORT $question+1;
	print REPORT "\" width=\"500\" height=\"200\" /></font></td></tr>";
}	
print REPORT "</table> \n <p>&nbsp;</p> <hr />\n";
print REPORT "<h2><a name=\"H\" id=\"H\"></a>H) Annotated reading list <a href=\"#top\" class=\"myButton\">back to top</a></h2>\n<p>";
print REPORT <<EOF;
<p>This format and content of the feedback provided by this program reflects the prior work and knowledge of many different groups. In the space below, I have created a short list of some of the more helpful materials that I've found during the time spent developing this project.</p>
<p>
	<dl>
	
		<dt><b>Anderson., L W., & Krathwohl, D. R. (eds.)</b> (2001). <i>A Taxonomy for Learning, Teaching, and Assessing: A Revision of Bloom's Taxonomy of Educational Objectives.</i> New York: Longman.  [<a href="http://www.amazon.com/Taxonomy-Learning-Teaching-Assessing-Educational/dp/0321084055">Find it in Amazon</a>]</dt>
		<dd>This book gives is an excellent update to the original taxonomy defined by Bloom in the 1950's. They use a two-dimensional taxonomy (cognitive process dimension and knowledge dimension). I have slightly tweaked this to make it cognitive process vs content area.</dd>

		<dt><b>Crowe A., Dirks C., Wenderoth M. P.</b> (2008). Biology in Bloom: implementing Bloom's taxonomy to enhance student learning in biology. <i>CBE Life Sci. Educ.</i> <b>7</b>:368-381. [<a href="http://dx.doi.org/10.1187/cbe.08-05-0024">Find it online</a>]</dt>
		<dd>This article is an excellent example of mapping multiple-choice exam items to course outcomes and Bloom's taxonomy. Many specific examples are given for various fields of Biology. Furthermore, they address the importance of formative feedback to enhance student comprehension.</dd>

	</dl>
</p>

EOF

print REPORT "</div>\n</body>\n<\html>\n\n";

close (REPORT);





################################################################################
# +--------------------------------------------------------------------------+ #
# | [-6-]        Subroutines that are called for repetitive tasks            | #
# +--------------------------------------------------------------------------+ #
################################################################################

# +--------------------------------------------------------------------------+ #
# | This is a simple routine to generate letter grades from percentages      | #
# +--------------------------------------------------------------------------+ #

sub letter_grade {
	local($this_score) = @_;
	if ($this_score < 60) {
		return('an F');
	}
	elsif ($this_score < 63) {
		return('a D-');
	}
	elsif ($this_score < 67) {
		return('a D');
	}
	elsif ($this_score < 70) {
		return('a D+');
	}
	elsif ($this_score < 73) {
		return('a C-');
	}
	elsif ($this_score < 77) {
		return('a C');
	}
	elsif ($this_score < 80) {
		return('a C+');
	}
	elsif ($this_score < 83) {
		return('a B-');
	}
	elsif ($this_score < 87) {
		return('a B');
	}
	elsif ($this_score < 90) {
		return('a B+');
	}
	elsif ($this_score < 93) {
		return('an A-');
	}
	else {
		return('an A');
	}
}


# +--------------------------------------------------------------------------+ #
# | This is a routine to generate specific feedback about each student's     | #
# | performance on different content areas evaluated in the assessment.      | #
# +--------------------------------------------------------------------------+ #

sub content_feedback {
	local($score,$possible,$section_score,$section_possible) = @_;
	$percent=$score/$possible*100;
	$section_percent=$section_score/$section_possible*100;
	$percent_diff=$section_percent-$percent;
	$missed=$possible-$score;
	$section_missed=$section_possible-$section_score;
	if($missed==0) {
		$percent_missed=0;
	}
	else {
		$percent_missed=$section_missed/$missed*100;
	}
	
	if($exam_score==100) {
		$message = "Since you did not miss any questions on this assignment, breaking out the scores by lecture content is really rather pointless. Just spend a few moments to review your responses. Keep up the good work. ";
	}
	else{
		if($percent_missed==0) {
			$message = " None of the questions that you missed were from this section. ";
		}
		elsif($percent_missed==100) {
			$message = " <span class=\"style_worse\">All of the questions that you missed were taken from the materials concerning this topic.</span> This is obviously where you need to review the most! ";
		}
		else{
			$message = " Around <b>";
			$message .= int($percent_missed*10+0.5)/10;
			$message .= "\%</b> of the questions that you missed were taken from the materials concerning this topic. ";
		}
	
	
		if($section_percent>=90) {
			$message.=" Your performance on these questions was <span class=\"style_better\">excellent</span> and it seems that you have a solid understanding of the information presented in this material. ";
		}
		elsif($section_percent>=80) {
			$message.=" Your score for this section is <span class=\"style_better\">very good</span> and it seems that you have a good understanding of the information presented in this material. ";
		}
		elsif($section_percent>=60) {
			$message.=" Your score for this section is <span class=\"style_worse\">weak</span>. You appear to have some basic understanding of the information presented in this material. However, there are probably some portions that you ought to brush up on. ";
		}
		else {
			$message.=" Your score for this material is <span class=\"style_worse\">lower than I would like</span>. It may be that you have an incomplete or incorrect understanding of this lecture's materials. It is also possible that you are having trouble with the different levels of critical thinking required by this assessment. Check over this report carefully to find out where your problems may be. Then, if you have concerns or questions, stop by my office for a chat. ";
		}
	
if($percent_diff>=15) {
			$message.="Your score was <span class=\"style_better\">much better</span> on this material than on the overall assessment. This material appears to be one of your strengths; try to find ways to apply what you have done here to other areas of the course. ";
		}
		elsif($percent_diff>=8) {
			$message.="Your score as <span class=\"style_better\">somewhat better</span> on this material than on the exam as a whole. ";
		}
		elsif($percent_diff>=-8) {
			$message .="Compared to your overall score, you performed <b>about the same</b> on this material as you did on the assessment. ";
		}
		elsif($percent_diff>=-15) {
			$message .="Your score was <span class=\"style_worse\">somewhat worse</span> on this material than on the overall assessment. This is a weaker area for you - you should spend some time re-reading your notes and text about this topic. ";
		}
		else{
			$message .="Compared to your overall score, you performed <span class=\"style_worse\">much worse</span></b> on this material than on the rest of the assessment. This represents a weak area in your understanding. You should spend some time reviewing this material. ";
		}
	}
	if ($section_possible<=10) {
		$message .= "<i>Since there were relatively few questions from this section, you should use a little caution when interpreting the significance of the calculated percentages presented here. Large differences in percent performance may be due to just a few responses. Just keep that in mind when judging your relative strengths and weaknesses.</i> ";
	}		
	
	return($message);
}



# +--------------------------------------------------------------------------+ #
# | This is a routine to generate specific feedback about each student's     | #
# | performance on different types of thinking skills                        | #
# +--------------------------------------------------------------------------+ #

sub skills_feedback {
	local($score,$possible,$section_score,$section_possible) = @_;
	$percent=$score/$possible*100;
	$section_percent=int($section_score/$section_possible*100);
	$percent_diff=$section_percent-$percent;
	$missed=$possible-$score;
	$section_missed=$section_possible-$section_score;
	if ($missed==0) {
		$percent_missed=0;
	}
	else {
		$percent_missed=int($section_missed/$missed*1000+0.5)/10;
	}
	
	if ($section_percent == 100) {	#exceptional
	$message = "You scored <strong>$section_score out of $section_possible</strong> points (<em>$section_percent\%</em>) on this portion of the exam.  This is a <span class=\"style_better\">fantastic</span> for this section of the exam. ";
		if ($percent_diff>15) {
			$message .= "You performed <span class=\"style_better\">much better</span> on these questions than you did on the exam as a whole. In fact, <b>none</b> of the questions that you missed were from this section. This section appears to be one of your strengths. You should take some time to reflect upon this success and try to build upon it. What do you think contributed to your high level of achievement here as compared to the whole exam? How can you use what you have done here to improve in other areas? ";
		}
		elsif ($percent_diff>8) {
			$message .= "You performed <span class=\"style_better\">somewhat better</span> on these questions than you did on the exam as a whole. Your high overall exam score makes this finding less surprising. However, the fact that none of your missed questions came from this section reveals that this is one of your relative strengths. Reflect for a bit on the factors (study techniques, critial thinking skills, etc.) that contributed most to your achievement in this section. How can you apply those factors to other parts of our course materials? "; 
		}
		elsif ($percent_diff>-8) {
			$message .= "You performed <strong>about the same</strong> on these questions as you did on the exam as a whole. This is not terribly surprising (given that you scored so high on the exam). Keep up the good work. ";
		}	
		else {
			$message .= "This is mathematically impossible. ";
		}
		if ($section_possible<=10) {
			$message .= "<i>Since there were relatively few questions from this section, you should use a little caution when interpreting the significance of the calculated percentages presented here. Large differences in percent performance may be due to just a few responses. Just keep that in mind when judging your relative strengths and weaknesses.</i> ";
		}
	}
	elsif ($section_percent >=90) {		#very good
	$message = "You scored <strong>$section_score out of $section_possible</strong> points (<em>$section_percent\%</em>) on this portion of the exam. This is a <span class=\"style_better\">great score</span> for this section of the exam. ";
		if ($percent_diff>15) {
			$message .= "You performed <span class=\"style_better\">much better</span> on these questions than you did on the exam as a whole. In fact, only <b>$percent_missed\%</b> of the questions that you missed were from this section. This section appears to be one of your strengths. You should take some time to reflect upon this success and try to build upon it. What do you think contributed to your high level of achievement here as compared to the whole exam? How can you use what you have done here to improve in other areas? ";
		}
		elsif ($percent_diff>8) {
			$message .= "You performed <span class=\"style_better\">somewhat better</span> on these questions than you did on the exam as a whole. About <b>$percent_missed\%</b> of your missed questions came from this section. While you performed pretty well on the overall exam, you were stronger here than in other areas. How can apply what you have shown here to other parts of our materials? ";
		}
		elsif ($percent_diff>-8) {
			$message .= "You performed <strong>about the same</strong> on these questions as you did on the exam as a whole; about <b>$percent_missed\%</b> of your missed questions came from this material. This is not terribly surprising (given that you scored fairly high on the exam). Keep up the good work. ";
		}
		else {
			$message .= "This is mathematically impossible. ";
		}
		if ($section_possible<=10) {
			$message .= "<i>Since there were relatively few questions from this section, you should use a little caution when interpreting the significance of the calculated percentages presented here. Large differences in percent performance may be due to just a few responses. Just keep that in mind when judging your relative strengths and weaknesses.</i> ";
		}
	}
	elsif ($section_percent >=70) {		#adequate
	$message = "You scored <strong>$section_score out of $section_possible</strong> points (<em>$section_percent\%</em>) on this portion of the exam. This is an <strong>adequate</strong> level of performance for the section. ";
		if ($percent_diff>15) {
			$message .= "You performed <span class=\"style_better\">much better</span> on these questions than you did on the exam as a whole. About <b>$percent_missed\%</b> of the questions that you missed came from this section. Although your overall score was alright, this section appears to be one of your strengths. You should take some time to reflect upon this success and try to build upon it. What do you think contributed to your high level of achievement here as compared to the whole exam? How can you use what you have done here to improve in other areas? It would be great to get your overall scores up to this level. ";
		}
		elsif ($percent_diff>8) {
			$message .= "You performed <span class=\"style_better\">somewhat better</span> on these questions than you did on the exam as a whole. Of the questions that you missed, about <b>$percent_missed\%</b> came from this section. While you did OK on the exam as a whole, this section is one of your bright spots. Try to figure out what went right for you here. Perhaps you can find some ways to improve your scores in other areas. ";
		}
		elsif ($percent_diff>-8) {
			$message .= "You performed <strong>about the same</strong> on these questions as you did on the exam as a whole; about <b>$percent_missed\%</b> of your missed questions came from this material. Although this level of work is adequate, there is room for some improvement. You should review your study strategies and the course materials from this section. I would like you to excel - not just get by. ";
		}
		elsif ($percent_diff>-15) {
			$message .= "Your performance on these questions was <span class=\"style_worse\">somewhat worse</span> than your overall exam score. About <b>$percent_missed\%</b> of your incorrect responses were from these materials. Your relatively weak score on this section suggests that you need to brush up on this content. ";
		}
		else {
			$message .= "Your performance here was <span class=\"style_worse\">much worse</span> than on the exam as a whole. About <b>$percent_missed\%</b> of the material that you missed was from this section. This represents a weakness that you should spend some time to address. It may be that you have an incomplete or incorrect understanding of the course materials. It is also possible that you may be having study skills or test-taking problems. Try to use the rest of this report to help sort out what is going on. If you have problems or concerns, stop by my office for chat. ";
		}
		if ($section_possible<=10) {
			$message .= "<i>Since there were relatively few questions from this section, you should use a little caution when interpreting the significance of the calculated percentages presented here. Large differences in percent performance may be due to just a few responses. Just keep that in mind when judging your relative strengths and weaknesses.</i> ";
		}
	}
	elsif ($section_percent >=60) {		#weak
	$message = "You scored <strong>$section_score out of $section_possible</strong> points (<em>$section_percent\%</em>) on this portion of the exam. This is <span class=\"style_worse\">somewhat lower</span> than I would like to see in general. ";
		if ($percent_diff>15) {
			$message .= "You performed <span class=\"style_better\">much better</span> on these questions than you did on the exam as a whole. About <b>$percent_missed\%</b> of the questions that you missed came from this section. Although your overall score was somewhat low, this section appears to be one of your strengths. You should take some time to reflect upon this success and try to build upon it. What do you think contributed to your high level of achievement here as compared to the whole exam? How can you use what you have done here to improve in other areas? It would be great to get your overall scores up to this level. We can discuss these things when you come for your mandatory office hours visit. ";
		}
		elsif ($percent_diff>8) {
			$message .= "You performed <span class=\"style_better\">somewhat better</span> on these questions than you did on the exam as a whole. Of the questions that you missed, about <b>$percent_missed\%</b> came from this section. While you did not score very high on the exam as a whole, this section is one of your bright spots. Try to figure out what went right for you here. Perhaps you can find some ways to improve your scores in other areas. ";
		}
		elsif ($percent_diff>-8) {
			$message .= "You performed <strong>about the same</strong> on these questions as you did on the exam as a whole; about <b>$percent_missed</b> of your missed questions came from this material. This level of work is not really adequate for the course. This means that there is a great deal of room for improvement in your scores. You should review your study strategies and the course materials from this section. I would like to work with you to improve your performance. We can look at what you are studying, how you are studying, and how often you are studying. I really want you to succeed in learning this material. ";
		}
		elsif ($percent_diff>-15) {
			$message .= "Your performance on these questions was <span class=\"style_worse\">somewhat worse</span> than your overall exam score. About <b>$percent_missed</b> of your incorrect responses were from these materials. This score shows me that you have not yet developed an adequate mastery of this course content. You will need to address this issue now Ð before it grows worse. Our course materials build upon each other. If you do not have an sufficient foundation, the later materials will be even more difficult for you. If you have questions or concerns, please stop by my office for a chat. ";
		}
		else {
			$message .= "Your performance here was <span class=\"style_worse\">much worse</span> than on the exam as a whole. About <b>$percent_missed\%</b> of the material that you missed was from this section. This represents a weakness that you need to address immediately. It may be that you have an incomplete or incorrect understanding of the course materials. It is also possible that you may be having study skills or test-taking problems. Try to use the rest of this report to help sort out what is going on. If you have problems or concerns, stop by my office for chat. ";
		}
		if ($section_possible<=10) {
			$message .= "<i>Since there were relatively few questions from this section, you should use a little caution when interpreting the significance of the calculated percentages presented here. Large differences in percent performance may be due to just a few responses. Just keep that in mind when judging your relative strengths and weaknesses.</i> ";
		}
	}
	else  {		#lower than I would like
	$message = "You only scored <strong>$section_score out of $section_possible</strong> points (<em>$section_percent\%</em>) on this portion of the exam. This is <span class=\"style_worse\">much lower</span> than I had hoped to see. "; 
		if ($percent_diff>15) {
			$message .= "On the plus side, you performed <span class=\"style_better\">much better</span> on these questions than you did on the exam as a whole. <b>About $percent_missed\%</b> of the questions that you missed came from this section. However, your overall score was extremely low. Relatively speaking, this section appears to be one of your strengths. Even this section score, though, is not really at an adequate level of performance. We are going to need to work together to improve your scores in order for your to successfully complete this course. There are a variety of things that we can try to help you out. We can discuss the possibilities when you come for your mandatory office hours visit. ";
		}
		elsif ($percent_diff>8) {
			$message .= "You performed <span class=\"style_better\">somewhat better</span> on these questions than you did on the exam as a whole. Of the questions that you missed, about <b>$percent_missed\%</b> came from this section. Although your section score here is a bit better than the exam, your overall performance was much lower than I would like. We are going to need to dramatically improve your scores in order for your to successfully complete this course. ";
		}
		elsif ($percent_diff>-8) {
			$message .= "You performed <strong>about the same</strong> on these questions as you did on the exam as a whole; about <b>$percent_missed\%</b> of your missed questions came from this material. This indicates that you are not yet proficient in working with the course level at this cognitive level. You may need to try some new study skills. Think of it this way - there is a great deal of room for improvement in your scores. ";
		}
		elsif ($percent_diff>-15) {
			$message .= "Your performance on these questions was <span class=\"style_worse\">somewhat worse</span> than your overall exam score. About <b>$percent_missed\%</b> of your incorrect responses were from these materials. ";
		}
		else {
			$message .= "Your performance here was <span class=\"style_worse\">much worse</span> than on the exam as a whole. About <b>$percent_missed\%</b> of the material that you missed was from this section. This represents a weakness that you need to address pretty soon. It may be that you have an incomplete or incorrect understanding of the course materials. It is also possible that you may also be having some trouble with the critical thinking skill necessary for this class. Try to use the rest of this report to help sort out what is going on. If you have problems or concerns, stop by my office for chat. ";
		}
		if ($section_possible<=10) {
			$message .= "<i>Since there were relatively few questions from this section, you should use a little caution when interpreting the significance of the calculated percentages presented here. Large differences in percent performance may be due to just a few responses. Just keep that in mind when judging your relative strengths and weaknesses.</i> ";
		}
	}

	return($message);
}
