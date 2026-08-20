cd  /home/dataverse/ckan-docker
export buildid="$(git branch --show-current): $(git log -1 --pretty=format:'[%h] %s')"
echo $buildid > version.txt
docker compose build --no-cache ckan && docker compose up -d ckan

if [ $? -eq 0 ]; then
  curl --request POST \
    --url "https://api.ipb.ac.id/telegrambot-webhook/doneBuild?chatId=-5019542413" --data "DataverseProd"
fi
