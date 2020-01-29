#! /usr/bin/perl

# Create instance records from raw marc.

use MARC::Record;
use Data::Dumper;
use JSON;
use Data::UUID;
$Data::Dumper::Indent = 1;

binmode STDOUT, ":utf8";

my $rules_file = shift;
my $ref_dir = shift;
if (! $ARGV[0]) {
  die "Usage: ./marc2inst.pl <mapping_rules> <ref_data_dir> <raw_marc_files>\n";
}

sub uuid {
  my $ug = Data::UUID->new;
  my $uuid = $ug->create();
  my $uustr = lc($ug->to_string($uuid));
  return $uustr;
}

sub getRules {
  my $rfile = shift;
  local $/ = '';
  open my $rules, $rfile or die "Can't open $rfile";
  my $jsonstr = <$rules>;
  my $json = decode_json($jsonstr);
  return $json;
}

sub getRefData {
  my $refdir = shift;
  my $refobj = {};
  local $/ = '';
  foreach (<$refdir/*.json>) {
    my $prop = $_;
    $prop =~ s/^(.+\/)?(.+?)\.json/$2/;
    # print "Opening reference data file '$prop.json'\n";    
    open my $refdata, $_ or die "Can't open $_";
    my $jsonstr = <$refdata>;
    my $json = eval { decode_json($jsonstr) };
    if ($@) {
      print "WARN $_ is not valid JSON!\n";
    } else {
      foreach (keys $json) {
        if ($_ ne 'totalRecords') {
          $refroot = $_;
          $refobj->{$refroot} = {};
          foreach (@{ $json->{$_} }) {
            my $name = $_->{name};
            my $id = $_->{id};
            $refobj->{$refroot}->{$name} = $id;
          }
        }
      }
    }
  }
 return $refobj;
}

foreach (@ARGV) {
  my $infile = $_;
  if (! -e $infile) {
    die "Can't find raw Marc file!"
  } elsif (! -e $ref_dir) {
    die "Can't find reference data directory!";
  } elsif (! -e $rules_file) {
    die "Can't find mapping rules file!";
  }

  my $rules = getRules($rules_file);
  # print Dumper($rules);

  $ref_dir =~ s/\/$//;
  my $refdata = getRefData($ref_dir);
  # print Dumper($refdata);

  my $save_path = $infile;
  $save_path =~ s/^(.+)\..+$/$1_instances.json/;

  my $ftypes = {
    id => 'string',
    hrid => 'string',
    source => 'string',
    title => 'string',
    indexTitle => 'string',
    alternativeTitles => 'array.object',
    editions => 'array',
    series => 'array',
    identifiers => 'array.object',
    contributors => 'array.object',
    subjects => 'array',
    classifications => 'array.object',
    publication => 'array.object',
    publicationFrequency => 'array',
    publicationRange => 'array',
    electronicAccess => 'array.object',
    instanceTypeId => 'string',
    instanceFormatIds => 'array',
    physicalDescriptions => 'array',
    lanuages => 'array',
    notes => 'array.object',
    modeOfIssuanceId => 'string',
    catalogedDate => 'string',
    previouslyHeld => 'boolean',
    staffSuppress => 'boolean',
    discoverySuppress => 'boolean',
    statisticalCodeIds => 'array',
    sourceRecordFormat => 'string',
    statusId => 'string',
    statusUpdatedDate => 'string',
    tags => 'object',
    holdingsRecords2 => 'array.object',
    natureOfContentTermIds => 'array.string'
  };

  # open a collection of raw marc records
  $/ = "\x1D";
  my $count = 0;
  open RAW, "<:encoding(UTF-8)", $infile;
  my $instances = [];
  while (<RAW>) {
    my $rec = {
      id => uuid(),
      hrid => '',
      source => 'MARC',
      title => '',
      indexTitle => '',
      alternativeTitles => [],
      editions => [],
      series => [],
      identifiers => [],
      contributors => [],
      subjects => [],
      classifications => [],
      publication => [],
      publicationFrequency => [],
      publicationRange => [],
      electronicAccess => [],
      instanceTypeId => '',
      instanceFormatIds => [],
      physicalDescriptions => [],
      lanuages => [],
      notes => [],
      modeOfIssuanceId => '',
      catalogedDate => '',
      previouslyHeld => '',
      staffSuppress => false,
      discoverySuppress => false,
      statisticalCodeIds => [],
      sourceRecordFormat => 'MARC',
      statusId => '',
      statusUpdatedDate => '',
      tags => {},
      holdingsRecords2 => [],
      natureOfContentTermIds => []
    };
    $count++;
    my $raw = $_;
    my $marc = MARC::Record->new_from_usmarc($raw);
    foreach ($marc->fields()) {
      my $field = $_;
      my $tag = $_->tag();
      my $fld_conf = $rules->{$tag};
      if ($fld_conf) {
        foreach (@{ $fld_conf }) {
          $fc = $_;
          print $tag;
          if ($fc->{entity}) {
            foreach (@{ $fc->{entity} }) {
              rule_proc($field, $_);
            }
          } else {
            rule_proc($field, $_);
          }
          print "\n\n";
        }
      }
    }
    last;
  }

  sub rule_proc {
    my $field = shift;
    my $conf = shift;
    my $prop = {};
  }

  exit;
  $out = JSON->new->pretty->encode($srs_recs);
  open OUT, ">:encoding(UTF-8)", $save_path;
  print OUT $out;
  print "\nDone! SRS records saved to $save_path\n";
}
