use strict;

use Test::Builder::Tester;
use Test::More tests => 30; # includes those in t/setup_common
use Test::File;

my $test_directory = 'test_files';
SKIP: {
    skip "setup already done", 5 if -d $test_directory;
    require "t/setup_common";
};

chdir $test_directory or print "bail out! Could not change directories: $!";

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Subroutines are defined
{
my @subs = qw( file_line_count_between file_line_count_is file_line_count_isnt );

foreach my $sub ( @subs )
	{
	no strict 'refs';
	ok( defined &{$sub}, "$sub is defined" );
	}

}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Line count
my $file    = 'min_file';

file_exists_ok( $file );

my @lines  = do { local @ARGV = $file; <> };
cmp_ok( scalar @lines, ">", 1, "$file has at least one line" );

my $lines  = @lines;
my $linesm = $lines - 1;
my $linesp = $lines + 1;

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Things that should work
{
test_out( "ok 1 - $file line count is between [$linesm] and [$linesp] lines" );
file_line_count_between( $file, $linesm, $linesp );
test_test();

test_out( "ok 1 - $file line count is between [$lines] and [$linesp] lines" );
file_line_count_between( $file, $lines, $linesp );
test_test();

test_out( "ok 1 - $file line count is between [$lines] and [$lines] lines" );
file_line_count_between( $file, $lines, $lines );
test_test();

test_out( "ok 1 - $file line count is $lines lines" );
file_line_count_is( $file, $lines );
test_test();

test_out( "ok 1 - $file line count is not $linesp lines" );
file_line_count_isnt( $file, $linesp );
test_test();
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Things that should fail (missing file)
{
my $missing = 'not_there';
file_not_exists_ok( $missing );

test_out( "not ok 1 - $missing line count is between [$linesm] and [$linesp] lines" );
test_diag(
	"File [$missing] does not exist!\n" .
	"#   Failed test '$missing line count is between [$linesm] and [$linesp] lines'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_between( $missing, $linesm, $linesp );
test_test();

test_out( "not ok 1 - $missing line count is between [$lines] and [$linesp] lines" );
test_diag(
	"File [$missing] does not exist!\n" .
	"#   Failed test '$missing line count is between [$lines] and [$linesp] lines'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_between( $missing, $lines, $linesp );
test_test();

test_out( "not ok 1 - $missing line count is between [$lines] and [$lines] lines" );
test_diag(
	"File [$missing] does not exist!\n" .
	"#   Failed test '$missing line count is between [$lines] and [$lines] lines'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_between( $missing, $lines, $lines );
test_test();

test_out( "not ok 1 - $missing line count is $lines lines" );
test_diag(
	"File [$missing] does not exist!\n" .
	"#   Failed test '$missing line count is $lines lines'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_is( $missing, $lines );
test_test();

test_out( "not ok 1 - $missing line count is not $lines lines" );
test_diag(
	"File [$missing] does not exist!\n" .
	"#   Failed test '$missing line count is not $lines lines'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_isnt( $missing, $lines );
test_test();

}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Things that should fail (missing line count)
{
my $file = 'min_file';
file_exists_ok( $file );

test_out( "not ok 1 - $file line count is between [] and [] lines" );
test_diag(
	"file_line_count_between expects positive whole numbers for the second and third arguments. Got [] and []!\n" .
	"#   Failed test '$file line count is between [] and [] lines'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_between( $file );
test_test();

test_out( "not ok 1 - $file line count is  lines" );
test_diag(
	"file_line_count_is expects a positive whole number for the second argument. Got []!\n" .
	"#   Failed test '$file line count is  lines'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_is( $file );
test_test();

test_out( "not ok 1 - $file line count is not  lines" );
test_diag(
	"file_line_count_is expects a positive whole number for the second argument. Got []!\n" .
	"#   Failed test '$file line count is not  lines'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_isnt( $file );
test_test();
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Things that should fail (wrong number)
{
my $name = "$file line count is $linesp lines";
test_out( "not ok 1 - $name" );
test_diag(
	"Expected [3] lines in [$file], got [$lines] lines!\n" .
	"#   Failed test '$name'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_is( $file, $linesp );
test_test();

test_out( "ok 1 - $file line count is not $linesp lines" );
file_line_count_isnt( $file, $linesp );
test_test();

$name = "$file line count is not $lines lines";
test_out( "not ok 1 - $name" );
test_diag(
	"Expected something other than [$lines] lines in [$file], but got [$lines] lines!\n" .
	"#   Failed test '$name'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_isnt( $file, $lines );
test_test();

my $linespp = $linesp + 1;
$name = "$file line count is between [$linesp] and [$linespp] lines";
test_out( "not ok 1 - $name" );
test_diag(
	"Expected a line count between [$linesp] and [$linespp] in [$file], but got [$lines] lines!\n" .
	"#   Failed test '$name'\n" .
	"#   at $0 line " . line_num(+5) . "."
	);
file_line_count_between( $file, $linesp, $linespp );
test_test();
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

END {
	chdir '..' or print "bail out! Could not change directories: $!";
	unlink glob( "test_files/*" );
	rmdir "test_files";
}
