$base = 'https://accounts.spotify.com';
$refresh_token_data = Get-Content refresh_token_data.json | ConvertFrom-Json -AsHashTable;

function Token-Refresh() {
    $token_data = Invoke-RestMethod -Method Post -ContentType "application/x-www-form-urlencoded" -Body $refresh_token_data -Uri "$base/api/token";

    $token_data.psobject.properties | foreach -Begin {$token_table = @{}} -Process {
        $token_table."$($_.Name)" = $_.Value
    } -End {$token_table};
}
