use File::Copy;
if ($#ARGV + 1 != 2) {
  print "usage: perl writeflash.pl DATAFILE SECTORNUM\n";
  exit;
}
my $datafile = $ARGV[0];
my $sectornum = $ARGV[1];
open(F, ">:raw", "sectornum.txt") or die "unable to create ./sectornum.txt";
print F pack("s<", $sectornum);
close(F);
copy($datafile, "data.bin") or die "unable to copy $datafile to ./data.bin";
print "xrun --io programmer.xe\n";
system("xrun --io programmer.xe");
unlink("sectornum.txt");
unlink("data.bin");
