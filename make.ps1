if($args[0] -eq "clean"){
  rm src/maps/*.lua
  return
}elseif($args[0] -eq "reset"){
  rm $env:AppData\LOVE\Hawkthorne\*.json
  rm src/maps/*.lua
  rm bin/
  return
}

Write-Host "Running make.ps1..."

$check = Test-Path -PathType Container bin
if($check -eq $false){
  New-Item 'bin' -type Directory
}

$webclient = New-Object System.Net.WebClient
$lovedir = "bin\love-0.10.1-win32\"
$check = Test-Path "bin\love-0.10.1-win32\love.exe"

#add love to the path if necessary
$foundlove = $env:Path.Contains($lovedir)
if($foundlove -eq $false){
  $env:Path += ";"+$lovedir
}

if($check -eq $false){

  $filename = (Get-Location).Path + "\bin\love-0.10.1-win32.zip"

  $check = Test-Path $filename

  if($check -eq $false){
    Write-Host "Downloading love2d..."
    $url = "https://github.com/love2d/love/releases/download/0.10.1/love-0.10.1-win32.zip"
    $webclient.DownloadFile($url,$filename)
  }

  $shell_app=new-object -com shell.application
  $zip_file = $shell_app.namespace($filename)
  $destination = $shell_app.namespace((Get-Location).Path + "\bin\")
  $destination.Copyhere($zip_file.items())
}

$tmx = "bin\tmx2lua.exe"
$check = Test-Path $tmx

if($check -eq $false){

  $filename = (Get-Location).Path + "\bin\tmx2lua.windows64.zip"

  $check = Test-Path $filename

  if($check -eq $false){
    Write-Host "Downloading tmx2lua..."
    $url = "https://github.com/hawkthorne/tmx2lua/releases/download/v1.0.0/tmx2lua.win64.zip"
    $webclient.DownloadFile($url,$filename)
  }

  $shell_app=new-object -com shell.application
  $zip_file = $shell_app.namespace($filename)
  $destination = $shell_app.namespace((Get-Location).Path + "\bin")
  $destination.Copyhere($zip_file.items())
}

$fileEntries = [IO.Directory]::GetFiles((Get-Location).Path + "\src\maps");
foreach($fileName in $fileEntries)
{
  $lua = $filename.split(".")[0] + ".lua"
  $exists = Test-Path $lua
  $older = $true

  if($exists -eq $true) {
    $older = (Get-Item $filename).LastWriteTime -gt (Get-Item $lua).LastWriteTime
  }

  if($older -eq $true) {
    .\bin\tmx2lua.exe $filename $lua
  }
}

if($args[0] -eq "run"){
  Write-Host "Running Journey to the Center of Hawkthorne..."
  if($args.Length -ne 1){
    .\bin\love-0.10.1-win32\love.exe src $args[1..($args.Length-1)]
  }else{
    .\bin\love-0.10.1-win32\love.exe src
  }
}elseif($args[0] -eq "test"){
  Write-Host "Testing Journey to the Center of Hawkthorne..."
  .\bin\love-0.10.1-win32\love.exe src --test --console
}
