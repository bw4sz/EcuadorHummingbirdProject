#!/bin/bash 

#Startup script
git clone https://github.com/bw4sz/EcuadorHummingbirdProject.git
cd EcuadorHummingbirdProject/tensorflow

declare -r USER="Ben"
declare -r PROJECT=$(gcloud config list project --format "value(core.project)")
declare -r JOB_ID="Annotation_${USER}_$(date +%Y%m%d_%H%M%S)"
declare -r BUCKET="gs://${PROJECT}-ml"
declare -r GCS_PATH="${BUCKET}/${USER}/${JOB_ID}"
declare -r MODEL_NAME="Plotwatcher_Annotation"

#from scratch
python pipeline.py \
    --project ${PROJECT} \
    --cloud \
    --train_input_path gs://api-project-773889352370-ml/TrainingData/training_dataGCS.csv \
    --eval_input_path gs://api-project-773889352370-ml/TrainingData/testing_dataGCS.csv \
    --input_dict gs://api-project-773889352370-ml/TrainingData/dict.txt \
    --deploy_model_name ${MODEL_NAME} \
    --gcs_bucket ${BUCKET} \
    --output_dir "${GCS_PATH}/training" \
    --sample_image_uri  gs://api-project-773889352370-ml/TrainingData/0_2.jpg  
    
exit

