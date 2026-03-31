FROM ghcr.io/fhir/ig-publisher-localdev

# Pre-download the IG Publisher JAR so builds don't need to fetch it
RUN mkdir -p /home/publisher/.ig-publisher && \
    curl -L -o /home/publisher/.ig-publisher/publisher.jar \
    "https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"

# Pre-install SUSHI globally
RUN npm install -g fsh-sushi

WORKDIR /home/publisher/ig
