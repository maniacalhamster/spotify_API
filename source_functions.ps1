if (!(Test-Path refresh_token_data.json)){
    Write-Host "No data for generating refresh token with (call auth.ps1 first)";
}

$player_base = "https://api.spotify.com/v1/me/player";
$header = @{'Authorization' = 'Bearer'};

function Token-Refresh() {
    $base = 'https://accounts.spotify.com';

    if (!(Test-Path refresh_token_data.json)){
        Write-Host "No data for generating refresh token with (call auth.ps1 first)";
        return;
    }

    $refresh_token_data = Get-Content refresh_token_data.json | ConvertFrom-Json -AsHashTable;

    $token_data = Invoke-RestMethod -Method Post -ContentType "application/x-www-form-urlencoded" -Body $refresh_token_data -Uri "$base/api/token";

    $token_data.psobject.properties | foreach -Begin {$token_table = @{}} -Process {
        $token_table."$($_.Name)" = $_.Value
    };

    $header.Authorization = "Bearer $($token_table.access_token)";
}

function Put-Request($url){
    Invoke-RestMethod -Method Put -Header $header -Uri $url;
}

function Get-Request($url){
    Invoke-RestMethod -Header $header -Uri $url;
}

function Spotify-Play($device_id){
    $spotify_url = Read-Host "Url to song";
    $uri = ConvertTo-SpotifyUri $spotify_url;

    $request_body = @{'uris' = @($uri)} | ConvertTo-Json;

    $url = "$player_base/play";
    if ($device_id){
        $url = "$url`?device_id=$device_id";
    }

    Invoke-RestMethod -Method Put -Body $request_body -ContentType "application/json" -Header $header -Uri $url;
}

function Spotify-Resume($device_id) {
    $url = "$player_base/play";
    if ($device_id){
        $url = "$url`?device_id=$device_id";
    }
    Put-Request $url;
}

function Spotify-Pause(){
    $url = "$player_base/pause";
    if ($device_id){
        $url = "$url`?device_id=$device_id";
    }
    Put-Request $url;
}

function Spotify-Devices(){
    Get-Request "$player_base/devices";
}

function ConvertTo-SpotifyUri($inp){
    return $inp -replace '.*.com/','spotify:' -replace '/',':' -replace '\?.*','';
}
