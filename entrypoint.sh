#!/bin/sh -l

mkdir -p ~/.ssh
ls -la ~/.ssh

ssh-keygen -R github.com
ssh-keyscan github.com
cat ~/.ssh/known_hosts

echo "Update git submodule"

eval `ssh-agent -s`
echo "${INPUT_SSH_KEY}" | ssh-add -

git clone "ssh://git@github.com/${INPUT_REPO_OWNER}/${INPUT_REPO}.git"

ssh-add -D

ssh-keygen -R github.com
ssh-keyscan github.com

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
ssh-keyscan github.com

echo "${INPUT_SSH_KEY}" | ssh-add -

git add .
git commit -m "update ${GITHUB_REPOSITORY} submodule"
git push "ssh://git@github.com/${INPUT_REPO_OWNER}/${INPUT_REPO}.git" "${GITHUB_REF_NAME}"

ssh-add -D

eval `ssh-agent -k`
