SEVICE_NAME=hoge
PROJECT_ID=fuga
GCP_ACCOUNT=xxx@xxx.com
GOOGLE_COMPUTE_ZONE=asia-northeast1-a
DOCKER_TAG="gcr.io/${PROJECT_ID}/${SEVICE_NAME}:latest"
GCP_MACHINE_TYPE=f1-micro

build:
	docker build -t ${DOCKER_TAG} .

run:
	docker run -it --rm ${DOCKER_TAG}

set_env:
	gcloud auth login --brief ${GCP_ACCOUNT}
	gcloud config set project ${PROJECT_ID}
	gcloud config set compute/zone ${GOOGLE_COMPUTE_ZONE}

cloudbuild:
	gcloud builds submit --tag ${DOCKER_TAG}

create_with_container:
	gcloud compute instances create-with-container ${SEVICE_NAME} \
    	--container-image ${DOCKER_TAG} \
    	--zone ${GOOGLE_COMPUTE_ZONE} \
    	--boot-disk-size 10
	gcloud compute instances add-tags ${SEVICE_NAME} \
    	--zone ${GOOGLE_COMPUTE_ZONE} \
    	--tags http-server,https-server

update_container:
	gcloud compute instances update-container ${SEVICE_NAME} \
    	--container-image ${DOCKER_TAG} \
    	--zone ${GOOGLE_COMPUTE_ZONE}

build_and_update:
	@make cloudbuild
	@make update_container

stop_instance:
	gcloud compute instances stop ${SEVICE_NAME}

start_instance:
	gcloud compute instances start ${SEVICE_NAME}

set_machine_type:
	@make stop_instance
	gcloud compute instances set-machine-type ${SEVICE_NAME} \
    	--machine-type ${GCP_MACHINE_TYPE}
	@make start_instance


.PHONY : set_env cloudbuild create-with-container update_container build_and_update stop_instance start_instance set_machine_type