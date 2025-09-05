# Container image that runs your code
FROM mcr.microsoft.com/dotnet/sdk:5.0

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY scripts/main.sh /main.sh

COPY scripts/auto-format/auto_format.sh /format.sh
COPY scripts/auto-format/amend_commit.sh /amend_commit.sh

COPY scripts/check-style/check_style.sh /check_style.sh
COPY scripts/check-style/generate_diff_report.sh /generate_diff_report.sh
COPY scripts/check-style/check_in_diff_report.sh /check_in_diff_report.sh

# Give execute permission on the code file to execute it
RUN chmod +x /main.sh

RUN chmod +x /format.sh
RUN chmod +x /amend_commit.sh

RUN chmod +x /check_style.sh
RUN chmod +x /generate_diff_report.sh
RUN chmod +x /check_in_diff_report.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/main.sh"]
