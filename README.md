
# Speaker Verification task in Voxceleb
This repository contains simple scripts for a training i-vector speaker recognition system on Voxceleb1[1] dataset using Kaldi. It was modified based on run.sh file on Kaldi/egs/sre10.

# Requirement
* Kaldi Toolkit

# How to use
1. Move all files to {kaldi_root}/egs/sre10 folder
2. Run run.sh file

# Result

The 2048 component GMM-UBM and 600-dimensional i-vector extractor were trained using voxceleb1 training data for verification task. Training parameter is almost same compared to sre10 baseline on Kaldi egs.

GMM-2048 CDS eer : 15.39%<br />
GMM-2048 LDA+CDS eer : 8.103%<br />
GMM-2048 PLDA eer : 5.446%<br />

# Note
The Voxceleb1 dataset, a large-scale speaker identification dataset was published in 2017 with speaker embedding baseline[1] and reported i-vector shows 8.8% EER. The i-vector was extracted using 1024 component GMM-UBM, so the EER is fairly worse compared to the result above.


# Reference
[1] A. Nagraniy, J. S. Chung, and A. Zisserman, “VoxCeleb: A large-scale speaker identification dataset,” in Interspeech, 2017, pp. 2616–2620.

* CSV file in data folder created from here 
(https://github.com/pyannote/pyannote-db-voxceleb/blob/master/scripts/prepare_data.ipynb)

