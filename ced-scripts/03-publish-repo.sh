HOST=$CED_CONNECTION_HOST
USER=$CED_CONNECTION_USERNAME
PK=$CED_CONNECTION_PRIVATE_KEY
PACKAGE_NAME="alafia-$CED_SUBSYSTEM_ID"

mkdir -p .ssh
echo "$PK" > .ssh/id_rsa
chmod -R 600 .ssh/id_rsa

cd $CED_ARTIFACT_FOLDER
#echo "::info::$(ls -la)::"
sftp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$HOST <<< $'cd pool\nmput *.deb\nbye'
echo "::info::$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$HOST /home/deb-repo/update-repo.sh $PACKAGE_NAME)::"