#! /usr/bin/perl

# Update raw, parsed, and formatted sections of SRS records.

use strict;
use warnings;
use MARC::Record;
use MARC::Record::MiJ;
use Data::Dumper;
use JSON;

binmode STDOUT, ":utf8";
$| = 1;

my $infile = shift or die "Usage: ./change_source_records.pl <source_records_file>\n";

if (! -e $infile) {
  die "Can't find raw Marc file!\n"
}

my $save_path = $infile;
$save_path =~ s/^(.+)\..+$/$1_srs.json/;


# open a collection of SRS records
open RECS, $infile or die "Can't open source record file!";
my $srs_recs = { records=>[] };
$/ = '';
my $in_string = <RECS>;
my $in_json = decode_json($in_string);
$in_string = '';

my $count = 0;

foreach (@{ $in_json->{records} }) {
  $count++;
  my $raw = $_->{rawRecord}->{content};
  print "\r$count";
  my $srs = {};
  my $marc = MARC::Record->new_from_usmarc($raw);

  # Do you editing to MARC fields here...

  #### Add hrid to 001 field ####

  my $f001 = $marc->field('001');
  my $oldcn = $f001->data();
  my $f003 = $marc->field('003');
  my $oldorg = $f003->data();
  my $hrid = $marc->subfield('907', 'a');
  $hrid =~ s/\.(b.......)./$1/;
  $f001->update($hrid);
  $f003->update('CaEvIII'); # Innovative assigned number
  my $f035 = $marc->field('035');
  $f035->add_subfields('a', "($oldorg)$oldcn");

  #### Delete 006/007 fields ####
  
  my @f006 = $marc->field('006');
  $marc->delete_field(@f006);
  my @f007 = $marc->field('007');
  $marc->delete_field(@f007);

  #### Delete 856 fields where subfield u contains "archive.org" ####

  # foreach ($marc->field('856')) {
  #  if ($_->subfield('u') =~ /archive.org/) {
  #    $marc->delete_field($_);
  #  }
  # }

  # End MARC editing

  my $mij = MARC::Record::MiJ->to_mij($marc);
  my $parsed = decode_json($mij);
  $_->{rawRecord}->{content} = $marc->as_usmarc();
  $_->{parsedRecord}->{content} = $parsed;
  $_->{parsedRecord}->{formattedContent} = $marc->as_formatted();
}
my $out = JSON->new->pretty->encode($in_json);
open OUT, ">:encoding(UTF-8)", $save_path;
print OUT $out;
print "\nDone! $count SRS records saved to $save_path\n";