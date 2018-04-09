#!/usr/bin/perl
#
# Copyright 2018   Suwon Shon
# Usage: make_voxceleb1_sv.pl /voxceleb1/ data/.

if (@ARGV != 2) {
  print STDERR "Usage: $0 <path-to-voxceleb1-dir> <path-to-output>\n";
  print STDERR "e.g. $0 /voxceleb1/ data\n";
  exit(1);
}
($db_base, $out_base_dir) = @ARGV;

$out_dir = "$out_base_dir/voxceleb1_trials";

$tmp_dir = "$out_dir";
if (system("mkdir -p $tmp_dir") != 0) {
  die "Error making directory $tmp_dir"; 
}

open(IN_TRIALS, "<", "$db_base/voxceleb1.verification.test.csv") or die "cannot open trials list";
open(OUT_TRIALS,">", "$out_dir/voxceleb1_trials_sv") or die "Could not open the output file $out_dir/voxceleb1_trials_sv";
$dummy = <IN_TRIALS>;
while(<IN_TRIALS>) {
  chomp;
  ($is_target,$enrollment,$test) = split(",", $_);
  $target='nontarget';
  if ($is_target eq 1) {
    $target='target';
  }
  print OUT_TRIALS "$enrollment $test $target\n";

}
close(IN_TRIALS) || die;
close(OUT_TRIALS) || die;





$out_dir = "$out_base_dir/voxceleb1_train";

$tmp_dir = "$out_dir/tmp";
if (system("mkdir -p $tmp_dir") != 0) {
  die "Error making directory $tmp_dir"; 
}

open(IN_TRIALS, "<", "$db_base/voxceleb1.csv") or die "cannot open trials list";
open(GNDR,">", "$out_dir/spk2gender") or die "Could not open the output file $out_dir/spk2gender";
open(SPKR,">", "$out_dir/utt2spk") or die "Could not open the output file $out_dir/utt2spk";
open(WAV,">", "$out_dir/wav.scp") or die "Could not open the output file $out_dir/wav.scp";

while(<IN_TRIALS>) {
  chomp;
  ($filename,$utt,$start,$end,$spkr,$is_sv,$is_sid) = split(",", $_);
  if ($is_sv eq 'dev') {
    print WAV "$filename"," ${db_base}voxceleb1_wav/${filename}.wav\n";
    print SPKR "$filename $spkr\n";
    print GNDR "$spkr m\n";
  }
}

close(IN_TRIALS) || die;
close(GNDR) || die;
close(SPKR) || die;
close(WAV) || die;


if (system(
  "utils/utt2spk_to_spk2utt.pl $out_dir/utt2spk >$out_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_dir";
}
system("utils/fix_data_dir.sh $out_dir");
if (system("utils/validate_data_dir.sh --no-text --no-feats $out_dir") != 0) {
  die "Error validating directory $out_dir";
}


$out_dir = "$out_base_dir/voxceleb1_test";

$tmp_dir = "$out_dir/tmp";
if (system("mkdir -p $tmp_dir") != 0) {
  die "Error making directory $tmp_dir"; 
}

open(IN_TRIALS, "<", "$db_base/voxceleb1.csv") or die "cannot open trials list";
open(GNDR,">", "$out_dir/spk2gender") or die "Could not open the output file $out_dir/spk2gender";
open(SPKR,">", "$out_dir/utt2spk") or die "Could not open the output file $out_dir/utt2spk";
open(WAV,">", "$out_dir/wav.scp") or die "Could not open the output file $out_dir/wav.scp";

while(<IN_TRIALS>) {
  chomp;
  ($filename,$utt,$start,$end,$spkr,$is_sv,$is_sid) = split(",", $_);
  if ($is_sv eq 'tst') {
    print WAV "$filename"," ${db_base}voxceleb1_wav/${filename}.wav\n";
    print SPKR "$filename $spkr\n";
    print GNDR "$spkr m\n";
  }
}

close(IN_TRIALS) || die;
close(GNDR) || die;
close(SPKR) || die;
close(WAV) || die;


if (system(
  "utils/utt2spk_to_spk2utt.pl $out_dir/utt2spk >$out_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_dir";
}
system("utils/fix_data_dir.sh $out_dir");
if (system("utils/validate_data_dir.sh --no-text --no-feats $out_dir") != 0) {
  die "Error validating directory $out_dir";
}




$out_dir = "$out_base_dir/voxceleb1_test_1utt";

$tmp_dir = "$out_dir/tmp";
if (system("mkdir -p $tmp_dir") != 0) {
  die "Error making directory $tmp_dir"; 
}

open(IN_TRIALS, "<", "$db_base/voxceleb1.csv") or die "cannot open trials list";
open(GNDR,">", "$out_dir/spk2gender") or die "Could not open the output file $out_dir/spk2gender";
open(SPKR,">", "$out_dir/utt2spk") or die "Could not open the output file $out_dir/utt2spk";
open(WAV,">", "$out_dir/wav.scp") or die "Could not open the output file $out_dir/wav.scp";

while(<IN_TRIALS>) {
  chomp;
  ($filename,$utt,$start,$end,$spkr,$is_sv,$is_sid) = split(",", $_);
  if ($is_sv eq 'tst') {
    print WAV "$filename"," ${db_base}voxceleb1_wav/${filename}.wav\n";
    print SPKR "$filename $filename\n";
    print GNDR "$filename m\n";
  }
}

close(IN_TRIALS) || die;
close(GNDR) || die;
close(SPKR) || die;
close(WAV) || die;


if (system(
  "utils/utt2spk_to_spk2utt.pl $out_dir/utt2spk >$out_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_dir";
}
system("utils/fix_data_dir.sh $out_dir");
if (system("utils/validate_data_dir.sh --no-text --no-feats $out_dir") != 0) {
  die "Error validating directory $out_dir";
}
