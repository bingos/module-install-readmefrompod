use strict;
use lib 'lib';
use inc::Module::Install;
use Config;

name 'Module-Install-ReadmeFromPod';
author 'Chris Williams <chris@bingosnet.co.uk>';
all_from 'lib/Module/Install/ReadmeFromPod.pm';
auto_license holder => 'Chris Williams';
build_requires 'Test::More' => 0.47;
build_requires 'File::Temp' => 0;
build_requires 'Capture::Tiny' => 0.05;
requires 'Module::Install' => 1.00;
requires 'Pod::Text' => 3.13;
requires 'Pod::Html' => 0;
requires 'Pod::Man' => 0;
recommends 'App::pod2pdf';
readme_from;    # Self hosting!
githubmeta;
clean_files 'dist have_make LICENSE';
if ( $Config{make} and can_run( $Config{make} ) ) {
  print "I can run '", $Config{make}, "' good\n";
  open HAVEMAKE, '>have_make' or die "$!\n";
  print HAVEMAKE "meep\n";
  close HAVEMAKE;
}
makemaker_args(dist => { PREOP => "$^X ./tools/git-log.pl > ./Changes" });
WriteAll();
