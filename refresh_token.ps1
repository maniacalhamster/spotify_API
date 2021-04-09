if (!(Test-Path refresh_token_data.json)){
    Write-Host "No data for generating refresh token with (call auth.ps1 first)";
}


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
    } -End {$token_table};
}
