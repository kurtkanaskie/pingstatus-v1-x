#! /bin/bash

# initially: gcloud services enable cloudbuild.googleapis.com cloudkms.googleapis.com
#
# Go to CLoud Build Settings page and set Cloud KMS CryptoKey Decrypter role to ENABLED.

# initially: gcloud kms keyrings create "apigee-cicd-credentials" --location global
# gcloud kms keyrings list --location global
# gcloud kms keys list     --location "global" --keyring "apigee-cicd-credentials"
# gcloud kms keys create cicd-dev --location global --keyring apigee-cicd-credentials --purpose encryption
# gcloud kms keys create cicd-test --location global --keyring apigee-cicd-credentials --purpose encryption
# gcloud kms keys create cicd-prod --location global --keyring apigee-cicd-credentials --purpose encryption

# create new/updated service account keys in SAs directory following naming convention "cicd-$ENV-service-account@$PROJECT_ID.iam.gserviceaccount.com"
# Re-run to update encrypted credentials and re-deploy

# Activate pingstatus-v1-x project

# DEV =====================================================
# Create key for this environment
# initially: gcloud kms keys create cicd-dev --location global --keyring apigee-cicd-credentials --purpose encryption
gcloud kms encrypt --location global --keyring apigee-cicd-credentials --key cicd-dev --plaintext-file /Users/kurtkanaskie/work/APIGEEX/SAs/apigeex-mint-kurt-cicd-dev-service-account.json --ciphertext-file cicd-dev.encrypted 
# gcloud kms decrypt --location global --keyring apigee-cicd-credentials --key cicd-dev --ciphertext-file cicd-dev.encrypted --plaintext-file cicd-dev.decrypted

# Create the encrypted values and place in cloudbuild...yaml
echo; echo dev 
echo username SA
echo -n cicd-dev-service-account@apigeex-mint-kurt.iam.gserviceaccount.com | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-dev | base64
# CiQAPi/lTgPWPOse+15zqPc8xYpcJgia1gsrg13D+oZI1sRPh1QSawAZitCxmfaRbGK1JoKR5qYDZWJtN3odYhR7mleWSBVmpz1c3FUg/ul7vLNKpLfdXtgJffVsvq5AGl16YjTnuADruQw0AVEubRkpg98xKmyBDh8Gkap3RA4mJO8O56+BEzUrf47JcVMVKSbj
cat /Users/kurtkanaskie/work/APIGEEX/SAs/portal_username.txt | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-dev | base64
# CiQAPi/lTuGJVvQ4lZnz06jt21KZgqJ5C/ab1HY4yv7ZS3UK3LoSNAAZitCxNmlm879zSPwswGKWzNyNZdFM+G5iCN/KklIqjaBABZRDQjfVucxoHEf0b/Xaekg=
cat /Users/kurtkanaskie/work/APIGEEX/SAs/portal_password.txt | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-dev | base64
# CiQAPi/lTpT1hAODwpdWWtHUkwIOkg4zw+R55d3xrZX6jUp2PYoSNQAZitCxsONPmco55Zq+1crtdRjlKVxjyYHIlWT4IkmfVSWRoc0F8agDtY/96OXceZTC6cB8

# TEST =====================================================
# Create key for this environment
# initially: gcloud kms keys create cicd-test --location global --keyring apigee-cicd-credentials --purpose encryption
gcloud kms encrypt --location global --keyring apigee-cicd-credentials --key cicd-test --plaintext-file /Users/kurtkanaskie/work/APIGEEX/SAs/apigeex-mint-kurt-cicd-test-service-account.json --ciphertext-file cicd-test.encrypted 
# gcloud kms decrypt --location global --keyring apigee-cicd-credentials --key cicd-test --ciphertext-file cicd-test.encrypted --plaintext-file cicd-test.decrypted

# Create the encrypted values and place in cloudbuild...yaml
echo; echo test 
echo username SA
echo -n cicd-test-service-account@apigeex-mint-kurt.iam.gserviceaccount.com | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-test | base64
# CiQAOAtgonXoRxxvhtOR3g0UKNDe4CBc4yMMOy4vqv34pJK6zoQSbABYqO8xOh7cfLxt1XGNV5VSJerQwcRr3852//V+v2cGXzEfqaWIoTFcTtxbHFDqWgSXDVA5rH5RFgECEuUT+a7BRGQP2vdQsW0IXw55G2v2kKK/VbrZbFTUplFow+ki9sgE6CfEGpvPc7gKsQ==
echo; echo Drupal username and password
cat /Users/kurtkanaskie/work/APIGEEX/SAs/portal_username.txt | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-test | base64
# CiQAOAtgonTg/BFjrCGokLecm1lybhLdSnsL8dcS2dzPVWTDRpcSNABYqO8xH1oYisqirlid0IL48n+oTe02f5nTr60GmWjM/hTtfKg+vsfCTPR2b3mSl5RKPDA=
cat /Users/kurtkanaskie/work/APIGEEX/SAs/portal_password.txt | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-test | base64
# CiQAOAtgog3mXMqgPmojMFvQV03D/OncXg8X6yQWjP7BvxtXe1ESNQBYqO8xqVXBKQH+ybc6R1sdE+3IG6HXHd27Q1GbkCGvHuTcfJhgtRuEAh2cmWTeGT+Rhw5h

# PROD =====================================================
# initially: gcloud kms keys create cicd-prod --location global --keyring apigee-cicd-credentials --purpose encryption
gcloud kms encrypt --location global --keyring apigee-cicd-credentials --key cicd-prod --plaintext-file /Users/kurtkanaskie/work/APIGEEX/SAs/apigeex-mint-kurt-cicd-prod-service-account.json --ciphertext-file cicd-prod.encrypted
# gcloud kms decrypt --location global --keyring apigee-cicd-credentials --key cicd-prod --ciphertext-file cicd-prod.encrypted --plaintext-file cicd-prod.decrypted

# Create the encrypted values and place in cloudbuild...yaml
echo; echo prod 
echo username SA
echo -n cicd-prod-service-account@apigeex-mint-kurt.iam.gserviceaccount.com | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-prod | base64
# CiQAUgGSUx2rTas/t4DMw55st64TzGQ2thH6+NrMURPPhHdpB5ASbABw2zfrnHX5gyQEgUykfRlqkb3GUpYu93EomvvJQpiXQSKbDDAFyAz4cHxYTnBn/usaSh8+ax2pSJtv9BQE7IkM32d+3ehSV48bnK5X0B/LP/5ItAfWiLf0mDA4R/oARUndyrCunjtloHvx8w==
echo; echo Drupal username and password
cat /Users/kurtkanaskie/work/APIGEEX/SAs/portal_username.txt | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-prod | base64
# CiQAUgGSU15tC3Z+62pZQlmI1T+jTjLVl4C0vRHfqA36P3welPUSNABw2zfrKWQA8nCGp56ah9tspGClhe0gLQc47v8kUZ/qvsR31UYbrvCxvBQlqw/fB3j9Uhc=
cat /Users/kurtkanaskie/work/APIGEEX/SAs/portal_password.txt | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=apigee-cicd-credentials --key=cicd-prod | base64
# CiQAUgGSU+9esomEzr860R54qZmQbh2HyG/6Rc0RWP2fIMA41A8SNQBw2zfrn2FZrV8cwZV8+GUKx78lVktULl46ekAg4BiAmoKxHWfWnBcJAKBBMpcd4kjBE+Fy



