function auth-duo
    duo-sso -session-duration=3600 -factor=push; set -x CODEARTIFACT_AUTH_TOKEN (aws codeartifact get-authorization-token --domain cisco-main --domain-owner 539909726087 --query authorizationToken --region=us-west-2 --output text)
end