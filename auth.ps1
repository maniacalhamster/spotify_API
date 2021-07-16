$dashboard_url = "https://developer.spotify.com/dashboard/applications";
if (!($client_id)) {
    Write-Host "Link: $dashboard_url";
    $client_id = Read-Host "Client ID" -AsSecureString | ConvertFrom-SecureString -AsPlainText;
}
if (!($client_secret)) {
    $client_secret = Read-Host "Client Secret" -AsSecureString | ConvertFrom-SecureString -AsPlainText;
}

if (!($redirect_uri)) {
    $redirect_uri = Read-Host "Redirect URI";
}
if (!($encoded_redirect_uri)) {
    $encoded_redirect_uri = [System.Web.HttpUtility]::UrlEncode($redirect_uri); 
}

$response_type = "code";
$scope = "user-read-recently-played user-top-read user-modify-playback-state user-read-currently-playing";
$base_url = "https://accounts.spotify.com";

$scope = [System.Web.HttpUtility]::UrlEncode($scope);
$auth_url = "$base_url/authorize?client_id=$client_id&response_type=$response_type&redirect_uri=$encoded_redirect_uri&scope=$scope";

Write-Host "Link: $auth_url";
edge $auth_url;

$code = ($(Read-Host "Redirect URL received") -replace ".*code=");
$grant_type = "authorization_code";

$refresh_token_request_body = @{
    "grant_type" = $grant_type;
    "code" = $code;
    "redirect_uri" = $redirect_uri;
    "client_id" = $client_id;
    "client_secret" = $client_secret;
};

$refresh_token_request_url = "$base_url/api/token"
$refresh_token = (Invoke-RestMethod -Uri $refresh_token_request_url -Method POST -Body $refresh_token_request_body).refresh_token;

@{
    "grant_type" = "refresh_token";
    "refresh_token" = $refresh_token;
    "client_id" = $client_id;
    "client_secret" = $client_secret;
} | ConvertTo-Json > refresh_token_data.json;
