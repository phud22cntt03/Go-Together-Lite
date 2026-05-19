$secretsFile = Join-Path $PSScriptRoot '..\.firebase.secrets.json'
$resolved = Resolve-Path $secretsFile -ErrorAction SilentlyContinue

if (-not $resolved) {
  Write-Host "Missing .firebase.secrets.json"
  Write-Host "Copy .firebase.secrets.json.example to .firebase.secrets.json and fill in the values."
  exit 1
}

flutter run --dart-define-from-file="$secretsFile" @args
