# Ping and Status APIs for Apigee X with CI/CD

This proxy demonstrates a simple design to demonstrate a full CI/CD lifecycle.
It uses the following health check or monitoring endpoints:
* GET /ping - response indicates that the proxy is operational
* GET /status - response indicates the the backend is operational

These endpoints can then be used by API Monitoring with Edge to send notifications when something is wrong.

## Disclaimer

This example is not an official Google product, nor is it part of an official Google product.

## License

This material is copyright 2019, Google LLC. and is licensed under the Apache 2.0 license.
See the [LICENSE](LICENSE) file included.

This code is open source.

# TL;DR
* git clone
* Specify your profile parameters on the command line or edit pom.xml profile
```
mvn -P test install \
    -Dapigee.org=$ORG \
    -Dapigee.env=$ENV \
    -Dapigee.username=$SA_EMAIL \
    -Dapigee.serviceaccount.file=$SA_KEY_FILE \
    -Dapi.northbound.domain=$ENVGROUP_HOSTNAME
```

## Overview
This proxy is managed as a single source code repository that is self contained for the Apigee X platform. It includes the proxy configuration and its associated resources files (e.g. properties, target servers) necessary for the API proxy design.
It also includes an Open API Specification (OAS) and tests (static, unit, and integration).

The key components enabling continuous integration are:
* GCP Cloud Build or Jenkins - build engine
* Maven - builder
* apigeelint - for static proxy linting
* npm, node - to run unit and integration tests
* Apickli - cucumber extension for RESTful API testing
* Cucumber - Behavior Driven Development
* JMeter - Performance testing (commented out)

Basically, everything the build engine does (Maven and other tools) can be done locally, either directly with the tool (e.g. jslint, cucumberjs) or via Maven commands. 

## Git structure
There are three branches, dev, test and prod which align to SDLC phases.

### dev branch
The dev branch is the "main" branch and is used for deployment using Maven to the "test" Programmable Proxy environment in Apigee.

### test branch
The "test" branch is the next "higher" level branch and is used for deployment using Maven to the "test" Programmable Proxy environment in Apigee.

### prod branch
The "prod" branch is the next "higher" level branch and is used for deployment via Maven to the "prod" Programmable Proxy environment in Apigee.

## Maven configuration

Maven uses a Service Account for the username and Service Account credentials for each CI/CD lifecycle. \
For example:
- cicd-dev-service-account@apigeex-mint-kurt.iam.gserviceaccount.com
- cicd-test-service-account@apigeex-mint-kurt.iam.gserviceaccount.com
- cicd-prod-service-account@apigeex-mint-kurt.iam.gserviceaccount.com

Create and download Service Accounts and keys. See [Service Account Overview](https://cloud.google.com/iam/docs/service-account-overview) for details.

### Local Install and Set Up
In the source directory there is a `package.json` file that holds the required node packages.

* Install node
* Install maven
* Install
    * cd source directory
    * `npm install` (creates node_modules)

Update the pom.xml profile with your values:
```
<profile>
    <id>test</id>
    <properties>
        <apigee.profile>test</apigee.profile>
        <apigee.hosturl>https://apigee.googleapis.com</apigee.hosturl>
        <apigee.apiversion>v1</apigee.apiversion>
        <apigee.options>override</apigee.options>
        <apigee.config.dir>target/resources/edge</apigee.config.dir>
        <apigee.config.exportDir>target/test/integration</apigee.config.exportDir>
        <apigee.config.options>update</apigee.config.options>
        <apigee.app.ignoreAPIProducts>true</apigee.app.ignoreAPIProducts>
        <!-- -->
        <!-- Override on command line or replace with your values -->
        <apigee.org>your-org-name</apigee.org>
        <apigee.env>test</apigee.env>
        <apigee.username>cicd-test-service-account@your-org-name.iam.gserviceaccount.com</apigee.username>
        <apigee.serviceaccount.file>/Users/yourusername/work/APIGEEX/SAs/your-org-name-cicd-test-service-account.json</apigee.serviceaccount.file>
        <api.northbound.domain>xapi-test.your.domain</api.northbound.domain>
        <!-- Hack to pass in multiple args, ' char is part of the expression -->
        <!-- without the 's the args get split into individual quoted values -->
        <api.testtag>' or @cors or @health or @errorHandling or @WIP or '</api.testtag>
        <!-- Smartdocs Drupal -->
        <portal.url>https://developerx.your.domain</portal.url>
        <portal.username>${PortalUsername}</portal.username>
        <portal.password>${PortalPassword}</portal.password>
        <portal.format>yaml</portal.format>
        <portal.api.doc.format>basic_html</portal.api.doc.format>
        <portal.directory>./target/resources/specs</portal.directory>
        <apigee.smartdocs.config.file>./target/resources/apicatalog-config.json</apigee.smartdocs.config.file>
        <apigee.smartdocs.config.options>create</apigee.smartdocs.config.options>
    </properties>
</profile>
```
##### Initial build and deploy to pingstatus-v1
```
mvn -P test install
```
## Git Setup

**NOTE:** This API proxy repository does not support a "feature" branch with replacement of proxy name and basepath.

### Intitially Create Branches based on SDLC (dev --> test --> prod)
Git suggests:
```
echo "# demo2" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:kurtkanaskie/demo2.git
git push -u origin main
```
But we're not going to do that, we're going to make `dev` the default branch.
### Set Lowest Level branch "dev" environment
```
git init
git branch -M dev
git remote add origin git@github.com:kurtkanaskie/demo.git
git push --set-upstream origin dev
```

### Create higher level branch "test"
```
git checkout -b test
git branch --set-upstream-to=origin/dev test
git push origin test
git checkout dev
```

### Create higher level branch "prod"
```
git checkout -b prod
git branch --set-upstream-to=origin/test prod
git push origin prod
git checkout dev
```

## Development and Deployment
### Initial Deploy to "dev"
```
git checkout dev
mvn -P dev install
```

### Make changes to "dev" and push to build
```
git checkout dev
# Make changes
git commit -am "Change 1"
git push
```
### Merge to Environment "test" and build
```
git checkout test
git pull #(does fast-forward or recursive merge and pulls from dev)
git push origin test #(triggers build or run mvn -P test install ...)
git checkout dev
```

### Merge to Environment "prod" and build
```
git checkout prod
git pull #(does fast-forward or recursive merge, pulls from test)
git push origin prod #(triggers build or run mvn -P prod install ...)
git checkout dev
```

### ALWAYS Switch back to dev
```
git checkout dev
```

## Running Tests Locally
Often it is necessary to iterate over tests to complete test development. Since Apickli/Cucumber tests are mostly text based, its easy to do this locally.
Here are the steps:
1. Install your proxy to Apigee and skip cleaning the target (-Dskip-clean=true)
```
mvn -P test process-resources apigee-config:exportAppKeys frontend:npm@integration \
    -Dapigee.config.exportDir=target/test/integration \
    -Dskip.clean=true \
    -Dapi.testtag=@health
```
2. Then you can iterate more quickly using by tags
```
npm run integration -- --tags @get-ping
```
Example result:
```
> pingstatus@1.0.0 integration
> node ./node_modules/cucumber/bin/cucumber.js target/test/integration/features "--tags" "@get-ping"

CURL TO: [https://xapi-test.kurtkanaskie.net/pingstatus/v1]
KEYS: key-12345 secret-67890
@health
Feature: API proxy health

      As API administrator
      I want to monitor Apigee proxy and backend service health
      So I can alert when it is down

  @health @get-ping
  Scenario: Verify the API proxy is responding
  ✔ Given I set X-APIKey header to `clientId`
  ✔ When I GET /ping
  ✔ Then response code should be 200
  ✔ And response header Content-Type should be application/json
  ✔ And response body path $.apiproxy should be `apiproxy`
  ✔ And response body path $.client should be ^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$
  ✔ And response body path $.latency should be ^\d{1,2}
  ✔ And response body path $.message should be PONG

1 scenario (1 passed)
8 steps (8 passed)
0m00.191s
```

#### Tests
To see what "tags" are in the tests for cucumberjs run:
```
find test -name *.feature -exec grep @ {} \;
```
Result:
```
@errorHandling
    @foo
    @post-foo
    @foobar
    @foobar
@cors
    @cors-ping
@health
    @get-ping
    @get-status
```

## Specific Usage

## All at once - full build and deploy
Replacer copies and replaces the resources dir into the target. Note use of -Dapigee.config.dir option.

### Maven all at once
* mvn -P test install 

### Cloud Build all at once
Cloud Build uses encrypted Service Account credentials and username/password for Portal. See the [gcloud-secret-keys.sh](gcloud-secret-keys.sh) script for steps to create the keyring and keys, and to create the encrypted secrets for use by Cloud Build.

* cloud-build-local --dryrun=true --config=cloudbuild-test.yaml --substitutions=BRANCH_NAME=local-gcloud,COMMIT_SHA=none .
* cloud-build-local --dryrun=false --config=cloudbuild-test.yaml --substitutions=BRANCH_NAME=local-gcloud,COMMIT_SHA=none .

## Other commands for iterations

### Full install and test, but skip cleaning target
* mvn -P test install -Dskip.clean=true

### Skip clean and export - just install, deploy and test
* mvn -P test install -Dskip.clean=true -Dskip.export=true

### Just update Developers, Products and Apps
* mvn -P test resources:copy-resources replacer:replace apigee-config:developers apigee-config:apiproducts apigee-config:apps apigee-config:exportAppKeys -Dskip.clean=true

### Just update resource files
* mvn -P test resources:copy-resources replacer:replace apigee-config:resourcefiles -Dskip.clean=true 

### Just update Target Servers
* mvn -P test resources:copy-resources replacer:replace apigee-config:targetservers -Dskip.clean=true 

### Export App keys
* mvn -P test apigee-config:exportAppKeys -Dskip.clean=true 

### Export Apps and run the tests (after skip.clean)
* mvn -P test resources:copy-resources replacer:replace apigee-config:exportAppKeys frontend:npm@integration -Dskip.clean=true  -Dapi.testtag=@get-ping

### Just run the tests (after skip.clean) - for test iterations
* mvn -P test resources:copy-resources replacer:replace frontend:npm@integration -Dapi.testtag=@health
* npm run integration
* npm run integration -- --tags @get-status
* npm run integration -- --tags @cors

### Skip Creating Apps and Overwrite latest revision
* mvn -P test install -Dapigee.config.options=update -Dapigee.options=update -Dskip.apps=true -Dapi.testtag=@health

### Other discrete commands
* mvn -P test validate (runs all validate phases: lint, apigeelint, unit)
* mvn jshint:lint
* mvn -P test frontend:npm@apigeelint
* mvn -P test frontend:npm@unit
* mvn -P test frontend:npm@integration

## Drupal
Enable modules JSON:API and HTTP Basic Authentication.

Add taxonomy elements: /admin/structure/taxonomy

The tool processes all files with `.yaml` or `.json` in the `portal.directory` as Open API Specifications. Putting other files with those suffices will cause errors.

Use username not email for admin, e.g. maintenance

### Just update the API Specs in Drupal
* mvn -P test clean resources:copy-resources replacer:replace apigee-smartdocs:apidoc

## Integrated Portal (not supported in X)
### Just update the Integrated Portal API Specs
Via process-resources after replacements or when in target
* mvn -P test resources:copy-resources replacer:replace apigee-config:specs 


