#! /bin/bash

# initially: gcloud services enable cloudbuild.googleapis.com cloudkms.googleapis.com
#
# Go to CLoud Build Settings page and set Cloud KMS CryptoKey Decrypter role to ENABLED.

# initially: gcloud kms keyrings create "apigee-cicd-credentials" --location global
gcloud kms keyrings list --location global
gcloud kms keys list     --location "global" --keyring "apigee-cicd-credentials"

# create new/updated service account keys in SAs directory following naming convention "cicd-$ENV-service-account@$PROJECT_ID.iam.gserviceaccount.com"
# Re-run to update encrypted credentials and re-deploy

# DEV =====================================================
# Create key for this environment
# initially: gcloud kms keys create cicd-dev --location global --keyring apigee-cicd-credentials --purpose encryption
# Create the SA encrypted file and git add cicd-dev.encrypted
gcloud kms encrypt --location global --keyring apigee-cicd-credentials --key cicd-dev --plaintext-file ../../SAs/cicd-dev-service-account-ngsaas-5g-kurt.json --ciphertext-file cicd-dev.encrypted
# gcloud kms decrypt --location global --keyring apigee-cicd-credentials --key cicd-dev --ciphertext-file cicd-dev.encrypted --plaintext-file cicd-dev.decrypted

# Create the encrypted values and place in cloudbuild...yaml
echo; echo dev username
echo -n cicd-dev-service-account@ngsaas-5g-kurt.iam.gserviceaccount.com | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-dev | base64
# e.g. CiQAZ2M7aOFmxGtFj19CnndpWO7fLsqwl8nfqswr5yCNnCuTD6451V8ruTM5Ljro6bEJXpSVAoKYbbgg10ipNuajFxgWJryPm8xLRwyHp2S/2slXmYKy4


# TEST =====================================================
# initially: gcloud kms keys create cicd-test --location global --keyring apigee-cicd-credentials --purpose encryption
gcloud kms encrypt --location global --keyring apigee-cicd-credentials --key cicd-test --plaintext-file ../../SAs/cicd-test-service-account-ngsaas-5g-kurt.json --ciphertext-file cicd-test.encrypted 
# gcloud kms decrypt --location global --keyring apigee-cicd-credentials --key cicd-test --ciphertext-file cicd-test.encrypted --plaintext-file cicd-test.decrypted

# Create the encrypted values and place in cloudbuild...yaml
echo; echo test username
echo -n cicd-test-service-account@ngsaas-5g-kurt.iam.gserviceaccount.com | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-test | base64
# e.g. CiQAyTb9u02Rmb3CFciv4j912QodXJfqhM61h9TCssQf9Xy4cLcir8422EdMjkz3WCGb3IM1MYNCs1CjKLbgzuqo9Q6wQdbK29tcChLhCry6rJAQT62qAjtDXX33N2lg


# PROD =====================================================
# initially: gcloud kms keys create cicd-prod --location global --keyring apigee-cicd-credentials --purpose encryption
gcloud kms encrypt --location global --keyring apigee-cicd-credentials --key cicd-prod --plaintext-file ../../SAs/cicd-prod-service-account-ngsaas-5g-kurt.json --ciphertext-file cicd-prod.encrypted
# gcloud kms decrypt --location global --keyring apigee-cicd-credentials --key cicd-prod --ciphertext-file cicd-prod.encrypted --plaintext-file cicd-prod.decrypted

# Create the encrypted values and place in cloudbuild...yaml

echo; echo prod username
echo -n cicd-prod-service-account@ngsaas-5g-kurt.iam.gserviceaccount.com | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-prod | base64
# e.g. CiQAI9l/6RdvK0HMHvoK+i7nLDEMKtgwZXSkDTj0wK6IsCt3t2lLg0dNzD1pG5mW7jlSWUeaucTUKFdmk30xfo1s0XFyuG3hA

