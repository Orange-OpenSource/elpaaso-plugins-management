#!/usr/bin/env bash
#
# Copyright (C) 2015 Orange
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -ev

if [ "${TRAVIS_PULL_REQUEST}" = "false" -a "$TRAVIS_BRANCH" = "master" ]
then
	#We are on master without PR
	export VERSION_SNAPSHOT=$(mvn help:evaluate -Dexpression=project.version |grep '^[0-9].*')
	echo "Current version extracted from pom.xml: $VERSION_SNAPSHOT"
	export VERSION_PREFIX=$(expr "$VERSION_SNAPSHOT" : "\(.*\)-SNAP.*")

	export GIT_SHORT_ID=${TRAVIS_COMMIT:0:7}

	export RELEASE_CANDIDATE_VERSION=$VERSION_PREFIX.${GIT_SHORT_ID}-SNAPSHOT

	export REPO_NAME=$(expr ${TRAVIS_REPO_SLUG} : ".*\/\(.*\)")

	echo "Release candidate version: $RELEASE_CANDIDATE_VERSION - Extracted repo name: $REPO_NAME"

	echo "Setting new version old: $VERSION_SNAPSHOT"

	mvn versions:set -DnewVersion=${RELEASE_CANDIDATE_VERSION} -DgenerateBackupPoms=false -DallowSnapshots=true

	echo "Compiling and deploying to OSS Jfrog"

	mvn deploy --settings settings.xml

	JFROG_PROMOTION_URL=http://oss.jfrog.org/api/plugins/build/promote/snapshotsToBintray/$REPO_NAME/${TRAVIS_BUILD_NUMBER}

	echo "Promotion URL to use: $JFROG_PROMOTION_URL"

	curl -X POST -u ${BINTRAY_USER}:${BINTRAY_PASSWORD} $JFROG_PROMOTION_URL

else
	mvn install --settings settings.xml
fi