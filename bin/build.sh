#!/usr/bin/env bash
set -ev

if [ "${TRAVIS_PULL_REQUEST}" = "false" && "$TRAVIS_BRANCH" = "master" ]
then
	mvn deploy --settings settings.xml

	#We are on master, prepare a branch as release candidate
	version_snapshot=$(mvn help:evaluate -Dexpression=project.version |grep '^[0-9].*')
	version_prefix=`expr $version_snapshot : "\(.*\)-SNAP.*"`

	export RELEASE_CANDIDATE_VERSION=$pom_version.${TRAVIS_BUILD_NUMBER}-SNAPSHOT

	export repo_name=`expr ${TRAVIS_REPO_SLUG} : ".*\/\(.*\)"`
	export BRANCH_PATH=release-candidate/$repo_name

	export BRANCH_NAME=$repo_name-$RELEASE_CANDIDATE_VERSION

	git checkout -b release-candidate/$TAG_NAME

	mvn versions:set -DnewVersion=$RELEASE_CANDIDATE_VERSION -DgenerateBackupPoms=false -DallowSnapshots=true

	git status
	git branch
	git remote -v

	git commit -a -m "New release candidate release-candidate/$BRANCH_NAME"

else
	mvn deploy --settings settings.xml
fi