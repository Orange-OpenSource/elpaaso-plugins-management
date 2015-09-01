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
	mvn deploy --settings settings.xml

	#We are on master, prepare a branch as release candidate
	export version_snapshot=$(mvn help:evaluate -Dexpression=project.version |grep '^[0-9].*')
	echo "Current version extracted from pom.xml: $version_snapshot"
	export version_prefix=$(expr $version_snapshot : "\(.*\)-SNAP.*")

	export RELEASE_CANDIDATE_VERSION=$version_prefix.${TRAVIS_BUILD_NUMBER}-SNAPSHOT
	echo "Release candidate vesrion: $RELEASE_CANDIDATE_VERSION"

	export repo_name=$(expr ${TRAVIS_REPO_SLUG} : ".*\/\(.*\)")
	export BRANCH_PATH=release-candidate/$repo_name

	export BRANCH_NAME=$repo_name-$RELEASE_CANDIDATE_VERSION
	export NEW_BRANCH_NAME=release-candidate/$BRANCH_NAME

	git checkout -b $NEW_BRANCH_NAME

	mvn versions:set -DnewVersion=$RELEASE_CANDIDATE_VERSION -DgenerateBackupPoms=false -DallowSnapshots=true

	git status
	git branch
	git remote -v

	git commit -a -m "New release candidate $NEW_BRANCH_NAME"
	git push origin $NEW_BRANCH_NAME

else
	mvn deploy --settings settings.xml
fi