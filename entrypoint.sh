#!/bin/sh -l

mkdir -p ~/.ssh
ls -la ~/.ssh

eval `ssh-agent -s`

ssh-keygen -R github.com
ssh-keyscan github.com >> ~/.ssh/known_hosts
cat ~/.ssh/known_hosts

echo "Update git submodule"

echo "${INPUT_SSH_KEY}" | ssh-add -

echo "git@github.com:${INPUT_REPO_OWNER}/${INPUT_REPO}.git"

git clone "git@github.com:${INPUT_REPO_OWNER}/${INPUT_REPO}.git"

ssh-add -D

ssh-keygen -R github.com
ssh-keyscan github.com >> ~/.ssh/known_hosts

cd "${INPUT_REPO}"

git checkout "${GITHUB_REF_NAME}"

if [ $? != 0 ]
then
    echo "${GITHUB_REF_NAME} not exists"
    exit 1
fi

git config user.email "${INPUT_COMMITTOR_USERNAME}"
git config user.name "${INPUT_COMMITTOR_EMAIL}"

echo "Update ${INPUT_PATH}"

echo "${INPUT_SSH_KEY_SUBMODULE}" | ssh-add -

git submodule update --init --recursive
git submodule update --remote --merge "${INPUT_PATH}"

cd "${INPUT_PATH}"
git checkout "${GITHUB_REF_NAME}"
cd ..

ssh-add -D

ssh-keygen -R github.com
ssh-keyscan github.com >> ~/.ssh/known_hosts

echo "${INPUT_SSH_KEY}" | ssh-add -

git add .
git commit -m "update ${GITHUB_REPOSITORY} submodule"
git push "git@github.com:${INPUT_REPO_OWNER}/${INPUT_REPO}.git" "${GITHUB_REF_NAME}"

ssh-add -D

eval `ssh-agent -k`
