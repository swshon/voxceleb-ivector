#!/bin/bash

# Written by Suwon Shon, 2018
# swshon@mit.edu

stage=0

. cmd.sh
. path.sh
set -e
mfccdir=`pwd`/mfcc
vaddir=`pwd`/mfcc
trials=data/voxceleb1_trials/voxceleb1_trials_sv
num_components=2048 # Larger than this doesn't make much of a difference.


if [ $stage -le 0 ]; then
# Preparing dataset folder voxceleb1. The voxceleb1 folder should have subdir voxceleb1_wav which contain wav files.
./local/make_voxceleb1_sv.pl /data/sls/scratch/swshon/dataset/voxceleb1/ data

# Extract speaker recogntion features.
steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj 100 --cmd "$train_cmd" \
    data/voxceleb1_train exp/make_mfcc $mfccdir
steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj 100 --cmd "$train_cmd" \
    data/voxceleb1_test exp/make_mfcc $mfccdir
steps/make_mfcc.sh --mfcc-config conf/mfcc.conf --nj 100 --cmd "$train_cmd" \
    data/voxceleb1_test_1utt exp/make_mfcc $mfccdir

for name in voxceleb1_train voxceleb1_test voxceleb1_test_1utt; do
  utils/fix_data_dir.sh data/${name}
done

fi

if [ $stage -le 1 ]; then

# VAD decision
sid/compute_vad_decision.sh --nj 40 --cmd "$train_cmd" \
    data/voxceleb1_train exp/make_vad $vaddir
sid/compute_vad_decision.sh --nj 40 --cmd "$train_cmd" \
    data/voxceleb1_test exp/make_vad $vaddir
sid/compute_vad_decision.sh --nj 40 --cmd "$train_cmd" \
    data/voxceleb1_test_1utt exp/make_vad $vaddir

for name in voxceleb1_train voxceleb1_test voxceleb1_test_1utt; do
  utils/fix_data_dir.sh data/${name}
done

fi



if [ $stage -le 2 ]; then

# Train UBM and i-vector extractor.
sid/train_diag_ubm.sh --nj 40 --num-threads 8 --cmd "$train_cmd --mem 20G"\
    data/voxceleb1_train $num_components \
    exp/diag_ubm_$num_components

sid/train_full_ubm.sh --nj 40 --remove-low-count-gaussians false \
    --cmd "$train_cmd --mem 25G" data/voxceleb1_train \
    exp/diag_ubm_$num_components exp/full_ubm_$num_components

sid/train_ivector_extractor.sh --num-threads 7 --nj 20 --num_processes 2 --cmd "$train_cmd --mem 16G" \
  --ivector-dim 600 \
  --num-iters 5 exp/full_ubm_$num_components/final.ubm data/voxceleb1_train \
  exp/extractor

fi

if [ $stage -le 3 ]; then

# Extract i-vectors.
sid/extract_ivectors.sh --cmd "$train_cmd --mem 6G " --nj 300 \
   exp/extractor data/voxceleb1_train \
   exp/ivectors_voxceleb1_train

sid/extract_ivectors.sh --cmd "$train_cmd --mem 6G " --nj 40 \
   exp/extractor data/voxceleb1_test \
   exp/ivectors_voxceleb1_test

sid/extract_ivectors.sh --cmd "$train_cmd --mem 6G " --nj 100 \
   exp/extractor data/voxceleb1_test_1utt \
   exp/ivectors_voxceleb1_test_1utt

fi



if [ $stage -le 4 ]; then

# cosine distance scoring
local/cosine_scoring.sh data/voxceleb1_test_1utt data/voxceleb1_test_1utt \
  exp/ivectors_voxceleb1_test_1utt exp/ivectors_voxceleb1_test_1utt $trials local/scores_voxceleb1

eer=`compute-eer <(python local/prepare_for_eer.py $trials local/scores_voxceleb1/cosine_scores) 2> /dev/null`
echo "CDS eer : $eer"

# LDA+cosine distance scoring
local/lda_scoring.sh data/voxceleb1_train data/voxceleb1_test_1utt data/voxceleb1_test_1utt \
  exp/ivectors_voxceleb1_train exp/ivectors_voxceleb1_test_1utt exp/ivectors_voxceleb1_test_1utt $trials \
  local/scores_voxceleb1

eer=`compute-eer <(python local/prepare_for_eer.py $trials local/scores_voxceleb1/lda_scores) 2> /dev/null`
echo "LDA+CDS eer : $eer"

# PLDA scoring
ivector-mean scp:exp/ivectors_voxceleb1_train/ivector.scp exp/ivectors_voxceleb1_train/mean.vec
local/plda_scoring.sh data/voxceleb1_train data/voxceleb1_test_1utt data/voxceleb1_test_1utt \
  exp/ivectors_voxceleb1_train exp/ivectors_voxceleb1_test_1utt exp/ivectors_voxceleb1_test_1utt \
  $trials local/scores_voxceleb1

eer=`compute-eer <(python local/prepare_for_eer.py $trials local/scores_voxceleb1/plda_scores) 2> /dev/null`
echo "PLDA eer : $eer"

fi


#GMM-2048 CDS eer : 15.39
#GMM-2048 LDA+CDS eer : 8.103
#GMM-2048 PLDA eer : 5.446


