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
* Specify your profile parameters
```
mvn -P test install -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration
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
                <EdgeUsername>yourusername@exco.com</EdgeUsername>
                <EdgePassword>yourpassword</EdgePassword>
                <EdgeNorthboundDomain>yourourgname-yourenv.apigee.net</EdgeNorthboundDomain>
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

### Intitial Deploy to "test" environment
* git checkout -b prod
* git push origin prod
* git checkout master

#### Initial Deploy
```
mvn -P test install...
```

### Merge to Environments "prod"
* git checkout prod
* git pull
* git merge --no-ff master
* git push

```
mvn -P prod install...
```

#### Switch back to master
* git checkout master

## Maven
### Jenkins Commands
The Jenkins build server runs Maven with these commands.

Set Environment variables via script
```
./set-edge-env-values.sh > edge.properties
```
This allows a single build project to be used for each of the branches, depending on which changed.

```
install -P${EdgeProfile} -Dapigee.org=${EdgeOrg} -Dapigee.env=${EdgeEnv} -Dapi.northbound.domain=${EdgeNorthboundDomain} -Dapigee.username=${EdgeInstallUsername} -Dapigee.password=${EdgeInstallPassword} -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dcommit=${GIT_COMMIT} -Dbranch=${GIT_BRANCH}
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
1 Install your proxy to Apigee if you are creating a new feature, otherwise just get a copy of the exising proxy you are building tests for.
2 Run Maven to copy resources and "replace" things.
    * `mvn -P test clean process-resources`
3 Run tests by tag or by feature file
    * cucumberjs target/test/apickli/features --tags @intg
    * cucumberjs target/test/apickli/features/errorHandling.feature

Alternatively, you can run the tests via Maven
* `mvn -P test process-resources frontend:npm@integration -api.testtag=@get-ping`

NOTE: the initial output from cucumber shows the proxy and basepath being used
```
    [yourname]$ cucumberjs test/apickli/features --tags @invalid-clientid-for-resource
==> pingstatus api: [yourorgname-test.apigee.net, /pingstatus/yournamev1]
    @intg
    Feature: Error handling

      As an API consumer
      I want consistent and meaningful error responses
      So that I can handle the errors correctly

      @invalid-clientid-for-resource
      Scenario: GET with invalid clientId for resource
        Given I set clientId header to `invalidClientId`
        When I GET /ping
        Then response code should be 400
        And response header Content-Type should be application/json
        And response body path $.message should be missing or invalid clientId
```

#### Tests
To see what "tags" are in the tests for cucumberjs run `grep @ *.features` or `find . -name *.feature -exec grep @ {} \;`
```
@intg
    @invalidclientid
    @invalid-clientid-for-resource
    @foo
    @foobar
@health
    @get-ping
    @get-statuses
```

## Specific Usage

## All at once - full build and deploy
Replacer copies and replaces the resources dir into the target. Note use of -Dapigee.config.dir option.

### Maven all at once
* mvn -P test install -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dapigee.smartdocs.config.options=update

### Maven all at once, don't update docs
* mvn -P test install -Dapigee.config.options=update -Dapigee.config.dir=target/resources/edge -Dapigee.config.exportDir=target/test/integration -Dskip.specs=true

### Cloud Build all at once
* cloud-build-local --dryrun=true --substitutions=BRANCH_NAME=local,COMMIT_SHA=none .
* cloud-build-local --dryrun=false --substitutions=BRANCH_NAME=local,COMMIT_SHA=none .

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
