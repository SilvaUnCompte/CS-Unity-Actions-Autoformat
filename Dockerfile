# Container image that runs your code
FROM mcr.microsoft.com/dotnet/sdk:5.0

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY scripts/format.sh /format.sh
COPY scripts/amend_commit.sh /amend_commit.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/format.sh"]
