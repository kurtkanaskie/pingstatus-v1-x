# Ping and Status API for Apigee X

This proxy demonstrates a simple design to demonstrate a full CI/CD lifecycle.
It uses the following health check or monitoring endpoints
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
This proxy is managed as a single source code repository that is self contained with the Apigee X proxy, config files for Apigee resources (e.g. resourcefiles, target servers), Open API Specification (OAS) and tests (static, unit, and integration).

The key components enabling continuous integration are:
* Jenkins or GCP Cloud Build - build engine
* Maven - builder
* npm, node - to run unit and integration tests
* apigeelint - for static proxy linting
* Apickli - cucumber extension for RESTful API testing
* Cucumber - Behavior Driven Development
* JMeter - Performance testing (commented out)

Basically, everything that Jenkins does using Maven and other tools can be done locally, either directly with the tool (e.g. jslint, cucumberjs) or via Maven commands. 

Set your $HOME/.m2/settings.xml  (optional)

Example:
```
<?xml version="1.0"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <profiles>
        <profile>
            <id>test</id>
            <!-- These are also the values for environment variables used by set-edge-env-values.sh for Jenkins -->
            <properties>
                <EdgeOrg>yourorgname</EdgeOrg>
                <EdgeEnv>yourenv</EdgeEnv>
                <EdgeNorthboundDomain>yourourgname-yourenv.apigee.net</EdgeNorthboundDomain>
                <EdgeUsername>cicd-test-service-account@yourproject.iam.gserviceaccount.com</EdgeUsername>
                <!-- The unencrypted file, cloudbuild uses encrypted file during build -->
                <EdgeServiceAccountFile>path/to/sa.json</EdgeServiceAccountFile>
                <EdgeAuthtype>oauth</EdgeAuthtype>
            </properties>
        </profile>
        ...
    </profiles>
</settings>
```
##### Initial build and deploy to pingstatus-v1
```
mvn -P test install -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@health
```
## Git Commands

**NOTE:** This API proxy repository does not support a "feature" branch with replacement of proxy mame and basepath.

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
mvn -P dev install ...
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
git pull #(does fast-forward or recursive merge)
    # OR
# git merge --no-ff dev (use instead of git pull)
git push origin test #(triggers build or run mvn -P test install ...)
git checkout dev
```

### Merge to Environment "prod" and build
```
git checkout prod
git pull #(does fast-forward or recursive merge)
    # OR
# git merge --no-ff dev (use instead of git pull)
git push origin prod #(triggers build or run mvn -P prod install ...)
git checkout dev
```

### ALWAYS Switch back to dev
```
git checkout dev
```

## Maven
### Jenkins Commands
The Jenkins build server runs Maven with these commands.

Set Environment variables via script
```
./set-edge-env-values.sh > edge.properties
```
This allows a single build project to be used for each of the branches, depending on which branch changed.

```
install -P${EdgeProfile} -Dapigee.org=${EdgeOrg} -Dapigee.env=${EdgeEnv} -Dapi.northbound.domain=${EdgeNorthboundDomain} -Dapigee.username=${EdgeInstallUsername} -Dapigee.serviceaccount.file=${EdgeServiceAccountFile} -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dcommit=${GIT_COMMIT} -Dbranch=${GIT_BRANCH}
```
## Local Install and Set Up
In the source directory there is a `package.json` file that holds the required node packages.

* Install node
* Install maven
* Install
    * cd source directory
    * `npm install` (creates node_modules)

## Running Tests Locally
Often it is necessary to interate over tests for a feature development. Since Apickli/Cucumber tests are mostly text based, its easy to do this locally.
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
  ??? Given I set X-APIKey header to `clientId`
  ??? When I GET /ping
  ??? Then response code should be 200
  ??? And response header Content-Type should be application/json
  ??? And response body path $.apiproxy should be `apiproxy`
  ??? And response body path $.client should be ^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$
  ??? And response body path $.latency should be ^\d{1,2}
  ??? And response body path $.message should be PONG

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
* mvn -P ngsaas-dev-1 install -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration

### Cloud Build all at once
* cloud-build-local --dryrun=true --config=cloudbuild-dev.yaml --substitutions=BRANCH_NAME=local-gcloud,COMMIT_SHA=none .
* cloud-build-local --dryrun=false --config=cloudbuild-dev.yaml --substitutions=BRANCH_NAME=local-gcloud,COMMIT_SHA=none .

## Other commands for iterations

### Full install and test, but skip cleaning target
* mvn -P test install -Dskip.clean=true -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@health

### Skip clean and export - just install, deploy and test
* mvn -P test install -Dskip.clean=true -Dskip.export=true -Dapigee.config.options=none -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@health

### Just update Developers, Products and Apps
* mvn -P test process-resources apigee-config:developers apigee-config:apiproducts apigee-config:apps apigee-config:exportAppKeys -Dapigee.config.options=update -Dskip.clean=true -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration

### Just update resource files
* mvn -P test process-resources apigee-config:resourcefiles -Dapigee.config.options=update -Dskip.clean=true -Dapigee.config.dir=target/resources/edge

### Just update Target Servers
* mvn -P test process-resources apigee-config:targetservers -Dapigee.config.options=update -Dskip.clean=true -Dapigee.config.dir=target/resources/edge

### Export App keys
* mvn -P test apigee-config:exportAppKeys -Dskip.clean=true -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration

### Export Apps and run the tests (after skip.clean)
* mvn -P test process-resources apigee-config:exportAppKeys frontend:npm@integration -Dskip.clean=true -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@get-ping

### Just run the tests (after skip.clean) - for test iterations
* mvn -P test process-resources -Dskip.clean=true frontend:npm@integration -Dapi.testtag=@health

### Skip Creating Apps and Overwrite latest revision
* mvn -P test install -Dapigee.config.options=update -Dapigee.options=update -Dskip.apps=true -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapi.testtag=@health

### Just update the API Specs in Drupal
* mvn -P test process-resources apigee-smartdocs:apidoc -Dapigee.smartdocs.config.options=update

### Just update the Integrated Portal API Specs
Via process-resources after replacements or when in target
* mvn -X -P test process-resources apigee-config:specs -Dapigee.config.options=update -Dskip.clean=true -Dapigee.config.dir=target/resources/edge
* mvn -P test -Dapigee.config.options=update apigee-config:specs -Dapigee.config.dir=target/resources/specs -Dapigee.config.dir=target/resources/edge

Via the source without replacements
* mvn -P test -Dapigee.config.options=update apigee-config:specs -Dapigee.config.dir=resources/edge

### Other discrete commands
* mvn -Ptest validate (runs all validate phases: lint, apigeelint, unit)
* mvn jshint:lint
* mvn -Ptest frontend:npm@apigeelint
* mvn -Ptest frontend:npm@unit
* mvn -Ptest frontend:npm@integration
