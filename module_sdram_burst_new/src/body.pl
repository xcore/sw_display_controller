#!/usr/bin/perl

$numberOfArgs = @ARGV;

if( @ARGV < 1) # is less than two arguments
{    
  print "usage: gensdio.pl buffer_length";
  print "* buffer_length should be in words.";
  exit 0;
}

$buf_length = $ARGV[0];

open(OUTFILE,">block_write_body.h");
for($i = 0; $i < $buf_length*2; $i++) {
	print OUTFILE "  ldw r11, cp[$i]\n";
	print OUTFILE "  out res[r2], r11\n";
}
close(OUTFILE);

open(OUTFILE,">block_read_body.h");


if( $buf_length == 64){
	for($i = 0; $i < 64-3; $i++) {
		print OUTFILE "  in r11, res[r2]\n";
		print OUTFILE "  stw r11, dp[$i]\n";
	}
} else {

	for($i = 0; $i < 63; $i++) {
		print OUTFILE "  in r11, res[r2]\n";
		print OUTFILE "  stw r11, dp[$i]\n";
	}
	print OUTFILE "  in r6, res[r2]\n";
	print OUTFILE "  set dp, r5\n";
	for($i = 0; $i < 64-3; $i++) {
		print OUTFILE "  in r11, res[r2]\n";
		print OUTFILE "  stw r11, dp[$i]\n";
	}
	print("buf size not supported\n");

}


close(OUTFILE);