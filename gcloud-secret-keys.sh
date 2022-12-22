#! /bin/bash

# initially: gcloud services enable cloudbuild.googleapis.com cloudkms.googleapis.com
#
# Go to CLoud Build Settings page and set Cloud KMS CryptoKey Decrypter role to ENABLED.

# initially: gcloud kms keyrings create "apigee-cicd-credentials" --location global
# gcloud kms keyrings list --location global
# gcloud kms keys list     --location "global" --keyring "apigee-cicd-credentials"

# create new/updated service account keys in SAs directory following naming convention "cicd-$ENV-service-account@$PROJECT_ID.iam.gserviceaccount.com"
# Re-run to update encrypted credentials and re-deploy

# Activate pingstatus-v1-x project

# TEST =====================================================
# Create key for this environment
# initially: gcloud kms keys create cicd-test --location global --keyring apigee-cicd-credentials --purpose encryption
gcloud kms encrypt --location global --keyring apigee-cicd-credentials --key cicd-test --plaintext-file /Users/kurtkanaskie/work/APIGEEX/SAs/apigeex-mint-kurt-cicd-test-service-account.json --ciphertext-file cicd-test.encrypted 
gcloud kms decrypt --location global --keyring apigee-cicd-credentials --key cicd-test --ciphertext-file cicd-test.encrypted --plaintext-file cicd-test.decrypted

# Create the encrypted values and place in cloudbuild...yaml
echo; echo test username
echo -n cicd-test-service-account@apigeex-mint-kurt.iam.gserviceaccount.com | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-test | base64
# e.g. CiQAyTb9u02Rmb3CFciv4j912QodXJfqhM61h9TCssQf9Xy4cLcir8422EdMjkz3WCGb3IM1MYNCs1CjKLbgzuqo9Q6wQdbK29tcChLhCry6rJAQT62qAjtDXX33N2lg


# PROD =====================================================
# initially: gcloud kms keys create cicd-prod --location global --keyring apigee-cicd-credentials --purpose encryption
gcloud kms encrypt --location global --keyring apigee-cicd-credentials --key cicd-prod --plaintext-file /Users/kurtkanaskie/work/APIGEEX/SAs/apigeex-mint-kurt-cicd-prod-service-account.json --ciphertext-file cicd-prod.encrypted
gcloud kms decrypt --location global --keyring apigee-cicd-credentials --key cicd-prod --ciphertext-file cicd-prod.encrypted --plaintext-file cicd-prod.decrypted

# Create the encrypted values and place in cloudbuild...yaml

echo; echo prod username
echo -n cicd-prod-service-account@apigeex-mint-kurt.iam.gserviceaccount.com | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-prod | base64
# e.g. CiQAI9l/6RdvK0HMHvoK+i7nLDEMKtgwZXSkDTj0wK6IsCt3t2lLg0dNzD1pG5mW7jlSWUeaucTUKFdmk30xfo1s0XFyuG3hA

echo; echo Drupal username and password
cat /Users/kurtkanaskie/work/APIGEEX/SAs/portal_username.txt | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-test | base64
cat /Users/kurtkanaskie/work/APIGEEX/SAs/portal_password.txt | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-test | base64