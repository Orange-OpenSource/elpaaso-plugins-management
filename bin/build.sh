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
echo "TRAVIS_BRANCH: <$TRAVIS_BRANCH> - TRAVIS_TAG: <$TRAVIS_TAG>"
#We are on master without PR
export VERSION_SNAPSHOT=$(mvn help:evaluate -Dexpression=project.version |grep '^[0-9].*')
echo "Current version extracted from pom.xml: $VERSION_SNAPSHOT"
export VERSION_PREFIX=$(expr "$VERSION_SNAPSHOT" : "\(.*\)-SNAP.*")

# Already know that "${TRAVIS_PULL_REQUEST}" = "false". Checked by Travis.yml
if [ "$TRAVIS_BRANCH" = "master" ]
then
	export RELEASE_CANDIDATE_VERSION=$VERSION_PREFIX.${TRAVIS_BUILD_NUMBER}-SNAPSHOT

	echo "Release candidate version: $RELEASE_CANDIDATE_VERSION"
	echo "Setting new version old: $VERSION_SNAPSHOT"

	ls -lrt
	mvn -X versions:set -DnewVersion=${RELEASE_CANDIDATE_VERSION} -DgenerateBackupPoms=false -DallowSnapshots=true
	echo "Compiling and deploying to OSS Jfrog"

	mvn deploy --settings settings.xml

	export TAG_NAME="releases/$RELEASE_CANDIDATE_VERSION"
	export TAG_DESC="Generated tag from TravisCI for build $TRAVIS_BUILD_NUMBER - $GIT_TAGNAME. [ ![Download](https://api.bintray.com/packages/elpaaso/maven/elpaaso-plugins-management/images/download.svg) ](https://bintray.com/elpaaso/maven/elpaaso-plugins-management/)"
	export RELEASE_NAME=$(expr "$RELEASE_CANDIDATE_VERSION" : "\(.*\)-SNAP.*")
	curl -X POST --data '{"tag_name":"' $TAG_NAME'","target_commitish":"master","name":"'$RELEASE_NAME'","body":"'$TAG_DESC'","draft": true,"prerelease": true}' https://$GH_TAGPERM@api.github.com/repos/Orange-OpenSource/elpaaso-plugins-management/releases

	echo "Extracted Travis repo name: $REPO_NAME"
	export REPO_NAME=$(expr ${TRAVIS_REPO_SLUG} : ".*\/\(.*\)")
	JFROG_PROMOTION_URL=http://oss.jfrog.org/api/plugins/build/promote/snapshotsToBintray/$REPO_NAME/${TRAVIS_BUILD_NUMBER}
	echo "Promotion URL to use: $JFROG_PROMOTION_URL"
	curl -X POST -u ${BINTRAY_USER}:${BINTRAY_PASSWORD} $JFROG_PROMOTION_URL
else
	mvn install --settings settings.xml
fi