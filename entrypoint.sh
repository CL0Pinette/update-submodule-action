#!/bin/sh -l

mkdir -p ~/.ssh

eval `ssh-agent -s`

ssh-keygen -R github.com >/dev/null 2>&1
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

echo "Update git submodule"

echo "${INPUT_SSH_KEY}" | ssh-add -

echo "git@github.com:${INPUT_REPO_OWNER}/${INPUT_REPO}.git"

rm -rf "${INPUT_REPO}"

git clone "git@github.com:${INPUT_REPO_OWNER}/${INPUT_REPO}.git"

ssh-add -D

ssh-keygen -R github.com >/dev/null 2>&1
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

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

git submodule update --init "${INPUT_PATH}"
git submodule update --remote --merge "${INPUT_PATH}"

cd "${INPUT_PATH}"
git checkout "${GITHUB_REF_NAME}"
cd ..

ssh-add -D

ssh-keygen -R github.com >/dev/null 2>&1
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

echo "${INPUT_SSH_KEY}" | ssh-add -

git add .
git commit -m "update ${GITHUB_REPOSITORY} submodule"
git push "git@github.com:${INPUT_REPO_OWNER}/${INPUT_REPO}.git" "${GITHUB_REF_NAME}"

ssh-add -D

eval `ssh-agent -k`
