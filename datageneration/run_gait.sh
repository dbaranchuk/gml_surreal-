#!/bin/bash

array=([0]='02_01' [10]='05_01' [29]='06_01' [429]='ung_07_01' [431]='ung_07_03' [433]='ung_07_05' [436]='ung_07_08' [439]='ung_07_11' [42]='08_01' [45]='08_04' [46]='08_05' [49]='08_09' [51]='08_11'  [106]='10_04' [552]='ung_12_01' [553]='ung_12_02' [554]='ung_12_03' [238]='15_01' [254]='26_01' [265]='27_01' [276]='32_01' [316]='37_01' [317]='38_01' [318]='38_02' [321]='39_01' [328]='39_08' [335]='43_01' [338]='45_01' [720]='ung_47_01' [721]='ung_49_01' [342]='55_04' [743]='ung_74_01' [790]='ung_77_28' [807]='ung_82_11' [808]='ung_82_12' [871]='ung_91_57' [441]='ung_104_02' [525]='ung_113_25' [573]='ung_132_18' [603]='ung_132_48' [549]='ung_120_20' [631]='ung_136_21' [671]='ung_139_28' [227]='143_32') 
#array=([721]='ung_49_01')

# SET PATHS HERE
FFMPEG_PATH=/home/local/tools/ffmpeg/ffmpeg_build_sequoia_h264
X264_PATH=/home/local/tools/ffmpeg/x264_build/
PYTHON2_PATH=/usr/ # PYTHON 2
BLENDER_PATH=/home/local/blender #tools/

# BUNLED PYTHON
BUNDLED_PYTHON=${BLENDER_PATH}/2.79/python
export PYTHONPATH=${BUNDLED_PYTHON}/lib/python3.4:${BUNDLED_PYTHON}/lib/python3.4/site-packages
export PYTHONPATH=${BUNDLED_PYTHON}:${PYTHONPATH}

# FFMPEG
export LD_LIBRARY_PATH=${FFMPEG_PATH}/lib:${X264_PATH}/lib:${LD_LIBRARY_PATH}
export PATH=${FFMPEG_PATH}/bin:${PATH}

subject_id=0
for i in "${!array[@]}"
do
    name=${array[$i]}
    # Forward Pass
    direction="forward"
    JOB_PARAMS="--idx ${i} --name ${name} --ishape 0 --stride 50 --subject_id ${subject_id} --direction ${direction}"
    echo $JOB_PARAMS
    $BLENDER_PATH/blender -b -t 4 -P main_part1.py --- ${JOB_PARAMS}
    PYTHONPATH="" ${PYTHON2_PATH}/bin/python2.7 main_part2.py --- ${JOB_PARAMS}

    # OpenPose
    mkdir "/home/local/data/cmc/synthetic/run0/${name}/openpose_annotation"
    cd "/home/local/tools/openpose/"
    ./build/examples/openpose/openpose.bin --video "/home/local/data/cmc/synthetic/run0/${name}/${name}_c0001.mp4" --write_json "/home/local/data/cmc/synthetic/run0/${name}/openpose_annotation/" --display 0 --render_pose 0 --model_pose "BODY_25"
    cd "/home/local/surreal/datageneration"

    # Rename 
    rm -rf "/home/local/data/cmc/synthetic/run0/${name}_f"
    mv "/home/local/data/cmc/synthetic/run0/${name}" "/home/local/data/cmc/synthetic/run0/${name}_f"
    ((subject_id++))

    # Backward Pass
    direction="backward"
    JOB_PARAMS="--idx ${i} --name ${name} --ishape 0 --stride 50 --subject_id ${subject_id} --direction ${direction}"
    echo $JOB_PARAMS
    $BLENDER_PATH/blender -b -t 4 -P main_part1.py --- ${JOB_PARAMS}
    PYTHONPATH="" ${PYTHON2_PATH}/bin/python2.7 main_part2.py --- ${JOB_PARAMS}
    
    # OpenPose
    mkdir "/home/local/data/cmc/synthetic/run0/${name}/openpose_annotation"
    cd "/home/local/tools/openpose/"
    ./build/examples/openpose/openpose.bin --video "/home/local/data/cmc/synthetic/run0/${name}/${name}_c0001.mp4" --write_json "/home/local/data/cmc/synthetic/run0/${name}/openpose_annotation/" --display 0 --render_pose 0 --model_pose "BODY_25"
    cd "/home/local/surreal/datageneration"
    
    # Rename
    rm -rf "/home/local/data/cmc/synthetic/run0/${name}_b"
    mv "/home/local/data/cmc/synthetic/run0/${name}" "/home/local/data/cmc/synthetic/run0/${name}_b"
    ((subject_id++))
done
